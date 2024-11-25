#!/bin/sh
#PBS -l nodes=2:ppn=32
#PBS -o vc.out
#PBS -e vc.err
#PBS -N vc
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
NUM_PROCESSES=64   # Adjust this based on the number of nodes and processors per node

# Dowload the PPS
wget https://pseudopotentials.quantum-espresso.org/upf_files/Te.pz-hgh.UPF
wget https://pseudopotentials.quantum-espresso.org/upf_files/O.pz-hgh.UPF
wget https://pseudopotentials.quantum-espresso.org/upf_files/La.pz-hgh.UPF

ecutwfc=100
ecut=$(($ecutwfc*1))
k=8
calculation='vc-relax'

cat > vc-relax.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'La2TeO2'
  outdir = './output/'
  pseudo_dir = './'
  disk_io = 'none'
/

&SYSTEM
  degauss = 0.002
  ecutwfc = $ecut
  degauss                   =  2.00000e-02
  ibrav                     = 0
  nat                       = 5
  nosym                     = .FALSE.
  ntyp                      = 3
  occupations               = "fixed"
/

&ELECTRONS
    conv_thr         =  1.00000e-09
    electron_maxstep = 80
    mixing_beta      =  4.00000e-01
    startingpot      = "atomic"
    startingwfc      = "atomic+random"
/

&ions
	ion_dynamics = 'bfgs'
/

&cell
    cell_dofree='all'
    cell_dynamics = 'bfgs'
/

K_POINTS {automatic}
  $k $k $k 0 0 0

CELL_PARAMETERS {angstrom}
 -2.064109   2.064109   6.563914
  2.064109  -2.064109   6.563914
  2.064109   2.064109  -6.563914

ATOMIC_SPECIES
La    138.90547  La.pz-hgh.UPF
O      15.99940  O.pz-hgh.UPF
Te    127.60000  Te.pz-hgh.UPF

ATOMIC_POSITIONS {angstrom}
La      2.064109   2.064109   2.088596
La      0.000000  -0.000000   4.475318
Te      0.000000   0.000000   0.000000
O       0.000000   2.064109   3.281957
O       2.064109   0.000000   3.281957
EOF
# This calculation doesn't involve magnetic phenomenon.

# Run SCF calculation.
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x < vc-relax.in > vc-relax.out
