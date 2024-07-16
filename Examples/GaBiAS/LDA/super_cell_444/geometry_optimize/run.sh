#!/bin/bash

# Change to the directory containing your input files
cd /data/girim/GaBiAs/LDA/super_cell_444/geometry_optimize/

# Load the Quantum ESPRESSO module
module load qe/7.0

# Set the PREFIX variable
PREFIX=vc-relax

# Run the SCF calculation in parallel using 16 processors
mpirun -np 32 pw.x < "${PREFIX}.in" > "${PREFIX}.out"


