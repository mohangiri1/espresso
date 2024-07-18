#!/bin/bash 

# Get the current working directory and change to it
cd /data/girim/Research/GaBiAs/calculation/SC/

# Load the Quantum ESPRESSO module
module load qe/7.0

ecutwfc=80
ecut=$(($ecutwfc*9))
k=4
calculation='vc-relax'

cat > vc-relax222.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'GaBiAs'
  outdir = './output_vc222/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  disk_io = 'none'
  tstress = .true.
  tprnfor = .true.
  restart_mode = 'from_scratch'
/

&SYSTEM
  degauss = 0.002
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 0
  celldm(1) = 21.2078512
  lspinorb = .TRUE.
  nat = 16
  noncolin = .TRUE.
  ntyp = 3
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
    cell_dofree='all'
    cell_dynamics = 'bfgs'
/
ATOMIC_SPECIES
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF
  Bi 208.9804 Bi.rel-pz-dn-rrkjus_psl.1.0.0.UPF

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS {crystal}
Ga      0.000000   0.000000   0.000000
As      0.125000   0.125000   0.125000
Ga      0.000000   0.000000   0.500001
As      0.125000   0.125000   0.625001
Ga      0.000000   0.500001   0.000000
As      0.125000   0.625001   0.125000
Ga      0.000000   0.500001   0.500001
As      0.125000   0.625001   0.625001
Ga      0.500001   0.000000   0.000000
As      0.625001   0.125000   0.125000
Ga      0.500001   0.000000   0.500001
As      0.625001   0.125000   0.625001
Ga      0.500001   0.500001   0.000000
Bi      0.625001   0.625001   0.125000
Ga      0.500001   0.500001   0.500001
As      0.625001   0.625001   0.625001

CELL_PARAMETERS {alat}
 -0.500000   0.000000   0.500000
  0.000000   0.500000   0.500000
 -0.500000   0.500000   0.000000

EOF

# Run SCF calculation.
mpirun -np 32 pw.x < vc-relax222.in > vc-relax222.out

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
attachment="vc-relax222.out"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."
EOF

# make executable

chmod +x email_result.sh
#run the executable
./email_result.sh
