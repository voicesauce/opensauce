import scipy.io as sio
import os

# read in the file outputted by shell_gui.sh and 
# break it up into list entries split on tab characters (\t)
f = open('tmp/selection.data', 'r')
raw = f.read().split('\t')
f.close()

os.remove('tmp/selection.data')

assert len(raw) == 3, "bad input"

# these lists correspond to each text segment that has
# been saved in "selection.data" by shell_gui.sh
f0 = raw[0] # F0 algorithm dialog
fmt = raw[1] # Formant algorithm dialog
other = raw[2] # "Other" dialog

# associate name of parameter with index in vector 
# output of shell_gui.sh
f0_hash = {
	'F0_Snack': '1',
	'F0_Praat': '2',
	'F0_SHR': '3'
}

fmt_hash = {
	'FMT_Snack': '1',
	'FMT_Praat': '2'
}

other_hash = {
    "Hx": "1",
    "Ax": "2",
    "H1H2_H2H4": "3",
    "H1A1_H1A2_H1A3": "4",
    "Energy": "5",
    "CPP": "6",
    "HNR": "7",
    "SHR": "8"
}

# parse each vector corresponding to each window dialog
# and find out which param's have been selected, then
# add them to the "selected" dictionary
selected = {}
for k in f0_hash.keys():
	if f0_hash[k] in f0:
		selected[k] = 1
	else:
		selected[k] = 0

for k in fmt_hash.keys():
	if fmt_hash[k] in fmt:
		selected[k] = 1
	else:
		selected[k] = 0

for k in other_hash.keys():
	if other_hash[k] in other:
		selected[k] = 1
	else:
		selected[k] = 0

# translate and save selected params dictionary to *.mat file
sio.savemat('params/params.mat', {'params': selected})





