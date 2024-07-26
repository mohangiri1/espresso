#!/bin/sh
#PBS -l nodes=1:ppn=32
#PBS -o 3Bi.out
#PBS -e 3Bi.err
#PBS -N 3Bi
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
k=2
calculation='scf'

cat > scf444_3Bi.in << EOF
&CONTROL
  calculation = '$calculation'
  prefix = 'GaBiAs'
  outdir = './output_scf444_3Bi/'
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
  celldm(1) = 42.652710487
  ntyp = 3
  nat = 128
  lspinorb = .TRUE.
  noncolin = .TRUE.
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

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS {crystal}
Ga            0.0002723398        0.0002723369       -0.0004598155
As            0.0623520311        0.0623520274        0.0625244538
Ga           -0.0000573376       -0.0000573396        0.2497905033
As            0.0622297244        0.0622297260        0.3127507742
Ga           -0.0000476333       -0.0000476264        0.5003292989
As            0.0625514895        0.0625514875        0.5625865604
Ga            0.0002880473        0.0002880531        0.7498733508
As            0.0627792947        0.0627792948        0.8122514071
Ga            0.0001114746        0.2484711739       -0.0000723047
As            0.0597631427        0.3125216333        0.0623863440
Ga            0.0001767084        0.2495324041        0.2500338517
As            0.0596518254        0.3124712939        0.3153243011
Ga           -0.0014240852        0.2499736762        0.5014802961
As            0.0624771815        0.3123601557        0.5626715401
Ga            0.0000307385        0.2503462658        0.7499005617
As            0.0626252490        0.3123483310        0.8125166370
Ga            0.0016553911        0.5002043867       -0.0010668952
As            0.0619956894        0.5624860463        0.0629563205
Ga            0.0001503741        0.5001444704        0.2507401569
As            0.0623933539        0.5624593407        0.3131338953
Ga           -0.0002639219        0.4997339225        0.5005466216
As            0.0622991360        0.5626713618        0.5623271193
Ga            0.0012425345        0.4997360750        0.7484762570
As            0.0626521389        0.5623310871        0.8119538190
Ga            0.0123520749        0.7470964350       -0.0047268975
As            0.0652194277        0.8127950658        0.0624307253
Ga            0.0003219380        0.7497315868        0.2500871161
As            0.0624775848        0.8125243815        0.3126106174
Ga            0.0000330052        0.7500159797        0.4999740215
As            0.0625689017        0.8124383729        0.5624410017
Ga            0.0005301350        0.7495203408        0.7498524410
As            0.0652704952        0.8127282522        0.8095337191
Ga            0.2484711778        0.0001114761       -0.0000723076
As            0.3125216341        0.0597631433        0.0623863467
Ga            0.2495324011        0.0001767072        0.2500338544
As            0.3124712985        0.0596518230        0.3153242962
Ga            0.2499736748       -0.0014240865        0.5014802946
As            0.3123601516        0.0624771849        0.5626715396
Ga            0.2503462660        0.0000307370        0.7499005636
As            0.3123483365        0.0626252486        0.8125166346
Ga            0.2454181708        0.2454181667       -0.0044866407
Bi            0.3123991155        0.3123991134        0.0624979901
Ga            0.2454052697        0.2454052678        0.2634799910
As            0.3122967521        0.3122967535        0.3155202883
Ga            0.2499595984        0.2499596038        0.5017559522
As            0.3126882386        0.3126882384        0.5624788879
Ga            0.2499524928        0.2499524943        0.7485261746
As            0.3125636049        0.3125636029        0.8096498962
Ga            0.2455752763        0.5124820811       -0.0048375411
As            0.3099513256        0.5653547334        0.0625196938
Ga            0.2496379210        0.4997451732        0.2504433217
As            0.3095729120        0.5626335033        0.3152969905
Ga            0.2485357168        0.5000275835        0.5014654956
As            0.3124776235        0.5624073165        0.5625767103
Ga            0.2497223956        0.5003413607        0.7498208084
As            0.3127664081        0.5651276632        0.8094580406
Ga            0.2514836020        0.7517077274       -0.0006209514
As            0.3094693773        0.8151989406        0.0630652089
Ga            0.2498704141        0.7502409668        0.2504374156
As            0.3120902609        0.8126589442        0.3129106107
Ga            0.2499453487        0.7497381642        0.5002551065
As            0.3125086875        0.8124619824        0.5621248453
Ga            0.2514475849        0.7512613046        0.7470775781
As            0.3122283114        0.8127835936        0.8122148397
Ga            0.5002043847        0.0016553935       -0.0010668950
As            0.5624860451        0.0619956882        0.0629563240
Ga            0.5001444719        0.0001503724        0.2507401531
As            0.5624593343        0.0623933522        0.3131338998
Ga            0.4997339177       -0.0002639170        0.5005466265
As            0.5626713580        0.0622991354        0.5623271215
Ga            0.4997360779        0.0012425292        0.7484762626
As            0.5623310869        0.0626521341        0.8119538249
Ga            0.5124820818        0.2455752752       -0.0048375459
As            0.5653547310        0.3099513187        0.0625196996
Ga            0.4997451694        0.2496379198        0.2504433244
As            0.5626335020        0.3095729088        0.3152969869
Ga            0.5000275871        0.2485357127        0.5014654960
As            0.5624073135        0.3124776265        0.5625767081
Ga            0.5003413682        0.2497223888        0.7498208045
As            0.5651276604        0.3127664108        0.8094580397
Ga            0.4956669782        0.4956669708       -0.0049521490
Bi            0.5626751161        0.5626751081        0.0622266775
Ga            0.4954039020        0.4954038964        0.2634155663
As            0.5622922656        0.5622922693        0.3155512771
Ga            0.4999387160        0.4999387157        0.5018160423
As            0.5627434788        0.5627434855        0.5623850415
Ga            0.5002944968        0.5002944958        0.7483980327
As            0.5628337192        0.5628337244        0.8094004735
Ga            0.4938720784        0.7638896785       -0.0046816159
As            0.5598011586        0.8152049629        0.0626004602
Ga            0.4993470313        0.7498443759        0.2506096207
As            0.5596086351        0.8125133072        0.3154157232
Ga            0.4985690505        0.7499892663        0.5014805659
As            0.5624341773        0.8123930103        0.5625910133
Ga            0.4992356884        0.7506644171        0.7498457870
As            0.5625268921        0.8151034007        0.8096128541
Ga            0.7470964353        0.0123520684       -0.0047268956
As            0.8127950621        0.0652194248        0.0624307249
Ga            0.7497315839        0.0003219358        0.2500871184
As            0.8125243792        0.0624775847        0.3126106199
Ga            0.7500159821        0.0000330033        0.4999740234
As            0.8124383645        0.0625689034        0.5624410045
Ga            0.7495203405        0.0005301325        0.7498524436
As            0.8127282441        0.0652704943        0.8095337263
Ga            0.7517077238        0.2514836001       -0.0006209517
As            0.8151989336        0.3094693695        0.0630652175
Ga            0.7502409674        0.2498704097        0.2504374210
As            0.8126589442        0.3120902595        0.3129106089
Ga            0.7497381657        0.2499453506        0.5002551059
As            0.8124619790        0.3125086881        0.5621248467
Ga            0.7512613046        0.2514475858        0.7470775775
As            0.8127835926        0.3122283123        0.8122148412
Ga            0.7638896860        0.4938720725       -0.0046816169
As            0.8152049594        0.5598011602        0.0626004632
Ga            0.7498443765        0.4993470303        0.2506096244
As            0.8125133014        0.5596086409        0.3154157210
Ga            0.7499892671        0.4985690458        0.5014805650
As            0.8123930015        0.5624341863        0.5625910130
Ga            0.7506644157        0.4992356893        0.7498457834
As            0.8151034022        0.5625268950        0.8096128492
Ga            0.7456152484        0.7456152445       -0.0050252342
Bi            0.8123026910        0.8123026852        0.0627089555
Ga            0.7453915257        0.7453915205        0.2637234586
As            0.8125620200        0.8125620244        0.3152424324
Ga            0.7499564464        0.7499564484        0.5015420520
As            0.8127396204        0.8127396223        0.5622316600
Ga            0.7503001897        0.7503001883        0.7484508980
As            0.8128285734        0.8128285768        0.8094280076

CELL_PARAMETERS {alat}
 -0.500000   0.000000   0.500000
  0.000000   0.500000   0.500000
 -0.500000   0.500000   0.000000

EOF

# Run SCF calculation.
mpirun -np 32 pw.x < scf444_3Bi.in > scf444_3Bi.out

#Produce a Python file called $calculation.py for the plot.
# Generate scf444_3Bi.py script
cat > scf444_3Bi.py << EOF
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
    filename = 'scf444_3Bi' + '_convergence.pdf'
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
    filename = 'scf444_3Bi' + '.out'  # Replace with your actual filename
    main(filename)

EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python scf444_3Bi.py
