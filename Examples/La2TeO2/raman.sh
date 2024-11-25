#!/bin/sh
#PBS -l nodes=2:ppn=32
#PBS -o raman.out
#PBS -e raman.err
#PBS -N raman
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
calculation='scf'

# ---------------------Create Scf file-------------------------------
cat > scf.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'La2TeO2'
  outdir = './output/'
  pseudo_dir = './'
/

&SYSTEM
  degauss = 0.002
  ecutwfc = $ecut
  degauss                   =  2.00000e-02
  ibrav                     = 0
  nat                       = 5
  nosym                     = .FALSE.
  ntyp                      = 3
/

&ELECTRONS
    conv_thr         =  1.00000e-09
    electron_maxstep = 80
    mixing_beta      =  4.00000e-01
    startingpot      = "atomic"
    startingwfc      = "atomic+random"
/


K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_SPECIES
La    138.90547  La.pz-hgh.UPF
O      15.99940  O.pz-hgh.UPF
Te    127.60000  Te.pz-hgh.UPF

CELL_PARAMETERS (angstrom)
  -1.949634763   1.949634763   6.052313028
   1.949634763  -1.949634763   6.052313028
   1.949634763   1.949634763  -6.052313028

ATOMIC_POSITIONS (angstrom)
La            1.9496347632        1.9496347632        1.8185905874
La           -0.0000000000        0.0000000000        4.2337224401
Te            0.0000000000        0.0000000000        0.0000000000
O            -0.0000000000        1.9496347632        3.0261565138
O             1.9496347632        0.0000000000        3.0261565138
EOF

# ---------------------------Create ph.in file------------------------------
cat > ph.in << EOF
phonon calc.
&INPUTPH
outdir    = './output/'
prefix    = 'La2TeO2'
fildyn    = 'La2TeO2.dmat'
tr2_ph    = 1d-14
epsil     = .true.
lraman    = .true.
trans     = .true.
asr       = .true.
/
0.0 0.0 0.0
EOF
#----------------------Create dynmat.in----------------------------------
cat > dynmat.in << EOF
&INPUT
fildyn = 'La2TeO2.dmat'
asr    = 'crystal'
/
EOF

# Run calculation.
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x < $calculation.in > $calculation.out
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE ph.x < ph.in > ph.out
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE dynmat.x < dynmat.in > dynmat.out
