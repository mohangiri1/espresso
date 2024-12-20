#!/bin/bash 

# Get the current working directory and change to it
cd /data/girim/Research/GaAs/calculation/SC/

# Load the Quantum ESPRESSO module
module load qe/7.0

ecutwfc=80
ecut=$(($ecutwfc*9))
k=4
calculation='vc-relax'

cat > vc-relax.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'GaAs'
  outdir = './output_vc/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  disk_io = 'none'
  tstress = .true.
  tprnfor = .true.
  restart_mode = 'from_scratch'
/

&SYSTEM
  degauss = 0.002
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 0
  celldm(1) = 21.2078512
  lspinorb = .TRUE.
  nat = 16
  noncolin = .TRUE.
  ntyp = 2
  occupations = 'smearing'
  smearing = 'gaussian'
  starting_magnetization(1) = 0.0000e+00
  nosym = .true.
/

&ELECTRONS
  conv_thr = 1e-08
  electron_maxstep = 80
  mixing_beta = 0.3
/

&ions
	ion_dynamics = 'bfgs'
/

&cell
    cell_dofree='all'
    cell_dynamics = 'bfgs'
/
ATOMIC_SPECIES
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS {crystal}
Ga      0.000000   0.000000   0.000000
As      0.125000   0.125000   0.125000
Ga      0.000000   0.000000   0.500001
As      0.125000   0.125000   0.625001
Ga      0.000000   0.500001   0.000000
As      0.125000   0.625001   0.125000
Ga      0.000000   0.500001   0.500001
As      0.125000   0.625001   0.625001
Ga      0.500001   0.000000   0.000000
As      0.625001   0.125000   0.125000
Ga      0.500001   0.000000   0.500001
As      0.625001   0.125000   0.625001
Ga      0.500001   0.500001   0.000000
As      0.625001   0.625001   0.125000
Ga      0.500001   0.500001   0.500001
As      0.625001   0.625001   0.625001


CELL_PARAMETERS {alat}
 -0.500000   0.000000   0.500000
  0.000000   0.500000   0.500000
 -0.500000   0.500000   0.000000

EOF

# Run SCF calculation.
mpirun -np 32 pw.x < vc-relax.in > vc-relax.out
