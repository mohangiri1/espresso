mkdir results
cp unfold_density.png ./results/unfold_density.png
cp unfold_fatband.png ./results/unfold_fatband.png
cp generate_kpoints.py ./results/generate_kpoints.py
cp GaBiAs-bands.in ./results/GaBiAs-bands.in
cp GaBiAs-bands.out ./results/GaBiAs-bands.out
cp GaBiAs-scf.in ./results/GaBiAs-scf.in
cp GaBiAs-scf.out ./results/GaBiAs-scf.out
cp bandstructure_unfolded-path.txt ./results/bandstructure_unfolded-path.txt
cp bandstructure_unfolded-GL.txt ./results/bandstructure_unfolded-GL.txt
cp kpoints_unfolded-GL.txt ./results/kpoints_unfolded-GL.txt
cp kpath_unfolded-path.txt ./results/kpath_unfolded-path.txt
tar -czvf results.tar.gz results
rm -r results
