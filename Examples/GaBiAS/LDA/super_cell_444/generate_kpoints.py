#!/usr/bin/env python3

### you need to install packages `banduppy` and `irrep` from pip

import banduppy
import shutil, os, glob
from subprocess import run
import numpy as np
import pickle

#unfold_path = banduppy.UnfoldingPath(
#    supercell=[[2, 0, 0],
#               [0, 2, 0],
#               [0, 0, 2]],  # Supercell matrix for 2x2x2 supercell
#    pathPBZ=[[0, 0, 0], [0.5, 0, 0], [0.5, 0.25, 0.25], [0.375, 0.375, 0.75], [0, 0, 0],
#             [0.5, 0.5, 0.5], [0.625, 0.25, 0.625], [0.5, 0.25, 0.25], [0.5, 0.5, 0.5],
#             [0.375, 0.375, 0.75]],  # Path nodes in reduced coordinates in the PBZ
#    nk=(30, 30, 30, 30, 30, 30, 30, 30, 30),  # Number of k-points in each segment
#    labels="GXWKGLUWLK"  # High-symmetry points
#)

unfold_path = banduppy.UnfoldingPath(
    supercell=[[4, 0, 0],
               [0, 4, 0],
               [0, 0, 4]],  # Supercell matrix for 2x2x2 supercell
    pathPBZ=[[0.5, 0, 0], [0, 0, 0], [0.5, 0.5, 0.5]],  # Path nodes in reduced coordinates in the PBZ
    nk=(30, 30, 30),  # Number of k-points in each segment
    labels="XGL"  # High-symmetry points
)

unfold = banduppy.Unfolding(
    supercell=[[4, 0, 0],
               [0, 4, 0],
               [0, 0, 4]],  # Supercell matrix for 2x2x2 supercell
    kpointsPBZ=np.array([np.linspace(0.0, 0.5, 12)]*3).T  # Adjust k-points if needed
)

kpointsPBZ = unfold_path.kpoints_SBZ_str()

pw_file = "GaBiAs"  # Use the appropriate input file name for GaAs
shutil.copy("input/" + pw_file + "-scf.in", ".")
open(pw_file + "-bands.in", "w").write(open("input/" + pw_file + "-bands.in").read() + kpointsPBZ)
