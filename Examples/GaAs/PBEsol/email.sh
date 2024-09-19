#!/bin/bash
#$ -N SendEmail
#$ -m bea
#$ -M user@domain.com

# Variables
recipient="mohan_giri1@baylor.edu"
subject="File From HPC"
body="Hi Mohan,
Please find the attachment.

Thank you
 ...........
 Regards,
 girim from KODIAK, HPC
 Baylor University"
attachment="$1" # Input the name of the file to send

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."

