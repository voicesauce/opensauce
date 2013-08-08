function res = OutputToText(instance)
	printf('\nOutputting to text...\n');
	
	verbose = instance.verbose;

	% user settings
	settings = getSettings();

	% user output settings
	ott = getOutputSettings();

	output_dir = ott.OT_outputdir; % where *.csv files are going to be stored
	if (strcmp('', output_dir) == 1)
		output_dir = instance.wavdir;
	elseif (exist(output_dir, 'dir') == 0) % if outdir doesn't exist already, create it
		printf('==> Creating directory %s for output...\n', output_dir);
		status = mkdir(output_dir);
		assert (status == 1, 'Error: Unable to create directory %s', output_dir);
	end

	% full list of parameters that will be displayed in output file
	paramlist = func_getoutputparameterlist(); % list ALL possible parameters

	% make sure the matfile directory actually exists
	matdir = instance.matdir;
    assert (exist(matdir, 'dir') == 7, 'Error: couldnt find matfile directory [%s]', matdir); % 7 indicates matdir is a directory

	% build the list of matfiles to parse
	dirlisting = dir(fullfile(matdir, '*.mat'));
	n = length(dirlisting);
	matfiles = cell(1, n);
	fprintf('==> List of *.mat files to process: [')
	for k=1:n
		matfiles{k} = dirlisting(k).name;
		fprintf(' %s ', matfiles{k});
	end
	fprintf(']\n');
	

	% check output files, create new files for dump, and open them for writing
	delimiter = 44; % ascii for comma
	fids = zeros(6, 1);

	if (ott.asSingleFile == 1) % dump everything into one *.csv file
		fprintf('==> Dumping to single file [ %s ]\n', ott.OT_Single);
		fid = fopen([output_dir ott.dirdelimiter ott.OT_Single], 'wt');
		assert (fid ~= -1, 'Error: Unable to open file %s for output.', ott.OT_Single);
		writeFileHeaders(fid, paramlist, ott, delimiter, instance);

		if (verbose == 2)
			fprintf('\t!!! Done writing file header\n');
		end
		%fidEGG = -1; %FIXME
		fids = [fid fid fid fid fid fid];

	else % dump data into multiple files
		fprintf('==> Dumping to multiple files\n', ott.OT_Single);
		fid1 = fopen([output_dir ott.dirdelimiter ott.OT_F0CPPE], 'wt');
	    fid2 = fopen([output_dir ott.dirdelimiter ott.OT_Formants], 'wt');
	    fid3 = fopen([output_dir ott.dirdelimiter ott.OT_HA], 'wt');
	    fid4 = fopen([output_dir ott.dirdelimiter ott.OT_HxHx], 'wt');
	    fid5 = fopen([output_dir ott.dirdelimiter ott.OT_HxAx], 'wt');
	    fids = [fid1 fid2 fid3 fid4 fid5];

	    for k=1:length(fids)
	    	assert (fids(k) ~= -1, 'Error: unable to open %s for output', fids(k));
	    end

		% --- EGG stuff --- %
	    fidEGG = -1;
	    if (ott.OT_includeEGG == 1)
	        x = sprintf('\t ==> EGG ON ...\n');
	        disp(x);
	        fidEGG = fopen(ott.OT_EGG, 'wt');
	        if (fidEGG == -1)
	            x = sprintf('Error: unable to open EGG file %s for output.', ott.OT_EGG);
	            disp(x);
	            return;
	        end
	    end
	    fids = [fids fidEGG];
	    % --- /EGG stuff --- %

	    writeFileHeaders(fids, paramlist, ott, delimiter, instance);
	end %endif

	errorcnt = 0;
	uniquefids = unique(fids); % store # of unique fids
	messages = cell(length(matfiles) + 1, 1); % allocate some memory for error messages
	dirdelim = ott.dirdelimiter;

	% process every file in matfiles (M = length(matfiles))
	M = length(matfiles);
	for k=1:M
		matfile = [matdir dirdelim matfiles{k}];
		textgridfile = [instance.textgrid_dir dirdelim matfiles{k}(1:end-3) 'Textgrid'];
		if (verbose == 2)
			fprintf('\t!!! textgridfile = [ %s ]', textgridfile);
		end
		
		printf('\n\tProcessing [ %s ] ... \n', matfile);
		
		mdata = func_buildMData(matfile, ott.O_smoothwinsize); % get parameter data out of matfile (?)
		frameshift = settings.frameshift;

		if (isfield(mdata, 'frameshift'))
			frameshift = mdata.frameshift;
		end

		% find the max length of the data
		if (isfield(mdata, 'strF0')) % Straight
			maxlen = length(mdata.strF0) * frameshift;
		elseif (isfield(mdata, 'sF0')) % Snack
			maxlen = length(mdata.sF0) * frameshift;
		elseif (isfield(mdata, 'pF0')) % Praat
			maxlen = length(mdata.pF0) * frameshift;
		elseif (isfield(mdata, 'shrF0')) % SHR
			maxlen = length(mdata.shrF0) * frameshift;
		elseif (isfield(mdata, 'oF0')) % Other -- should be unreachable
			printf('Error: This line should be unreachable, but I guess its whatever.');
			maxlen = length(mdata.oF0) * frameshift;
		end

		% load up the textgrid data, or if it doesn't exist, use the whole file
		if (exist(textgridfile, 'file') == 0) % file not found, use start and end
			fprintf('\t ==> No TextGrid file [ %s ] found, using all data points...\n');
			start = 1;
			stop = maxlen;
			labels = {matfiles{k}};

		else % use textgrid start points
			fprintf('\t ==> Using TextGrid file [ %s ] ... ', textgridfile);
			ignorelabels = textscan(settings.TextgridIgnoreList, '%s', 'delimiter', ',');
			ignorelabels = ignorelabels{1};

			if (verbose == 2)
				fprintf('\t!!! Ignoring labels { %s } ... ', ignorelabels{1});
			end

			[labels, start, stop] = func_readTextgrid(textgridfile);

			%labels_tmp = [];
			labels_tmp = "";
			start_tmp = [];
			stop_tmp = [];

			for m=1:length(settings.TextgridTierNumber)
				inx = settings.TextgridTierNumber(m);
				if (inx <= length(labels))
					%labels_tmp = [labels_tmp; labels{inx}];
					labels_tmp = [labels{inx}];
					start_tmp = [start_tmp; start{inx}];
					stop_tmp = [stop_tmp; stop{inx}];
				end
			end

			labels = labels_tmp;
			start = start_tmp * 1000; % milliseconds
			stop = stop_tmp * 1000; % milliseconds

			% just pull out the start/stop of the labels that aren't ignored
			L = length(labels);
			inx = 1:L;
			for n=1:L
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

		end %endif

		% --- EGG stuff --- %
        % get the EGG file if requested
        [proceedEGG, EGGfile] = checkEGGfilename(matfiles{k}, ott);
        if (ott.OT_includeEGG == 1 && proceedEGG == 0)
            fprintf('\t ==> EGG file not found.\n');
            errorcnt = errorcnt + 1;
        end

        if (proceedEGG)
            [EGGData, EGGTime] = func_readEGGfile(EGGfile, settings.EGGheaders, settings.EGGtimelabel);
        end
        % --- /EGG stuff --- %

		% assume each file has the parameters in the mat file
		paramlist_valid = ones(length(paramlist), 1);

		% no segments -- complete dump
		if (ott.useSegments == 0)
			printf('\t ==> Complete dump (no segments) ...');
			% for each label, loop through and write out the selected parameters
			for n=1:length(start)
	            sstart = round(start(n) / frameshift);  % get the correct sample
	            sstop = round(stop(n) / frameshift);

	            % guard against 0 and maxlen
	            sstart(sstart == 0) = 1;
	            sstop(sstop > maxlen) = maxlen;

	            for s=sstart:sstop
	            	for m=1:length(uniquefids)
	            		if (uniquefids(m) == -1)
	            			continue;
	            		end

	                    fprintf(uniquefids(m), '%s%c', matfiles{k}, delimiter);

	                    if (ott.OT_includeTextgridLabels == 1)
	                        fprintf(uniquefids(m), '%s%c', labels{n}, delimiter);
	                        fprintf(uniquefids(m), '%.3f%c', start(n), delimiter);
	                        fprintf(uniquefids(m), '%.3f%c', stop(n), delimiter);
	                    end

	                    fprintf(uniquefids(m), '%.3f%c', s * frameshift, delimiter);
	                end %endfor (m)

	                % print out the selected params
	                for m=1:length(paramlist)
	                	val = settings.NotANumber; % default is NaN label
	                	C = textscan(paramlist{m}, '%s %s', 'delimiter', '(');
	                	fidinx = func_getfileinx(paramlist{m});
	                	param = C{2}{1}(1:end-1);

	                	if (isfield(mdata, param))
	                		% if (verbose == 2)
	                		% 	fprintf('param %s\n', param);
	                		% end
	                		data = mdata.(param);
	                		if (length(data) == 1 && isnan(data)) % guard against empty vectors
	                			paramlist_valid(m) = 0;
	                		else
	                			if (~isnan(data) && ~isinf(data(s)))
	                				val = sprintf('%.3f', data(s));
	                			end
	                		end
	                	else
	                		if (paramlist_valid(m) == 1)
	                			messages{k} = [messages{k} param ' not found.'];
	                			errorcnt = errorcnt + 1;
	                			paramlist_valid(m) = 0;
	                		end
	                	end %endif (isfield)

	                	fprintf(fids(fidinx), '%s%c', val, delimiter);
	                end %endfor (m)

	                % --- EGG STUFF --- %
                    % for the case where EGG was requested, but no EGG file was found
                    if (ott.OT_includeEGG == 1 && proceedEGG == 0)
                        fidinx = 6;
                        EGGheaders = textscan(settings.EGGheaders, '%s', 'delimiter', ',');
                        EGGheaders = EGGheaders{1};

                        for m=1:length(EGGheaders)
                            fprintf(fids(fidinx), '%s%c', settings.NotANumber, delimiter);
                        end
                    end

                    % process EGG stuff
                    if (proceedEGG)
                        fidinx = 6;

                        % find the time segment from EGGTime, use that to index EGGData
                        t = s * frameshift; % this is the time in ms. Get the closest EGGTime to t
                        [val, s_EGG] = min(abs(EGGTime - t));

                        if (abs(t - EGGTime(s_EGG)) / t > 0.05) % if t_EGG is more than 5% away from t, it is not correct
                            for m=1:length(EGGData)
                                fprintf(fids(fidinx), '%s%c', settings.NotANumber, delimiter);
                            end
                        else
                            for m=1:length(EGGData)
                                fprintf(fids(fidinx), '%.3f%c', EGGData{m}(s_EGG), delimiter);
                            end
                        end
                    end %endif (proceedEGG)
                    % --- /EGG STUFF --- %

	                % finally, write out new line
	                for m=1:length(uniquefids)
	                	if (uniquefids(m) == -1)
	                		continue;
	                	end
	                	fprintf(uniquefids(m), '\n');
	                end % endfor (m)
	            end % endfor (s)
	        end % endfor (n)


	    % outputting with segments
		else 
			nseg = ott.OT_numSegments;
			fprintf('\t ==> Dump using %d segments...', nseg);

			for n=1:length(start) % for each segment, print out overall mean, then part means
				
				for m=1:length(uniquefids) % print out the header stuff
					if (uniquefids(m) == -1)
						continue;
					end
	                fprintf(uniquefids(m), '%s%c', matfiles{k}, delimiter);
	                if (ott.OT_includeTextgridLabels == 1)
	                    fprintf(uniquefids(m), '%s%c', labels{n}, delimiter);
	                    fprintf(uniquefids(m), '%.3f%c', start(n), delimiter);
	                    fprintf(uniquefids(m), '%.3f%c', stop(n), delimiter);
	                end
	            end % endfor (m)

	            % get array of start and stop times for the segments. First one
	            % is the total mean
	            tsegs = linspace(start(n), stop(n), nseg+1);
	            tstart = zeros(nseg+1, 1);
	            tstop = zeros(nseg+1, 1);
	            tstart(1) = start(n);
	            tstop(1) = stop(n);
	            tstart(2:end) = tsegs(1:nseg);
	            tstop(2:end) = tsegs(2:nseg+1);
	            
	            % get the sample equivalents
	            sstart = round(tstart ./ frameshift);
	            sstop = round(tstop ./ frameshift);
	            
	            % don't output segments if Nseg == 1
	            if (nseg == 1)
	                sstart = sstart(1);
	                sstop = sstop(1);
	            end

	            % guard against 0 and maxlen
	            sstart(sstart == 0) = 1;
	            sstop(sstop > maxlen) = maxlen;

	            for m=1:length(paramlist)
	            	val = settings.NotANumber; %default value is no value

	            	fidinx = func_getfileinx(paramlist{m});
	            	C = textscan(paramlist{m}, '%s %s', 'delimiter', '(');
	            	param = C{2}{1}(1:end-1);
		           	if (isfield(mdata, param))
	                    data = mdata.(param);
	                    
	                    for p=1:length(sstart)
	                        if (length(data)==1 && isnan(data))
	                            paramlist_valid(m) = 0;
	                        else
	                        	warning off;
	                            dataseg = data(sstart(p):sstop(p));
	                            mdataseg = mean(dataseg(~isnan(dataseg) & ~isinf(dataseg)));
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
	                end %endif
	            end %endfor (m)

	            % --- EGG STUFF --- %
                    % this is the case when EGG was requested but no egg file was found
                if (ott.OT_includeEGG == 1 && proceedEGG == 0)
                    fidinx = 6;
                    EGGheaders = textscan(settings.EGGheaders, '%s', 'delimiter', ',');
                    EGGheaders = EGGheaders{1};
                    for m=1:length(EGGheaders)
                        for p=1:length(tstart)
                            fprintf(fids(fidinx), '%s%c', settings.NotANumber, delimiter);
                        end
                    end
                end

                    % process EGG stuff
                if (proceedEGG)
                    fidinx = 6;

                    for m=1:length(EGGData)
                        for p=1:length(tstart)
                            EGGInx = (EGGTime >= tstart(p)) & (EGGTime <= tstop(p));
                            meanval = mean(EGGData{m}(EGGInx));
                            if (~isempty(meanval) && ~isnan(meanval) && ~isinf(meanval))
                                val = sprintf('%.3f', meanval);
                            else
                                val = settings.NotANumber;
                            end
                            fprintf(fids(fidinx), '%s%c', val, delimiter);
                        end
                    end
                end
                % --- /EGG STUFF --- %


		        % finally, write out new line
	            for m=1:length(uniquefids)
	                if (uniquefids(m) == -1)
	                    continue;
	                end
	                fprintf(uniquefids(m), '\n');
	            end %endfor (m)

	        end %endfor (n)

	    end %endif

	end %endfor (k)

	for k=1:length(uniquefids)
		if (uniquefids(k) == -1)
			continue;
		end
		fclose(uniquefids(k));
	end

	fprintf('\n...Done.');

	if (errorcnt > 0)
		fprintf(' Warning: errorcnt > 0\n');
	else
		fprintf('\n');
	end

	res = 0;

end %endfunction


function writeFileHeaders(fids, paramlist, outs, delimiter, instance)
	% fids = file ids; paramlist = output parameter list; outs = outputsettings
	% delimiter = filesystem delimiter
	if (instance.verbose == 2)
		fprintf('\t!!! Writing file headers...\n');
	end

	for k=1:length(fids)
		% this should never happen becaused we already checked
		% assert (fids(k) ~= -1, 'Error: writeFileHeaders: fids(%d) == -1', k);
		if (fids(k) == -1)
			continue;
		end

		fprintf(fids(k), 'Filename%c', delimiter);

		% include textgrid labels
		if (outs.OT_includeTextgridLabels == 1) 
			fprintf(fids(k), 'Label%c', delimiter);
		    fprintf(fids(k), 'seg_Start%c', delimiter);
		    fprintf(fids(k), 'seg_End%c', delimiter);
		end

		% only print timestamp when doing complete dump
		if (outs.useSegments == 0)
			fprintf(fids(k), 't_ms%c', delimiter);
		end
	end

	% make file ids same length as using multiple files
	if (length(fids) == 1)
		% --- EGG STUFF --- %
        if (outs.OT_includeEGG)
            fids = [fids fids fids fids fids fids];
        % --- /EGG STUFF --- %
    	else
			fids = [fids fids fids fids fids -1];
		end
	end

	% separate case for complete data dump
	if (outs.useSegments == 0)
		for k=1:length(paramlist)
			fidinx = func_getfileinx(paramlist{k});
			C = textscan(paramlist{k}, '%s %s', 'delimiter', '(');
			fprintf(fids(fidinx), '%s%c', C{2}{1}(1:end-1), delimiter);
		end

		% --- EGG STUFF --- %
        if (outs.OT_includeEGG)
            fidinx = 6;
            user_settings = getSettings();
            C = textscan(user_settings.EGGheaders, '%s', 'delimiter', ',');
            for n=1:length(C{1})
                fprintf(fids(fidinx), '%s%c', C{1}{n}, delimiter);
            end
        end
        % --- /EGG STUFF --- %

		% finally, write out a new line
		fids = unique(fids);
		for k=1:length(fids)
			if (fids(k) == -1)
				continue;
			end
			fprintf(fids(k), '\n');
		end

	% using segments
	else 
		nseg = outs.OT_numSegments;

		% for each parameter, print the mean, followed be the means of each segment
		for k=1:length(paramlist)
			fidinx = func_getfileinx(paramlist{k}); % find where/into which file we should put output for this param
			C = textscan(paramlist{k}, '%s %s', 'delimiter', '(');
			label = C{2}{1}(1:end-1);

			fprintf(fids(fidinx), '%s_mean%c', label, delimiter);
			if (nseg > 1)
				for n=1:nseg
					segno = sprintf('%3d', n);
					segno = strrep(segno, ' ', '0');
					fprintf(fids(fidinx), '%s_mean%s%c', label, segno, delimiter);
				end
			end
		end

		% --- EGG STUFF --- %
        if (outs.OT_includeEGG)
            fidinx = 6;
            user_settings = getSettings();
            C = textscan(user_settings.EGGheaders, '%s', 'delimiter', ',');
            for n=1:length(C{1})
                fprintf(fids(fidinx), '%s_mean%c', C{1}{n}, delimiter);

                if (nseg > 1)
                    for m=1:nseg
                        segno = sprintf('%3d', m);
                        segno = strrep(segno, ' ', '0');
                        fprintf(fids(fidinx), '%s_means%s%c', C{1}{n}, segno, delimiter);
                    end
                end
            end
        end
        % --- /EGG STUFF --- %

		% finally, write out a new line
		fids = unique(fids);
		for k=1:length(fids)
			if (fids(k) == -1)
				continue;
			end
			fprintf(fids(k), '\n');
		end %endfor
	end %endfor
end %endfunction


function [proceedEGG, EGGfile] = checkEGGfilename(matfile, ott)
    if (ott.OT_includeEGG == 0)
        proceedEGG = 0;
        EGGfile = '';
        return;
    end

    EGGfile = [ott.OT_EGGdir ott.dirdelimiter matfile(1:end-3) 'egg']; % attempt to open .egg
    fprintf('\t ==> Checking EGG filename [ %s ]\n', EGGfile);
    if (exist(EGGfile, 'file') == 0)
        proceedEGG = 0;

        if (length(matfile) > 10)
            if (strcmpi(matfile(end-9:end-4), '_Audio')) %case insensitive
                EGGfile = [ott.OT_EGGdir ott.dirdelimiter matfile(1:end-9) 'ch1.egg']; % try with ch1 first

                if (exist(EGGfile, 'file') == 0)
                    EGGfile = [ott.OT_EGGdir ott.dirdelimiter matfile(1:end-10) '.egg']; % next try with .egg w/0 _Audio
                    if (exist(EGGfile, 'file') == 0)
                        proceedEGG = 0;
                    else
                        proceedEGG = 1;
                    end
                else
                    proceedEGG = 1;
                end
            end
        end
    else
        proceedEGG = 1;
    end
end %endfunction

 









