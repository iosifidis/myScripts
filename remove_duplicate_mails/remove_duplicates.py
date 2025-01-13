#!/usr/bin/env python3

# Script για αφαίρεση διπλών emails
input_file = "parousies.txt"
output_file = "unique_emails.txt"

def extract_emails(line):
    """Εξάγει emails από μια γραμμή χρησιμοποιώντας διαχωριστή '/'."""
    return [email.strip() for email in line.split('/') if "@" in email]

def remove_duplicate_emails(input_file, output_file):
    unique_emails = set()
    with open(input_file, "r", encoding="utf-8") as infile:
        for line in infile:
            emails = extract_emails(line)
            for email in emails:
                unique_emails.add(email)
    
    with open(output_file, "w", encoding="utf-8") as outfile:
        for email in sorted(unique_emails):  # Προαιρετική ταξινόμηση για ευκολότερη ανάγνωση
            outfile.write(email + "\n")
        outfile.write(f"\nΣυνολικός αριθμός μοναδικών emails: {len(unique_emails)}\n")
    
    return len(unique_emails)

# Εκτέλεση της συνάρτησης
unique_count = remove_duplicate_emails(input_file, output_file)
print(f"Η διαδικασία ολοκληρώθηκε. Τα μοναδικά emails αποθηκεύτηκαν στο {output_file}.")
print(f"Συνολικός αριθμός μοναδικών emails: {unique_count}")

