#!/bin/bash

echo "--- Ξεκινάει το Universal Linux Backup Script ---"

# Ο φάκελος όπου θα αποθηκευτούν όλα
BACKUP_DIR=~/linux-backup
mkdir -p "$BACKUP_DIR/home_settings" "$BACKUP_DIR/repos"
rm -rf "$BACKUP_DIR/home_settings/"* "$BACKUP_DIR/repos/"*

# --- Ανίχνευση του Συστήματος ---
OS_ID=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    echo "Δεν μπορώ να ανιχνεύσω το λειτουργικό σύστημα. Έξοδος."
    exit 1
fi

echo "Ανιχνεύθηκε το σύστημα: $OS_ID"

# 1. Backup λιστών πακέτων (ανάλογα με το OS)
echo "1. Δημιουργία λίστας πακέτων..."
case "$OS_ID" in
    fedora)
        dnf repoquery --userinstalled --qf '%{name}' > "$BACKUP_DIR/dnf_packages.list"
        echo "   Αποθηκεύτηκαν πακέτα για dnf."
        ;;
    opensuse-tumbleweed | opensuse-leap)
        # Η εντολή zypper δεν έχει εύκολο τρόπο για "user-installed", παίρνουμε τα πάντα.
        zypper search --installed-only --type package | tail -n +6 | awk '{print $3}' > "$BACKUP_DIR/zypper_packages.list"
        echo "   Αποθηκεύτηκαν πακέτα για zypper."
        ;;
    ubuntu | debian | linuxmint)
        # Αυτή η εντολή βρίσκει πακέτα που δεν εγκαταστάθηκαν ως εξαρτήσεις
        apt-mark showmanual > "$BACKUP_DIR/apt_packages.list"
        echo "   Αποθηκεύτηκαν πακέτα για apt."
        ;;
    *)
        echo "Αυτή η διανομή ($OS_ID) δεν υποστηρίζεται για backup πακέτων."
        ;;
esac

# 2. Backup λίστας Flatpak (Universal)
if command -v flatpak &> /dev/null; then
    echo "2. Δημιουργία λίστας Flatpak πακέτων..."
    flatpak list --app --columns=application > "$BACKUP_DIR/flatpak_packages.list"
fi

# 3. Backup λίστας Snap (Universal)
if command -v snap &> /dev/null; then
    echo "3. Δημιουργία λίστας Snap πακέτων..."
    # Αποθηκεύουμε τα ονόματα των snaps, εξαιρώντας τα core/base snaps.
    snap list | awk 'NR>1 {print $1}' | grep -vE '^(core|snapd|bare|gtk-common-themes|gnome-.*)$' > "$BACKUP_DIR/snap_packages.list"
fi


# 4. Backup Αποθετηρίων (Repositories)
echo "4. Backup των αποθετηρίων..."
case "$OS_ID" in
    fedora)
        sudo rsync -a /etc/yum.repos.d/ "$BACKUP_DIR/repos/fedora/"
        ;;
    opensuse-tumbleweed | opensuse-leap)
        sudo rsync -a /etc/zypp/repos.d/ "$BACKUP_DIR/repos/suse/"
        ;;
    ubuntu | debian | linuxmint)
        sudo rsync -a /etc/apt/sources.list.d/ "$BACKUP_DIR/repos/debian/"
        # Σημείωση: Δεν κρατάμε τις PPA GPG keys, αυτό είναι πιο σύνθετο.
        ;;
esac

# 5. Backup συνδέσεων Wi-Fi (Universal για NetworkManager)
if [ -d /etc/NetworkManager/system-connections ]; then
    echo "5. Backup των συνδέσεων Wi-Fi..."
    sudo rsync -a /etc/NetworkManager/system-connections/ "$BACKUP_DIR/network_connections/"
fi

# 6. Backup ρυθμίσεων χρήστη (dotfiles) - Η "Minimal" μέθοδος που τελειοποιήσαμε
echo "6. Στοχευμένο backup των dotfiles..."

# α) Βασικά dotfiles
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
rsync -avR --files-from="$BACKUP_DIR/dotfiles.list" "$HOME/" "$BACKUP_DIR/home_settings/"

# β) Ρυθμίσεις-κλειδιά για Chrome & Code
mkdir -p "$BACKUP_DIR/home_settings/.config/google-chrome/Default"
mkdir -p "$BACKUP_DIR/home_settings/.config/Code/User"

if [ -f "$HOME/.config/google-chrome/Default/Preferences" ]; then cp "$HOME/.config/google-chrome/Default/Preferences" "$BACKUP_DIR/home_settings/.config/google-chrome/Default/"; fi
if [ -f "$HOME/.config/google-chrome/Default/Bookmarks" ]; then cp "$HOME/.config/google-chrome/Default/Bookmarks" "$BACKUP_DIR/home_settings/.config/google-chrome/Default/"; fi
if [ -f "$HOME/.config/Code/User/settings.json" ]; then cp "$HOME/.config/Code/User/settings.json" "$BACKUP_DIR/home_settings/.config/Code/User/"; fi
if [ -f "$HOME/.config/Code/User/keybindings.json" ]; then cp "$HOME/.config/Code/User/keybindings.json" "$BACKUP_DIR/home_settings/.config/Code/User/"; fi

echo "--- Το Universal Backup ολοκληρώθηκε στον φάκελο: $BACKUP_DIR ---"
