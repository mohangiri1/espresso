#!/bin/bash

# Get the current working directory and change to it
cd /data/girim/Research/GaBiAs/

# Load the Quantum ESPRESSO module
module load qe/7.0

# Run the SCF calculation
pw.x <scf.in > scf.out

# Run the bands calculation
pw.x < bands.in > bands.out

# Run the bands.x executable
bands.x < bands.kp.in > bands.kp.out

# Run the Python script
#python bandstructure_plot.py
