#!/bin/bash

# Get the current working directory and change to it
cd /data/girim/GaAs/LDA/source_code/

# Load the Quantum ESPRESSO module
module load qe/7.0

# Run the SCF calculation
pw.x <scf.in > scf.out

# Run the NSCF calculation
pw.x <nscf.in > nscf.out

# Run the dos calculation
dos.x <dos.in > dos.out

#Run projected dos calculation
projwfc.x <pdos.in> pdos.out

#summing for the Ga s orbital:
sumpdos.x *\(Ga\)*\(s_j*\) > atom_Ga_s.dat

#summing for the Ga p orbital:
sumpdos.x *\(Ga\)*\(p_j*\) > atom_Ga_p.dat

#summing for the Ga d orbital:
sumpdos.x *\(Ga\)*\(d_j*\) > atom_Ga_d.dat

#summing for the As s orbital:
sumpdos.x *\(As\)*\(s_j*\) > atom_As_s.dat

#summing for the As p orbital:
sumpdos.x *\(As\)*\(p_j*\) > atom_As_p.dat


# Run the bands calculation
pw.x < bands.in > bands.out

# Run the bands.x executable
bands.x < bands.kp.in > bands.kp.out

