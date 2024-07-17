#!/bin/bash 

# Get the current working directory and change to it
cd /data/girim/Research/GaAs/calculation/BC/

# Load the Quantum ESPRESSO module
module load qe/7.0

# store figure in figure folder
mkdir figure

#Set the sci.mplstyle for plotting the result in matplotlib.------------------------------------------------------------------
cat > sci.mplstyle << EOF
# Figure properties
figure.figsize     : 6.5, 5

# Font properties
font.family        : Arial
font.size          : 22

#### LaTeX
mathtext.default   : regular

# Axes properties
axes.titlesize     : medium  # fontsize of the axes title
axes.titlepad      : 10      # pad between axes and title in points
axes.titleweight   : normal  # font weight for axes title
axes.linewidth     : 2       # edge linewidth
axes.labelpad      : 10      # space between label and axis
axes.prop_cycle    : cycler(color=['1f77b4', 'd62728', '2ca02c', 'ff7f0e', '9467bd', '8c564b', 'e377c2', '7f7f7f', 'bcbd22', '17becf'])

# Tick properties
# x-axis
xtick.top          : True
xtick.direction    : in
xtick.major.size   : 9
xtick.major.width  : 2
xtick.major.pad    : 4
xtick.minor.visible: True
xtick.minor.size   : 6
xtick.minor.width  : 2
xtick.minor.pad    : 4

# y-axis
ytick.right        : True
ytick.direction    : in
ytick.major.size   : 9
ytick.major.width  : 2
ytick.major.pad    : 4
ytick.minor.visible: True
ytick.minor.size   : 6
ytick.minor.width  : 2
ytick.minor.pad    : 4

# Line properties
lines.linewidth    : 2
lines.markersize   : 10

# Legend properties
legend.framealpha  : 1
legend.frameon     : False
legend.fontsize    : 19

# Increase the default DPI, and change the file type from png to pdf 
savefig.dpi        : 600      # figure dots per inch
savefig.format     : pdf      # png, ps, pdf, svg
savefig.bbox       : tight    # {tight, standard}
savefig.transparent: True     # transparent background
EOF

# -----------------------Setting the general parameters for the calculation common to all-------------------------------------
ecutwfc=80
ecut=$(($ecutwfc*9))
celldm1=10.6039256
prefix='GaAs'

# ----------------------------Perform Scf Calculation ----------------------scf---------------------------------
k=8
calculation=scf
cat > $calculation.in << EOF
&CONTROL
  calculation = $calculation
  prefix = $prefix
  outdir = './output/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  verbosity = 'high'
/

&SYSTEM
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  celldm(1) = $celldm1
  ibrav = 2
  nat = 2
  ntyp = 2
  occupations = 'smearing'
  smearing = 'gaussian'
  degauss = 0.002
  noncolin = .TRUE.
  lspinorb = .TRUE.
  nosym = .true.
  starting_magnetization(1) = 0.0000e+00
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

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF

# Run SCF calculation.
mpirun -np 32 pw.x < $calculation.in > $calculation.out
cp $calculation.out ./figure/$calculation.out

#Produce a Python file called $calculation.py for the plot.
# Generate $calculation.py script
cat > $calculation.py << EOF
import re
import matplotlib.pyplot as plt
plt.style.use('sci.mplstyle')

def extract_iteration_numbers(filename):
    iteration_numbers = []
    with open(filename, 'r') as file:
        for line in file:
            if 'iteration # ' in line:
                iteration_match = re.search(r'iteration #\s+(\d+)', line)
                if iteration_match:
                    iteration_numbers.append(int(iteration_match.group(1)))
    return iteration_numbers

def extract_total_cpu_time(filename):
    cpu_times = []
    with open(filename, 'r') as file:
        for line in file:
            if 'total cpu time spent up to now is' in line:
                cpu_time_match = re.search(r'total cpu time spent up to now is\s+(\d+\.\d+)', line)
                if cpu_time_match:
                    cpu_times.append(float(cpu_time_match.group(1)))
    cpu_times = cpu_times[1:]
    return cpu_times

def extract_total_energy(filename):
    total_energies = []
    with open(filename, 'r') as file:
        for line in file:
            if 'total energy' in line:
                energy_match = re.search(r'total energy\s*=\s*(-?\d+\.\d+)', line)
                if energy_match:
                    total_energies.append(float(energy_match.group(1)))
    #total_energies.append(total_energies[-1])
    return total_energies

def extract_scf_accuracy(filename):
    scf_accuracies = []
    with open(filename, 'r') as file:
        for line in file:
            if 'estimated scf accuracy' in line:
                accuracy_match = re.search(r'estimated scf accuracy\s*<\s*(-?\d+(\.\d*)?(E[-+]?\d+)?)', line)
                if accuracy_match:
                    scf_accuracies.append(float(accuracy_match.group(1)))
    return scf_accuracies


def plot_values(iteration_numbers, cpu_times, total_energies, scf_accuracies):
    plt.figure(figsize=(12, 8))

    # Plot iteration numbers vs CPU time
    plt.subplot(221)
    plt.plot(iteration_numbers, cpu_times, marker='o', linestyle='-', color='b')
    plt.title('Iteration vs CPU Time')
    plt.xlabel('Iteration Number')
    plt.ylabel('CPU Time (secs)')

    # Plot iteration numbers vs Total Energy
    plt.subplot(222)
    plt.plot(iteration_numbers, total_energies, marker='o', linestyle='-', color='r')
    plt.title('Iteration vs Total Energy')
    plt.xlabel('Iteration Number')
    plt.ylabel('Total Energy (Ry)')
    plt.ticklabel_format(style='plain', axis='y')  # Display y-axis ticks in plain format
    
    # Plot iteration numbers vs SCF Accuracy
    plt.subplot(223)
    plt.plot(iteration_numbers, scf_accuracies, marker='o', linestyle='-', color='g')
    plt.title('Iteration vs SCF Accuracy')
    plt.xlabel('Iteration Number')
    plt.ylabel('SCF Accuracy (Ry)')

    plt.tight_layout()
    filename = '$calculation' + '_convergence.pdf'
    plt.savefig('./figure/' + filename)
    plt.show()

def main(filename):
    # Extract values
    iteration_numbers = extract_iteration_numbers(filename)
    print('Iteration Numbers: ', iteration_numbers)
    cpu_times = extract_total_cpu_time(filename)
    total_energies = extract_total_energy(filename)
    print('Total Energy: ', total_energies)
    scf_accuracies = extract_scf_accuracy(filename)
    print('scf accuracy: ', scf_accuracies)

    # Plot values
    plot_values(iteration_numbers, cpu_times, total_energies, scf_accuracies)

if __name__ == "__main__":
    filename = '$calculation' + '.out'  # Replace with your actual filename
    main(filename)

EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python $calculation.py

#Copy the pure scf calculation output in a directory called 'output_scf'
cp -r output output_$calculation

# Perform nscf Calculation----------------------------nscf--------------------------------------------------------------
#calculation, occupations and k are to be changed in nscf calculation.
calculation=nscf
occupations='tetrahedra'
k=8
cat > $calculation.in << EOF
&CONTROL
  calculation = $calculation
  prefix = $prefix
  outdir = './output/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  verbosity = 'high'
/

&SYSTEM
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  celldm(1) = $celldm1
  ibrav = 2
  nat = 2
  ntyp = 2
  occupations = $occupations
  smearing = 'gaussian'
  degauss = 0.002
  noncolin = .TRUE.
  lspinorb = .TRUE.
  nosym = .true.
  starting_magnetization(1) = 0.0000e+00
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

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF

# Run nSCF calculation.
mpirun -np 32 pw.x < $calculation.in > $calculation.out
#Copy the pure scf calculation output in a directory called 'output_scf'
cp -r output output_$calculation


#-----------------------------dos calculation ---------------------------------------------------
cat > dos.in <<EOF
&dos
	DeltaE = 0.1
	emax = 20
	emin = -20
	prefix = $prefix
 	outdir      = './output/'
/
EOF
# Run the dos calculation
dos.x <dos.in > dos.out

#------------------------------------------PDOS------------------------------------------
cat > pdos.in <<EOF
&projwfc
	DeltaE = 0.1
	emax = 20
	emin = -20
	prefix = 'GaAs'
	filproj = $prefix
 	outdir      = './output/'
/
EOF

#Run projected dos calculation
projwfc.x <pdos.in> pdos.out
cp pdos.out ./figure/pdos.out

#summing for the Ga s orbital:
sumpdos.x *\(Ga\)*\(s_j*\) > atom_Ga_s.dat
cp atom_Ga_s.dat ./figure/atom_Ga_s.dat

#summing for the Ga p orbital:
sumpdos.x *\(Ga\)*\(p_j*\) > atom_Ga_p.dat
cp atom_Ga_p.dat ./figure/atom_Ga_p.dat

#summing for the Ga d orbital:
sumpdos.x *\(Ga\)*\(d_j*\) > atom_Ga_d.dat
cp atom_Ga_d.dat ./figure/atom_Ga_d.dat

#summing for the As s orbital:
sumpdos.x *\(As\)*\(s_j*\) > atom_As_s.dat
cp atom_As_s.dat ./figure/atom_As_s.dat

#summing for the As p orbital:
sumpdos.x *\(As\)*\(p_j*\) > atom_As_p.dat
cp atom_As_p.dat ./figure/atom_As_p.dat

#---------------------------------plot Dos--------------------------------------------------------------------------------------
cat > dos_pdos_plot.py <<EOF
#Projected Dos:

import matplotlib.pyplot as plt
import numpy as np
plt.style.use('sci.mplstyle')

def read_data_dos(file_path):
    """
    Reads data from a file and returns energy, dos, idos, and Fermi energy.

    Args:
    file_path (str): Path to the data file.

    Returns:
    energy (array): Energy values.
    dos (array): DOS values.
    idos (array): Integrated DOS values.
    fermi_energy (float): Fermi energy.
    """
    with open(file_path, 'r') as file:
        for line in file:
            if 'EFermi' in line:
                fermi_energy = float(line.split('=')[1].strip().split()[0])
                break
    energy, dos, idos = np.loadtxt(file_path, unpack=True, skiprows=1)
    energy -= fermi_energy
    return energy, dos, idos, fermi_energy

def read_data_fermiEnergy(file_path_dos):
    """
    Read the Fermi energy from a DOS (Density of States) data file.

    Args:
    file_path_dos (str): Path to the file containing DOS data.

    Returns:
    fermi_energy (float): Fermi energy extracted from the file.
    """
    with open(file_path_dos, 'r') as file:
        for line in file:
            if 'EFermi' in line:
                fermi_energy = float(line.split('=')[1].strip().split()[0])
                break
    return fermi_energy


def read_data(file_path_pdos, fermi_energy):
    """
    Read PDOS (Projected Density of States) data from a file and adjust the energy values.

    Args:
    file_path_pdos (str): Path to the file containing PDOS data.
    fermi_energy (float): Fermi energy used for adjusting the energy values.

    Returns:
    energy (array): Adjusted energy values relative to the Fermi energy.
    pdos (array): PDOS values.
    """
    energy, pdos = np.loadtxt(file_path_pdos, unpack=True, skiprows=1)
    energy -= fermi_energy
    return energy, pdos

def plot_dos(energy, dos, fermi_energy):
    """
    Plots Density of States (DOS) with respect to energy.

    Args:
    energy (array): Energy values.
    dos (array): DOS values.
    fermi_energy (float): Fermi energy.
    """
    plt.figure(figsize=(12, 6))
    plt.plot(energy, dos, linewidth=0.75, color='red', label = 'Total dos')
    #plt.yticks([])
    plt.xlabel(r'$E - E_f$ [eV]')
    plt.ylabel('DOS [States/eV]')
    #plt.axvline(x=0, linewidth=0.5, color='k', linestyle=(0, (8, 10)))
    plt.ylim(0, 5)
    plt.fill_between(energy, 0, dos, where=(energy < 0), facecolor='red', alpha=0.25)
    #plt.text(0, 1.7, 'Fermi energy', rotation=90)
    #plt.title('Density of States')
    plt.xlim(min(energy), max(energy))
    plt.xlim(-17,10)
    plt.legend()
    plt.savefig('./figure/dos_total.pdf')
    plt.show()

def Ga_s_p_pdos(Ga_s, Ga_p, fermi_energy):
    """
    Plot the Projected Density of States (PDOS) for Ga atoms, considering s and p orbitals.

    Args:
    Ga_s (str): Path to the file containing Ga s PDOS data.
    Ga_p (str): Path to the file containing Ga p PDOS data.
    fermi_energy (float): Fermi energy.

    Returns:
    None
    """
    plt.figure(figsize=(12, 6))
    
    # Plot Ga s PDOS
    energy, pdos = read_data(Ga_s, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='red', label='Ga s')

    # Plot Ga p PDOS
    energy, pdos = read_data(Ga_p, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='black', label='Ga p')
    
    #plt.yticks([])
    plt.xlabel(r'$E - E_f$ [eV]')
    plt.ylabel('PDOS [States/eV]')
    plt.ylim(0, )
    plt.legend()
    plt.savefig('./figure/Ga_s_p_pdos.pdf')
    plt.show()
    
def Ga_d_pdos(Ga_d, fermi_energy):
    """
    Plot the Projected Density of States (PDOS) for Ga atoms, considering d orbitals.

    Args:
    Ga_d (str): Path to the file containing Ga d PDOS data.
    fermi_energy (float): Fermi energy.

    Returns:
    None
    """
    plt.figure(figsize=(12, 6))

    energy, pdos = read_data(Ga_d, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='blue', label='Ga d')

    #plt.yticks([])
    plt.xlabel(r'$E - E_f$ [eV]')
    plt.ylabel('PDOS [States/eV]')
    plt.ylim(0, )
    plt.legend()
    plt.savefig('./figure/Ga_d_pdos.pdf')
    plt.show()
    
def Ga_s_p_d_pdos(Ga_s, Ga_p, Ga_d, fermi_energy):
    """
    Plot the Projected Density of States (PDOS) for Ga atoms, considering s, p, and d orbitals.

    Args:
    Ga_s (str): Path to the file containing Ga s PDOS data.
    Ga_p (str): Path to the file containing Ga p PDOS data.
    Ga_d (str): Path to the file containing Ga d PDOS data.
    fermi_energy (float): Fermi energy.

    Returns:
    None
    """
    plt.figure(figsize=(12, 6))
    
    # Plot Ga s PDOS
    energy, pdos = read_data(Ga_s, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='red', label='Ga s')

    # Plot Ga p PDOS
    energy, pdos = read_data(Ga_p, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='black', label='Ga p')
    
    # Plot Ga d PDOS
    energy, pdos = read_data(Ga_d, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='blue', label='Ga d')
    
    #plt.yticks([])
    plt.xlabel(r'$E - E_f$ [eV]')
    plt.ylabel('PDOS [States/eV]')
    plt.ylim(0, )
    plt.legend()
    plt.savefig('./figure/Ga_s_p_d_pdos.pdf')
    plt.show()
    
def As_s_p_pdos(As_s, As_p, fermi_energy):
    """
    Plot the Projected Density of States (PDOS) for As atoms, considering s and p orbitals.

    Args:
    As_s (str): Path to the file containing As s PDOS data.
    As_p (str): Path to the file containing As p PDOS data.
    fermi_energy (float): Fermi energy.

    Returns:
    None
    """
    plt.figure(figsize=(12, 6))
    
    # Plot As s PDOS
    energy, pdos = read_data(As_s, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='red', label='As s')

    # Plot As p PDOS
    energy, pdos = read_data(As_p, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='black', label='As p')
    
    #plt.yticks([])
    plt.xlabel(r'$E - E_f$ [eV]')
    plt.ylabel('PDOS [States/eV]')
    plt.ylim(0, )
    plt.legend()
    plt.savefig('./figure/As_s_p_pdos.pdf')
    plt.show()
    
def GaAs_s_p_pdos(Ga_s, Ga_p, As_s, As_p, fermi_energy):
    """
    Plot the Projected Density of States (PDOS) for Ga and As atoms, considering s and p orbitals.

    Args:
    Ga_s (str): Path to the file containing Ga s PDOS data.
    Ga_p (str): Path to the file containing Ga p PDOS data.
    As_s (str): Path to the file containing As s PDOS data.
    As_p (str): Path to the file containing As p PDOS data.
    fermi_energy (float): Fermi energy.

    Returns:
    None
    """
    plt.figure(figsize=(12, 6))
    
    # Plot Ga s PDOS
    energy, pdos = read_data(Ga_s, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='red', label='Ga s')

    # Plot Ga p PDOS
    energy, pdos = read_data(Ga_p, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='black', label='Ga p')
    
    # Plot As s PDOS
    energy, pdos = read_data(As_s, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='green', label='As s')

    # Plot As p PDOS
    energy, pdos = read_data(As_p, fermi_energy)
    plt.plot(energy, pdos, linewidth=0.75, color='blue', label='As p')
    
    #plt.yticks([])
    plt.xlabel(r'$E - E_f$ [eV]')
    plt.ylabel('PDOS [States/eV]')
    plt.ylim(0, )
    plt.legend()
    plt.savefig('./figure/GaAs_s_p_pdos.pdf')
    plt.show()
    
def pdos_dos(pdos_tot, fermi_energy):
    """
    Plot the Total Density of States (DOS) and Total Projected Density of States (PDOS).

    Args:
    pdos_tot (str): Path to the file containing total PDOS data.
    fermi_energy (float): Fermi energy.

    Returns:
    None
    """
    energy, dos, pdos = np.loadtxt(pdos_tot, unpack = True)
    energy -= fermi_energy
    plt.figure(figsize=(12, 6))
    plt.plot(energy, dos, linewidth=0.75, color='red', label = 'Total dos')
    plt.plot(energy, pdos, linewidth=0.75, color='blue', label = 'Total pdos')
    #plt.yticks([])
    plt.xlabel(r'$E - E_f$ [eV]')
    plt.ylabel('DOS [States/eV]')
    #plt.axvline(x=0, linewidth=0.5, color='k', linestyle=(0, (8, 10)))
    plt.ylim(0, )
    plt.fill_between(energy, 0, dos, where=(energy < 0), facecolor='red', alpha=0.25)
    #plt.text(0, 1.7, 'Fermi energy', rotation=90)
    #plt.title('Density of States')
    plt.xlim(min(energy), max(energy))
    plt.xlim(-17,10)
    plt.legend()
    plt.savefig('./figure/pdos_dos.pdf')
    plt.show()

# Example usage:
#Total Dos
file_path_dos = 'GaAs.dos'
energy, dos, idos, fermi_energy = read_data_dos(file_path_dos)
plot_dos(energy, dos, fermi_energy)

#Pdos of Ga in GaAs
Ga_s = 'atom_Ga_s.dat'
Ga_p = 'atom_Ga_p.dat'
Ga_d = 'atom_Ga_d.dat'
fermi_energy = read_data_fermiEnergy(file_path_dos)
Ga_s_p_pdos(Ga_s, Ga_p, fermi_energy)
Ga_d_pdos(Ga_d, fermi_energy)
Ga_s_p_d_pdos(Ga_s, Ga_p, Ga_d, fermi_energy)

#Pdos of As in GaAs
As_p = 'atom_As_p.dat'
As_s = 'atom_As_s.dat'
As_s_p_pdos(As_s, As_p, fermi_energy)

#Pdos of Ga and As in GaAs
GaAs_s_p_pdos(Ga_s, Ga_p, As_s, As_p, fermi_energy)

#Total Pdos and Total Dos in GaAs
pdos_tot = 'GaAs.pdos_tot'
pdos_dos(pdos_tot, fermi_energy)
EOF

# Plot the dos
source /home/girim/python_venv/my-python/bin/activate
python dos_pdos_plot.py

#------------------------------------------bands calculation ---------------------------------------------------------------------
#calculation, occupations and k for k path are to be changed in nscf calculation.
calculation=bands
occupations='smearing'
k_number=20 # Number of calculating points along the k path
nbnd=26
cat > $calculation.in << EOF
&CONTROL
  calculation = $calculation
  prefix = $prefix
  outdir = './output/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  verbosity = 'high'
/

&SYSTEM
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  celldm(1) = $celldm1
  ibrav = 2
  nat = 2
  ntyp = 2
  nbnd = $nbnd
  occupations = $occupations
  smearing = 'gaussian'
  degauss = 0.002
  noncolin = .TRUE.
  lspinorb = .TRUE.
  nosym = .true.
  starting_magnetization(1) = 0.0000e+00
/

&ELECTRONS
  conv_thr = 1e-08
  electron_maxstep = 80
  mixing_beta = 0.3
/

ATOMIC_SPECIES
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF

K_POINTS {crystal_b}
  5
  0.500 0.500 0.500   $k_number ! L
  0.000 0.000 0.000   $k_number ! G
  0.500 0.000 0.500   $k_number ! X
  0.375 0.375 0.750   $k_number ! K
  0.000 0.000 0.000   $k_number ! G

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF

# Run bands calculation.
mpirun -np 32 pw.x < $calculation.in > $calculation.out
cp $calculation.out ./figure/$calculation.out
#Copy the pure bands calculation output in a directory called 'output_scf'
cp -r output output_$calculation

#-----------------------------------bands post processing ---bands.kp.in----------------------------------
cat > bands.kp.in <<EOF
 &bands
    prefix  = 'GaAs'
    filband = 'bands.dat'
    outdir      = './output/'
 /
EOF
# Run the bands.x executable
mpirun -np 32 bands.x < bands.kp.in > bands.kp.out
cp bands.kp.out ./figure/bands.kp.out

#--------------------------plot band structure-----------------------------------------------------------------
#Produce a Python file called bands.py for the plot.
# Generate bands.py script
cat > $calculation.py << EOF
import matplotlib.pyplot as plt
import numpy as np
plt.style.use('sci.mplstyle')

def symmetry_point_k_pos(bands_kp_out_file: str):
    ''' 
    Reads the .bands.kp.out file and searches the k values of the high symmetry points and returns
    
    input: 
        bands_kp_out_file (str): Filename of the post processed output.
                                example: GaAs.bands.kp.out
                                
    returns:
        symmetry_coordinates (list)
        
    
    '''

    # Initialize an empty list to store the x-coordinate values
    symmetry_coordinates = []

    # Open the file and read its contents
    with open(bands_kp_out_file, 'r') as file:
        # Iterate over each line in the file
        for line in file:
            # Check if the line contains the "high-symmetry point" information
            if 'high-symmetry point' in line:
                # Split the line into parts based on whitespace
                parts = line.split()
                # Extract the x-coordinate value (the last part of the line)
                x_coordinate = float(parts[-1])
                # Append the x-coordinate value to the symmetry_coordinates list
                symmetry_coordinates.append(x_coordinate)

    # Print the extracted symmetry coordinates
    #print(symmetry_coordinates)
    
    return symmetry_coordinates

def fermi_energy_finder(scf_out_file: str) -> float:
    """
    Find the Fermi energy value from the SCF output file.

    Parameters:
        scf_out_file (str): File path to the SCF output file.

    Returns:
        float: Fermi energy value.
    """
    fermi_energy = None
    with open(scf_out_file, 'r') as file:
        for line in file:
            if 'highest occupied level' in line:
                fermi_energy = float(line.split()[4])
                break
                
            if 'the Fermi energy is' in line:
                fermi_energy = float(line.split()[4])
                break
    return fermi_energy

def load_bands_data(bands_data_file: str):
    """
    Load bands data from a file.

    Parameters:
        bands_data_file (str): The file path to the bands data.

    Returns:
        tuple: A tuple containing two numpy arrays:
            - k (np.ndarray): Array of unique k-values.
            - bands (np.ndarray): Array of band energies reshaped as (num_bands, num_k_points).
    """
    # Load data
    data = np.loadtxt(bands_data_file)

    k = np.unique(data[:, 0])
    bands = np.reshape(data[:, 1], (-1, len(k)))
    
    return k, bands

def band_structure_plot(bands_kp_out_file: str
                        , bands_data_file: str
                        , labels: list
                        , output_figure_name: str
                        , scf_out_file: str):
    """
    Plot the band structure from bands data and high-symmetry k-points.

    Parameters:
        bands_kp_out_file (str): File path to the file containing high-symmetry k-points.
        bands_data_file (str): File path to the bands data file.
        labels (list): List of labels for high-symmetry k-points.
        output_figure_name (str): Output file name for the figure.
        scf_out_file (str): File path to the SCF output file.

    Returns:
        None
    """

    plt.rcParams["figure.dpi"] = 150
    plt.rcParams["figure.facecolor"] = "white"
    plt.rcParams["figure.figsize"] = (8, 6)

    # Initialize an empty list to store the x-coordinate values
    symmetry_coordinates = symmetry_point_k_pos(bands_kp_out_file)

    k, bands = load_bands_data(bands_data_file)
    
    fermi_energy = fermi_energy_finder(scf_out_file)
    #fermi energy is subtracted from the file to rescale energy in terms of fermi energy.
    for band in range(len(bands)):
        plt.plot(k, bands[band, :] - fermi_energy, linewidth=1, alpha=0.5, color='k')
    plt.xlim(min(k), max(k))
    #plt.ylim(-0.3,0.3)

    # Plot vertical lines for high-symmetry k-points
    for point in symmetry_coordinates:
        plt.axvline(point, linewidth=0.75, color='k', alpha=0.5)

    # Text labels
    plt.xticks(ticks=symmetry_coordinates, labels=labels)
    plt.ylabel("Energy (eV)")
    
    # Fermi energy horizontal line
    plt.axhline(fermi_energy - fermi_energy, linestyle=(0, (5, 5)), linewidth=0.75, color='k', alpha=0.5)
    
#    # Adding text at Fermi level line
#    text_x_position = min(k) + 0.05 * (max(k) - min(k))  # Adjust 0.02 to change the position of the text
#
#    plt.text(text_x_position, fermi_energy, '$E_f$', ha='left', va='center', fontsize=8)


    plt.savefig(f'./figure/{output_figure_name}.pdf')
    plt.show()
    
labels=['L', '$\Gamma$', 'X', 'K', '$\Gamma$']
output_figure_name = 'GaAs_bandstructure'
fermi_energy = 0.1
# Define the file path
bands_kp_out_file = 'bands.kp.out'
bands_data_file = 'bands.dat.gnu'
scf_out_file = 'scf.out'

band_structure_plot(bands_kp_out_file
                        , bands_data_file
                        , labels
                        , output_figure_name
                        , scf_out_file)
EOF
    
# Plot the bandstructure
source /home/girim/python_venv/my-python/bin/activate
python $calculation.py

# Compress the figures and the results.
tar -czvf results.tar.gz figure

#!/bin/bash
#$ -N SendEmail
#$ -m bea
#$ -M user@domain.com

# Variables
recipient="mohan_giri1@baylor.edu"
subject="Completion of the Run"
body="The job in the HPC has been completed. The results are attached in the compressed file."
attachment="results.tar.gz"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."

