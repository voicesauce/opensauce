from __future__ import division
import sys, re

point_buffer = 0.025

rawfields = []
tgf = open('/Users/kate/speech-tech/voice-sauce/vs-octave/tests/sounds/textgrid/hmong_f4_40_a.TextGrid', 'rb')
for line in tgf:
	rawfields.append(line)
tgf.close()

tiers = 0
proceed_int = 0
proceed_pnt = 0
xmin = 0
xmax = 1

"""
cases: 'intervals:size, xmin, xmax, text, points:size, time, mark'
"""

fields = {
	'file_type': re.compile(r'(File\stype\s)=(?P<file_type>\s.+)'),
	'obj_class': re.compile(r'(Object\sclass\s)=(?P<obj_class>\s.+)'),
	'xmin': re.compile(r'(xmin\s)=(?P<xmin>\s\d+)'),
	'xmax': re.compile(r'(xmax\s)=(?P<xmax>\s\d+)'),
	'tiers?': re.compile(r'(tiers\?\s)(?P<tiers>\<.+)'),
	'item_1': re.compile(r'(\s+item\s)(?P<item_1>\[1.+)'),
	'item_class': re.compile(r'(\s+class\s=)(?P<item_class>\s+.+)'),
	'item_name': re.compile(r'(\s+name\s=)(?P<item_name>\s+.+)'),
	'intervals_size': re.compile(r'(\s+intervals\:\ssize\s=)(?P<intervals_size>\s\d)'),
	'interval_no': re.compile(r'(\s+intervals\s\[)(?P<interval_no>\d)\]'),
	'int_xmin': re.compile(r'(\s+xmin\s=)(?P<int_xmin>\s\d).*'),
	'int_xmax': re.compile(r'(\s+xmax\s=)(?P<int_xmax>\s\d).*'),
	'int_text': re.compile(r'(\s+text\s=)(?P<int_text>\w+)')
}

for f in rawfields:
	for k in fields.keys():
		m = re.match(fields[k], f)
		if m:
			print "match"
			print m.groupdict()

# test = rawfields[1]
# m = re.match(fields['obj_class'], test)
# if m:
# 	print m.group('obj_class')

# for f in rawfields:
# 	if any(re.match(fields[k], f) for k in fields)
# 	if m:
# 		print m.groups()







	
