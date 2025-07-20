#!/bin/bash

# ==============================================================================
# Σενάριο για τις εργασίες συντήρησης μετά από μια επιτυχημένη αναβάθμιση του Fedora.
# Βασισμένο στην επίσημη τεκμηρίωση του Fedora.
#
# Χρήση:
# 1. Εκτελέστε αυτό το σενάριο ΜΕΤΑ την ολοκλήρωση της αναβάθμισης
#    και την επανεκκίνηση στη νέα έκδοση του Fedora.
# 2. Αποθηκεύστε το αρχείο ως fedora_post_upgrade_cleanup.sh
# 3. Δώστε του δικαιώματα εκτέλεσης: chmod +x fedora_post_upgrade_cleanup.sh
# 4. Εκτελέστε το με δικαιώματα διαχειριστή: sudo ./fedora_post_upgrade_cleanup.sh
# ==============================================================================

# Έξοδος σε περίπτωση σφάλματος
set -e

# --- Έλεγχος για δικαιώματα διαχειριστή (root) ---
if [[ $EUID -ne 0 ]]; then
   echo "Αυτό το σενάrio πρέπει να εκτελεστεί με δικαιώματα διαχειριστή (sudo)." 
   exit 1
fi

# --- Ορισμός χρωμάτων για την έξοδο ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Ορισμός των συναρτήσεων καθαρισμού ---

# 1. Ενημέρωση αρχείων ρυθμίσεων
update_config_files() {
    echo -e "\n${YELLOW}--- 1. Ενημέρωση Αρχείων Ρυθμίσεων (.rpmnew/.rpmsave) ---${NC}"
    echo "Εγκατάσταση του 'rpmconf' για τη διαχείριση αρχείων ρυθμίσεων..."
    dnf install -y rpmconf
    echo -e "\n${YELLOW}ΠΡΟΣΟΧΗ:${NC} Η παρακάτω εντολή είναι διαδραστική."
    echo "Θα ερωτηθείτε τι να κάνετε για κάθε αρχείο ρυθμίσεων που έχει αλλάξει."
    echo "Επιλογές: Y (ναι), N (όχι), D (διαφορά), Z (shell), M (συγχώνευση)."
    echo "Πατήστε ENTER για να ξεκινήσετε..."
    read
    rpmconf -a
    echo -e "${GREEN}Η διαχείριση αρχείων ρυθμίσεων ολοκληρώθηκε.${NC}"
}

# 2. Καθαρισμός πακέτων που αποσύρθηκαν
cleanup_retired_packages() {
    echo -e "\n${YELLOW}--- 2. Καθαρισμός Πακέτων που Αποσύρθηκαν (Retired Packages) ---${NC}"
    echo "Αυτή η ενέργεια αφαιρεί πακέτα που υπήρχαν σε παλαιότερες εκδόσεις αλλά έχουν αποσυρθεί."
    CURRENT_VERSION=$(grep -oP '(?<=^VERSION_ID=)\d+' /etc/os-release)
    SUGGESTED_OLD_VERSION=$((CURRENT_VERSION - 1))
    
    read -p "Παρακαλώ εισάγετε την έκδοση του Fedora ΑΠΟ την οποία κάνατε την αναβάθμιση (π.χ. $SUGGESTED_OLD_VERSION): " OLD_VERSION
    
    if ! [[ "$OLD_VERSION" =~ ^[0-9]+$ ]]; then
        echo "Μη έγκυρη έκδοση. Παρακαλώ εισάγετε μόνο έναν αριθμό."
        return
    fi
    
    echo "Εγκατάσταση του 'remove-retired-packages'..."
    dnf install -y remove-retired-packages
    
    echo "Αναζήτηση για πακέτα που αποσύρθηκαν από την έκδοση $OLD_VERSION..."
    remove-retired-packages "$OLD_VERSION"
    echo -e "${GREEN}Ο καθαρισμός των πακέτων που αποσύρθηκαν ολοκληρώθηκε.${NC}"
}

# 3. Αφαίρεση διπλότυπων πακέτων
remove_duplicates() {
    echo -e "\n${YELLOW}--- 3. Αφαίρεση Διπλότυπων Πακέτων ---${NC}"
    echo "Αναζήτηση για πακέτα που έχουν εγκατεστημένες πολλαπλές εκδόσεις..."
    if ! dnf remove --duplicates; then
        echo "Δεν βρέθηκαν διπλότυπα ή η διαδικασία ακυρώθηκε."
    fi
    echo -e "${GREEN}Ο καθαρισμός διπλότυπων ολοκληρώθηκε.${NC}"
}

# 4. Αφαίρεση παλιών πυρήνων
remove_old_kernels() {
    echo -e "\n${YELLOW}--- 4. Αφαίρεση Παλαιών Πυρήνων (Kernels) ---${NC}"
    echo "Αυτή η ενέργεια θα αφαιρέσει όλους τους παλιούς πυρήνες, κρατώντας μόνο τον πιο πρόσφατο."
    old_kernels=($(dnf repoquery --installonly --latest-limit=-1 -q))
    if [ "${#old_kernels[@]}" -eq 0 ]; then
        echo -e "${GREEN}Δεν βρέθηκαν παλιοί πυρήνες για αφαίρεση.${NC}"
        return
    fi
    
    echo "Οι ακόλουθοι παλιοί πυρήνες θα αφαιρεθούν:"
    echo "${old_kernels[@]}"
    read -p "Θέλετε να συνεχίσετε; (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dnf remove -y "${old_kernels[@]}"
        echo -e "${GREEN}Οι παλιοί πυρήνες αφαιρέθηκαν με επιτυχία.${NC}"
    else
        echo "Η αφαίρεση πυρήνων ακυρώθηκε."
    fi
}

# 5. Αφαίρεση ορφανών πακέτων
autoremove_packages() {
    echo -e "\n${YELLOW}--- 5. Αφαίρεση Ορφανών Πακέτων (Autoremove) ---${NC}"
    echo "Αυτή η ενέργεια θα αφαιρέσει πακέτα που εγκαταστάθηκαν ως εξαρτήσεις αλλά δεν χρειάζονται πλέον."
    if ! dnf autoremove; then
        echo "Δεν βρέθηκαν πακέτα για αφαίρεση ή η διαδικασία ακυρώθηκε."
    fi
    echo -e "${GREEN}Ο καθαρισμός ορφανών πακέτων ολοκληρώθηκε.${NC}"
}

# --- Κύριο μενού ---
while true; do
    echo -e "\n${GREEN}=====================================================${NC}"
    echo -e "${GREEN} Μενού Εργασιών Συντήρησης μετά την Αναβάθμιση${NC}"
    echo -e "${GREEN}=====================================================${NC}"
    echo " 1. Ενημέρωση αρχείων ρυθμίσεων (.rpmnew/.rpmsave)"
    echo " 2. Καθαρισμός πακέτων που αποσύρθηκαν (retired)"
    echo " 3. Αφαίρεση διπλότυπων πακέτων"
    echo " 4. Αφαίρεση παλαιών πυρήνων (kernels)"
    echo " 5. Αφαίρεση ορφανών πακέτων (autoremove)"
    echo "-----------------------------------------------------"
    echo " A. Εκτέλεση ΟΛΩΝ των παραπάνω βημάτων"
    echo " Q. Έξοδος"
    echo "====================================================="
    read -p "Επιλέξτε μια ενέργεια: " choice

    case $choice in
        1) update_config_files ;;
        2) cleanup_retired_packages ;;
        3) remove_duplicates ;;
        4) remove_old_kernels ;;
        5) autoremove_packages ;;
        [aA])
            echo -e "\n${YELLOW}Εκτέλεση όλων των βημάτων συντήρησης...${NC}"
            update_config_files
            cleanup_retired_packages
            remove_duplicates
            remove_old_kernels
            autoremove_packages
            echo -e "\n${GREEN}Όλες οι εργασίες συντήρησης ολοκληρώθηκαν!${NC}"
            ;;
        [qQ])
            echo "Έξοδος από το σενάριο."
            break
            ;;
        *)
            echo "Μη έγκυρη επιλογή, παρακαλώ προσπαθήστε ξανά."
            ;;
    esac
    read -p "Πατήστε ENTER για να επιστρέψετε στο μενού..."
done