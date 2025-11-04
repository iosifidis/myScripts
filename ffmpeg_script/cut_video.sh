#!/bin/bash

# Simple Video Cutter - A simple and interactive Bash script for quickly
# cutting local videos or simple streams using the power of FFMPEG
#
# Copyright (C) 2025 Efstathios Iosifidis
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# --- Χρώματα για καλύτερη οπτική ανάδραση ---
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'; NC='\033[0m'

# --- Έλεγχος Εξαρτήσεων ---
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}Το FFMPEG δεν βρέθηκε! Παρακαλώ εγκαταστήστε το.${NC}"; exit 1;
fi

echo -e "${CYAN}🎬 Απλό & Αξιόπιστο Video Cutter${NC}"
echo "--------------------------------------------------"

# --- Ερωτήσεις στον χρήστη ---
read -p "🔗 Δώσε το τοπικό αρχείο ή το URL του stream: " INPUT_FILE
if [[ -z "$INPUT_FILE" ]]; then
    echo -e "${RED}Δεν δόθηκε αρχείο εισόδου. Τερματισμός.${NC}"; exit 1;
fi

echo -e "\n${YELLOW}Επιλέξτε μέθοδο κοψίματος:${NC}"
echo " [1] Γρήγορη Αντιγραφή (Ταχύτατη, διατηρεί την αρχική ποιότητα)"
echo " [2] Καλύτερη Ποιότητα (Πιο αργή, ιδανική για μέγιστη συμβατότητα)"
read -p "Επιλογή [1]: " PROCESS_CHOICE
PROCESS_CHOICE=${PROCESS_CHOICE:-1}

while true; do read -p "🕒 Χρόνος έναρξης (HH:MM:SS) ή [Enter] για την αρχή: " START_TIME; if [[ -z "$START_TIME" || "$START_TIME" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then break; else echo -e "${YELLOW}Λάθος μορφή.${NC}"; fi; done
while true; do read -p "🕔 Χρόνος λήξης (HH:MM:SS) ή [Enter] για το τέλος: " END_TIME; if [[ -z "$END_TIME" || "$END_TIME" =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then break; else echo -e "${YELLOW}Λάθος μορφή.${NC}"; fi; done
read -p "💾 Όνομα αρχείου εξόδου [προεπιλογή: my_clip.mp4]: " OUTPUT_FILE
OUTPUT_FILE=${OUTPUT_FILE:-my_clip.mp4}

echo "--------------------------------------------------"
echo -e "${GREEN}Επιβεβαίωση στοιχείων...${NC}"
echo "  Είσοδος: $INPUT_FILE"
[[ -z "$START_TIME" ]] && echo "  Έναρξη: Από την αρχή" || echo "  Έναρξη: $START_TIME"
[[ -z "$END_TIME" ]] && echo "  Λήξη: Μέχρι το τέλος" || echo "  Λήξη: $END_TIME"
if [[ "$PROCESS_CHOICE" == "1" ]]; then echo "  Μέθοδος: Γρήγορη Αντιγραφή"; else echo "  Μέθοδος: Καλύτερη Ποιότητα"; fi
echo "  Έξοδος:   $OUTPUT_FILE"
echo "--------------------------------------------------"

read -p "Πατήστε [Enter] για να ξεκινήσετε ή [Ctrl+C] για ακύρωση..."
echo ""

echo -e "\n${CYAN}🚀 Εκκίνηση κοψίματος με FFMPEG...${NC}"

# --- Υπολογισμός διάρκειας (μόνο αν χρειάζεται) ---
DURATION=""
if [[ -n "$START_TIME" && -n "$END_TIME" ]]; then
    START_SECONDS=$(date -u -d "1970-01-01 $START_TIME" +%s)
    END_SECONDS=$(date -u -d "1970-01-01 $END_TIME" +%s)
    DURATION=$((END_SECONDS - START_SECONDS))
fi

# --- Κατασκευή της εντολής FFMPEG ---
FFMPEG_CMD=("ffmpeg")

# Το -ss ΠΡΙΝ το -i είναι πάντα πιο γρήγορο για seek
if [[ -n "$START_TIME" ]]; then
    FFMPEG_CMD+=("-ss" "$START_TIME")
fi

FFMPEG_CMD+=("-i" "$INPUT_FILE")

# Ορισμός διάρκειας / σημείου τέλους
if [[ -z "$START_TIME" && -n "$END_TIME" ]]; then
    FFMPEG_CMD+=("-to" "$END_TIME")
elif [[ -n "$DURATION" ]]; then
    FFMPEG_CMD+=("-t" "$DURATION")
fi

# --- Επιλογή μεθόδου κωδικοποίησης ---
if [[ "$PROCESS_CHOICE" == "1" ]]; then
    # Γρήγορη Αντιγραφή
    FFMPEG_CMD+=("-c" "copy")
else
    # Καλύτερη Ποιότητα (Επανακωδικοποίηση)
    # -c:v libx264: Ο πιο δημοφιλής και συμβατός video codec
    # -preset veryfast: Μια καλή ισορροπία μεταξύ ταχύτητας και ποιότητας
    # -crf 23: Το επίπεδο ποιότητας (18 είναι σχεδόν τέλειο, 23 είναι πολύ καλό, 28 είναι ΟΚ)
    # -c:a aac: Ο standard audio codec για mp4
    # -b:a 192k: Μια καλή ποιότητα ήχου
    FFMPEG_CMD+=("-c:v" "libx264" "-preset" "veryfast" "-crf" "23" "-c:a" "aac" "-b:a" "192k")
fi

FFMPEG_CMD+=("-y" "$OUTPUT_FILE")

# Εκτέλεση της εντολής
"${FFMPEG_CMD[@]}"

# --- ΤΕΛΙΚΟ ΜΗΝΥΜΑ ---
if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}✅ Mission accomplished! Το αρχείο είναι έτοιμο στο '$OUTPUT_FILE'!${NC}"
else
    echo -e "\n${RED}❌ Η αποστολή απέτυχε. Ελέγξτε το παραπάνω σφάλμα.${NC}"
    exit 1
fi
