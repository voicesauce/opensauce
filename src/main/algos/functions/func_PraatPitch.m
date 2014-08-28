function [F0, err] = func_PraatPitch(wavfile, frameshift, frameprecision, minF0, maxF0, ...
                                     silthres, voicethres, octavecost, ...
                                     octavejumpcost, voiunvoicost, ...
                                     killoctavejumps, smooth, smoothbw, ...
                                     interpolate, method, datalen)
% [F0, err = func_PraatPitch(wavfile, frameshift, maxF0, minF0,
% voicethres, octavecost, octavejumpcost, voiunvoicost, datalen)
% Input:  wavfile - input wav file
%         frameshift - in seconds
%         maxF0 - maximum F0
%         minF0 - minimum F0
%         silthres - Silence threshold (Praat specific)
%         voicethres - Voice threshold (Praat specific)
%         octavecost - Octave Cost (Praat specific)
%         octavejumpcost - Octave Jump Cost (Praat specific)
%         voiunvoicost - Voiced/unvoiced Cost (Praat specific)
%         killoctavejumps - Kill octave jumps? (Praat specific)
%         smooth - Smooth? (Praat specific)
%         smoothbw - Smoothing bandwidth (Hz) (Praat specific)
%         interpolate - Interpolate? (Praat specific)
%         method - autocorrelation (ac) or cross-correlation (cc)
%         datalen - output data length
% Output: F0 - F0 values
%         err - error flag
% Notes:  This currently only works on PC and Mac.
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Modified by Kristine Yu 2010-10-16
% Copyright UCLA SPAPL 2010

% Modified by Kate Silverstein 2013-07-12
% --- KS Notes ---
% - You can use "testPraat.m" to test this function.
% - wavfile must be full path to wavfile (i.e. /Users/path-to-wavfile on
% Mac)
% 
% TODO: 
% 1. instead of passing in all 15 of these arguments, why not just
% pass in settings.praat and query the data stucture
% 2. haven't tested this on a PC yet

% settings 
iwantfilecleanup = 1;  %delete files when done

% check if we need to put double quotes around wavfile
if (wavfile(1) ~= '"')
    pwavfile = ['"' wavfile '"'];
else
    pwavfile = wavfile;
end

if (ispc)  % pc can run praatcon.exe
  disp('ISPC...')
  printf()
    cmd = sprintf(['Windows\\praatcon.exe Windows\\praatF0.praat %s %.3f ' ...
    '%.3f %.3f %.3f %.3f %.3f %.3f %.3f %d %d %.3f %d %s'], pwavfile, frameshift, minF0, maxF0, silthres, ...
                  voicethres, octavecost, octavejumpcost, voiunvoicost, ...
                  killoctavejumps, smooth, smoothbw, interpolate, method);
 elseif (ismac) % mac osx can run Praat using terminal, call Praat from
                % Nix/ folder

% KS this stuff seemed to be causing problems -- easier to just pass in the full path to the wavfile                
%   curr_dir = pwd;
%   %curr_wav = [curr_dir wavfile(2:end)]; % this passes in the file '/Users/kate/speech-tech/voice-sauce/VoiceSaucemong_f4_40_a.wav'
%   curr_wav = [curr_dir '/sounds/' wavfile];

             
% --- from praatF0.praat:
%    comment F0 Measurement Parameters
%    positive time_step 0.005 /frameshift
%    positive minimum_pitch 50 /minF0
%    positive maximum_pitch 500 /maxF0
%    positive silence_threshold 0.03 /silthres
%    positive voicing_threshold 0.45 /voicethres
%    positive octave_cost 0.01 /octavecost
%    positive octave_jump_cost 0.35 /ojc
%    positive voiced_unvoiced_cost 0.14 /voiunvoi
%    boolean kill_octave_jumps no /killoctavejumps
%    boolean smooth no /smooth
%    positive smooth_bandwidth 5 /smoothbw
%    boolean interpolate no /interpolate
%    sentence Method cc /method


% KS make sure wavfile exists before we pass the cmd to praat
  assert (exist(wavfile, 'file') ~= 0, ...
      'wav file [%s] not found / there is an error in the path to it.', wavfile);

  cmd = sprintf('$SAUCE_ROOT/src/main/praat/MacOS/Praat $SAUCE_ROOT/src/main/praat/Windows/praatF0.praat %s %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %d %d %.3f %d %s', ...
      wavfile, ...       %curr_wav, ... just pass in fulle path to wavfile instead of 'curr_wav'
      frameshift, ... 
      minF0, ...
      maxF0, ...
      silthres, ...
      voicethres, ...
      octavecost, ...
      octavejumpcost, ...
      voiunvoicost, ...
      killoctavejumps, ...
      smooth, ...
      smoothbw, ...
      interpolate, ...
      method);
  
 
else % otherwise  
    F0 = NaN; 
    err = -1;
    return;
end

% KS have to define f0file as a variable before you inquire as to existence as a file,
% otherwise error is thrown
f0file = '';

%call up praat for pc
if (ispc)
  err = system(cmd);
  if (err ~= 0)  % oops, error, exit now
    fprintf("func_PraatPitch: err=%d", err);
    F0 = NaN;
    if (iwantfilecleanup)
      if (exist(f0file, 'file') ~= 0)
        delete(f0file);
      end        
    end
    return;
  end
end

%call up praat for Mac OSX
if (ismac)
 err = unix(cmd);
  if (err ~= 0)  % oops, error, exit now
    printf('func_PraatPitch: err=%d', err);
    F0 = NaN;
    if (iwantfilecleanup)
      if (exist(f0file, 'file') ~= 0)
        delete(f0file);
      end        
    end
    return;
  end
end


% Get f0 file
if strcmp(method, 'ac') %if autocorrelation, get .praatac file
  f0file = [wavfile '.praatac'];
else
  f0file = [wavfile '.praatcc']; % else, cross-correlation, get .praatcc file
end


% praat call was successful, return F0 values
F0 = zeros(datalen, 1) * NaN; 

fid = fopen(f0file, 'rt');

% read the rest
C = textscan(fid, '%f %f', 'delimiter', '\n', 'TreatAsEmpty', '--undefined--');
fclose(fid);

t = round(C{1} * 1000);  % time locations from praat pitch track

%KY Since Praat outputs no values in silence/if no f0 value returned, must pad with leading
% undefined values if needed, so we set start time to 0, rather than t(1)

start = 0;
finish = t(end);
increment = frameshift * 1000;

for k=start:increment:finish
    [val, inx] = min(abs(t - k)); % try to find the closest value
    if (abs(t(inx) - k) > frameprecision * frameshift * 1000)  % no valid value found
        continue;
    end
    
    n = round(k / (frameshift * 1000)) + 1; % KY I added a one since
                                            % Matlab indexing starts at 1
                                            % not 0
    if (n < 1 || n > datalen)
        continue;
    end
    
    F0(n) = C{2}(inx);
end

if (iwantfilecleanup)
    if (exist(f0file, 'file') ~= 0)
        delete(f0file);
    end    
end
