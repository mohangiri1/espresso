#!/bin/sh
#PBS -l nodes=1:ppn=32
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
NUM_PROCESSES=32   # Adjust this based on the number of nodes and processors per node

#----------------------Create dynmat.in----------------------------------
cat > raman_plots.py << EOF
import numpy as np

def read_dynmat(filename):
    """
    Reads the dynmat.out file and extracts the relevant data columns.

    Parameters:
        filename (str): Path to the dynmat.out file.

    Returns:
        dict: A dictionary containing the extracted columns as NumPy arrays.
              Keys are ['cm-1', 'THz', 'IR', 'Raman', 'depol_fact'].
    """
    # Initialize lists to hold the data
    cm_1, THz, IR, Raman, depol_fact = [], [], [], [], []

    with open(filename, 'r') as file:
        for line in file:
            if line.startswith("#") or not line.strip():  # Skip headers or empty lines
                continue

            parts = line.split()
            # Ensure the line has the expected number of columns and valid data
            try:
                if len(parts) == 6:
                    cm_1.append(float(parts[1]))
                    THz.append(float(parts[2]))
                    IR.append(float(parts[3]))
                    Raman.append(float(parts[4]))
                    depol_fact.append(float(parts[5]))
            except ValueError:
                # Skip lines that can't be converted to floats
                continue

    # Convert lists to NumPy arrays for efficient computation
    return {
        'cm-1': np.array(cm_1),
        'THz': np.array(THz),
        'IR': np.array(IR),
        'Raman': np.array(Raman),
        'depol_fact': np.array(depol_fact)
    }

# Example usage:
# filename = 'dynmat.out'
# data = read_dynmat(filename)
# print(data['cm-1'])

#The Gaussian function
def gaussian(w, G, w0, I0):
    return I0*np.exp(-((w-w0)/G)**2)


#Fitting with the Gaussian function
def fit(w, G, peak):
    fit = gaussian(w, G, 0, 0)
    for w0, I0 in peak:
        fit = fit + gaussian(w, G, w0, I0)
    return fit
# Example usage:
filename = './dynmat.out'
data = read_dynmat(filename)
wavenumber = data['cm-1']
intensity = data['Raman']

peaks = []
for i in range(len(wavenumber)):
    peaks.append((wavenumber[i], intensity[i])) 

w = np.linspace(min(wavenumber), max(wavenumber) + 100, 500)

import matplotlib.pyplot as plt
# Create figure object
plt.figure()
# Plot the non-resonant Raman
plt.plot(w, fit(w,2, peaks), c='b')
plt.plot(wavenumber, intensity,'o', c='r')
# Add the x and y-axis labels
plt.xlabel('Raman shift (cm$^{-1}$)')
plt.ylabel('Intensity (a.u.)')
# Hide y-axis minor ticks
plt.tick_params(axis='y', which='both', right=False, left=False, labelleft=False)
plt.tick_params(axis='x', which='both', top=False)
# Set the axis limits
plt.xlim(370, 420)
# Save a figure to the pdf file
plt.savefig('plot-raman.pdf')
# Show plot
plt.show()

# For filtered output:
wavenumber = wavenumber[intensity>10]
intensity = intensity[intensity>10]
w = np.linspace(min(wavenumber) - 50, max(wavenumber) + 50, 500)

# Create figure object
plt.figure()
# Plot the non-resonant Raman
plt.plot(w, fit(w,2, peaks), c='b')
plt.plot(wavenumber, intensity,'o', c='r')
# Add the x and y-axis labels
plt.xlabel('Raman shift (cm$^{-1}$)')
plt.ylabel('Intensity (a.u.)')
# Hide y-axis minor ticks
plt.tick_params(axis='y', which='both', right=False, left=False, labelleft=False)
plt.tick_params(axis='x', which='both', top=False)
# Set the axis limits
#plt.xlim(370, 420)
# Save a figure to the pdf file
plt.savefig('filtered_plot-raman.pdf')
# Show plot
plt.show()
EOF
# Plot the Raman
source /home/girim/python_venv/my-python/bin/activate
python raman_plots.py
