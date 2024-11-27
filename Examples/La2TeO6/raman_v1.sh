#!/bin/sh
#PBS -l nodes=4:ppn=32
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

# Create new folder and go to the folder
mkdir raman; cd raman

# Specify the hostfile (optional, if not provided by PBS)
HOSTFILE=$PBS_NODEFILE

# Set the number of processes (total across nodes)
NUM_PROCESSES=128   # Adjust this based on the number of nodes and processors per node

# Dowload the PPS
wget https://pseudopotentials.quantum-espresso.org/upf_files/Te.pz-hgh.UPF
wget https://pseudopotentials.quantum-espresso.org/upf_files/O.pz-hgh.UPF
wget https://pseudopotentials.quantum-espresso.org/upf_files/La.pz-hgh.UPF

ecutwfc=50
ecut=$(($ecutwfc*1))
k=4
calculation='scf'

# ---------------------Create Scf file-------------------------------
cat > scf.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'La2TeO6'
  outdir = './output/'
  pseudo_dir = './'
/

&SYSTEM
  ecutwfc = $ecut
  ibrav                     = 0
  nat                       = 36
  nosym                     = .FALSE.
  ntyp                      = 3
/

&ELECTRONS
    conv_thr         =  1.00000e-09
    electron_maxstep = 80
    mixing_beta      =  4.00000e-01
/


K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_SPECIES
La    138.90547  La.pz-hgh.UPF
O      15.99940  O.pz-hgh.UPF
Te    127.60000  Te.pz-hgh.UPF

CELL_PARAMETERS angstrom
    5.5176897900     0.0000000000     0.0000000000
    0.0000000000     9.4660402200     0.0000000000
    0.0000000000     0.0000000000    10.3804324600


ATOMIC_POSITIONS angstrom
La       2.9020617201     0.9940765923     9.9238833937
La       0.1432168251     3.7389435177     0.4565490663
La       2.6156280699     5.7270967023     5.6467652963
La       5.3744729649     8.4719636277     4.7336671637
La       2.9169119753     2.0605965065     3.7251805382
La       0.1580670803     2.6724236035     6.6552519218
La       2.6007778147     6.7936166165     1.4650356918
La       5.3596227097     7.4054437135     8.9153967682
Te       2.5366206560     9.4307033972     6.6463385558
Te       5.2954655510     4.7683569328     3.7340939042
Te       2.9810691340     4.6976832872     8.9243101342
Te       0.2222242390     0.0353368228     1.4561223258
O        1.6451771207     1.2943736552     1.8194448320
O        4.4040220157     3.4386464548     8.5609876280
O        3.8725126693     6.0273937652     3.3707713980
O        1.1136677743     8.1716665648     7.0096610620
O        3.9520276555     1.0579440604     5.8650919496
O        1.1931827605     3.6750760496     4.5153405104
O        1.5656621345     5.7909641704     9.7055567404
O        4.3245070295     8.4080961596     0.6748757196
O        3.7299152049     6.0071471357     7.7517067955
O        0.9710703099     8.1919131943     2.6287256645
O        1.7877745851     1.2741270257     7.8189418945
O        4.5466194801     3.4588930843     2.5614905655
O        3.6832593857     8.9582725459     8.0945151796
O        0.9244144907     5.2407877841     2.2859172804
O        1.8344304043     4.2252524359     7.4761335104
O        4.5932752993     0.5077676741     2.9042989496
O        1.4013022394     0.7969842636     5.2871354214
O        4.1601471344     3.9360358464     5.0932970386
O        4.1163875506     5.5300043736    10.2835132686
O        1.3575426556     8.6690559564     0.0969191914
O        0.3754797834     6.1189489276     4.9722655559
O        3.1343246784     8.0801114024     5.4081669041
O        5.1422100066     1.3859288176     0.2179506741
O        2.3833651116     3.3470912924    10.1624817859
EOF

# ---------------------------Create ph.in file------------------------------
cat > ph.in << EOF
phonon calc.
&INPUTPH
outdir    = './output/'
prefix    = 'La2TeO6'
fildyn    = 'La2TeO6.dmat'
tr2_ph    = 1d-14,
amass(1)  =  138.90547,
amass(2)  =  15.99940,
amass(3)  =  127.60000,
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
fildyn = 'La2TeO6.dmat'
asr    = 'crystal'
/
EOF

# Run calculation.
mpiexec -bootstrap ssh -np 32 -hostfile $HOSTFILE pw.x < $calculation.in > $calculation.out
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE ph.x < ph.in > ph.out
mpiexec -bootstrap ssh -np $NUM_PROCESSES -hostfile $HOSTFILE dynmat.x < dynmat.in > dynmat.out

#---------------------------Create raman_plots.py-----------------------------
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
#plt.xlim(370, 420)
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

# Exit the folder
cd ..
