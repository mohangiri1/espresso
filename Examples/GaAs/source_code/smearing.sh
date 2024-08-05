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

ecutwfc=80
ecut=$(($ecutwfc*9))
k=8
calculation=scf
celldm1=10.6039256

# Explore the effect of the smearing functions and energies

# Set a variable sf for the smearing functions.
for sf in fd gauss mp mv; do
# Set a variable se for the smearing energies.
for se in 0.005 0.010 0.015 0.020 0.025 0.030 0.035 0.040; do

# Make input file for the scf calculation.
cat > $sf.$se.in << EOF

&CONTROL
  calculation = '$calculation'
  prefix = 'GaAs'
  outdir = './output/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  disk_io = 'none'
/

&SYSTEM
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 2
  celldm(1) = $celldm1
  lspinorb = .TRUE.
  nat = 2
  noncolin = .TRUE.
  ntyp = 2
  occupations = 'smearing'
  smearing = '$sf'
  degauss = $se
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
  $k $k $k 0 0 0

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF

# Run pw.x for SCF calculation.
mpirun -np 32 pw.x <$sf.$se.in> $sf.$se.out

# Write the name of the smearing functions, the smearing energies, and total energies.

awk -v var="$sf" '/!/ {printf"%-6s %1.3f %s\n",var,'$se',$5}' $sf.$se.out >> calc-smearing.dat

# End of for sf loop.
done
# End of for se loop.
done

#Produce a Python file called analyze_plot.py for the plot.
# Generate analyze_plot.py script
cat > analyze_plot.py << 'EOF'
# Import the necessary packages and modules
import matplotlib.pyplot as plt
#plt.style.use('../../matplotlib/sci.mplstyle')

# Open and read the file calc-smearing.dat
f = open('calc-smearing.dat', 'r')
f_smearing = [line for line in f.readlines() if line.strip()]
f.close()

# Number of the smearing functions
nsf = 4
# Number of the values of smearing energy
nse = 8

# Read the smearing energy (se) and total energy (energy) for each smearing function
se = []
ener = []
for i in range(nsf):
    se.append([])
    ener.append([])
    for j in range(nse):
        tmp1 = f_smearing[i*nse+j].split()[1]
        tmp2 = f_smearing[i*nse+j].split()[2]
        se[i].append(float(tmp1))
        ener[i].append(float(tmp2))

# Create figure object
plt.figure()
# Plot the data
plt.plot(se[0], ener[0], 'o-', label='Fermi-Dirac')
plt.plot(se[1], ener[1], 's-', label='Gaussian')
plt.plot(se[2], ener[2], 'v-', label='Methfessel-Paxton')
plt.plot(se[3], ener[3], '^-', label='Marzari-Vanderbilt')

# Add the the legend
plt.legend(loc='lower left')
# Add the x and y-axis labels
plt.xlabel('Smearing energy (Ry)')
plt.ylabel('Total energy (Ry)')
# Set the axis limits
plt.xlim(0.002, 0.042)
plt.ylim(-23.914, -23.908)

# Save a figure to the pdf file
plt.savefig('plot-smearing.pdf')
# Show figure
plt.show()
EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python analyze_plot.py
