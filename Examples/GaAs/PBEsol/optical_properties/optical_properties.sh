#!/bin/sh
#PBS -l nodes=1:ppn=36
#PBS -o optical.out
#PBS -e optical.err
#PBS -N optcl
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
NUM_PROCESSES=36   # Adjust this based on the number of nodes and processors per node

#Download the input files
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/optical_properties/scf.in
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/optical_properties/nscf.in
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/optical_properties/epsilon-jdos.in
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/optical_properties/epsilon.in
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/optical_properties/epsilon_plot.py
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/optical_properties/jdos_plot.py
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/optical_properties/sci.mplstyle

# Run the Codes for the calculation
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x <scf.in> scf.out
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x <nscf.in> nscf.out
if [ $? ne 0]
then
  echo "epsilon is calculated"
else
  echo "epsilon calculation failed."
fi
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE epsilon.x <epsilon.in> epsilon.out
if [ $? ne 0]
then
  echo "epsilon is calculated"
else
  echo "epsilon calculation failed."
fi
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE epsilon.x <epsilon-jdos.in> epsilon-jdos.out
if [ $? ne 0]
then
  echo "JDOS is calculated"
else
  echo "JDOS calculation failed."
fi
# Plot the bandstructure
source /home/girim/python_venv/my-python/bin/activate
python epsilon_plot.py
python jdos_plot.py

# Download the script to email the result
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/email.sh

rm -r GaAs.save
chmod +xxx email.sh
echo "Job finished at `date`"
echo
