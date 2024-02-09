import re

filenames = ["iso-2533-1975-table5.yaml", "iso-2533-1975-table6.yaml", "iso-2533-1975-table7.yaml"]

inputs = [0 for x in range(len(filenames))]
counts = [0 for x in range(len(filenames))]

for i, name in enumerate(filenames):
	inputs[i] = open(name, "r")
	for s in inputs[i]:
		if s.startswith("  - "):
			counts[i] += 1
	inputs[i].close()
	inputs[i] = open(name, "r")

for i, count in enumerate(counts):
	if i > 0 and count != counts[i-1]:
		print("More or missing rows in some of the files?")
		exit()

entriesh = [{} for x in range(counts[0])]
entriesH = [{} for x in range(counts[0])]

currentEntries = 0 #0 for h, 1 for H

for i in range(counts[0]):
	for f in inputs:
		match = None
		while match is None:
			line = f.readline()
			if line == "rows-h:\n":
				currentEntries = 0
			elif line == "rows-H:\n":
				currentEntries = 1
			match = re.search(r'^  (-| ) (.+):(.*)', line)
		while match is not None:
			if currentEntries == 0:
				entriesh[i][match.group(2)] = match.group(3)
			else:
				entriesH[i][match.group(2)] = match.group(3)
			
			line = f.readline()
			match = re.search(r'^  (-| ) (.+):(.*)', line)

for f in inputs:
	f.close()

def output(filename, entries, geopotential):
	output = open(filename, "w")
	output.write("---\n")
	
	for e in entries:
		if e == {}:
			continue
		if geopotential:
			output.write("- H: " + str(float(e["geopotential-altitude"])) + "\n")
			output.write("  h: " + str(float(e["geometrical-altitude"])) + "\n")
		else:
			output.write("- h: " + str(float(e["geometrical-altitude"])) + "\n")
			output.write("  H: " + str(float(e["geopotential-altitude"])) + "\n")
		
		output.write("  TK: " + str(float(e["temperature-K"])/1000) + "\n")
		output.write("  TC: " + str(float(e["temperature-C"])/1000) + "\n")
		output.write("  p_mbar:" + e["p-mbar"] + "\n")
		output.write("  p_mmhg:" + e["p-mmHg"] + "\n")
		output.write("  rho:" + e["density"] + "\n")
		output.write("  g:" + e["acceleration"] + "\n")
		output.write("  p_p_n:" + e["ppn"] + "\n")
		output.write("  rho_rho_n:" + e["rhorhon"] + "\n")
		output.write("  root_rho_rho_n:" + e["sqrt-rhorhon"] + "\n")
		output.write("  a: " + str(float(e["speed-of-sound"])/1000) + "\n")
		output.write("  mu:" + e["dynamic-viscosity"] + "\n")
		output.write("  v:" + e["kinematic-viscosity"] + "\n")
		output.write("  lambda:" + e["thermal-conductivity"] + "\n")
		output.write("  H_p:" + e["pressure-scale-height"] + "\n")
		output.write("  gamma:" + e["specific-weight"] + "\n")
		output.write("  n:" + e["air-number-density"] + "\n")
		output.write("  v_bar:" + e["mean-speed"] + "\n")
		output.write("  omega:" + e["frequency"] + "\n")
		output.write("  l:" + e["mean-free-path"] + "\n")
		output.write("\n")

	output.close()


output("tests-geometric.yml", entriesh, geopotential = False)
output("tests-geopotential.yml", entriesH, geopotential = True)