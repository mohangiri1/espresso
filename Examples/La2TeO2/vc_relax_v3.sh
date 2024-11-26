#!/bin/sh
#PBS -l nodes=1:ppn=16
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
NUM_PROCESSES=16   # Adjust this based on the number of nodes and processors per node

# make a new folder and go to the folder.
mkdir vc; cd vc

# Dowload the PPS
wget https://pseudopotentials.quantum-espresso.org/upf_files/Te.pz-hgh.UPF
wget https://pseudopotentials.quantum-espresso.org/upf_files/O.pz-hgh.UPF
wget https://pseudopotentials.quantum-espresso.org/upf_files/pz.pbe-hgh.UPF

ecutwfc=100
ecut=$(($ecutwfc*1))
k=4
calculation='vc-relax'

cat > vc-relax.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'La2TeO2'
  outdir = './output/'
  pseudo_dir = './'
  forc_conv_thr = 0.001
  disk_io = 'none'
/

&SYSTEM
  ecutwfc = $ecut
  ibrav                     = 0
  nat                       = 5
  nosym                     = .FALSE.
  ntyp                      = 3
/

&ELECTRONS
    conv_thr         =  1.00000e-10
    electron_maxstep = 80
    mixing_beta      =  4.00000e-01
/

&ions
	ion_dynamics = 'bfgs'
/

&cell
    cell_dofree='all'
    cell_dynamics = 'bfgs'
    press = 0.0
    press_conv_thr = 0.5
/

ATOMIC_SPECIES
La    138.90547  La.pz-hgh.UPF
O      15.99940  O.pz-hgh.UPF
Te    127.60000  Te.pz-hgh.UPF

ATOMIC_POSITIONS angstrom
La       2.0641092700     2.0641092700     2.0885956903
La      -0.0000000000     0.0000000000     4.4753181097
O       -0.0000000000     2.0641092700     3.2819569000
O        2.0641092700     0.0000000000     3.2819569000
Te       0.0000000000     0.0000000000     0.0000000000
K_POINTS automatic
$k $k $k 0 0 0
CELL_PARAMETERS angstrom
   -2.0641092700     2.0641092700     6.5639138000
    2.0641092700    -2.0641092700     6.5639138000
    2.0641092700     2.0641092700    -6.5639138000
EOF
# This calculation doesn't involve magnetic phenomenon.

# Run SCF calculation.
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x < vc-relax.in > vc-relax.out

# Exit from the folder
cd ..
