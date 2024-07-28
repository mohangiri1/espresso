#!/bin/sh
#PBS -l nodes=1:ppn=32
#PBS -o 2Bi.out
#PBS -e 2Bi.err
#PBS -N 2Bi
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

cat > scf444_2Bi.in << EOF
&CONTROL
  calculation = '$calculation'
  prefix = 'GaBiAs'
  outdir = './output_scf444_2Bi/'
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
  celldm(1) = 42.574093746
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
Ga           -0.0000488839       -0.0000488847        0.0000832209
As            0.0623072387        0.0623072442        0.0625421733
Ga           -0.0000344541       -0.0000344481        0.2498067723
As            0.0622396969        0.0622396951        0.3127353255
Ga           -0.0000252411       -0.0000252430        0.5002677754
As            0.0625068740        0.0625068793        0.5626501652
Ga           -0.0000338140       -0.0000338104        0.7499844369
As            0.0625059997        0.0625059957        0.8125236129
Ga            0.0000668624        0.2485108523       -0.0000510968
As            0.0597295234        0.3126124719        0.0624248288
Ga            0.0002017505        0.2494757941        0.2500533116
As            0.0596094263        0.3125994731        0.3152009028
Ga           -0.0014510126        0.2500023891        0.5014622720
As            0.0625173641        0.3123582762        0.5626513218
Ga            0.0002423297        0.2500645239        0.7499425930
As            0.0626605204        0.3123492815        0.8124962216
Ga            0.0014193364        0.5002484769       -0.0005292350
As            0.0593087535        0.5654263067        0.0628239914
Ga           -0.0000906179        0.5002708061        0.2503479865
As            0.0621401921        0.5627407115        0.3128357660
Ga           -0.0000349877        0.4997573916        0.5002683395
As            0.0623299739        0.5626586177        0.5623174399
Ga            0.0014448791        0.4997597225        0.7485312431
As            0.0623776412        0.5626076701        0.8122395568
Ga           -0.0014705013        0.7515047250       -0.0000127285
As            0.0624663747        0.8126825118        0.0622939004
Ga            0.0000466571        0.7502573012        0.2497348070
As            0.0624398204        0.8125597888        0.3125275152
Ga            0.0000017347        0.7500252520        0.4999851847
As            0.0625263489        0.8124727417        0.5625137285
Ga            0.0002509417        0.7500434676        0.7499581496
As            0.0625119964        0.8126129773        0.8125327725
Ga            0.2485108561        0.0000668614       -0.0000510969
As            0.3126124762        0.0597295253        0.0624248298
Ga            0.2494757847        0.0002017594        0.2500533074
As            0.3125994755        0.0596094035        0.3152009171
Ga            0.2500023798       -0.0014510155        0.5014622858
As            0.3123582820        0.0625173643        0.5626513190
Ga            0.2500645236        0.0002423384        0.7499425900
As            0.3123492813        0.0626605221        0.8124962242
Ga            0.2454344471        0.2454344485       -0.0044750130
Bi            0.3126502359        0.3126502578        0.0622354434
Ga            0.2454236351        0.2454236079        0.2634412695
As            0.3123174975        0.3123174876        0.3155110109
Ga            0.2499683046        0.2499683037        0.5017430909
As            0.3126994994        0.3126994955        0.5624601034
Ga            0.2499578780        0.2499578781        0.7485307368
As            0.3125790052        0.3125790120        0.8096125523
Ga            0.2438716847        0.5138890447       -0.0046528662
As            0.3097728410        0.5653129484        0.0626365670
Ga            0.2493882133        0.4997814032        0.2506092440
As            0.3095662358        0.5626365074        0.3152898515
Ga            0.2485458023        0.5000161076        0.5014632562
As            0.3124731844        0.5623940924        0.5625705932
Ga            0.2494617106        0.5003747680        0.7498887509
As            0.3125792952        0.5650844481        0.8095865108
Ga            0.2499849270        0.7517277839       -0.0005386441
As            0.3097730360        0.8150096396        0.0628020944
Ga            0.2499092401        0.7502679653        0.2503430399
As            0.3121964281        0.8126931758        0.3128240843
Ga            0.2499709811        0.7497585512        0.5002599668
As            0.3127119054        0.8122818402        0.5623100689
Ga            0.2499660424        0.7512498309        0.7485204585
As            0.3120699625        0.8129231738        0.8122289738
Ga            0.5002484854        0.0014193327       -0.0005292354
As            0.5654263039        0.0593087550        0.0628239985
Ga            0.5002708093       -0.0000906270        0.2503479930
As            0.5627407027        0.0621401962        0.3128357685
Ga            0.4997573938       -0.0000349985        0.5002683420
As            0.5626586240        0.0623299663        0.5623174398
Ga            0.4997597171        0.0014448943        0.7485312321
As            0.5626076626        0.0623776505        0.8122395573
Ga            0.5138890219        0.2438716838       -0.0046528442
As            0.5653129473        0.3097728372        0.0626365712
Ga            0.4997814028        0.2493882198        0.2506092476
As            0.5626365177        0.3095662186        0.3152898645
Ga            0.5000161111        0.2485457989        0.5014632643
As            0.5623940948        0.3124731849        0.5625705978
Ga            0.5003747537        0.2494617243        0.7498887558
As            0.5650844388        0.3125792904        0.8095865276
Ga            0.4956136104        0.4956136033       -0.0050127185
Bi            0.5625318208        0.5625318439        0.0624613820
Ga            0.4954050870        0.4954050695        0.2636970115
As            0.5625798578        0.5625798445        0.3152377645
Ga            0.4999628698        0.4999628729        0.5015349039
As            0.5627450510        0.5627450385        0.5622258059
Ga            0.5002968281        0.5002968273        0.7484664880
As            0.5628415950        0.5628416084        0.8093931965
Ga            0.4954241020        0.7637349259       -0.0045758088
As            0.5626281730        0.8151561758        0.0625543439
Ga            0.4994670196        0.7503567310        0.2502707835
As            0.5625205364        0.8124747772        0.3126170932
Ga            0.5000210638        0.7500176566        0.4999782767
As            0.5624355497        0.8125538879        0.5624373933
Ga            0.4992560009        0.7505603845        0.7499135608
As            0.5625470089        0.8152340046        0.8096317349
Ga            0.7515047207       -0.0014704975       -0.0000127287
As            0.8126825169        0.0624663637        0.0622939022
Ga            0.7502572897        0.0000466606        0.2497348139
As            0.8125597915        0.0624398172        0.3125275165
Ga            0.7500252568        0.0000017356        0.4999851808
As            0.8124727502        0.0625263345        0.5625137391
Ga            0.7500434575        0.0002509469        0.7499581552
As            0.8126129788        0.0625119973        0.8125327685
Ga            0.7517277881        0.2499849161       -0.0005386368
As            0.8150096403        0.3097730387        0.0628020949
Ga            0.7502679717        0.2499092327        0.2503430431
As            0.8126931700        0.3121964315        0.3128240893
Ga            0.7497585521        0.2499709694        0.5002599777
As            0.8122818460        0.3127118963        0.5623100704
Ga            0.7512498191        0.2499660515        0.7485204637
As            0.8129231678        0.3120699722        0.8122289773
Ga            0.7637348995        0.4954241026       -0.0045757874
As            0.8151561773        0.5626281647        0.0625543463
Ga            0.7503567370        0.4994670223        0.2502707859
As            0.8124747873        0.5625205342        0.3126170926
Ga            0.7500176685        0.5000210569        0.4999782758
As            0.8125538989        0.5624355405        0.5624373902
Ga            0.7505603673        0.4992560150        0.7499135628
As            0.8152339936        0.5625470010        0.8096317548
Ga            0.7502774817        0.7502774742       -0.0005125702
As            0.8123617176        0.8123617238        0.0626604282
Ga            0.7499666630        0.7499666736        0.2500069540
As            0.8125066415        0.8125066370        0.3124673173
Ga            0.7499737664        0.7499737683        0.5000588050
As            0.8125530270        0.8125530244        0.5624282010
Ga            0.7502858267        0.7502858288        0.7499417395
As            0.8127726928        0.8127726977        0.8122562108


CELL_PARAMETERS {alat}
 -0.500000   0.000000   0.500000
  0.000000   0.500000   0.500000
 -0.500000   0.500000   0.000000

EOF

# Run SCF calculation.
mpirun -np 32 pw.x < scf444_2Bi.in > scf444_2Bi.out

#Produce a Python file called $calculation.py for the plot.
# Generate scf444_2Bi.py script
cat > scf444_2Bi.py << EOF
import re
import matplotlib.pyplot as plt
#plt.style.use('sci.mplstyle')

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
    filename = 'scf444_2Bi' + '_convergence.pdf'
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
    filename = 'scf444_2Bi' + '.out'  # Replace with your actual filename
    main(filename)

EOF
    
# Plot the Convergence
source /home/girim/python_venv/my-python/bin/activate
python scf444_2Bi.py
