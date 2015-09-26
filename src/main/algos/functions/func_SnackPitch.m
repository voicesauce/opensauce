function [F0, V, err] = func_SnackPitch(wavfile, windowsize, frameshift, maxF0, minF0)
% [F0, V, err] = func_SnackPitch(wavfile, windowsize, frameshift, maxF0, minF0)
% Input:  wavfile - input wav file
%         windowlength - windowlength in seconds
%         frameshift - in seconds
%         maxF0/minF0 - max and min thresholds
% Output: F0, V - F0 and voicing vectors
%         err - error flag
% Notes:  If on Windows/PC, this function will call up the Snack executable
% in the Windows folder. Otherwise, it will try to call up Snack - this
% require Snack to be installed beforehand.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009

%settings
TAG = 'func_SnackPitch.m';
iwantfilecleanup = 1;  %delete tcl,f0,frm files when done
tclfilename = 'tclforsnackpitch.tcl'; %produce tcl file to call snack
% make the wavfile acceptable to tcl in Snack
wavfile = strrep(wavfile, '[', '\[');
wavfile = strrep(wavfile, ']', '\]');
wavfile = ['"' wavfile '"'];
% snack parameters
% printf('%s : parameters : windowlength=%d/1000 frameshift=%d/1000 maxF0=%d minF0=%d\n', TAG, windowsize, frameshift, maxF0, minF0);
wl = double(str2num(windowsize))/1000.0;
fs = double(str2num(frameshift))/1000.0;
assert(wl > 0 && fs > 0, '%s : error : wl=%f fs=%f', TAG, wl, fs);


sWindow = num2str(wl);
sFrame = num2str(fs);
sMinF0 = minF0;
sMaxF0 = maxF0;

% sWindow = num2str(wl);
% sFrame = num2str(fs);
% sMinF0 = num2str(minF0);
% sMaxF0 = num2str(maxF0);

printf('sWindow=%s\n', sWindow);
printf('sFrame=%s\n', sFrame);
printf('sMinF0=%s\n', sMinF0);
printf('sMaxF0=%s\n', sMaxF0);

if (ispc)  % pc can run snack.exe
    wavfile = strrep(wavfile, '\', '\\');
    err = system(['bin\Windows\snack.exe pitch ' wavfile ' -method esps -framelength ' sFrame ' -windowlength ' sWindow ' -maxpitch ' sMaxF0 ' -minpitch ' sMinF0]);
    % err = system(['Windows\snack.exe pitch ' wavfile ' -method esps -framelength ' num2str(frameshift) ' -windowlength ' num2str(windowsize) ' -maxpitch ' num2str(maxF0) ' -minpitch ' num2str(minF0)]);
else
    % for *nix 
    %cmd = 'tclsh'; % for older Macs and 'nixes
    %cmd = 'wish8.6'; % seems to work for OSX Snow Leopard
    %cmd = 'wish84';  % for pc  
    cmd = 'wish8.4'
    fid = fopen(tclfilename, 'wt');
    fprintf(fid, '#!/bin/sh\n');
    fprintf(fid, '# the next line restarts with wish \\\n');
    fprintf(fid, 'exec wish8.6 "$0" "$@"\n\n');
    fprintf(fid, 'package require snack\n\n');
    fprintf(fid, 'snack::sound s\n\n');
    fprintf(fid, 's read %s\n\n', wavfile);
    fprintf(fid, 'set fd [open [file rootname %s].f0 w]\n', wavfile);
    % FLOATS are %f NOT %d !!!!
    fprintf(fid, 'puts $fd [join [s pitch -method esps -framelength %s -windowlength %s -maxpitch %s -minpitch %s] \\n]\n', sFrame, sWindow, sMaxF0, sMinF0);
    fprintf(fid, 'close $fd\n\n');
    fprintf(fid, 'exit');
    fclose(fid);
    err = system([cmd ' ' tclfilename]);
end

% change back into original file
wavfile = strrep(wavfile, '\[', '[');
wavfile = strrep(wavfile, '\]', ']');
pitchfile = [wavfile(2:end-4) 'f0'];  % this should be where the F0's are stored
% oops, exit now
if (err ~= 0)
    printf('%s : err != 0\n', TAG);
    F0 = NaN;
    V = NaN;
    if (iwantfilecleanup)
        pitchfile = strrep(pitchfile, '\\', '\');
        if (exist(pitchfile, 'file') ~= 0)
            delete(pitchfile);
        end
        % if (exist(tclfilename, 'file') ~= 0)
        %     delete(tclfilename);
        % end
    end
    return;
endif
   
% snack executed successfully, read out the F0 values
[F0, V, dummy1, dummy2] = textread(pitchfile, '%f %f %f %f');
if (iwantfilecleanup)
    pitchfile = strrep(pitchfile, '\\', '\');
    if (exist(pitchfile, 'file') ~= 0)
        delete(pitchfile);
    end
    if (exist(tclfilename, 'file') ~= 0)
        delete(tclfilename);
    end
end


