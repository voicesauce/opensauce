import scipy.io as sio
import re
import os.path

def csv_to_mat(file, output_file, delimiter=","):
	assert os.path.isfile(file), "setup : error : file %s does not exist" % file
	map = {}
	d = delimiter
	with open(file, "r") as f:
		for line in f.readlines():
			data = line.split(d)
			if len(data) == 2:
				map[data[0]] = data[1].strip("\n")
	# convert strings to floats/ints where appropriate
	integer = re.compile(r'^\d+$')
	double = re.compile(r'\d*\.\d+$')
	for (key, value) in map.items():
		if re.match(integer, value):
			map[key] = int(value)
		elif re.match(double, value):
			map[key] = float(value)
		elif value[0] == "'" or value[-1] == "'":
			map[key] = re.sub("'", "", value)
	sio.savemat(output_file, map)
	# print "setup : wrote : ", output_file

def csv_to_dict(file, delimiter=","):
	d = delimiter
	map = {}
	with open(file, "r") as f:
		for line in f.readlines():
			data = line.split(d)
			assert len(data) == 2
			map[data[0]] = data[1]
	return map

def dict_to_csv(dict, outfile):
	string = ""
	for (k, v) in dict.items():
		string += k+","+v.strip("\n")+"\n"
	string = string.strip("\n")
	with open(outfile, "w") as f:
		f.write(string)

# map dependencies among measurement functions
deps = {
	"F0_Straight": [],
	"F0_Snack": [],
	"F0_Praat": [],
	"F0_SHR": [],
	"F0_Other": [],
	"Formants_Snack": ["f0"],
	"Formants_Praat": ["f0"],
	"Formants_Other": ["f0"],
	"H1_H2_H4": ["f0"],
	"A1_A2_A3": ["f0", "fmt"],
	"H1H2_H2H4_norm": ["f0", "fmt", "H1_H2_H4"],
	"H1A1_H1A2_H1A3_norm": ["f0", "fmt", "H1_H2_H4", "A1_A2_A3"],
	"Energy": ["f0"],
	"CPP": ["f0"],
	"HNR": ["f0"],
	"SHR": ["f0"]
}

def validate_settings(settings, tgdir, datadir):
	settings_valid = {}
	if settings.has_key('useTextGrid') and settings['useTextGrid'].strip("\n") == '1':
		if len(tgdir) > 0:
			settings_valid['textgrid_dir'] = tgdir
		else:
			settings_valid['textgrid_dir'] = datadir
	for (k, v) in settings.items():
		if not settings_valid.has_key(k):
			settings_valid[k] = v
	return settings_valid



def validate(settings, docket, rundir, tgdir, datadir):
	# validate the docket file and write everything out
	global deps
	assert os.path.isfile(docket), "setup : error : docket file %s does not exist" % docket
	assert os.path.isfile(settings), "setup : error : settings file %s does not exist" % settings
	settings = csv_to_dict(settings)
	settings = validate_settings(settings, tgdir, datadir)
	docket = csv_to_dict(docket)
	assert settings.has_key("F0algorithm")
	assert settings.has_key("FMTalgorithm")
	F0 = re.sub("'", "", settings["F0algorithm"].strip("\n"))
	FMT = re.sub("'", "", settings["FMTalgorithm"].strip("\n"))
	assert F0 in deps.keys(), "setup : invalid F0 algorithm : %s" % F0
	assert FMT in deps.keys(), "setup : invalid Formants algorithm : %s" % FMT
	# find the measurements that are "turned on" in the docket file
	turned_on = []
	for (k, v) in docket.items():
		if v.strip("\n") == "1":
			turned_on.append(k)
	# insert specified F0, FMT algorithms into dependency map
	for (k, depends) in deps.items():
		if "f0" in depends:
			deps[k][depends.index("f0")] = F0
		if "fmt" in depends:
			deps[k][depends.index("fmt")] = FMT
	# check dependencies
	for i in turned_on:
		assert deps.has_key(i)
		for require in deps[i]:
			if not require in turned_on:
				print "setup : added missing dependency to docket: ", i, "requires", require
				turned_on.append(require)
	docket_valid = {}
	for t in turned_on:
		docket_valid[t] = "1"
	# copy settings, validated docket file and corresponding *.mat files to rundir
	# FIXME we're copying settings/docket twice ....
	docket_path = rundir+"/docket"
	docket_out = rundir+"/docket.mat"
	settings_path = rundir+"/settings"
	settings_out = rundir+"/settings.mat"
	dict_to_csv(settings, settings_path)
	dict_to_csv(docket_valid, docket_path)
	csv_to_mat(settings_path, settings_out)
	csv_to_mat(docket_path, docket_out)

if __name__ == "__main__":
	import sys
	assert len(sys.argv) >= 2
	directive = sys.argv[1]
	# print directive
	if directive == "--validate":
		assert len(sys.argv) >= 5
		settings, docket, rundir, tgdir, datadir = sys.argv[2:]
		validate(settings, docket, rundir, tgdir, datadir)
	elif directive == "--ott":
		assert len(sys.argv) == 4
		ott_file, rundir = sys.argv[2:]
		out_file = rundir+"/output_settings.mat"
		csv_to_mat(ott_file, out_file)
	else:
		print "usage error. ", sys.argv

	# import sys
	# # print sys.argv
	# usage = "python utils.py settings.csv docket.docket rundir"
	# assert len(sys.argv) == 4, "setup : error : %s" % usage
	# settings, docket, rundir = sys.argv[1:]
	# # TODO add support for different delimiters
	# validate(settings, docket, rundir)



