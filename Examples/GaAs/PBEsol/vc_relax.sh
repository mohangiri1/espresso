#!/bin/sh
#PBS -l nodes=1:ppn=20
#PBS -o vc_relax.out
#PBS -e vc_relax.err
#PBS -N vc_rel
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

# Load the Quantum ESPRESSO module
module load qe/7.0
module load mpi

# Get the current working directory and change to it
cd $PBS_O_WORKDIR

# Specify the hostfile (optional, if not provided by PBS)
HOSTFILE=$PBS_NODEFILE

# Set the number of processes (total across nodes)
NUM_PROCESSES=20   # Adjust this based on the number of nodes and processors per node

mkdir vc_relax; cd vc_relax

# Download the Pseudopotential files:
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Ga.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Bi.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/As.upf

ecutwfc=70
#ecut=$(($ecutwfc*9))
k=8
calculation='vc-relax'

cat > vc-relax.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'GaAs'
  outdir = './'
  pseudo_dir = './'
/

&SYSTEM
  degauss = 0.002
  !ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 2
  celldm(1) = 11.00
  lspinorb = .TRUE.
  nat = 2
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
    cell_dofree='ibrav'
    cell_dynamics = 'bfgs'
/
ATOMIC_SPECIES
  As 74.9216 As.upf
  Ga 69.72 Ga.upf

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF

# Run Quantum ESPRESSO (pw.x) with mpiexec using -bootstrap ssh
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x < vc-relax.in > vc-relax.out
rm -r GaAs.save
