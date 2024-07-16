#!/bin/bash

# Navigate to the directory containing the first script for the overall calculation.
cd /data/girim/GaAs/LDA/
# Execute the script to run the overall calculation
./run.sh &

# Navigate to the directory containing the k_points optimization.
cd /data/girim/GaAs/LDA/k_points/
# Execute the k_points_convergence.sh script
./k_points_convergence.sh $

# Navigate to the directory containing the ecutwfc optimization.
cd /data/girim/GaAs/LDA/ecutwfc/
# Execute the  script ecutwfc_convergence.sh.
./ecutwfc_convergence.sh &

