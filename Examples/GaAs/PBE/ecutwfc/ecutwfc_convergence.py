import numpy as np
import matplotlib.pyplot as plt
from lmfit import Model

def read_convergence_data(file_path):
    """Read convergence data from a file."""
    ecutwfc = []
    energy = []
    with open(file_path, 'r') as file:
        #next(file)  # Skip the header line
        for line in file:
            data = line.split()
            ecutwfc.append(float(data[0]))
            energy.append(float(data[1]))
    return np.array(ecutwfc), np.array(energy)

def find_convergence(ecutwfc, energy, threshold=1e-2):
    """Find the convergence point where energy change is below a threshold."""
    energy_diff = np.diff(energy)
    converged_idx = np.where(np.abs(energy_diff) < threshold)[0][0]
    return ecutwfc[converged_idx], energy[converged_idx]

def plot_convergence(ecutwfc, energy, converged_ecutwfc, converged_energy, accuracy):
    """Plot energy as a function of ecutwfc and mark the convergence point."""
    plt.figure(figsize=(10, 6))

    # Sort ecutwfc if necessary
    sorted_indices = np.argsort(ecutwfc)
    sorted_ecutwfc = ecutwfc[sorted_indices]
    sorted_energy = energy[sorted_indices]

    plt.plot(sorted_ecutwfc, sorted_energy, linestyle='-')
    plt.scatter(converged_ecutwfc, converged_energy, color='red', label='Convergence Point')
    
    # Draw vertical line at convergence point
    plt.axvline(x=converged_ecutwfc, color='gray', linestyle='--', linewidth=1)
    
    # Display convergence information in the legend
    legend_text = f'Convergence Point\necutwfc = {converged_ecutwfc}\nEnergy = {converged_energy}\naccuracy = {accuracy} meV'
    plt.legend([legend_text], loc='upper right')
    
    plt.xlabel('ecutwfc')
    plt.ylabel('Total Energy (Ry)')
    plt.title('Convergence of Total Energy with ecutwfc')
    plt.grid(True)
    plt.savefig('ecutwfc_convergence_plot.pdf')
    plt.show()
    
def exponential_decay_fit(energy, ecutwfc):
    """
    Fit an exponential decay model to the given data.

    Parameters:
    - energy (array-like): Array-like object containing the total energy values.
    - ecutwfc (array-like): Array-like object containing the ecutwfc values.

    Returns:
    - float: The value of the parameter C, which represents the limit as x approaches infinity in the exponential decay model y = Ae^(-Bx) + C.
    
    This function fits an exponential decay model y = Ae^(-Bx) + C to the provided data using lmfit. It then plots the fit and returns the value of parameter C, which corresponds to the limit of y as x approaches infinity in the model.
    """

    # Define the exponential decay model
    def exp_decay(x, A, B, C):
        return A * np.exp(-B * x) + C

    # Create a model instance
    model = Model(exp_decay)

    # Set initial parameters
    params = model.make_params(A=min(energy), B=1/70, C=min(energy))

    # Perform the fit
    result = model.fit(energy, x=ecutwfc, params=params)

    # Plot the fit
    plt.figure(figsize=(10, 6))
    plt.scatter(ecutwfc, energy, label='Data')
    plt.plot(ecutwfc, result.best_fit, 'r-', label='Exponential Fit')
    plt.xlabel('ecutwfc')
    plt.ylabel('Total Energy')
    plt.legend()
    plt.title('Exponential Decay Fit')
    plt.grid()
    plt.savefig('ecutwfc_convergence_plot_fit.pdf')
    plt.show()

    # Return the limit as x approaches infinity (C parameter) #Total Energy at ecut = infinity
    return result.params['C'].value

def ecutwfc_accuracy_estimation(E_converged: float, E_inf: float):
    """
    Calculate the estimated energy calculation accuracy in milli-electron volts (meV).

    Parameters:
    - E_converged (float): The converged energy value obtained from the calculation.
    - E_inf (float): The estimated energy at infinity obtained from a model or fitting.

    Returns:
    - accuracy in meV
    
    This function calculates the estimated energy calculation accuracy in milli-electron volts (meV) based on the difference between the converged energy value and the estimated energy at infinity.
    """

    accuracy_Ry = E_converged - E_inf #accuracy in Rydberg
    accuracy_eV = accuracy_Ry * 13.6057
    accuracy_meV = accuracy_eV*1000 # accuracy in meV
    print(f"Estimated Energy calculation accuracy: {accuracy_meV} meV")
    
    return accuracy_meV

if __name__ == "__main__":
    # Read convergence data
    ecutwfc, energy = read_convergence_data('convergence_data.txt')

    # Find convergence point
    converged_ecutwfc, converged_energy = find_convergence(ecutwfc, energy, threshold = 1e-2)
    
    # Fit the convergence data to predict the Total energy at ecutwfc = Infinity.
    E_inf = exponential_decay_fit(energy, ecutwfc)
    
    #Estimate the accuracy of the convergence
    accuracy = ecutwfc_accuracy_estimation(converged_energy, E_inf)

    # Plot convergence
    plot_convergence(ecutwfc, energy, converged_ecutwfc, converged_energy, accuracy)
    

    print(f"Convergence achieved at ecutwfc = {converged_ecutwfc} with total energy = {converged_energy} Ry.")
