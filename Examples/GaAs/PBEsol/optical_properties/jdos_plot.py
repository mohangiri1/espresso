# Import the necessary packages and modules
import matplotlib.pyplot as plt
plt.style.use('./sci.mplstyle')
import numpy as np

# Load data
ener, jdos = np.loadtxt('jdos_GaAs.dat', unpack=True)

# Create figure object
plt.figure()
# Plot the JDOS
plt.plot(ener, jdos, c='b')
# Add the x and y-axis labels
plt.xlabel('Energy (eV)')
plt.ylabel('JDOS (states/eV/unit-cell)')
# Set the axis limits
# plt.xlim(0, 6)
# plt.ylim(0, 0.022)
# Save a figure to the pdf file
plt.savefig('plot-jdos.pdf')
# Show plot
plt.show()
