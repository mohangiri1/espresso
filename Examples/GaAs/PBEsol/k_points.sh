#!/bin/sh
#PBS -l nodes=1:ppn=20
#PBS -o k_points.out
#PBS -e k_points.err
#PBS -N kpnts
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
NUM_PROCESSES=80   # Adjust this based on the number of nodes and processors per node

mkdir k_points; cd k_points
# Download the Pseudopotential files:
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Ga.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Bi.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/As.upf

# Convergence test of k points.
# Set a variable k.
ecutwfc=70
#ecut=$(($ecutwfc*9))
for k in 2 4 6 8 10 ; do
    # Make input file for the SCF calculation.
    # k is assigned by variable k.
    cat > k.$k.in << EOF
&CONTROL
  calculation = 'scf'
  prefix = 'GaAs'
  outdir = './'
  pseudo_dir = './'
/

&SYSTEM
  degauss = 0.002
  !ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 2
  celldm(1) = 10.7073764239
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

ATOMIC_SPECIES
  As 74.9216 As.upf
  Ga 69.72 Ga.upf

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF
    # Run SCF calculation: # Run Quantum ESPRESSO (pw.x) with mpiexec using -bootstrap ssh
    mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x < k.$k.in > k.$k.out

    # Write cut-off and total energies in calc-ecut.dat.
    awk '/!/ {printf"%d %s\n",'$k',$5}' k.$k.out >> convergence_data.txt
    rm -r k.$k.in
    rm -r GaAs.save

done

#Produce a Python file called analyze_plot.py for the plot.
# Generate analyze_plot.py script
cat > analyze_plot.py << 'EOF'
import numpy as np
import matplotlib.pyplot as plt
from lmfit import Model

def read_convergence_data(file_path):
    """Read convergence data from a file."""
    k_points = []
    energy = []
    with open(file_path, 'r') as file:
        #next(file)  # Skip the header line
        for line in file:
            data = line.split()
            k_points.append(int(data[0]))
            energy.append(float(data[1]))
    return np.array(k_points), np.array(energy)

def find_convergence(k_points, energy, number_of_atoms, threshold=1e-5):
    """Find the convergence point where energy change is below a threshold."""
    energy_diff = np.diff(energy)
    energy_diff_per_atom = np.abs(energy_diff)/number_of_atoms
    converged_idx = np.where(np.abs(energy_diff_per_atom) < threshold)[0][0]
    return k_points[converged_idx], energy[converged_idx]

def plot_convergence(k_points, energy, converged_k_points, converged_energy, accuracy):
    """Plot energy as a function of k_points and mark the convergence point."""
    plt.figure(figsize=(10, 6))
    plt.plot(k_points, energy, marker='o', linestyle='-', label='Total Energy')
    
    # Add red marker at the convergence point
    plt.scatter(converged_k_points, converged_energy, color='red', label='Convergence Point')
    
    # Display convergence information in the legend
    legend_text = f'\nk points = {converged_k_points}\nEnergy = {converged_energy}\nAccuracy = {accuracy} meV per atom'
    plt.legend([legend_text], title='Convergence Point', loc='upper right')
    
    plt.xlabel('K Points')
    plt.ylabel('Total Energy (Ry)')
    plt.title('Convergence of Total Energy with K Points')
    plt.grid(True)
    plt.savefig('k_points_convergence_plot.pdf')
    plt.show()
    
def exponential_decay_fit(energy, k_points):
    """
    Fit an exponential decay model to the given data.

    Parameters:
    - energy (array-like): Array-like object containing the total energy values.
    - k_points (array-like): Array-like object containing the k_points values.

    Returns:
    - float: The value of the parameter C, which represents the limit as x approaches infinity in the exponential decay model y = Ae^(-Bx) + C.
    
    This function fits an exponential decay model y = Ae^(-Bx) + C to the provided data using lmfit. It then plots the fit and returns the value of parameter C, which corresponds to the limit of y as x approaches infinity in the model.
    """

    # Define the exponential decay model
    def exp_decay(x, A, B, C):
        return A * np.exp(-B * x) + C

    # Create a model instance
    model = Model(exp_decay)

    # Set initial parameters
    params = model.make_params(A=min(energy), B=1/4, C=min(energy))

    # Perform the fit
    result = model.fit(energy, x=k_points, params=params)

    # Plot the fit
    plt.figure(figsize=(10, 6))
    plt.scatter(k_points, energy, label='Data')
    plt.plot(k_points, result.best_fit, 'r-', label='Exponential Fit')
    plt.xlabel('K points')
    plt.ylabel('Total Energy')
    plt.legend()
    plt.title('Exponential Decay Fit')
    plt.grid()
    plt.savefig('k_points_convergence_plot_fit.pdf')
    plt.show()

    # Return the limit as x approaches infinity (C parameter) #Total Energy at ecut = infinity
    return result.params['C'].value

def k_accuracy_estimation(E_converged: float, number_of_atoms, E_inf: float):
    """
    Calculate the estimated energy calculation accuracy in milli-electron volts (meV).

    Parameters:
    - E_converged (float): The converged energy value obtained from the calculation.
    - E_inf (float): The estimated energy at infinity obtained from a model or fitting.
    - number_of_atoms (int): The number of atoms used in the calculation.

    Returns:
    - accuracy in meV per atom.
    
    This function calculates the estimated energy calculation accuracy in milli-electron volts (meV) based on the difference between the converged energy value and the estimated energy at infinity.
    """

    accuracy_Ry = (E_converged - E_inf)/number_of_atoms #accuracy in Rydberg
    accuracy_eV = accuracy_Ry * 13.6057
    accuracy_meV = accuracy_eV*1000 # accuracy in meV
    print(f"Estimated Energy calculation accuracy: {accuracy_meV} meV per atom")
    
    return accuracy_meV

if __name__ == "__main__":
    # Read convergence data
    k_points, energy = read_convergence_data('convergence_data.txt')
    number_of_atoms = 2
    # Find convergence point
    converged_k_points, converged_energy = find_convergence(k_points, energy, number_of_atoms, threshold=1e-3)
    
    # Fit the convergence data to predict the Total energy at k points = Infinity.
    E_inf = exponential_decay_fit(energy, k_points)
    
    #Estimate the accuracy of the convergence
    accuracy = k_accuracy_estimation(converged_energy, number_of_atoms, E_inf)
    
    # Plot convergence
    plot_convergence(k_points, energy, converged_k_points, converged_energy, accuracy)

    print(f"Convergence achieved at k points = {converged_k_points} with total energy = {converged_energy} Ry.")
EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python analyze_plot.py
