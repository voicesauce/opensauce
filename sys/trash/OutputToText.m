function res = OutputToText(cp)
% If this function isn't working, make sure to check
% settings/getOutputSettings.m

cleanup = 0;
if (nargin == 1)
    cleanup = 1;
end

verbose = 1;

printf('Outputting *.mat files to text format...\n');

settings = getSettings();
opsettings = getOutputSettings();

output_dir = opsettings.OT_outputdir;
if (exist(output_dir, 'dir') == 0)
    printf('Creating directory [%s] for text output...', output_dir);
    status = mkdir(output_dir);
    assert (status == 1, 'couldnt create directory [%s]', output_dir);
end

paramlist = func_getoutputparameterlist();
matdir = opsettings.OT_matdir;
assert (exist(matdir, 'dir') == 7, 'couldnt find matfile directory [%s]', matdir); % 7 indicates matdir is a directory

dirlisting = dir(fullfile(matdir, '*.mat'));
n = length(dirlisting);
matfiles = cell(1, n);
for k=1:n
    matfiles{k} = dirlisting(k).name;
end
printf('list of .mat files to process: ');
for k=1:length(matfiles)
    printf(' %s ', matfiles{k});
end
printf('\n');

delimiter = 44; % ascii for comma

% check output files
fids = zeros(6, 1);
if (opsettings.asSingleFile == 1)
    fid = fopen([output_dir opsettings.dirdelimiter opsettings.OT_Single], 'wt');
    if (fid == -1)
        disp('Error: unable to open file for output.')
        return;
    end
    
    writeFileHeaders(fid, paramlist, opsettings, delimiter);
    fidEGG = -1; % TODO: EGG stuff
    fids = [fid fid fid fid fid fid];
    
    % multiple files
else
    fid1 = fopen([output_dir opsettings.dirdelimiter opsettings.OT_F0CPPE], 'wt');
    fid2 = fopen([output_dir opsettings.dirdelimiter opsettings.OT_Formants], 'wt');
    fid3 = fopen([output_dir opsettings.dirdelimiter opsettings.OT_HA], 'wt');
    fid4 = fopen([output_dir opsettings.dirdelimiter opsettings.OT_HxHx], 'wt');
    fid5 = fopen([output_dir opsettings.dirdelimiter opsettings.OT_HxAx], 'wt');
    
    fids = [fid1 fid2 fid3 fid4 fid5];
    
    for k=1:length(fids)
        if (fids(k) == -1)
            X = ['Error: Unable to open ', fids(k), ' for output.'];
            disp(X)
            return;
        end
    end
    writeFileHeaders(fids, paramlist, opsettings, delimiter);
end

errorcnt = 0;
uniquefids = unique(fids); % store # of unique fids
messages = cell(length(matfiles) + 1, 1);

% % process every file in matfiles
for k=1:length(matfiles)
    % if (verbose)
    %     printf(' STARTING MAIN LOOP \n\n');
    %     printf(' length(matfiles) = [ %d ], k = [ %d ]\n', length(matfiles), k);
    % end
    matfile = [opsettings.OT_matdir opsettings.dirdelimiter matfiles{k}];
    TGfile = [opsettings.OT_Textgriddir opsettings.dirdelimiter matfiles{k}(1:end-3) 'Textgrid'];
    printf('matfile: %s,  textgridfile: %s\n', matfile, TGfile);
    messages{k} = sprintf('%d/%d. %s: ', k, length(matfiles), matfiles{k});
    mdata = func_buildMData(matfile, opsettings.O_smoothwinsize);
    frameshift = settings.frameshift;
    
    if (isfield(mdata, 'frameshift'))
        frameshift = mdata.frameshift;
    end
    
    % find the max length of the data
    if (isfield(mdata, 'strF0'))
        maxlen = length(mdata.strF0) * frameshift;
    elseif (isfield(mdata, 'sF0'))
        maxlen = length(mdata.sF0) * frameshift;
    elseif (isfield(mdata, 'pF0'))
        maxlen = length(mdata.pF0) * frameshift;
    elseif (isfield(mdata, 'oF0'))
        maxlen = length(mdata.oF0) * frameshift;
    end
    
    
    
    % load up the textgrid data, or if it doesn't exist, use the whole file
    if (exist(TGfile, 'file') == 0) % file not found, use start and end
        printf('text grid file not found / DNE. using all data points.\n');
        messages{k} = [messages{k} 'Textgrid not found - using all data points'];
        
        start = 1;
        stop = maxlen;
        labels = {matfiles{k}};
        
        
    else % use textgrid start points
        printf('textgrid file found.\n');
        ignorelabels = textscan(settings.TextgridIgnoreList, '%s', 'delimiter', ',');
        ignorelabels = ignorelabels{1};
        
        %[labels, start, stop] = func_readTextgrid(TGfile);
        [labels, start, stop] = readTextGrid(TGfile);



        % if (verbose)
        %     lab = labels{1};
        %     n = length(lab);
        %     printf('labels = ');
        %     for k=1:n
        %         printf(' (%d)  =  %s ', k, lab{k});
        %     end
        %     printf('\n');
        % end

        labels_tmp = [];
        start_tmp = [];
        stop_tmp = [];
        
        for m=1:length(settings.TextgridTierNumber)
            inx = settings.TextgridTierNumber(m);
            if (inx <= length(labels))
                labels_tmp = [labels_tmp; labels{inx}];
                start_tmp = [start_tmp; start{inx}];
                stop_tmp = [stop_tmp; stop{inx}];
            end
        end
        
        labels = labels_tmp;
        start = start_tmp * 1000; % milliseconds
        stop = stop_tmp * 1000; % milliseconds
        
        % just pull out the start/stop of the labels that aren't
        % ignored
        inx = 1:length(labels);
        for n=1:length(labels)
            switch(labels{n})
                case ignorelabels
                    inx(n) = 0;
            end
        end
        inx = unique(inx);
        inx(inx == 0) = [];
        labels = labels(inx);
        start = start(inx);
        stop = stop(inx);

        len_labs = length(labels);
        printf('length labels = [ %d ] \n', len_labs);
        for it=1:len_labs
            printf(' %s  %.4f  %.4f \n', labels{it}, start(it), stop(it));
        end


    end
    
    % TODO: EGG stuff
    
    % assume each file has the parameters in the mat file
    paramlist_valid = ones(length(paramlist), 1);
    
    % no segments - complete dump
    if(opsettings.OT_noSegments == 1)
        % for each label, loop through and write out the selected
        % parameters
        for n=1:length(start)
            sstart = round(start(n) / frameshift);  % get the correct sample
            sstop = round(stop(n) / frameshift);
            
            sstart(sstart == 0) = 1; % special case for t = 0
            sstop(sstop > maxlen) = maxlen; % special case for t=maxlen
            for s=sstart:sstop
                
                for m=1:length(uniquefids)
                    
                    if (uniquefids(m) == -1)
                        continue;
                    end
                    
                    fprintf(uniquefids(m), '%s%c', matfiles{k}, delimiter);
                    
                    if (opsettings.OT_includeTextgridLabels == 1)
                        fprintf(uniquefids(m), '%s%c', labels{n}, delimiter);
                        fprintf(uniquefids(m), '%.3f%c', start(n), delimiter);
                        fprintf(uniquefids(m), '%.3f%c', stop(n), delimiter);
                    end
                    
                    
                    fprintf(uniquefids(m), '%.3f%c', s * frameshift, delimiter);
                end
                
                
                % print out the selected params
                for m=1:length(paramlist)
                    
                    val = settings.NotANumber;  % default is the NaN label
                    
                    C = textscan(paramlist{m}, '%s %s', 'delimiter', '(');
                    fidinx = func_getfileinx(paramlist{m});
                    param = C{2}{1}(1:end-1);
                    
                    if (isfield(mdata, param))
                        data = mdata.(param);
                        if (length(data)==1 && isnan(data)) % guard against empty vectors
                            paramlist_valid(m) = 0;
                        else
                            if (~isnan(data(s)) && ~isinf(data(s)))
                                val = sprintf('%.3f', data(s));
                            end
                        end
                    else
                        if (paramlist_valid(m) == 1)
                            messages{k} = [messages{k} param ' not found, '];
                            %                             set(MBoxHandles.listbox_messages, 'String', messages, 'Value', k);
                            %                             drawnow;
                            errorcnt = errorcnt + 1;
                            paramlist_valid(m) = 0;
                        end
                    end
                    
                    fprintf(fids(fidinx), '%s%c', val, delimiter);
                    
                end
                
                % TODO more egg stuff
                
                % finally, write out new line
                for m=1:length(uniquefids)
                    if (uniquefids(m) == -1)
                        continue;
                    end
                    fprintf(uniquefids(m), '\n');
                end
            end
        end
        
        % outputing with segments
    else

        Nseg = opsettings.OT_numSegments;
        
        % for each segment, print out overall mean, then part means
        for n=1:length(start)
            % print out the header stuff
            for m=1:length(uniquefids)

                if (uniquefids(m) == -1)
                    continue;
                end
                

                fprintf(uniquefids(m), '%s%c', matfiles{k}, delimiter);
                if (opsettings.OT_includeTextgridLabels == 1)
                    fprintf(uniquefids(m), '%s%c', labels{n}, delimiter);
                    fprintf(uniquefids(m), '%.3f%c', start(n), delimiter);
                    fprintf(uniquefids(m), '%.3f%c', stop(n), delimiter);
                end
            end
            
            % get array of start and stop times for the segments. First one
            % is the total mean
            tsegs = linspace(start(n), stop(n), Nseg+1);
            tstart = zeros(Nseg+1, 1);
            tstop = zeros(Nseg+1, 1);
            tstart(1) = start(n);
            tstop(1) = stop(n);
            tstart(2:end) = tsegs(1:Nseg);
            tstop(2:end) = tsegs(2:Nseg+1);
            
            % get the sample equivalents
            sstart = round(tstart ./ frameshift);
            sstop = round(tstop ./ frameshift);
            
            % don't output segments if Nseg == 1
            if (Nseg == 1)
                sstart = sstart(1);
                sstop = sstop(1);
            end
            
            % guard against 0 and maxlen
            if (sstart == 0)
                sstart = 1;
            end

            if(sstop > maxlen)
                sstop = maxlen;
            end


            % sstart(sstart == 0) = 1;
            % sstop(sstop > maxlen) = maxlen;
            
            for m=1:length(paramlist)
                val = settings.NotANumber;  % default value is no value
                
                fidinx = func_getfileinx(paramlist{m});
                C = textscan(paramlist{m}, '%s %s', 'delimiter', '(');
                param = C{2}{1}(1:end-1);

                if (isfield(mdata, param))
                    data = mdata.(param);
                    
                    for p=1:length(sstart)
                        if (length(data)==1 && isnan(data))
                            paramlist_valid(m) = 0;
                        else
                            dataseg = data(sstart(p):sstop(p));


                            mdataseg = mean(dataseg(~isnan(dataseg) & ~isinf(dataseg))); %FIXME: throws div-by-zero warnings in octave


                            if (~isempty(mdataseg) && ~isnan(mdataseg) && ~isinf(mdataseg))
                                val = sprintf('%.3f', mdataseg);
                            end
                        end
                        fprintf(fids(fidinx), '%s%c', val, delimiter);
                    end
                else
                    if (paramlist_valid(m) == 1)
                        messages{k} = [messages{k} param ' not found, '];
                        errorcnt = errorcnt + 1;
                        paramlist_valid(m) = 0;
                    end
                    
                    for p=1:length(sstart)
                        fprintf(fids(fidinx), '%s%c', val, delimiter);
                    end
                end
                
            end
            %TODO EGG stuff
            
            % finally, write out new line
            for m=1:length(uniquefids)
                if (uniquefids(m) == -1)
                    continue;
                end
                fprintf(uniquefids(m), '\n');
            end
        end
    end
end



for k=1:length(uniquefids)
    if (uniquefids(k) == -1)
        continue;
    end
    fclose(uniquefids(k));
end

disp('Done.')

if (cleanup == 1)
    datalist = dir(fullfile(output_dir, '*.csv'));
    n = length(datalist);
    X = sprintf('Cleaning up %d *.csv files in %s', n, output_dir);
    disp(X)
    for k=1:n
        datfile = [output_dir '/' datalist(k).name];
        if (exist(datfile, 'file'))
            delete(datfile)
        end
    end
end
% if (errorcnt > 0)
%     X = ['There may have been some errors'];
%     disp(X)
%     % for k=1:length(messages)
%     %     disp(messages{k})
%     % end
res = 0; % 0 for success
end





function writeFileHeaders(fids, paramlist, settings, delimiter)
disp('writing file headers...')
for k=1:length(fids)
    if (fids(k) == -1)
        continue;
    end
    
    fprintf(fids(k), 'Filename%c', delimiter);
    if(settings.OT_includeTextgridLabels == 1)
        fprintf(fids(k), 'Label%c', delimiter);
        fprintf(fids(k), 'seg_Start%c', delimiter);
        fprintf(fids(k), 'seg_End%c', delimiter);
    end
    
    % only print a time stamp when doing complete dumps
    if(settings.OT_noSegments == 1)
        fprintf(fids(k), 't_ms%c', delimiter);
    end
end


% make file ids same length as using multiple files
% TODO: include EGG
if (length(fids) == 1)
    fids = [fids fids fids fids fids -1];
end

% separate case for complete data dump
if (settings.OT_noSegments == 1)
    for k=1:length(paramlist)
        fidinx = func_getfileinx(paramlist{k});
        C = textscan(paramlist{k}, '%s %s', 'delimiter', '(');
        fprintf(fids(fidinx), '%s%c', C{2}{1}(1:end-1), delimiter);
    end
    %TODO EGG stuff
    
    % finally, write out new line
    fids = unique(fids);
    for k=1:length(fids)
        if (fids(k) == -1)
            continue;
        end
        fprintf(fids(k), '\n');
    end
    
    % using segments
else
    Nseg = settings.OT_numSegments;
    
    % for each parameter, print the mean, followed by th emeans of each
    % segment
    for k=1:length(paramlist)
        fidinx = func_getfileinx(paramlist{k});
        C = textscan(paramlist{k}, '%s %s', 'delimiter', '(');
        label = C{2}{1}(1:end-1);
        fprintf(fids(fidinx), '%s_mean%c', label, delimiter);
        if (Nseg > 1)
            for n=1:Nseg
                segno = sprintf('%3d', n);
                segno = strrep(segno, ' ', '0');
                fprintf(fids(fidinx), '%s_mean%s%c', label, segno, delimiter);
            end
        end
    end
    % TODO: EGG stuff
    
    % finally, write out a new line
    fids = unique(fids);
    for k=1:length(fids)
        if (fids(k) == -1)
            continue;
        end
        fprintf(fids(k), '\n');
    end
end
end



