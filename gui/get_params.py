import scipy.io as sio

f = open('selection.data', 'r')
raw = f.read().split('\t')
f.close()

assert len(raw) == 3, "bad input"

f0 = raw[0]
fmt = raw[1]
other = raw[2]

f0_hash = {
	'F0_Snack': '1',
	'F0_Praat': '2',
	'F0_SHR': '3'
}

selected = {}

for k in f0_hash.keys():
	if f0_hash[k] in f0:
		selected[k] = 1
	else:
		selected[k] = 0

fmt_hash = {
	'FMT_Snack': '1',
	'FMT_Praat': '2'
}


for k in fmt_hash.keys():
	if fmt_hash[k] in fmt:
		selected[k] = 1
	else:
		selected[k] = 0

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

for k in other_hash.keys():
	if other_hash[k] in other:
		selected[k] = 1
	else:
		selected[k] = 0

for k in selected:
	print k, selected[k]

sio.savemat('params.mat', {'params': selected})


