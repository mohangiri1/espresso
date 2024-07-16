#!/bin/bash

# Change to the directory containing your input files
cd /data/girim/GaAs/LDA/super_cell/

# Activate the Python virtual environment
source /home/girim/python-venv/my-python/bin/activate

# Run the script to generate k-points
python3 generate_kpoints.py

# Load the Quantum ESPRESSO module
module load qe/7.0

# Set the PREFIX variable
PREFIX=GaAs

# Run the SCF calculation in parallel using 16 processors
mpirun -np 16 pw.x < "${PREFIX}-scf.in" > "${PREFIX}-scf.out"

# Run the bands calculation in parallel using 16 processors
mpirun -np 16 pw.x < "${PREFIX}-bands.in" > "${PREFIX}-bands.out"

# Run the band unfolding script
python3 banduppy_unfolding.py
