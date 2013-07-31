# OpenSauce

This version of [VoiceSauce](http://www.seas.ucla.edu/spapl/voicesauce/) is compatible with GNU Octave, knock on wood. More documentation to come.

## Running OpenSauce on *.wav files

1. Check settings/getSettings.m
2. Check params/getParameters.m
3. Check settings/getOutputSettings.m
4. Use the command

	$ octave -qf sauce.m [wavdir] [matdir]

	Where [wavdir] is the directory where your *.wav files are stored and [outdir] is the directory where you'd like VoiceSauce to store the resulting *.mat files. "-qf" suppresses the Octave startup message.

The command above carries out all calculations specified in getParameters.m and then runs OutputToText on the resulting *.mat files.

## Issues
* STRAIGHT doesn't work (because it relies on p files)
* Calculating "H1, H2, H3" takes a very long time
* Resampling to 16 kHz is not yet implemented
* Outputting to text with "useSegments = 0" (i.e. complete dump without segments) takes a very long time
* Octave may throw some warnings that you wouldn't see if you were using MATLAB. Running Octave with the "--braindead" option helps some.

## Folder structure
* vs-octave
	* sauce.m - script that runs batch_process then OutputToText
	* algos/ - folder where all of the measurement algorithms are stored
		* wrappers/ - interfaces into each of the measurement methods stored here (e.g. doStraight.m, etc.)
		* functions/ - implementations of each of the measurement methods stored here (e.g. func_getStraight.m, etc.)
	* optim-1.2.2/ - source code for a slightly-modified version of Octave's optim package (for fminsearch.m, etc.)
	* bin/ - folder where VoiceSauce.m and other executables are stored; main interface into the program
	* params/ - folder where parameter files are stored
	* settings/ - folder where settings files are stored
	* sys/ - folder where main functions are stored (batch_process.m, OutputToText.m)
		* helpers/ - misc helper functions
		* MacOS/ - just has the Praat binary (used in PraatPitch and Praat Formants)
		* Windows/ - stores *.praat scripts used for PraatPitch and Praat Formants. may want to move somewhere else later.
	* tests/ - tests for main pieces of functionality