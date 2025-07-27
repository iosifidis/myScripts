# Απλός Downloader αρχείων από ιστοσελίδες

Αυτό είναι ένα απλό αλλά ισχυρό script σε Python που σας επιτρέπει να κατεβάσετε μαζικά όλα τα αρχεία ενός συγκεκριμένου τύπου (π.χ. `.mp3`, `.pdf`, `.jpg`) που βρίσκονται ως σύνδεσμοι σε μία ιστοσελίδα. Εσείς δίνετε το URL, τον τύπο αρχείου και προαιρετικά ένα όνομα φακέλου, και το script αναλαμβάνει τα υπόλοιπα.

## Χαρακτηριστικά

-   Σαρώνει ένα συγκεκριμένο URL για όλες τις ετικέτες `<a>`.
-   Φιλτράρει τους συνδέσμους με βάση τον τύπο αρχείου που ορίζει ο χρήστης (δεν επηρεάζεται από πεζά/κεφαλαία).
-   Ζητά από τον χρήστη το URL, τον τύπο αρχείου και ένα προσαρμοσμένο όνομα για τον φάκελο αποθήκευσης.
-   Αν δεν δοθεί όνομα φακέλου, δημιουργεί αυτόματα ένα βασισμένο στο domain της ιστοσελίδας και τον τύπο των αρχείων.
-   Δημιουργεί έναν ειδικό φάκελο για τα αρχεία, ώστε να παραμένουν οργανωμένα.
-   Διαχειρίζεται σωστά τόσο απόλυτους (`http://...`) όσο και σχετικούς (`/files/doc.pdf`) συνδέσμους.
-   Εμφανίζει την πρόοδο της λήψης και παρέχει σαφή ενημέρωση για κάθε αρχείο.
-   Περιλαμβάνει κεφαλίδα `User-Agent` για να προσομοιώνει ένα πρόγραμμα περιήγησης, αποφεύγοντας τον αποκλεισμό από απλά μέτρα προστασίας.
-   Αποφεύγει τις διπλές λήψεις επεξεργαζόμενος μια μοναδική λίστα συνδέσμων.

## Προαπαιτούμενα

Θα πρέπει να έχετε εγκατεστημένη την **Python 3** στον υπολογιστή σας.

## Εγκατάσταση

1.  Κάντε "clone" αυτό το αποθετήριο ή απλώς κατεβάστε το αρχείο `downloader.py`.

2.  Ανοίξτε το τερματικό σας (terminal) ή τη γραμμή εντολών (command prompt) και εγκαταστήστε τις απαραίτητες βιβλιοθήκες χρησιμοποιώντας την `pip`:
    ```bash
    pip install requests beautifulsoup4
    ```

## Χρήση

1.  Μεταβείτε στον φάκελο όπου αποθηκεύσατε το `downloader.py` μέσω του τερματικού σας.

2.  Εκτελέστε το script με την παρακάτω εντολή:
    ```bash
    python downloader.py
    ```

3.  Ακολουθήστε τις οδηγίες που θα εμφανιστούν στην οθόνη:
    -   Εισάγετε το πλήρες URL της σελίδας που θέλετε να σαρώσετε.
    -   Εισάγετε τον τύπο αρχείου που σας ενδιαφέρει (π.χ. `mp3`, `pdf`, `zip`) χωρίς την τελεία.
    -   Δώστε ένα όνομα για τον φάκελο όπου θα αποθηκευτούν τα αρχεία ή πατήστε `Enter` για να δημιουργηθεί ένα αυτόματα.

### Παράδειγμα χρήσης

```shell
$ python downloader.py

Εισάγετε το πλήρες URL της σελίδας (π.χ. http://example.com/page): http://example.com/lessons
Εισάγετε τον τύπο αρχείου χωρίς την τελεία (π.χ. mp3, pdf, jpg): pdf
Δώστε ένα όνομα για τον φάκελο αποθήκευσης (ή πατήστε Enter για αυτόματο): Τα Μαθήματά μου

[*] Προσπάθεια σύνδεσης με τη σελίδα: http://example.com/lessons
[*] Τα αρχεία θα αποθηκευτούν στον φάκελο: 'Τα Μαθήματά μου'
[*] Βρέθηκαν 5 αρχεία τύπου '.pdf'. Ξεκινά η λήψη...

[1/5] Λήψη από: http://example.com/files/lesson1.pdf
[+] Επιτυχία: Το αρχείο αποθηκεύτηκε ως 'Τα Μαθήματά μου/lesson1.pdf'

... και ούτω καθεξής ...

[***] Η διαδικασία ολοκληρώθηκε! [***]
```

## Αποποίηση ευθύνης

Παρακαλούμε χρησιμοποιήστε αυτό το script υπεύθυνα. Βεβαιωθείτε ότι έχετε το δικαίωμα να κατεβάζετε και να χρησιμοποιείτε το περιεχόμενο από τις ιστοσελίδες-στόχους. Ο δημιουργός δεν φέρει καμία ευθύνη για οποιαδήποτε κακή χρήση αυτού του εργαλείου.

---

# Simple Web File Downloader

This is a simple but powerful Python script that allows you to download all files of a specific type (e.g., `.mp3`, `.pdf`, `.jpg`) linked on a single webpage. You provide the URL, the file extension, and an optional folder name, and the script does the rest.

## Features

-   Scans a given URL for all `<a>` tags.
-   Filters links by a user-specified file extension (case-insensitive).
-   Prompts the user for the target URL, file type, and a custom folder name.
-   If no folder name is provided, it automatically creates one based on the website's domain and file type.
-   Creates a dedicated folder for the downloads to keep them organized.
-   Correctly handles both absolute (`http://...`) and relative (`/files/doc.pdf`) links.
-   Displays the download progress and provides clear feedback for each file.
-   Includes a `User-Agent` header to appear as a standard browser, avoiding blocks from simple anti-bot measures.
-   Avoids duplicate downloads by processing a unique list of file URLs.

## Prerequisites

You need to have **Python 3** installed on your system.

## Installation

1.  Clone this repository or simply download the `downloader.py` script.

2.  Open your terminal or command prompt and install the required libraries using `pip`:
    ```bash
    pip install requests beautifulsoup4
    ```

## Usage

1.  Navigate to the directory where you saved `downloader.py` using your terminal.

2.  Run the script with the following command:
    ```bash
    python downloader.py
    ```

3.  Follow the on-screen prompts:
    -   Enter the full URL of the page you want to scan.
    -   Enter the desired file extension (e.g., `mp3`, `pdf`, `zip`) without the dot.
    -   Provide a name for the folder where the files will be saved, or press `Enter` to let the script generate one automatically.

### Example

```shell
$ python downloader.py

Εισάγετε το πλήρες URL της σελίδας (π.χ. http://example.com/page): http://example.com/audio-lessons
Εισάγετε τον τύπο αρχείου χωρίς την τελεία (π.χ. mp3, pdf, jpg): mp3
Δώστε ένα όνομα για τον φάκελο αποθήκευσης (ή πατήστε Enter για αυτόματο): My Audio Lessons

[*] Connecting to page: http://example.com/audio-lessons
[*] Files will be saved in folder: 'My Audio Lessons'
[*] Found 5 files of type '.mp3'. Starting download...

[1/5] Downloading from: http://example.com/audio/lesson1.mp3
[+] Success: File saved as 'My Audio Lessons/lesson1.mp3'

... and so on ...

[***] Process completed! [***]
```

## Disclaimer

Please use this script responsibly. Ensure you have the right to download and use the content from the websites you target. The author is not responsible for any misuse of this tool.

