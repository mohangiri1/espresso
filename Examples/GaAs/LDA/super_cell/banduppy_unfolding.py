#!/usr/bin/env python3

### you need to install packages `banduppy` and `irrep` from pip

import banduppy
import shutil, os, glob
from subprocess import run
import numpy as np
import pickle

QEpath = ""

nproc = 16
PWSCF = "mpirun -np {np}  {QEpath}/pw.x -nk {npk} -nb {npb}".format(np=nproc, QEpath=QEpath, npk=nproc/4, npb=4).split()

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
    supercell=[[2, 0, 0],
               [0, 2, 0],
               [0, 0, 2]],  # Supercell matrix for 2x2x2 supercell
    pathPBZ=[[0.5, 0, 0], [0, 0, 0], [0.5, 0.5, 0.5]],  # Path nodes in reduced coordinates in the PBZ
    nk=(30, 30, 30),  # Number of k-points in each segment
    labels="XGL"  # High-symmetry points
)

unfold = banduppy.Unfolding(
    supercell=[[2, 0, 0],
               [0, 2, 0],
               [0, 0, 2]],  # Supercell matrix for 2x2x2 supercell
    kpointsPBZ=np.array([np.linspace(0.0, 0.5, 12)]*3).T  # Adjust k-points if needed
)

kpointsPBZ = unfold_path.kpoints_SBZ_str()

try:
    print("unpickling unfold")
    unfold_path = pickle.load(open("unfold-path.pickle", "rb"))
    unfold = pickle.load(open("unfold.pickle", "rb"))
except Exception as err:
    print("error while unpickling unfold '{}', unfolding it".format(err))
    try:
        print("unpickling bandstructure")
        bands = pickle.load(open("bandstructure.pickle", "rb"))
        print("unpickling - success")
    except Exception as err:
        print("Unable to unpickle bandstructure '{}' \n  Reading bandstructure from .save folder ".format(err))
        try:
            bands = banduppy.BandStructure(code="espresso", prefix="GaAs")  # Use the appropriate prefix for GaAs
        except Exception as err:
            print("error reading bandstructure '{}' \n calculating it".format(err))
            pw_file = "GaAs"  # Use the appropriate input file name for GaAs
            shutil.copy("input/" + pw_file + "-scf.in", ".")
            open(pw_file + "-bands.in", "w").write(open("input/" + pw_file + "-bands.in").read() + kpointsPBZ)
            scf_run = run(PWSCF, stdin=open(pw_file + "-scf.in"), stdout=open(pw_file + "-scf.out", "w"))
            bands_run = run(PWSCF, stdin=open(pw_file + "-bands.in"), stdout=open(pw_file + "-bands.out", "w"))
            for f in glob.glob("*.wfc*"):
                os.remove(f)
            bands = banduppy.BandStructure(code="espresso", prefix="GaAs")
        pickle.dump(bands, open("bandstructure.pickle", "wb"))

    unfold_path.unfold(bands, break_thresh=0.1, suffix="path")
    unfold.unfold(bands, suffix="GL")
    pickle.dump(unfold_path, open("unfold-path.pickle", "wb"))
    pickle.dump(unfold, open("unfold.pickle", "wb"))

# Now plot the result as fat band
unfold_path.plot(save_file="unfold_fatband.png", plotSC=True, Emin=-5, Emax=5, Ef='auto', fatfactor=50, mode='fatband')
# Or as a colormap
unfold_path.plot(save_file="unfold_density.png", plotSC=True, Emin=-5, Emax=5, Ef='auto', mode='density', smear=0.2, nE=200)

# Or use the data to plot in any other format
data = np.loadtxt("bandstructure_unfolded-path.txt")
