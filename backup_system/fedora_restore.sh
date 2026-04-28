#!/bin/bash

BACKUP_DIR=~/fedora-backup

echo "--- Ξεκινάει η επαναφορά του συστήματος ---"

# Βήματα 1-3 για πακέτα και repos (ίδια με πριν)
echo "1. Επαναφορά αποθετηρίων..."
sudo cp -r "$BACKUP_DIR/yum.repos.d/"* /etc/yum.repos.d/
sudo dnf makecache

echo "2. Εγκατάσταση DNF πακέτων..."
xargs -a "$BACKUP_DIR/dnf_packages.list" sudo dnf install -y

echo "3. Εγκατάσταση Flatpak πακέτων..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
xargs -a "$BACKUP_DIR/flatpak_packages.list" flatpak install -y --noninteractive

# 4. Επαναφορά των επιλεγμένων ρυθμίσεων
echo "4. Επαναφορά των ρυθμίσεων χρήστη..."
# Απλά αντιγράφουμε τα πάντα από το home_settings στον home φάκελο
rsync -av --progress "$BACKUP_DIR/home_settings/" "$HOME/"

# 5. ΕΠΑΝΑΦΟΡΑ ΡΥΘΜΙΣΕΩΝ ΔΙΚΤΥΟΥ <<<
echo "5. Επαναφορά των συνδέσεων Wi-Fi..."
if [ -d "$BACKUP_DIR/network_connections" ]; then
    sudo rsync -a "$BACKUP_DIR/network_connections/" /etc/NetworkManager/system-connections/
    echo "Ενημέρωση του NetworkManager για τις νέες ρυθμίσεις..."
    sudo systemctl reload NetworkManager
else
    echo "Δεν βρέθηκε backup για τις συνδέσεις δικτύου."
fi

echo "--- Η επαναφορά ολοκληρώθηκε! ---"
echo "Κάνε μια επανεκκίνηση για να εφαρμοστούν όλες οι αλλαγές."
