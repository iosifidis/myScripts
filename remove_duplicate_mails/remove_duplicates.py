#!/usr/bin/env python3

# Remove Duplicate Mails - This python script gets the file parousies.txt
# and remove the duplicate mails.
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

