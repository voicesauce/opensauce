# Bugs
* STRAIGHT doesn't work
* "resample to 16 kHz" is not yet implemented
* various Octave warnings

## OutputToText
* should output only parameters that have been calculated rather than the whole list of all 54 params (this isn't an option yet)
* "complete dump" is very slow
* something may be wrong with "use textgrid labels"
* EGG bug: EGG.csv stored in top folder rather than in data folder

	## func_readTextGrid
	* move POINT_BUFFER into settings
	* figure out what's wrong with point-source tier segmentation
	* something's wrong when you try to use multiple tiers


# Enhancements
* Hx is a bottleneck ==> CVX optimization instead of NMSMAX? (see CVXPY)
* Need better/error-proof way to change settings & parameters
* Need to check settings dependencies before processing

# Testing
* need to check that EGG files are processed correctly
