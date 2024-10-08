#!/bin/sh
#PBS -l nodes=1:ppn=32
#PBS -o GaAs_444_scf.out
#PBS -e GaAs_444_scf.err
#PBS -N GaAs_444_scf
#PBS -m be -M mohan_giri1@baylor.edu
echo "------------------"
echo
echo "Job working directory: $PBS_O_WORKDIR"
echo

num=`cat $PBS_NODEFILE | wc -l`
echo "Total processes: $num"
echo

echo "Job starting at `date`"
echo

# Get the current working directory and change to it
cd $PBS_O_WORKDIR

# Load the Quantum ESPRESSO module
module load qe/7.0

ecutwfc=80
ecut=$(($ecutwfc*9))
k=2
calculation='scf'

cat > GaAs-scf.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'GaAs'
  outdir = './output444/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  tstress = .true.
  tprnfor = .true.
  restart_mode = 'from_scratch'
/

&SYSTEM
  degauss = 0.002
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 0
  celldm(1) = 42.4157024
  lspinorb = .TRUE.
  nat = 128
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
ATOMIC_SPECIES
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS {crystal}
Ga      0.000000   0.000000   0.000000
As      0.062500   0.062500   0.062500
Ga      0.000000   0.000000   0.250000
As      0.062500   0.062500   0.312500
Ga      0.000000   0.000000   0.500001
As      0.062500   0.062500   0.562501
Ga      0.000000   0.000000   0.750001
As      0.062500   0.062500   0.812501
Ga      0.000000   0.250000   0.000000
As      0.062500   0.312500   0.062500
Ga      0.000000   0.250000   0.250000
As      0.062500   0.312500   0.312500
Ga      0.000000   0.250000   0.500001
As      0.062500   0.312500   0.562501
Ga      0.000000   0.250000   0.750001
As      0.062500   0.312500   0.812501
Ga      0.000000   0.500001   0.000000
As      0.062500   0.562501   0.062500
Ga      0.000000   0.500001   0.250000
As      0.062500   0.562501   0.312500
Ga      0.000000   0.500001   0.500001
As      0.062500   0.562501   0.562501
Ga      0.000000   0.500001   0.750001
As      0.062500   0.562501   0.812501
Ga      0.000000   0.750001   0.000000
As      0.062500   0.812501   0.062500
Ga      0.000000   0.750001   0.250000
As      0.062500   0.812501   0.312500
Ga      0.000000   0.750001   0.500001
As      0.062500   0.812501   0.562501
Ga      0.000000   0.750001   0.750001
As      0.062500   0.812501   0.812501
Ga      0.250000   0.000000   0.000000
As      0.312500   0.062500   0.062500
Ga      0.250000   0.000000   0.250000
As      0.312500   0.062500   0.312500
Ga      0.250000   0.000000   0.500001
As      0.312500   0.062500   0.562501
Ga      0.250000   0.000000   0.750001
As      0.312500   0.062500   0.812501
Ga      0.250000   0.250000   0.000000
As      0.312500   0.312500   0.062500
Ga      0.250000   0.250000   0.250000
As      0.312500   0.312500   0.312500
Ga      0.250000   0.250000   0.500001
As      0.312500   0.312500   0.562501
Ga      0.250000   0.250000   0.750001
As      0.312500   0.312500   0.812501
Ga      0.250000   0.500001   0.000000
As      0.312500   0.562501   0.062500
Ga      0.250000   0.500001   0.250000
As      0.312500   0.562501   0.312500
Ga      0.250000   0.500001   0.500001
As      0.312500   0.562501   0.562501
Ga      0.250000   0.500001   0.750001
As      0.312500   0.562501   0.812501
Ga      0.250000   0.750001   0.000000
As      0.312500   0.812501   0.062500
Ga      0.250000   0.750001   0.250000
As      0.312500   0.812501   0.312500
Ga      0.250000   0.750001   0.500001
As      0.312500   0.812501   0.562501
Ga      0.250000   0.750001   0.750001
As      0.312500   0.812501   0.812501
Ga      0.500001   0.000000   0.000000
As      0.562501   0.062500   0.062500
Ga      0.500001   0.000000   0.250000
As      0.562501   0.062500   0.312500
Ga      0.500001   0.000000   0.500001
As      0.562501   0.062500   0.562501
Ga      0.500001   0.000000   0.750001
As      0.562501   0.062500   0.812501
Ga      0.500001   0.250000   0.000000
As      0.562501   0.312500   0.062500
Ga      0.500001   0.250000   0.250000
As      0.562501   0.312500   0.312500
Ga      0.500001   0.250000   0.500001
As      0.562501   0.312500   0.562501
Ga      0.500001   0.250000   0.750001
As      0.562501   0.312500   0.812501
Ga      0.500001   0.500001   0.000000
As      0.562501   0.562501   0.062500
Ga      0.500001   0.500001   0.250000
As      0.562501   0.562501   0.312500
Ga      0.500001   0.500001   0.500001
As      0.562501   0.562501   0.562501
Ga      0.500001   0.500001   0.750001
As      0.562501   0.562501   0.812501
Ga      0.500001   0.750001   0.000000
As      0.562501   0.812501   0.062500
Ga      0.500001   0.750001   0.250000
As      0.562501   0.812501   0.312500
Ga      0.500001   0.750001   0.500001
As      0.562501   0.812501   0.562501
Ga      0.500001   0.750001   0.750001
As      0.562501   0.812501   0.812501
Ga      0.750001   0.000000   0.000000
As      0.812501   0.062500   0.062500
Ga      0.750001   0.000000   0.250000
As      0.812501   0.062500   0.312500
Ga      0.750001   0.000000   0.500001
As      0.812501   0.062500   0.562501
Ga      0.750001   0.000000   0.750001
As      0.812501   0.062500   0.812501
Ga      0.750001   0.250000   0.000000
As      0.812501   0.312500   0.062500
Ga      0.750001   0.250000   0.250000
As      0.812501   0.312500   0.312500
Ga      0.750001   0.250000   0.500001
As      0.812501   0.312500   0.562501
Ga      0.750001   0.250000   0.750001
As      0.812501   0.312500   0.812501
Ga      0.750001   0.500001   0.000000
As      0.812501   0.562501   0.062500
Ga      0.750001   0.500001   0.250000
As      0.812501   0.562501   0.312500
Ga      0.750001   0.500001   0.500001
As      0.812501   0.562501   0.562501
Ga      0.750001   0.500001   0.750001
As      0.812501   0.562501   0.812501
Ga      0.750001   0.750001   0.000000
As      0.812501   0.812501   0.062500
Ga      0.750001   0.750001   0.250000
As      0.812501   0.812501   0.312500
Ga      0.750001   0.750001   0.500001
As      0.812501   0.812501   0.562501
Ga      0.750001   0.750001   0.750001
As      0.812501   0.812501   0.812501

CELL_PARAMETERS {alat}
 -0.500000   0.000000   0.500000
  0.000000   0.500000   0.500000
 -0.500000   0.500000   0.000000

EOF

# Run SCF calculation.
mpirun -np 32 pw.x < GaAs-scf.in > GaAs-scf.out

#$ -N SendEmail
#$ -m bea
#$ -M user@domain.com

# Variables
recipient="mohan_giri1@baylor.edu"
subject="Completion of the Run"
body="The job in the HPC has been completed. The results are attached in the compressed file."
attachment="GaAs-scf.out"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."

echo
echo "Job finished at `date`"
