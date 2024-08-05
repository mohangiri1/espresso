#!/bin/sh
#PBS -l nodes=1:ppn=4
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

# Convergence test of rho cut-off energy.
# Set a variable ecutrho from 4 times ecutwfc to 11 times ecutwfc Ry.
ecutwfc=80
for ecutrho in 4 5 6 7 8 9 10 11 ; do
    # Make input file for the SCF calculation.
    # ecutrho is assigned by variable ecut.
    ecut=$((ecutrho*80))
    cat > ecutrho.$ecut.in << EOF
&CONTROL
  calculation = 'scf'
  prefix = 'GaAs'
  outdir = './output/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
/

&SYSTEM
  degauss = 0.002
  ecutrho = $ecut
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
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF

K_POINTS {automatic}
  4 4 4 0 0 0

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF
    # Run SCF calculation.
    mpirun -np 4 pw.x < ecutrho.$ecut.in > ecutrho.$ecut.out

    # Write cut-off and total energies in calc-ecut.dat.
    awk '/!/ {printf"%d %s\n",'$ecut',$5}' ecutrho.$ecut.out >> convergence_data.txt

done

#Produce a Python file called analyze_plot.py for the plot.
# Generate analyze_plot.py script
cat > analyze_plot.py << 'EOF'
import numpy as np
import matplotlib.pyplot as plt
from lmfit import Model

def read_convergence_data(file_path):
    """Read convergence data from a file."""
    ecutrho = []
    energy = []
    with open(file_path, 'r') as file:
        #next(file)  # Skip the header line
        for line in file:
            data = line.split()
            ecutrho.append(float(data[0]))
            energy.append(float(data[1]))
    return np.array(ecutrho), np.array(energy)

def find_convergence(ecutrho, energy, number_of_atoms, threshold=1e-3):
    """Find the convergence point where energy change is below a threshold."""
    energy_diff = np.diff(energy)
    energy_diff_per_atom = np.abs(energy_diff)/number_of_atoms
    converged_idx = np.where(np.abs(energy_diff_per_atom) < threshold)[0][0]
    return ecutrho[converged_idx], energy[converged_idx]

def plot_convergence(ecutrho, energy, converged_ecutrho, converged_energy, accuracy):
    """Plot energy as a function of ecutrho and mark the convergence point."""
    plt.figure(figsize=(10, 6))

    # Sort ecutrho if necessary
    sorted_indices = np.argsort(ecutrho)
    sorted_ecutrho = ecutrho[sorted_indices]
    sorted_energy = energy[sorted_indices]

    plt.plot(sorted_ecutrho, sorted_energy, linestyle='-')
    plt.scatter(converged_ecutrho, converged_energy, color='red', label='Convergence Point')
    
    # Draw vertical line at convergence point
    plt.axvline(x=converged_ecutrho, color='gray', linestyle='--', linewidth=1)
    
    # Display convergence information in the legend
    legend_text = f'Convergence Point\necutrho = {converged_ecutrho}\nEnergy = {converged_energy}\naccuracy = {accuracy} meV'
    plt.legend([legend_text], loc='upper right')
    
    plt.xlabel('ecutrho')
    plt.ylabel('Total Energy (Ry)')
    plt.title('Convergence of Total Energy with ecutrho')
    plt.grid(True)
    plt.savefig('ecutrho_convergence_plot.pdf')
    plt.show()
    
def exponential_decay_fit(energy, ecutrho):
    """
    Fit an exponential decay model to the given data.

    Parameters:
    - energy (array-like): Array-like object containing the total energy values.
    - ecutrho (array-like): Array-like object containing the ecutrho values.

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
    result = model.fit(energy, x=ecutrho, params=params)

    # Plot the fit
    plt.figure(figsize=(10, 6))
    plt.scatter(ecutrho, energy, label='Data')
    plt.plot(ecutrho, result.best_fit, 'r-', label='Exponential Fit')
    plt.xlabel('ecutrho')
    plt.ylabel('Total Energy')
    plt.legend()
    plt.title('Exponential Decay Fit')
    plt.grid()
    plt.savefig('convergence_plot_fit.pdf')
    plt.show()

    # Return the limit as x approaches infinity (C parameter) #Total Energy at ecut = infinity
    return result.params['C'].value

def ecutrho_accuracy_estimation(E_converged: float, number_of_atoms, E_inf: float):
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
    # ecutrho, energy = read_convergence_data('/content/sample_data/convergence_data.txt')
    ecutrho, energy = read_convergence_data('./convergence_data.txt')
    number_of_atoms = 2

    # Find convergence point
    converged_ecutrho, converged_energy = find_convergence(ecutrho, energy, number_of_atoms, threshold = 1e-5)
    
    # Fit the convergence data to predict the Total energy at ecutrho = Infinity.
    E_inf = exponential_decay_fit(energy, ecutrho)
    
    #Estimate the accuracy of the convergence
    accuracy = ecutrho_accuracy_estimation(converged_energy, number_of_atoms, E_inf)

    # Plot convergence
    plot_convergence(ecutrho, energy, converged_ecutrho, converged_energy, accuracy)
    

    print(f"Convergence achieved at ecutrho = {converged_ecutrho} with total energy = {converged_energy} Ry.")
EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python analyze_plot.py
