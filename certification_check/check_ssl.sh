#!/bin/bash

# --- Ρυθμίσεις ---
DOMAINS_FILE="domains.txt"
WARN_DAYS_7=7
WARN_DAYS_15=15
RECENTLY_EXPIRED_LIMIT=30 # Όριο ημερών για πιστοποιητικά που έχουν λήξει πρόσφατα

# --- Έλεγχος Απαιτούμενων Εντολών ---
if ! command -v column &> /dev/null; then
    echo "Σφάλμα: Η εντολή 'column' δεν βρέθηκε, αλλά είναι απαραίτητη για τη μορφοποίηση του πίνακα."
    echo "Παρακαλώ εγκαταστήστε το πακέτο 'bsdmainutils' (Debian/Ubuntu) ή 'util-linux' (CentOS/Fedora)."
    exit 1
fi

# --- Έλεγχος ύπαρξης αρχείου ---
if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Σφάλμα: Το αρχείο '$DOMAINS_FILE' δεν βρέθηκε!"
    exit 1
fi

# --- Αρχικοποίηση ---
temp_results_file=$(mktemp)
trap 'rm -f -- "$temp_results_file"' EXIT

declare -a expires_in_7_days
declare -a expires_in_15_days
declare -a recently_expired_certs # ΝΕΑ ΛΙΣΤΑ: Για πιστοποιητικά που έχουν λήξει πρόσφατα (1-30 ημέρες)
declare -a very_expired_certs     # Λίστα για τα πολύ παλιά ληγμένα πιστοποιητικά
declare -a failed_checks

echo "Ξεκινά ο έλεγχos πιστοποιητικών από το αρχείο '$DOMAINS_FILE'..."
echo ""

# --- ΒΗΜΑ 1: Συλλογή δεδομένων με ένδειξη προόδου ---

mapfile -t all_domains < <(grep -v -e '^#' -e '^$' "$DOMAINS_FILE")
total_domains=${#all_domains[@]}
processed_count=0
spinner_chars="|/-\\"

for domain in "${all_domains[@]}"; do
    processed_count=$((processed_count + 1))
    spinner_i=$((processed_count % 4))

    echo -ne "\r[${spinner_chars:spinner_i:1}] Έλεγχος ${processed_count}/${total_domains}: $domain..."

    # expiration_date_str=$(timeout 10s openssl s_client -connect "$domain":443 -servername "$domain" 2>/dev/null </dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    expiration_date_str=$(timeout 10s openssl s_client -4 -connect "$domain":443 -servername "$domain" 2>/dev/null </dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

    if [ -z "$expiration_date_str" ]; then
        echo -ne "\r\033[K"
        failed_checks+=("Δεν ήταν δυνατή η σύνδεση ή η λήψη του πιστοποιητικού για το '$domain'.")
        continue
    fi

    exp_seconds=$(LC_ALL=C date -d "$expiration_date_str" "+%s" 2>/dev/null)

    if [ -z "$exp_seconds" ] || [ "$exp_seconds" -eq 0 ]; then
        echo -ne "\r\033[K"
        failed_checks+=("Αδύνατη η επεξεργασία της ημερομηνίας λήξης για το '$domain'.")
        continue
    fi

    now_seconds=$(date +%s)
    days_left=$(( (exp_seconds - now_seconds) / 86400 ))
    formatted_exp_date=$(date -d "@$exp_seconds" +'%Y-%m-%d')

    # --- ΒΕΛΤΙΩΜΕΝΗ ΛΟΓΙΚΗ ΔΙΑΧΩΡΙΣΜΟΥ ---
    if [ "$days_left" -lt 0 ]; then
        abs_days=${days_left#-}
        days_message=$( [ "$abs_days" -eq 1 ] && echo "έληξε πριν από 1 ημέρα" || echo "έληξε πριν από $abs_days ημέρες" )

        if [ "$abs_days" -gt "$RECENTLY_EXPIRED_LIMIT" ]; then
            status_text="ΕΧΕΙ ΛΗΞΕΙ (ΠΑΛΙΟ)"
            very_expired_certs+=("$domain: $status_text ($days_message, $formatted_exp_date)")
        else
            status_text="ΕΧΕΙ ΛΗΞΕΙ"
            recently_expired_certs+=("$domain: $status_text ($days_message, $formatted_exp_date)")
        fi
    elif [ "$days_left" -le "$WARN_DAYS_7" ]; then
        if [ "$days_left" -eq 0 ]; then days_message="λήγει σήμερα!";
        elif [ "$days_left" -eq 1 ]; then days_message="σε 1 ημέρα από σήμερα";
        else days_message="σε $days_left ημέρες από σήμερα"; fi
        status_text="ΛΗΓΕΙ ΣΥΝΤΟΜΑ"
        expires_in_7_days+=("$domain: $status_text ($days_message, $formatted_exp_date)")
    elif [ "$days_left" -le "$WARN_DAYS_15" ]; then
        days_message="σε $days_left ημέρες από σήμερα"
        status_text="ΠΡΟΕΙΔΟΠΟΙΗΣΗ"
        expires_in_15_days+=("$domain: $status_text ($days_message, $formatted_exp_date)")
    else
        days_message="σε $days_left ημέρες από σήμερα"
        status_text="OK"
    fi

    status_column="Το πιστοποιητικό για το '$domain' είναι: $status_text"
    echo "$days_left|$status_column|$formatted_exp_date|$days_message" >> "$temp_results_file"
done

# --- ΒΗΜΑ 2: Εμφάνιση του Πίνακα με τέλεια στοίχιση ---
echo -e "\r\033[KΟ έλεγχος ολοκληρώθηκε. Ακολουθεί ο ταξινομημένος πίνακας:\n"

header_line="Κατάσταση Πιστοποιητικού|Ημερομηνία Λήξης|Περιγραφή"

if [ -s "$temp_results_file" ]; then
    full_table_input=$(
        echo "$header_line"
        sort -n -t'|' -k1 "$temp_results_file" | cut -d'|' -f2-
    )

    echo "$full_table_input" | column -t -s'|' -o ' | ' | awk 'NR==1{print; gsub(/./,"-"); print} NR>1{print}'
else
    echo "Δεν βρέθηκαν πιστοποιητικά προς εμφάνιση στον πίνακα."
fi


# --- ΒΗΜΑ 3: Εμφάνιση Σύνοψης ---
echo ""
echo "============================== ΣΥΝΟΨΗ ΑΠΟΤΕΛΕΣΜΑΤΩΝ =============================="
echo ""

if [ ${#failed_checks[@]} -gt 0 ]; then
    echo "❌ ΣΦΑΛΜΑΤΑ ΠΟΥ ΠΡΟΕΚΥΨΑΝ ΚΑΤΑ ΤΟΝ ΕΛΕΓΧΟ:"
    printf "  - %s\n" "${failed_checks[@]}"
    echo ""
fi

if [ ${#very_expired_certs[@]} -gt 0 ]; then
    echo "🚨 ΚΡΙΤΙΚΟ: ΠΙΣΤΟΠΟΙΗΤΙΚΑ ΠΟΥ ΕΧΟΥΝ ΛΗΞΕΙ ΠΡΙΝ ΑΠΟ ΠΑΝΩ ΑΠΟ $RECENTLY_EXPIRED_LIMIT ΗΜΕΡΕΣ:"
    printf "  - %s\n" "${very_expired_certs[@]}"
    echo ""
fi

# ΝΕΑ, ΞΕΧΩΡΙΣΤΗ ΕΝΟΤΗΤΑ ΓΙΑ ΤΑ ΠΡΟΣΦΑΤΑ ΛΗΓΜΕΝΑ
if [ ${#recently_expired_certs[@]} -gt 0 ]; then
    echo "⚠️ ΠΡΟΣΟΧΗ: ΠΙΣΤΟΠΟΙΗΤΙΚΑ ΠΟΥ ΕΧΟΥΝ ΛΗΞΕΙ ΠΡΟΣΦΑΤΑ (τις τελευταίες $RECENTLY_EXPIRED_LIMIT ημέρες):"
    printf "  - %s\n" "${recently_expired_certs[@]}"
    echo ""
fi

# ΔΙΟΡΘΩΜΕΝΗ ΕΝΟΤΗΤΑ ΓΙΑ ΑΥΤΑ ΠΟΥ ΛΗΓΟΥΝ ΣΥΝΤΟΜΑ
if [ ${#expires_in_7_days[@]} -gt 0 ]; then
    echo "🔔 ΠΡΟΣΟΧΗ: ΠΙΣΤΟΠΟΙΗΤΙΚΑ ΠΟΥ ΛΗΓΟΥΝ ΣΥΝΤΟΜΑ (στις επόμενες 0-$WARN_DAYS_7 ημέρες):"
    printf "  - %s\n" "${expires_in_7_days[@]}"
    echo ""
else
    echo "✅ Κανένα πιστοποιητικό δεν λήγει τις επόμενες $WARN_DAYS_7 ημέρες."
    echo ""
fi

if [ ${#expires_in_15_days[@]} -gt 0 ]; then
    echo "ℹ️ ΠΛΗΡΟΦΟΡΙΑ: ΠΙΣΤΟΠΟΙΗΤΙΚΑ ΠΟΥ ΛΗΓΟΥΝ ΣΕ 8-$WARN_DAYS_15 ΗΜΕΡΕΣ:"
    printf "  - %s\n" "${expires_in_15_days[@]}"
    echo ""
else
    echo "✅ Κανένα πιστοποιητικό δεν λήγει στο διάστημα 8-$WARN_DAYS_15 ημερών."
    echo ""
fi

echo "=================================================================================="
echo "Ο έλεγχος ολοκληρώθηκε."
