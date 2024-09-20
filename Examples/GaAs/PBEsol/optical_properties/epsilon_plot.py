# Import the necessary packages and modules
import matplotlib.pyplot as plt
plt.style.use('./sci.mplstyle')
import numpy as np

# Set parameter
c = 299792458  # velocity of light (m/s)
hbar = 6.582119569e-16  # reduced Planck constant (eV.s)
l = 2.0 / 0.65  # Reduce thickness of the unit cell (2nm) to real thickness (0.65 nm)

# Function to safely load data while skipping invalid lines
def safe_loadtxt(filename):
    data = []
    with open(filename, 'r') as file:
        for line in file:
            try:
                # Attempt to convert the line to a list of floats
                data.append([float(x) for x in line.split()])
            except ValueError:
                # Skip the line if it contains non-numeric characters
                print(f"Skipping invalid line: {line.strip()}")
    return np.array(data).T  # Transpose to unpack correctly

# Load and clean the real part of the dielectric tensor diagonal components
real_data = safe_loadtxt('epsr_GaAs.dat')
if real_data.size == 0:
    raise ValueError("No valid data in epsr_GaAs.dat")

ener_real, repsx, repsy, repsz = real_data

# Load and clean the imaginary part of the dielectric tensor diagonal components
imag_data = safe_loadtxt('epsi_GaAs.dat')
if imag_data.size == 0:
    raise ValueError("No valid data in epsi_GaAs.dat")

ener_imag, iepsx, iepsy, iepsz = imag_data

# Ensure that both energy arrays (ener_real and ener_imag) have the same size
if len(ener_real) != len(ener_imag):
    min_length = min(len(ener_real), len(ener_imag))
    print(f"Warning: Length mismatch. Truncating arrays to the smallest length: {min_length}")
    ener_real = ener_real[:min_length]
    ener_imag = ener_imag[:min_length]
    repsx = repsx[:min_length]
    repsy = repsy[:min_length]
    repsz = repsz[:min_length]
    iepsx = iepsx[:min_length]
    iepsy = iepsy[:min_length]
    iepsz = iepsz[:min_length]

# Now, the sizes of all arrays are consistent
ener = ener_real  # Since both energy arrays are now truncated to the same size

# Absorption coefficient in x-, y-, z-directions
alphax = 2 * (ener / hbar) * np.sqrt((np.sqrt((l * repsx)**2 + (l * iepsx)**2) - l * repsx) / 2) / c
alphay = 2 * (ener / hbar) * np.sqrt((np.sqrt((l * repsy)**2 + (l * iepsy)**2) - l * repsy) / 2) / c
alphaz = 2 * (ener / hbar) * np.sqrt((np.sqrt((l * repsz)**2 + (l * iepsz)**2) - l * repsz) / 2) / c

# Create figure object
fig, (ax1, ax3) = plt.subplots(1, 2, constrained_layout=True, figsize=(10, 4))
ax2 = ax1.twinx()

# Plot the epsilon (real and imaginary parts)
ax1.plot(ener, l * repsx, 'b-')
ax2.plot(ener, l * iepsx, 'r--')

# Add the x and y-axis labels
ax1.set_xlabel('Photon energy (eV)')
ax1.set_ylabel(r'Re$(\varepsilon_{xx})$', color='b')
ax1.tick_params(axis='y', labelcolor='b')
ax2.set_ylabel(r'Im$(\varepsilon_{xx})$', color='r')
ax2.tick_params(axis='y', labelcolor='r')

# Set the axis limits
ax1.set_xlim(0, 6)
ax1.set_ylim(0, 36)
ax2.set_ylim(0, 36)

# Plot the absorption coefficient
ax3.plot(ener, alphax / 10**8, c='k')

# Add the x and y-axis labels
ax3.set_xlabel('Photon energy (eV)')
ax3.set_ylabel(r'$\alpha_{xx}$ (10$^8$/m)')

# Set the axis limits
ax3.set_xlim(0, 6)
ax3.set_ylim(0, 1.4)

# Save the figure to a PDF file
plt.savefig('plot-optic.pdf')
plt.show()
