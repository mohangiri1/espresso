
#!/bin/bash

# Get the current working directory and change to it
cd /data/girim/Research/GaAs/convergence/geometric_optimize/

# Load the Quantum ESPRESSO module
module load qe/7.0

ecut=80
ecutrho=$(($ecut*9))
k=4
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
  outdir = './output/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
/

&SYSTEM
  degauss = 0.002
  ecutrho = $ecutrho
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
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  As 0.25  0.25  0.25
EOF

    # Run Quantum ESPRESSO
    pw.x < celldm${percent_change}.in > "celldm${percent_change}.out"

    # Extract total energy from output file
    total_energy=$(grep -m 1 "!" "celldm${percent_change}.out" | awk '{print $5}')

    # Append celldm(1) and total energy to data file
    echo "$new_celldm $total_energy" >> volume_optimization_data.txt
done
