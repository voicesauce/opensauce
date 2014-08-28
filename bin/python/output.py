from utils import csv_to_mat, csv_to_dict
import scipy.io as sio

def load_paramlist():
	import os
	root = "/Users/kate/voicesauce/opensauce"
	fid = root+"/resources/output_paramlist.txt"
	# fid = os.environ["SAUCE_ROOT"]+"/resources/output_paramlist.txt"
	return {k.strip("\n"): None for k in open(fid, "r").readlines()}

def output_to_text(user_settings, output_settings, m_dir):
	import os
	# user_settings : path to csv of user settings e.g. config/settings/default.csv
	# output_settings : path to csv of output settings e.g. config/settings/output_settings.csv
	# output_dir : path to *.mat files 
	user = csv_to_dict(user_settings)
	ott = csv_to_dict(output_settings)
	assert ott.has_key('singleFilename')
	# outfile = ott['singleFilename']
	outfile = "out.txt"
	matfiles = [m_dir+"/"+f for f in os.listdir(m_dir) if f.endswith(".mat")]
	test = matfiles[0]
	fields = [x[0] for x in sio.whosmat(test)]
	print fields
	# print test
	# d = sio.loadmat(test)
	data = sio.loadmat(test)
	print type(data)
	delim = ","
	# with open(outfile, "w") as f:
		# for (field, vals) in data.items():
	# data = [sio.loadmat(f) for f in os.listdir(m_dir) if f.endswith(".mat")]


def validate(settings_csv, dir):
	fname = settings_csv.split("/")[-1]
	fname = fname.split(".")[0]+".mat"
	fname = dir+"/"+fname
	print "output.py : ", fname
	csv_to_mat(settings_csv, fname)

if __name__ == "__main__":
	import sys
	assert len(sys.argv) == 3
	print "output.py : ", sys.argv
	validate(sys.argv[1], sys.argv[2])
	# us = "/Users/kate/voicesauce/opensauce/config/settings/default.csv"
	# ott = "/Users/kate/voicesauce/opensauce/config/settings/output_settings.csv"
	# mdir = "/Users/kate/voicesauce/opensauce/runs/mat"
	# output_to_text(us, ott, mdir)