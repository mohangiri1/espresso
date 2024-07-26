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

cat > scf444_1Bi.in << EOF
&CONTROL
  calculation = '$calculation'
  prefix = 'GaBiAs'
  outdir = './output_scf444_1Bi/'
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
  celldm(1) = 42.492544383
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
  electron_maxstep = 200
  mixing_beta = 0.3
  diago_david_ndim = 4
/

ATOMIC_SPECIES
  As 74.9216 As.rel-pz-n-rrkjus_psl.0.2.UPF
  Ga 69.72 Ga.rel-pz-dn-rrkjus_psl.0.2.UPF
  Bi 208.9804 Bi.rel-pz-dn-rrkjus_psl.1.0.0.UPF

K_POINTS {automatic}
  $k $k $k 0 0 0

ATOMIC_POSITIONS {crystal}
Ga           -0.0000329557       -0.0000329714        0.0000988744
As            0.0625553621        0.0625553574        0.0623454461
Ga           -0.0000118983       -0.0000119107        0.2497874101
As            0.0622838810        0.0622838704        0.3127161493
Ga           -0.0000118390       -0.0000118524        0.5002362346
As            0.0625553426        0.0625553319        0.5625438434
Ga           -0.0000330383       -0.0000330535        0.7499670514
As            0.0624999952        0.0624999862        0.8125000354
Ga           -0.0013712605        0.2500332619        0.0000331197
As            0.0595536653        0.3126710819        0.0626711388
Ga           -0.0000526978        0.2494912678        0.2502807356
As            0.0595536880        0.3126711576        0.3151040145
Ga           -0.0013711237        0.2500332475        0.5013046225
As            0.0625553392        0.3123454942        0.5625438384
Ga           -0.0000330453        0.2500990318        0.7499670415
As            0.0625553675        0.3123454958        0.8125553093
Ga           -0.0000526750        0.5002806012       -0.0005085157
As            0.0595536641        0.5651041292        0.0626711391
Ga           -0.0000527035        0.5002807080        0.2502807308
As            0.0622838796        0.5627161071        0.3127161493
Ga           -0.0000118491        0.4997874593        0.5002362259
As            0.0625256409        0.5624804950        0.5624969204
Ga           -0.0000119435        0.4997874945        0.7499881033
As            0.0622838616        0.5627160999        0.8122839463
Ga           -0.0013712553        0.7513048734        0.0000331202
As            0.0625553642        0.8125438360        0.0623454458
Ga           -0.0000118987        0.7502363805        0.2497874069
As            0.0625256581        0.8124969060        0.3124805296
Ga            0.0000062736        0.7499978860        0.4999979359
As            0.0625256404        0.8124969454        0.5624969218
Ga           -0.0000119381        0.7502363360        0.7499881101
As            0.0625553743        0.8125438275        0.8125553110
Ga            0.2500332654       -0.0013712731        0.0000331208
As            0.3126710833        0.0595536565        0.0626711387
Ga            0.2494912768       -0.0000527068        0.2502807329
As            0.3126711507        0.0595536966        0.3151040110
Ga            0.2500332561       -0.0013711323        0.5013046186
As            0.3123454902        0.0625553349        0.5625438429
Ga            0.2500990375       -0.0000330567        0.7499670451
As            0.3123454895        0.0625553653        0.8125553119
Ga            0.2454746636        0.2454746397       -0.0045251446
Bi            0.3125000870        0.3125001091        0.0624997084
Ga            0.2454748112        0.2454748316        0.2635755217
As            0.3126711489        0.3126711509        0.3151040075
Ga            0.2500332507        0.2500332502        0.5013046114
As            0.3125893824        0.3125893911        0.5624105122
Ga            0.2500332668        0.2500332645        0.7486285551
As            0.3126710772        0.3126710812        0.8095537704
Ga            0.2454746568        0.5135758632       -0.0045251522
As            0.3126710804        0.5651041326        0.0626711408
Ga            0.2494912692        0.5002806970        0.2502807271
As            0.3124521452        0.5625423741        0.3125424082
Ga            0.2500213882        0.4999198438        0.5000294134
As            0.3124522137        0.5625423429        0.5624631143
Ga            0.2494912941        0.5002807083        0.7499472980
As            0.3126710782        0.5651040852        0.8095537666
Ga            0.2500332620        0.7513048726        0.0000331162
As            0.3125893249        0.8124106259        0.0625894243
Ga            0.2500213588        0.7500293789        0.2499198714
As            0.3124521483        0.8124630781        0.3125424100
Ga            0.2500213911        0.7500293501        0.5000294208
As            0.3125893885        0.8124107180        0.5624105117
Ga            0.2500332729        0.7513049038        0.7486285562
As            0.3123454925        0.8125438302        0.8125553121
Ga            0.5002805918       -0.0000526769       -0.0005085094
As            0.5651041304        0.0595536647        0.0626711380
Ga            0.5002806945       -0.0000527028        0.2502807355
As            0.5627161094        0.0622838726        0.3127161525
Ga            0.4997874485       -0.0000118522        0.5002362336
As            0.5624804982        0.0625256340        0.5624969206
Ga            0.4997874820       -0.0000119489        0.7499881121
As            0.5627161004        0.0622838574        0.8122839480
Ga            0.5135758305        0.2454746638       -0.0045251612
As            0.5651041245        0.3126710786        0.0626711380
Ga            0.5002806883        0.2494912678        0.2502807301
As            0.5625423739        0.3124521470        0.3125424069
Ga            0.4999198300        0.2500213885        0.5000294194
As            0.5625423396        0.3124522195        0.5624631110
Ga            0.5002806984        0.2494912945        0.7499473003
As            0.5651040854        0.3126710820        0.8095537614
Ga            0.5002805829        0.5002805961       -0.0005085161
As            0.5625423338        0.5625423331        0.0624522542
Ga            0.4999758496        0.4999758666        0.2499759297
As            0.5624999869        0.5624999844        0.3125000538
Ga            0.4999759059        0.4999759228        0.5000722553
As            0.5625423392        0.5625423408        0.5624631112
Ga            0.5002806962        0.5002807115        0.7499472978
As            0.5627160979        0.5627161002        0.8122839473
Ga            0.4999197977        0.7500293642        0.0000214582
As            0.5625423331        0.8124630838        0.0624522566
Ga            0.4999758541        0.7500723450        0.2499759368
As            0.5625423742        0.8124630775        0.3125424087
Ga            0.4999198331        0.7500293513        0.5000294253
As            0.5624804998        0.8124969498        0.5624969223
Ga            0.4997874802        0.7502363353        0.7499881112
As            0.5624805362        0.8124968776        0.8125257090
Ga            0.7513048713       -0.0013712614        0.0000331237
As            0.8125438486        0.0625553576        0.0623454443
Ga            0.7502363797       -0.0000119052        0.2497874099
As            0.8124969168        0.0625256500        0.3124805278
Ga            0.7499978842        0.0000062662        0.4999979412
As            0.8124969590        0.0625256311        0.5624969208
Ga            0.7502363319       -0.0000119417        0.7499881170
As            0.8125438436        0.0625553622        0.8125553125
Ga            0.7513048588        0.2500332669        0.0000331182
As            0.8124106337        0.3125893264        0.0625894181
Ga            0.7500293741        0.2500213560        0.2499198718
As            0.8124630854        0.3124521452        0.3125424056
Ga            0.7500293456        0.2500213897        0.5000294256
As            0.8124107253        0.3125893891        0.5624105098
Ga            0.7513049029        0.2500332680        0.7486285596
As            0.8125438395        0.3123454957        0.8125553078
Ga            0.7500293541        0.4999198116        0.0000214555
As            0.8124630856        0.5625423317        0.0624522579
Ga            0.7500723363        0.4999758666        0.2499759375
As            0.8124630827        0.5625423767        0.3125424059
Ga            0.7500293411        0.4999198478        0.5000294213
As            0.8124969573        0.5624804986        0.5624969181
Ga            0.7502363220        0.4997874975        0.7499881075
As            0.8124968878        0.5624805314        0.8125257068
Ga            0.7500293592        0.7500293695        0.0000214618
As            0.8124106359        0.8124106275        0.0625894191
Ga            0.7500293764        0.7500293887        0.2499198764
As            0.8124969181        0.8124969084        0.3124805281
Ga            0.7499978846        0.7499978915        0.4999979375
As            0.8124999796        0.8124999674        0.5625000875
Ga            0.7499978872        0.7499978941        0.7500063089
As            0.8124968875        0.8124968773        0.8125257095

CELL_PARAMETERS {alat}
 -0.500000   0.000000   0.500000
  0.000000   0.500000   0.500000
 -0.500000   0.500000   0.000000

EOF

# Run SCF calculation.
mpirun -np 32 pw.x < scf444_1Bi.in > scf444_1Bi.out

#Produce a Python file called $calculation.py for the plot.
# Generate scf444_1Bi.py script
cat > scf444_1Bi.py << EOF
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
    filename = 'scf444_1Bi' + '_convergence.pdf'
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
    filename = 'scf444_1Bi' + '.out'  # Replace with your actual filename
    main(filename)

EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python scf444_1Bi.py
