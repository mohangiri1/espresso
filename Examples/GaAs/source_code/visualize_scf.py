import re
import matplotlib.pyplot as plt

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
    plt.show()

def main(filename):
    # Extract values
    iteration_numbers = extract_iteration_numbers(filename)
    print(iteration_numbers)
    cpu_times = extract_total_cpu_time(filename)
    total_energies = extract_total_energy(filename)
    scf_accuracies = extract_scf_accuracy(filename)
    print(scf_accuracies)

    # Plot values
    plot_values(iteration_numbers, cpu_times, total_energies, scf_accuracies)

if __name__ == "__main__":
    filename = 'k.4.out'  # Replace with your actual filename
    main(filename)

