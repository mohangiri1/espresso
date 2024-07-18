#!/bin/bash

# Change to the directory containing your input files
cd /data/girim/GaBiAs/LDA/super_cell_444/

# Activate the Python virtual environment
#source /home/girim/python_venv/my-python/bin/activate

# Run the script to generate k-points
#python3 generate_kpoints.py

# Load the Quantum ESPRESSO module
module load qe/7.0

# Set the PREFIX variable
PREFIX=GaBiAs

# Run the SCF calculation in parallel using 16 processors
mpirun -np 32 pw.x < "${PREFIX}-scf.in" > "${PREFIX}-scf.out"

#Create a script for sending the email
cat > email_result.sh <<'EOF'
#!/bin/bash
#$ -N SendEmail
#$ -m bea
#$ -M user@domain.com

# Variables
recipient="mohan_giri1@baylor.edu"
subject="Completion of the Run"
body="The job in the HPC has been completed. The results are attached in the compressed file."
attachment="GaBiAs-scf.out"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."
EOF

# make executable

chmod +x email_result.sh
#run the executable
./email_result.sh


# Run the bands calculation in parallel using 16 processors
mpirun -np 32 pw.x < "${PREFIX}-bands.in" > "${PREFIX}-bands.out"

#Create a script for sending the email
cat > email_result.sh <<'EOF'
#!/bin/bash
#$ -N SendEmail
#$ -m bea
#$ -M user@domain.com

# Variables
recipient="mohan_giri1@baylor.edu"
subject="Completion of the Run"
body="The job in the HPC has been completed. The results are attached in the compressed file."
attachment="GaBiAs-bands.out"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."
EOF

# make executable

chmod +x email_result.sh
#run the executable
./email_result.sh

# Activate the Python virtual environment
source /home/girim/python_venv/my-python/bin/activate

# Run the band unfolding script
python3 banduppy_unfolding.py
