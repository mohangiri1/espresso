#!/bin/bash

# Get the current working directory and change to it
cd /data/girim/GaAs/LDA/volume_optimiz/

# Load the Quantum ESPRESSO module
module load qe/7.0

# Define the range of variation for celldm(1)
min_percent=-10
max_percent=10
step_percent=1

# Create a new or clear existing data file
echo "celldm(1) Total_Energy" > volume_optimization_data.txt

# Loop over the percentage change
for percent_change in $(seq $min_percent $step_percent $max_percent)
 do
    echo "Running SCF calculation with percent_change = $percent_change"
    # Calculate the new value of celldm(1)

    new_celldm=$(echo "scale=10; (1 + $percent_change/100) * 10.601362796" | bc)

    # Modify the input file with the updated celldm(1) value
    # Create a new input file with the updated ecutwfc value
    sed "s/celldm(1) = .*/celldm(1) = $new_celldm,/" scf.in > scf_$percent_change.in

    # Run Quantum ESPRESSO
    pw.x < scf_${percent_change}.in > "scf_${percent_change}.out"

    # Extract total energy from output file
    total_energy=$(grep -m 1 "!" "scf_${percent_change}.out" | awk '{print $5}')

    # Append celldm(1) and total energy to data file
    echo "$new_celldm $total_energy" >> volume_optimization_data.txt
done
