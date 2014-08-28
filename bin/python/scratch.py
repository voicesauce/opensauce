file = "/Users/kate/voicesauce/opensauce/output_paramlist.txt

with open(file, "r") as f:
	for line in f.readlines():
		d = line.split(",")
		print "'"+d[0]+"',0;"