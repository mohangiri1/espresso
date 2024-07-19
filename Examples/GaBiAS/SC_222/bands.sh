#!/bin/bash 

# Get the current working directory and change to it
cd /data/girim/Research/GaBiAs/calculation/SC/

# Load the Quantum ESPRESSO module
module load qe/7.0

ecutwfc=80
ecut=$(($ecutwfc*9))
calculation='bands'
k_number=20 # Number of calculating points along the k path
nbnd=200

cat > bands222.in << EOF
&CONTROL
  calculation = $calculation
  prefix = 'GaBiAs'
  outdir = './output_scf222/'
  pseudo_dir = '/data/girim/Research/pseudopotential/LDA/'
  tstress = .true.
  tprnfor = .true.
  restart_mode = 'from_scratch'
/

&SYSTEM
  degauss = 0.002
  ecutrho = $ecut
  ecutwfc = $ecutwfc
  ibrav = 0
  nbnd = $nbnd
  celldm(1) = 21.535684921
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

ATOMIC_SPECIES
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF
  Bi 208.9804 Bi.rel-pz-dn-rrkjus_psl.1.0.0.UPF

K_POINTS {crystal_b}
  5
  0.500 0.500 0.500   $k_number ! L
  0.000 0.000 0.000   $k_number ! G
  0.500 0.000 0.500   $k_number ! X
  0.375 0.375 0.750   $k_number ! K
  0.000 0.000 0.000   $k_number ! G

ATOMIC_POSITIONS (crystal)
Ga            0.0004351364        0.0004351773       -0.0013045725
As            0.1248506272        0.1248505588        0.1251499758
Ga            0.0004356338        0.0004357109        0.5004353281
As            0.1250005455        0.1250004922        0.6250001722
Ga            0.0193975098        0.4935346788       -0.0064654008
As            0.1248508602        0.6251497115        0.1251502325
Ga            0.0004359332        0.4986950949        0.5004355964
As            0.1248510054        0.6251501978        0.6248507677
Ga            0.4935346271        0.0193975593       -0.0064654198
As            0.6251497669        0.1248508441        0.1251502239
Ga            0.4986950343        0.0004359892        0.5004356122
As            0.6251502636        0.1248509403        0.6248507807
Ga            0.4935349333        0.4935349598       -0.0064651023
Bi            0.6250004816        0.6250004778        0.1250008796
Ga            0.4935350624        0.4935351331        0.5193978512
As            0.6251505793        0.6251504742        0.6248510750

CELL_PARAMETERS {alat}
 -0.500000   0.000000   0.500000
  0.000000   0.500000   0.500000
 -0.500000   0.500000   0.000000

EOF

# Run SCF calculation.
mpirun -np 32 pw.x < bands222.in > bands222.out

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
attachment="bands222.out"

# Send email
echo -e "$body" | /usr/bin/mail -s "$subject" -a "$attachment" "$recipient"

echo "Email has been sent to Mohan."
EOF

# make executable

chmod +x email_result.sh
#run the executable
./email_result.sh
