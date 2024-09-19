#!/bin/sh
#PBS -l nodes=1:ppn=20
#PBS -o eqn_of_state.out
#PBS -e eqn_of_state.err
#PBS -N eqnst
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

mkdir eqn_of_state; cd eqn_of_state
# Download the Pseudopotential files:
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Ga.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/Bi.upf
wget https://raw.githubusercontent.com/mohangiri1/espresso/refs/heads/main/Examples/GaAs/PBEsol/As.upf

ecut=70
#ecutrho=$(($ecut*9))
k=8
initial_celldm=10.7073764239

# Define the range of variation for celldm(1)
min_percent=-10
max_percent=10
step_percent=1

# Create a new or clear existing data file
echo "celldm(1) Total_Energy" > volume_optimization_data.txt

# Loop over the percentage change
for percent_change in $(seq $min_percent $step_percent $max_percent)
 do
    echo "Running SCF calculation with percent_change = $percent_change"
    # Calculate the new value of celldm(1)

    new_celldm=$(echo "scale=10; (1 + $percent_change/100) * $initial_celldm" | bc)

    # Modify the input file with the updated celldm(1) value
cat > celldm.$percent_change.in << EOF
&CONTROL
  calculation = 'scf'
  prefix = 'GaAs'
  outdir = './'
  pseudo_dir = './'
/

&SYSTEM
  degauss = 0.002
  !ecutrho = $ecutrho
  ecutwfc = $ecut
  ibrav = 2
  celldm(1) = $new_celldm
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
    mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE pw.x < celldm.${percent_change}.in > "celldm.${percent_change}.out"

    # Extract total energy from output file
    total_energy=$(grep -m 1 "!" "celldm.${percent_change}.out" | awk '{print $5}')

    # Append celldm(1) and total energy to data file
    echo "$new_celldm $total_energy" >> volume_optimization_data.txt

    rm -r celldm.${percent_change}.in
    rm -r GaAs.save

    
done

#Produce a Python file called analyze_plot.py for the plot.
# Generate analyze_plot.py script
cat > analyze_plot.py << 'EOF'
import numpy as np
import matplotlib.pyplot as plt 

def read_data(filename):
    """
    Reads data from the volume optimization data file.

    Parameters:
    filename (str): The name of the data file.

    Returns:
    tuple: A tuple containing lists of celldm(1) values and corresponding total energies.
    """
    celldm_values = []
    total_energies = []
    with open(filename, 'r') as file:
        next(file)  # Skip the header
        for line in file:
            data = line.split()
            celldm_values.append(float(data[0]))
            total_energies.append(float(data[1]))
    return celldm_values, total_energies

def plot_data(celldm_values, total_energies, convergence_point):
    """
    Plots the total energy as a function of celldm(1) and marks the convergence point.

    Parameters:
    celldm_values (list): List of celldm(1) values.
    total_energies (list): List of total energies.
    convergence_point (tuple): Tuple containing the celldm(1) value and total energy at convergence.
    """
    plt.plot(celldm_values, total_energies, 'o--')

    # Add custom legend entry for converged point
    legend_entry = f'Converged Point\nCelldm(1) = {convergence_point[0]} Bohr \n or {convergence_point[0]/1.88973} Å\nTotal Energy = {convergence_point[1]}'
    plt.legend([legend_entry], loc='upper right')

    plt.xlabel('celldm(1) [Bohr]')
    plt.ylabel('Total Energy [Ry]')
    plt.title('Volume Optimization Convergence')

    plt.grid(True)
    plt.savefig('volume_optimized.pdf')
    plt.show()

def fit_data(celldm_values, total_energies, convergence_point):
    """
    Plots the total energy as a function of celldm(1) and marks the convergence point.

    Parameters:
    celldm_values (list): List of celldm(1) values.
    total_energies (list): List of total energies.
    convergence_point (tuple): Tuple containing the celldm(1) value and total energy at convergence.
    """
    plt.plot(celldm_values, total_energies, 'o')

    # Third order polynomial fit
    coeffs = np.polyfit(celldm_values, total_energies, 3)
    fit_values = np.polyval(coeffs, celldm_values)
    plt.plot(celldm_values, fit_values,'--', label='Fit')

    # Create strings for fitted parameters
    fitted_params_str = '\n'.join([f'$a_{i}$ = {coeffs[i]:.2f}' for i in range(len(coeffs))])

    # Add custom legend entry for fitted parameters
    legend_entry = f'Fitted Parameters:\n{fitted_params_str}'
    plt.legend([legend_entry], loc='upper left', bbox_to_anchor=(1, 1))

    plt.xlabel('celldm(1) [Bohr]')
    plt.ylabel('Total Energy [Ry]')
    plt.title('Volume Optimization Convergence')

    plt.grid(True)
    plt.savefig('volume_optimized_fit.pdf', bbox_inches='tight')
    plt.show()



def find_convergence(celldm_values, total_energies):
    """
    Finds the convergence point in the total energy data.

    Parameters:
    celldm_values (list): List of celldm(1) values.
    total_energies (list): List of total energies.

    Returns:
    tuple: A tuple containing the celldm(1) value and total energy at convergence.
    """
    min_energy_index = np.argmin(total_energies)
    convergence_point = (celldm_values[min_energy_index], total_energies[min_energy_index])
    return convergence_point

# Read data from file
filename = 'volume_optimization_data.txt'
celldm_values, total_energies = read_data(filename)

# Find convergence point
convergence_point = find_convergence(celldm_values, total_energies)

# Plot data and convergence point
plot_data(celldm_values, total_energies, convergence_point)
fit_data(celldm_values, total_energies, convergence_point)
print("Convergence point at celldm(1) =", convergence_point[0], "with Total Energy =", convergence_point[1])
print(f'Converged lattice parameter is: {convergence_point[0]/1.88973} Å')

EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python analyze_plot.py
