#!/bin/bash

# Get the current working directory and change to it
cd /data/girim/GaAs/LDA/k_points/

# Load the Quantum ESPRESSO module
module load qe/7.0

# Define the starting and ending points for k points
start_kpoints=2
end_kpoints=8

# Loop over different values of k points and perform SCF calculations
for kpoints in $(seq $start_kpoints $end_kpoints)
do
    k_value=$(( kpoints ))  # To get 222, 333, 444, ...
    echo "Running SCF calculation with k points = $k_value"

    # Create a new input file with the updated k points value
    sed -e "s/K_POINTS.*/K_POINTS (automatic)\n  $k_value $k_value $k_value 1 1 1/" scf.in > scf_$k_value.in

    # Run the SCF calculation
    pw.x < scf_$k_value.in > scf_$k_value.out

    # Extract the total energy from the output file and print it
    total_energy=$(grep "!" scf_$k_value.out | tail -1 | awk '{print $5}')
    echo "Total energy for k points = $k_value: $total_energy Ry"

    # Store the k points and total energy in the convergence data file
    echo "$k_value   $total_energy" >> convergence_data_kpoints.txt
done

echo "Convergence test for k points completed. Data saved in convergence_data_kpoints.txt."
