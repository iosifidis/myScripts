# Σενάρια αναβάθμισης & καθαρισμού Fedora (Upgrade & Cleanup Scripts)

Ένα σύνολο από δύο σενάρια (scripts) για την αυτοματοποίηση της διαδικασίας αναβάθμισης του Fedora Linux στην επόμενη έκδοση, καθώς και για τον μετέπειτα καθαρισμό του συστήματος. Τα σενάρια βασίζονται στην [επίσημη τεκμηρίωση αναβάθμισης του Fedora](https://docs.fedoraproject.org/en-US/quick-docs/upgrading-fedora-offline/).

*English version below.*

---

## ⚠️ Προσοχή: Διαβάστε Πριν Ξεκινήσετε

Η αναβάθμιση του λειτουργικού συστήματος είναι μια διαδικασία που ενέχει κινδύνους.

**Βεβαιωθείτε ότι έχετε δημιουργήσει ένα ΠΛΗΡΕΣ ΚΑΙ ΕΠΑΛΗΘΕΥΜΕΝΟ ΑΝΤΙΓΡΑΦΟ ΑΣΦΑΛΕΙΑΣ (BACKUP) των σημαντικών σας αρχείων πριν χρησιμοποιήσετε αυτά τα σενάρια.**

Οι δημιουργοί αυτών των σεναρίων δεν φέρουν καμία ευθύνη για τυχόν απώλεια δεδομένων ή βλάβη του συστήματός σας. Η χρήση τους γίνεται με αποκλειστικά δική σας ευθύνη.

## Χαρακτηριστικά

- **Αυτοματοποιημένη διαδικασία**: Ακολουθεί τα βήματα της επίσημης τεκμηρίωσης του Fedora με ελάχιστη παρέμβαση από τον χρήστη.
- **Έξυπνη διαχείριση σφαλμάτων**: Προσπαθεί αυτόματα να επιλύσει κοινά προβλήματα εξαρτήσεων (`--allowerasing`).
- **Ανίχνευση έκδοσης**: Εντοπίζει αυτόματα την τρέχουσα και την επόμενη έκδοση του Fedora.
- **Συμβατότητα με DNF5**: Επιλέγει αυτόματα την κατάλληλη εντολή (`dnf` ή `dnf5`) ανάλογα με την έκδοση του Fedora.
- **Μενού καθαρισμού**: Παρέχει ένα διαδραστικό μενού μετά την αναβάθμιση για να εκτελέσετε συνήθεις εργασίες συντήρησης.
- **Ελληνική γλώσσα**: Όλες οι οδηγίες και τα μηνύματα είναι στα Ελληνικά.

## Περιεχόμενα

1.  **`fedora-upgrade.sh`**: Το κύριο σενάριο που προετοιμάζει και ξεκινά την διαδικασία αναβάθμισης.
2.  **`fedora_post_upgrade_cleanup.sh`**: Ένα βοηθητικό σενάριο με μενού, για να το εκτελέσετε **μετά** την επιτυχημένη ολοκλήρωση της αναβάθμισης.

## Οδηγίες Χρήσης

### Βήμα 1: Λήψη των Σναρίων

Κάντε κλώνο (clone) το αποθετήριο στον υπολογιστή σας ή κατεβάστε τα αρχεία `sh` ξεχωριστά.

```sh
https://github.com/iosifidis/myScripts.git
cd myScripts
```

### Βήμα 2: Παροχή Δικαιωμάτων Εκτέλεσης

Δώστε δικαιώματα εκτέλεσης και στα δύο αρχεία.

```sh
chmod +x fedora-upgrade.sh fedora_post_upgrade_cleanup.sh
```

### Βήμα 3: Εκτέλεση του Σναρίου Αναβάθμισης

Εκτελέστε το κύριο σενάριο με δικαιώματα διαχειριστή (`sudo`).

```sh
sudo ./fedora-upgrade.sh
```

Το σενάριο θα σας καθοδηγήσει στα παρακάτω βήματα:
1.  Θα σας ζητήσει να επιβεβαιώσετε ότι έχετε πάρει αντίγραφο ασφαλείας.
2.  Θα ενημερώσει πλήρως το τρέχον σύστημά σας.
3.  Θα κατεβάσει τα πακέτα για την επόμενη έκδοση του Fedora.
4.  Τέλος, θα σας ζητήσει να πατήσετε ένα πλήκτρο για να κάνει **επανεκκίνηση** και να ξεκινήσει την offline αναβάθμιση.

**Κατά τη διάρκεια της επανεκκίνησης, θα δείτε μια οθόνη προόδου. Μην διακόψετε αυτή τη διαδικασία!**

### Βήμα 4: Εκτέλεση του Σναρίου Καθαρισμού (Μετά την Αναβάθμιση)

Αφού η αναβάθμιση ολοκληρωθεί και έχετε συνδεθεί με επιτυχία στη νέα έκδοση του Fedora, εκτελέστε το δεύτερο σενάριο για να κάνετε συντήρηση στο σύστημά σας.

```sh
sudo ./fedora_post_upgrade_cleanup.sh
```

Θα εμφανιστεί ένα μενού με τις παρακάτω επιλογές:
- **Ενημέρωση αρχείων ρυθμίσεων**: Διαχειρίζεται τα αρχεία `.rpmnew` και `.rpmsave`.
- **Καθαρισμός πακέτων που αποσύρθηκαν**: Αφαιρεί πακέτα που δεν υπάρχουν πια στη νέα έκδοση.
- **Αφαίρεση διπλότυπων πακέτων**: Καθαρίζει διπλότυπες εγγραφές πακέτων.
- **Αφαίρεση παλιών πυρήνων**: Διατηρεί μόνο τον πιο πρόσφατο πυρήνα.
- **Αφαίρεση ορφανών πακέτων**: Κάνει `dnf autoremove`.

Μπορείτε να εκτελέσετε τις ενέργειες μία-μία ή όλες μαζί.

## Άδεια Χρήσης

Αυτό το έργο διατίθεται υπό την [Άδεια MIT](LICENSE).

---
---

# (English Version) Fedora Upgrade & Cleanup Scripts

A set of two scripts to automate the process of upgrading Fedora Linux to the next major release, as well as for performing post-upgrade system cleanup. The scripts are based on the [official Fedora upgrade documentation](https://docs.fedoraproject.org/en-US/quick-docs/upgrading-fedora-offline/).

*All script prompts and messages are in Greek.*

---

## ⚠️ Warning: Read before you begin

Upgrading an operating system is an inherently risky procedure.

**Ensure you have a FULL AND VERIFIED BACKUP of your important files before using these scripts.**

The authors of these scripts are not responsible for any data loss or damage to your system. Use them at your own risk.

## Features

- **Automated process**: Follows the official Fedora documentation steps with minimal user intervention.
- **Smart error handling**: Automatically retries with `--allowerasing` to solve common dependency issues.
- **Version-Aware**: Automatically detects the current and target Fedora versions.
- **DNF5 compatible**: Automatically selects the correct command (`dnf` or `dnf5`) based on your Fedora release.
- **Cleanup menu**: Provides an interactive menu for common post-upgrade maintenance tasks.
- **Greek language**: All prompts and messages are in Greek.

## Contents

1.  **`fedora-upgrade.sh`**: The main script that prepares and initiates the upgrade process.
2.  **`fedora_post_upgrade_cleanup.sh`**: A helper script with a menu, intended to be run **after** the upgrade is successfully completed.

## Usage instructions

### Step 1: Get the Scripts

Clone the repository to your computer or download the `.sh` files individually.

```sh
https://github.com/iosifidis/myScripts.git
cd myScripts
```

### Step 2: Make Scripts Executable

Grant execute permissions to both script files.

```sh
chmod +x fedora-upgrade.sh fedora_post_upgrade_cleanup.sh
```

### Step 3: Run the Upgrade Script

Execute the main script with administrator privileges (`sudo`).

```sh
sudo ./fedora-upgrade.sh
```

The script will guide you through the following steps:
1.  It will ask you to confirm that you have created a backup.
2.  It will fully update your current system.
3.  It will download the packages for the next Fedora release.
4.  Finally, it will ask you to press a key to **reboot** and begin the offline upgrade.

**During the reboot, you will see a progress screen. Do not interrupt this process!**

### Step 4: Run the cleanup script (Post-Upgrade)

After the upgrade is complete and you have successfully logged into the new version of Fedora, run the second script to perform system maintenance.

```sh
sudo ./fedora_post_upgrade_cleanup.sh
```

A menu will appear with the following options:
- **Update config files**: Manages `.rpmnew` and `.rpmsave` files.
- **Cleanup retired packages**: Removes packages that no longer exist in the new release.
- **Remove duplicate packages**: Cleans up duplicate package entries.
- **Remove old kernels**: Keeps only the most recent kernel.
- **Remove orphan packages**: Performs a `dnf autoremove`.

You can execute these actions one by one or all at once.

## License

This project is licensed under the [MIT License](LICENSE).
