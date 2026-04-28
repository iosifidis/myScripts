#!/bin/bash

# Ο φάκελος όπου θα αποθηκευτούν όλα τα backup
BACKUP_DIR=~/fedora-backup
mkdir -p "$BACKUP_DIR"

echo "--- Ξεκινάει το backup για το Fedora ---"

# 1. Backup λίστας πακέτων από DNF (επίσημα αποθετήρια)
echo "1. Δημιουργία λίστας DNF πακέτων..."
dnf repoquery --installed --qf '%{name}' > "$BACKUP_DIR/dnf_packages.list"

# 2. Backup λίστας πακέτων από Flatpak
echo "2. Δημιουργία λίστας Flatpak πακέτων..."
flatpak list --app --columns=application > "$BACKUP_DIR/flatpak_packages.list"

# 3. Backup των αποθετηρίων (Repositories) τρίτων (π.χ. COPR, RPM Fusion)
echo "3. Backup των αποθετηρίων..."
cp -r /etc/yum.repos.d/ "$BACKUP_DIR/yum.repos.d"

# 4. Δημιουργία BACKUP ΡΥΘΜΙΣΕΩΝ ΔΙΚΤΥΟΥ
echo "4. Backup των συνδέσεων Wi-Fi..."
# Χρησιμοποιούμε rsync -a για να διατηρήσουμε δικαιώματα και ιδιοκτησία
sudo rsync -a /etc/NetworkManager/system-connections/ "$BACKUP_DIR/network_connections/"

# 4. Δημιουργία της λίστας με τα αρχεία/φακέλους που θέλουμε
echo "5. Δημιουργία λίστας επιθυμητών ρυθμίσεων (dotfiles)..."

cat <<EOF > "$BACKUP_DIR/dotfiles.list"
.bashrc
.bash_profile
.gitconfig
.ssh
.fonts
.icons
.themes
.local/share/keyrings
EOF
rsync -avR --progress --files-from="$BACKUP_DIR/dotfiles.list" "$HOME/" "$BACKUP_DIR/home_settings/"

# 5. Backup του .config με ΣΤΟΧΕΥΜΕΝΕΣ ΕΞΑΙΡΕΣΕΙΣ
echo "6. Backup του .config (εξαιρώντας cache και μεγάλα δεδομένα)..."

rsync -av --progress \
    --exclude 'google-chrome' \
    --exclude 'Code' \
    --exclude 'Cursor' \
    --exclude 'BraveSoftware' \
    --exclude 'Logseq' \
    --exclude 'MongoDB Compass' \
    --exclude 'Outline' \
    --exclude 'superProductivity' \
    --exclude 'gcloud' \
    --exclude 'Slack' \
    --exclude 'LM Studio' \
    --exclude 'VirtualBox' \
    --exclude 'Udeler' \
    --exclude 'Cal' \
    --exclude 'ubports-installer' \
    --exclude 'camunda-modeler' \
    --exclude 'balena-etcher-electron' \
    --exclude 'libreoffice' \
    "$HOME/.config/" "$BACKUP_DIR/home_settings/.config/"
    
# 7. Στοχευμένη αντιγραφή ΜΟΝΟ των βασικών ρυθμίσεων από τις εξαιρεθείσες εφαρμογές
echo "7. Στοχευμένη αντιγραφή των βασικών ρυθμίσεων για Chrome, Code κτλ..."
mkdir -p "$BACKUP_DIR/home_settings/.config/google-chrome/Default"
mkdir -p "$BACKUP_DIR/home_settings/.config/Code/User"

# Χρησιμοποιούμε if [ -f ... ] για να ελέγξουμε αν το αρχείο υπάρχει ΠΡΙΝ το αντιγράψουμε

if [ -f "$HOME/.config/google-chrome/Default/Preferences" ]; then
    cp "$HOME/.config/google-chrome/Default/Preferences" "$BACKUP_DIR/home_settings/.config/google-chrome/Default/"
fi

if [ -f "$HOME/.config/google-chrome/Default/Bookmarks" ]; then
    cp "$HOME/.config/google-chrome/Default/Bookmarks" "$BACKUP_DIR/home_settings/.config/google-chrome/Default/"
fi

if [ -f "$HOME/.config/Code/User/settings.json" ]; then
    cp "$HOME/.config/Code/User/settings.json" "$BACKUP_DIR/home_settings/.config/Code/User/"
fi

# Εδώ είναι η διόρθωση για το keybindings.json
if [ -f "$HOME/.config/Code/User/keybindings.json" ]; then
    cp "$HOME/.config/Code/User/keybindings.json" "$BACKUP_DIR/home_settings/.config/Code/User/"
fi

echo "--- Το backup ολοκληρώθηκε! ---"
echo "Ελέγξε το μέγεθος του φακέλου: du -sh $BACKUP_DIR"
echo "Αντέγραψε αυτόν τον φάκελο σε έναν εξωτερικό δίσκο!"
