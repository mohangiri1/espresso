mkdir results
cp unfold_density.png ./results/unfold_density.png
cp unfold_fatband.png ./results/unfold_fatband.png
cp generate_kpoints.py ./results/generate_kpoints.py
cp GaAs-bands.in ./results/GaAs-bands.in
cp GaAs-bands.out ./results/GaAs-bands.out
cp GaAs-scf.in ./results/GaAs-scf.in
cp GaAs-scf.out ./results/GaAs-scf.out
cp bandstructure_unfolded-path.txt ./results/bandstructure_unfolded-path.txt
cp bandstructure_unfolded-GL.txt ./results/bandstructure_unfolded-GL.txt
cp kpoints_unfolded-GL.txt ./results/kpoints_unfolded-GL.txt
cp kpath_unfolded-path.txt ./results/kpath_unfolded-path.txt
tar -czvf results.tar.gz results
rm -r results
