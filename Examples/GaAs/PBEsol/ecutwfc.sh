#!/bin/sh
#PBS -l nodes=1:ppn=16
#PBS -o ecutrho.out
#PBS -e ecutrho.err
#PBS -N wfc
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

mkdir ecutwfc
cd ecutwfc

# Download the Pseudopotential files:
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Ga.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Bi.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/As.upf


# Define the starting and ending points for ecutwfc
start_ecutwfc=30
end_ecutwfc=100

# Ensure the starting and ending points are multiples of 10
start_ecutwfc=$(( (start_ecutwfc + 9) / 10 * 10 ))
end_ecutwfc=$(( (end_ecutwfc + 9) / 10 * 10 ))
for ecut in $(seq $start_ecutwfc 10 $end_ecutwfc); do
# Make input file for the SCF calculation.
# ecutwfc is assigned by variable ecut.

cat > ecut.$ecut.in << EOF
&CONTROL
  calculation = 'scf'
  prefix = 'GaAs'
  outdir = './'
  pseudo_dir = './'
/

&SYSTEM
  degauss = 0.002
  !ecutrho = $((ecut*8))
  !ecutrho = 1435
  ecutwfc = $ecut
  ibrav = 2
  celldm(1) = 10.6039256
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
  4 4 4 0 0 0

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF

# Run SCF calculation: # Run Quantum ESPRESSO (pw.x) with mpiexec using -bootstrap ssh
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x <ecut.$ecut.in> ecut.$ecut.out

# Write cut-off and total energies in convergence_data.txt.
awk '/!/ {printf"%d %s\n",'$ecut',$5}' ecut.$ecut.out >> convergence_data.txt
rm -r ecut.$ecut.in
rm -r GaAs.save
# End of for loop
done

#Produce a Python file called analyze_plot.py for the plot.
# Generate analyze_plot.py script
cat > analyze_plot.py << 'EOF'
import numpy as np
import matplotlib.pyplot as plt
from lmfit import Model

def read_convergence_data(file_path):
    """Read convergence data from a file."""
    ecutwfc = []
    energy = []
    with open(file_path, 'r') as file:
        #next(file)  # Skip the header line
        for line in file:
            data = line.split()
            ecutwfc.append(float(data[0]))
            energy.append(float(data[1]))
    return np.array(ecutwfc), np.array(energy)

def find_convergence(ecutwfc, energy, number_of_atoms, threshold=1e-3):
    """Find the convergence point where energy change is below a threshold."""
    energy_diff = np.diff(energy)
    energy_diff_per_atom = np.abs(energy_diff)/number_of_atoms
    converged_idx = np.where(np.abs(energy_diff_per_atom) < threshold)[0][0]
    return ecutwfc[converged_idx], energy[converged_idx]

def plot_convergence(ecutwfc, energy, converged_ecutwfc, converged_energy, accuracy):
    """Plot energy as a function of ecutwfc and mark the convergence point."""
    plt.figure(figsize=(10, 6))

    # Sort ecutwfc if necessary
    sorted_indices = np.argsort(ecutwfc)
    sorted_ecutwfc = ecutwfc[sorted_indices]
    sorted_energy = energy[sorted_indices]

    plt.plot(sorted_ecutwfc, sorted_energy, linestyle='-')
    plt.scatter(converged_ecutwfc, converged_energy, color='red', label='Convergence Point')
    
    # Draw vertical line at convergence point
    plt.axvline(x=converged_ecutwfc, color='gray', linestyle='--', linewidth=1)
    
    # Display convergence information in the legend
    legend_text = f'Convergence Point\necutwfc = {converged_ecutwfc}\nEnergy = {converged_energy}\naccuracy = {accuracy} meV'
    plt.legend([legend_text], loc='upper right')
    
    plt.xlabel('ecutwfc')
    plt.ylabel('Total Energy (Ry)')
    plt.title('Convergence of Total Energy with ecutwfc')
    plt.grid(True)
    plt.savefig('ecutwfc_convergence_plot.pdf')
    plt.show()
    
def exponential_decay_fit(energy, ecutwfc):
    """
    Fit an exponential decay model to the given data.

    Parameters:
    - energy (array-like): Array-like object containing the total energy values.
    - ecutwfc (array-like): Array-like object containing the ecutwfc values.

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
    params = model.make_params(A=min(energy), B=1/70, C=min(energy))

    # Perform the fit
    result = model.fit(energy, x=ecutwfc, params=params)

    # Plot the fit
    plt.figure(figsize=(10, 6))
    plt.scatter(ecutwfc, energy, label='Data')
    plt.plot(ecutwfc, result.best_fit, 'r-', label='Exponential Fit')
    plt.xlabel('ecutwfc')
    plt.ylabel('Total Energy')
    plt.legend()
    plt.title('Exponential Decay Fit')
    plt.grid()
    plt.savefig('convergence_plot_fit.pdf')
    plt.show()

    # Return the limit as x approaches infinity (C parameter) #Total Energy at ecut = infinity
    return result.params['C'].value

def ecutwfc_accuracy_estimation(E_converged: float, number_of_atoms, E_inf: float):
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
    # ecutwfc, energy = read_convergence_data('/content/sample_data/convergence_data.txt')
    ecutwfc, energy = read_convergence_data('./convergence_data.txt')
    number_of_atoms = 2

    # Find convergence point
    converged_ecutwfc, converged_energy = find_convergence(ecutwfc, energy, number_of_atoms, threshold = 1e-5)
    
    # Fit the convergence data to predict the Total energy at ecutwfc = Infinity.
    E_inf = exponential_decay_fit(energy, ecutwfc)
    
    #Estimate the accuracy of the convergence
    accuracy = ecutwfc_accuracy_estimation(converged_energy, number_of_atoms, E_inf)

    # Plot convergence
    plot_convergence(ecutwfc, energy, converged_ecutwfc, converged_energy, accuracy)
    

    print(f"Convergence achieved at ecutwfc = {converged_ecutwfc} with total energy = {converged_energy} Ry.")
EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python analyze_plot.py
