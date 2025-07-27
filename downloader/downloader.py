#!/usr/bin/env python3

import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

def download_files_from_url(url, file_type, custom_folder_name):
    """
    Βρίσκει και κατεβάζει αρχεία συγκεκριμένου τύπου από ένα URL,
    αποθηκεύοντάς τα σε έναν φάκελο που ορίζει ο χρήστης.
    """
    try:
        # 1. Κατέβασμα του περιεχομένου της σελίδας
        print(f"[*] Προσπάθεια σύνδεσης με τη σελίδα: {url}")
        headers = {'User-Agent': 'Mozilla/5.0'} # Κάποιες σελίδες μπλοκάρουν requests χωρίς User-Agent
        response = requests.get(url, headers=headers)
        response.raise_for_status()  # Ελέγχει αν η σύνδεση ήταν επιτυχής

    except requests.exceptions.RequestException as e:
        print(f"[!] Σφάλμα: Δεν ήταν δυνατή η πρόσβαση στο URL. {e}")
        return

    # 2. Ανάλυση του HTML της σελίδας
    soup = BeautifulSoup(response.text, 'html.parser')

    # 3. Δημιουργία φακέλου για την αποθήκευση
    # Έλεγχος αν ο χρήστης έδωσε όνομα. Αν όχι, δημιουργία αυτόματου ονόματος.
    if not custom_folder_name or not custom_folder_name.strip():
        domain_name = urlparse(url).netloc.replace('.', '_')
        download_folder = f"{domain_name}_{file_type}_files"
        print(f"[*] Δεν δόθηκε όνομα, θα χρησιμοποιηθεί το αυτόματο: '{download_folder}'")
    else:
        # Καθαρίζουμε τυχόν κενά στην αρχή ή το τέλος
        download_folder = custom_folder_name.strip()
    
    try:
        os.makedirs(download_folder, exist_ok=True)
        print(f"[*] Τα αρχεία θα αποθηκευτούν στον φάκελο: '{download_folder}'")
    except OSError as e:
        print(f"[!] Σφάλμα: Δεν είναι δυνατή η δημιουργία του φακέλου '{download_folder}'.")
        print(f"[*] Βεβαιωθείτε ότι το όνομα δεν περιέχει μη επιτρεπτούς χαρακτήρες (π.χ. / \\ : * ? \" < > |).")
        print(f"[*] Σφάλμα συστήματος: {e}")
        return

    # 4. Εύρεση όλων των συνδέσμων
    links_found = soup.find_all('a', href=True)
    files_to_download = []
    
    for link in links_found:
        href = link.get('href')
        if href.lower().endswith(f'.{file_type.lower()}'):
            full_url = urljoin(url, href)
            files_to_download.append(full_url)
    
    files_to_download = list(set(files_to_download))

    if not files_to_download:
        print(f"[!] Δεν βρέθηκαν σύνδεσμοι για αρχεία τύπου '.{file_type}' σε αυτή τη σελίδα.")
        return

    print(f"[*] Βρέθηκαν {len(files_to_download)} αρχεία τύπου '.{file_type}'. Ξεκινά η λήψη...")

    # 5. Λήψη των αρχείων
    for i, file_url in enumerate(files_to_download, 1):
        try:
            print(f"\n[{i}/{len(files_to_download)}] Λήψη από: {file_url}")
            file_response = requests.get(file_url, stream=True, headers=headers)
            file_response.raise_for_status()

            filename = os.path.basename(urlparse(file_url).path)
            if not filename:
                filename = f"downloaded_file_{i}.{file_type}"
                
            save_path = os.path.join(download_folder, filename)

            with open(save_path, 'wb') as f:
                for chunk in file_response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            print(f"[+] Επιτυχία: Το αρχείο αποθηκεύτηκε ως '{save_path}'")

        except requests.exceptions.RequestException as e:
            print(f"[-] Αποτυχία λήψης του αρχείου {file_url}. Σφάλμα: {e}")
        except Exception as e:
            print(f"[-] Παρουσιάστηκε ένα μη αναμενόμενο σφάλμα κατά τη λήψη του {file_url}. Σφάλμα: {e}")

    print("\n[***] Η διαδικασία ολοκληρώθηκε! [***]")

if __name__ == "__main__":
    target_url = input("Εισάγετε το πλήρες URL της σελίδας (π.χ. http://example.com/page): ")
    target_file_type = input("Εισάγετε τον τύπο αρχείου χωρίς την τελεία (π.χ. mp3, pdf, jpg): ")
    
    # --- ΝΕΑ ΕΡΩΤΗΣΗ ---
    target_folder_name = input("Δώστε ένα όνομα για τον φάκελο αποθήκευσης (ή πατήστε Enter για αυτόματο): ")

    if target_url and target_file_type:
        download_files_from_url(target_url, target_file_type, target_folder_name)
    else:
        print("Πρέπει να δώσετε τουλάχιστον το URL και τον τύπο αρχείου.")
