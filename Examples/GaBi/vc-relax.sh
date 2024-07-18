#!/bin/bash 

# Get the current working directory and change to it
mkdir geometr
cd /data/girim/Research/GaBi/convergence/geometric_optimize

# Load the Quantum ESPRESSO module
module load qe/7.0

ecutwfc=80
ecut=$(($ecutwfc*9))
k=6
calculation='vc-relax'

cat > vc-relax.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'GaBi'
  outdir = './output/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  disk_io = 'none'
/

&SYSTEM
  degauss = 0.002
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 2
  celldm(1) = 11.7729984
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

&ions
	ion_dynamics = 'bfgs'
/

&cell
    cell_dofree='ibrav'
    cell_dynamics = 'bfgs'
/
ATOMIC_SPECIES
  Bi 208.9804 Bi.rel-pz-dn-rrkjus_psl.1.0.0.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS (crystal)
  Ga 0.0   0.0   0.0
  Bi 0.25  0.25  0.25
EOF

# Run SCF calculation.
mpirun -np 32 pw.x < vc-relax.in > vc-relax.out
rm -r ./output/

#Create a script for sending the email
cat > email_result.sh <<'EOF'
#!/bin/bash
#$ -N SendEmail
#$ -m bea
#$ -M user@domain.com

# Variables
recipient="mohan_giri1@baylor.edu"
subject="Completion of the Run"
body="The job in the HPC has been completed. The results are attached in the compressed file."
attachment="vc-relax.out"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."
EOF

# make executable

chmod +x email_result.sh
#run the executable
./email_result.sh
