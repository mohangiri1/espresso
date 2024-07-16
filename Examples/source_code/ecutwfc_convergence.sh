#!/bin/bash

# Get the current working directory and change to it
cd /data/girim/Research/

# Load the Quantum ESPRESSO module
module load qe/7.0

# Define the starting and ending points for ecutwfc
start_ecutwfc=30
end_ecutwfc=200

# Ensure the starting and ending points are multiples of 10
start_ecutwfc=$(( (start_ecutwfc + 9) / 10 * 10 ))
end_ecutwfc=$(( (end_ecutwfc + 9) / 10 * 10 ))

# Create an empty convergence data file or clear existing file
> convergence_data.txt

# Loop over different values of ecutwfc and perform SCF calculations
for ecutwfc in $(seq $start_ecutwfc 10 $end_ecutwfc)
do
    echo "Running SCF calculation with ecutwfc = $ecutwfc"

    # Create a new input file with the updated ecutwfc value
    sed "s/ecutwfc = .*/ecutwfc = $ecutwfc,/" scf.in > scf_$ecutwfc.in

    # Run the SCF calculation
    pw.x < scf_$ecutwfc.in > scf_$ecutwfc.out

    # Check if SCF calculation was successful
    if [ $? -eq 0 ]; then
        # Extract the total energy from the output file and print it
        total_energy=$(grep "!" scf_$ecutwfc.out | tail -1 | awk '{print $5}')
        echo "Total energy for ecutwfc = $ecutwfc: $total_energy Ry"

        # Store the ecutwfc and total energy in the convergence data file
        echo "$ecutwfc   $total_energy" >> convergence_data.txt
    else
        echo "Error: SCF calculation failed for ecutwfc = $ecutwfc"
    fi
done

echo "Convergence test completed. Data saved in convergence_data.txt."
