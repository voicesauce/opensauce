# OpenSauce

OpenSauce is a MATLAB-free edition of [VoiceSauce](http://www.seas.ucla.edu/spapl/voicesauce/), software for automated voice measurements, which is compatible with GNU Octave (knock on wood). More documentation to come.

## Requirements
* [GNU Octave](https://www.gnu.org/software/octave/)
* Currently, OpenSauce only works on Mac OSX (tested on Mountain Lion)
* You may need to install [Tcl/Tk](http://www.activestate.com/activetcl)

## Running OpenSauce on a batch of *.wav files
1. Check settings/getSettings.m
2. Check params/getParameters.m
3. Check settings/getOutputSettings.m
4. Use the command:

	$ octave -qf sauce.m [wavdir] [matdir]

	Where [wavdir] is the directory where your *.wav files are stored and [outdir] is the directory where you'd like VoiceSauce to store the resulting *.mat files. "-qf" suppresses the Octave startup message.

PLEASE NOTE that [wavdir] and [matdir] need to be absolute paths (e.g. "/Users/johndoe/wavfiles" or "~/wavfiles" rather than "../wavfiles").

The command above carries out all calculations specified in getParameters.m and then runs OutputToText on the resulting *.mat files.
