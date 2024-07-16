#!/bin/bash

# Get the current working directory and change to it
cd /data/girim/das/

# Load the Quantum ESPRESSO module
module load qe/7.0

# Define the range of variation for celldm(1)
min_percent=-10
max_percent=10
step_percent=1

# Create a new or clear existing data file
echo "celldm(1) Total_Energy" > volume_optimization_data.txt

# Loop over the percentage change
for ((percent_change=min_percent; percent_change<=max_percent; percent_change+=step_percent)); do
    # Calculate the new value of celldm(1)
    new_celldm=$(echo "scale=10; (1 + $percent_change/100) * 10.601362796" | bc)

    # Modify the input file with the updated celldm(1) value
    sed -i "s/celldm(1) = 10.601362796/celldm(1) = $new_celldm/" scf.in

    # Run Quantum ESPRESSO
    pw.x < scf.in > "scf_${percent_change}.out"

    # Extract total energy from output file
    total_energy=$(grep -m 1 "!" "scf_${percent_change}.out" | awk '{print $5}')

    # Append celldm(1) and total energy to data file
    echo "$new_celldm $total_energy" >> volume_optimization_data.txt
done
