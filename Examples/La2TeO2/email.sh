#!/bin/bash
#$ -N SendEmail
#$ -m bea
#$ -M user@domain.com

# Variables
recipient="mohan_giri1@baylor.edu"
subject="Completion of the Run"
body="The job in the HPC has been completed. The results are attached in the compressed file."
attachment="$1"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."
