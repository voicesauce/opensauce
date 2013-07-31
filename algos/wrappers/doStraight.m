function err = doStraight(settings)

printf('...skipping Straight...');
err = 0;
return;

% get relevant settings into memory
matfile = settings.matfile;
textgridfile = settings.textgridfile;
frameshift = settings.frameshift;
data_len = settings.data_len;
Fs = settings.Fs;
y = settings.y;

% 0 for success
err = 0;

if (exist(textgridfile, 'file') == 0)
    disp('no tgfile.')
    settings.useTextGrid = 0;
end

% if we went to use textgrid segments
if(settings.useTextGrid == 1)
    try
        [strF0, V] = func_StraightPitch(y, Fs, settings, textgridfile);
    catch
        err = 1; % 1 for fail
    end
else % otherwise
    try
        [strF0, V] = func_StraightPitch(y, Fs, settings);
    catch
        err = 1; % 1 for fail
    end
end

% cryptic error message
assert (err == 0, 'Something went wrong with Straight.');

% if (strcmp(settings.F0algorithm, 'F0 (Straight)') && err == 1)
%     disp('problem with STRAIGHT, unable to proceed.')
%     res = 1;
%     return;
% end

strF0 = strF0(1:frameshift:end); %drop samples if necessary

if (length(strF0) > data_len)
    strF0 = strF0(1:data_len);
elseif (length(strF0) < data_len)
    strF0 = [strF0; ones(data_len - length(strF0), 1) * NaN];
end

% save our work
if (exist(matfile, 'file'))
    save(matfile, 'strF0', 'Fs', '-append');
else
    save(matfile, 'strF0', 'Fs');
end
