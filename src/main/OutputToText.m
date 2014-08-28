function result = OutputToText(ott_settings_mat, settings_mat, outdir, matdir)
	% TODO list:
	% - finish Textgrid stuff
	% - finish EGG stuff
	% - only write e.g. HxAx.csv if there are corresponding fieldnames in matfiles
	% - validate/prune ott settings
	% - validate/prune/unify ott, user settings (e.g. dir delimiter)
	result = -1; 
	TAG = 'OutputToText : ';
	printf('\nOutput to text...\n'); 
	% printf('%s ott=%s settings=%s\n', TAG, ott_settings_mat, settings_mat);
	ott = load(ott_settings_mat); % output settings from output config file (e.g. config/output.config)
	user = load(settings_mat); % user settings from sauce config file (e.g. config/sauce.config)
	assert(exist(outdir, 'dir') == 7);
	outdir = [outdir '/']; 
	% printf('outdir=%s matdir=%s\n', outdir, matdir);
	paramlist = func_getoutputparameterlist(); % all possible parameters
	assert(exist(matdir, 'dir') == 7);
	% load in the *.mat files
	mlisting = dir(fullfile(matdir, '*.mat'));
	m = length(mlisting);
	matfiles = cell(1,m);
	for i=1:m
		% printf('%s\n', mlisting(i).name);
		matfiles{i} = mlisting(i).name;
	endfor
	delim = 44; 
	fids = writeFileHeaders(outdir, paramlist, ott, delim);
	assert(length(matfiles)==m);
	errors = 0; fidset = unique(fids); dirdelim = ott.dirdelimiter;
	% process the files and write them out to disk
	for i=1:m
		matfile = [matdir dirdelim matfiles{i}];
		printf('%s processing file: %s , (%d/%d)\n', TAG, matfile, i, m);
		writeFile(matfile, i, ott, user, matfiles, paramlist, fids);
	endfor
	% close the files we've opened
	for k=1:length(fidset)
		fclose(fidset(k));
	endfor
	printf('%s done.\n');
	result = 0
end

function result = writeFile(matfile, curr, ott, user, matfiles, paramlist, fids)
	TAG = 'OutputToText : '; result = -1;
	delim = 44;
	dirdelim = ott.dirdelimiter;
	fidset = unique(fids);
	tgdir = user.textgrid_dir;
	tgfile = [tgdir dirdelim matfiles{curr}(1:end-3) 'Textgrid'];
	printf('Texgrid file %s exists?...', tgfile);
	useTG = false;
	if (exist(tgfile, 'file') ~= 0 && user.useTextGrid)
		printf('found.\n', tgfile);
		useTG = true;
	else
		printf('useTextGrid: %d\n', user.useTextGrid)
	endif
	mdata = func_buildMData(matfile, ott.smoothwinsize);
	frameshift = user.frameshift;
	if (isfield(mdata, 'frameshift')) % this could be wrong if the mat file has its own frameshift
		frameshift = mdata.frameshift; 
	endif
	% find the max length of the data
	fields = {'strF0', 'sF0', 'pF0', 'shrF0', 'oF0'};
	maxlen = -1;
	for i=1:length(fields)
		if (isfield(mdata, fields{i}))
			len = length(mdata.(fields{i})) * frameshift;
			if (len >= maxlen)
				maxlen = len;
			endif
		endif
	endfor
	% fprintf('%s found maxlen=%d\n', TAG, maxlen);
	if (~useTG)
		start = 1; stop = maxlen; labels = {matfiles{curr}};
	else
		ignore = textscan(user.TextgridIgnoreList, '%s', 'delimiter', '|');
		ignore = ignore{1};
		[labels, start, stop] = func_readTextgrid(tgfile);
		labelsTmp = ""; startTmp = []; stopTmp = [];
		for i=1:length(user.TextgridTierNumber)
			inx = user.TextgridTierNumber(i);
			if (inx <= length(labels))
				labelsTmp = [labels{inx}]; 
				startTmp = [startTmp; start{inx}]; 
				stopTmp = [stopTmp; stop{inx}];
			endif
		endfor
		labels = labelsTmp; 
		start = startTmp*1000; % milliseconds
		stop = stopTmp*1000; % milliseconds
		% just null out the start/stop of the labels that aren't ignored
		L = length(labels);
		inx = 1:L;
		for i=1:L
			switch(labels{i})
			case ignore
				inx(i) = 0;
			endswitch
		endfor
		inx = unique(inx); inx(inx == 0) = [];
		labels = labels(inx); start = start(inx); stop = stop(inx);
	endif

	% TODO EGG stuff

	% assume each file has the parameters in the mat file
	paramlist_valid = ones(length(paramlist), 1);
	if (~ott.useSegments)
		for i=1:length(start)
			sstart = round(start(i)/frameshift); sstop = round(stop(i)/frameshift);
			% guard against 0 and maxlen
			sstart(sstart == 0) = 1; sstop(sstop>maxlen) = maxlen;
			for s=sstart:sstop
				for j=1:length(fidset)
					fprintf(fidset(j), '%s%c', matfiles{curr}, delim);
					if (ott.includeTextgridLabels == 1)
                        fprintf(fidset(j), '%s%c', labels{i}, delim);
                        fprintf(fidset(j), '%.3f%c', start(i), delim);
                        fprintf(fidset(j), '%.3f%c', stop(i), delim);
                    endif
					fprintf(fidset(j), '%.3f%c', s*frameshift, delim);
				endfor
				for j=1:length(paramlist)
					val = user.NotANumber;
					C = textscan(paramlist{j}, '%s %s', 'delimiter', '(');
					idx = func_getfileinx(paramlist{j});
					param = C{2}{1}(1:end-1);
					if (isfield(mdata, param))
						data = mdata.(param);
						if (~isnan(data) && ~isinf(data))
							val = sprintf('%.3f', data(s));
						else
							paramlist_valid(j) = 0;
						endif
					else
						if (paramlist_valid(j) == 1)
							paramlist_valid(j) = 0;
						endif
					endif
					if (paramlist_valid(j) == 1)
						fprintf(fids(idx), '%s%c', val, delim);
					endif
				endfor
				% TODO EGG stuff
				% write out a new line
				for j=1:length(fidset)
					fprintf(fidset(j), '\n');
				endfor %k
			endfor %s=sstart:sstop
		endfor %j=1:length(start)
	else
		% multiple segments
		nseg = ott.numSegments;
		for i=1:1:length(start)
			for j=1:length(fidset)
				fprintf(fidset(j), '%s%c', matfiles{curr}, delim);
				if (ott.includeTextgridLabels == 1)
                    fprintf(fidset(j), '%s%c', labels{i}, delim);
                    fprintf(fidset(j), '%.3f%c', start(i), delim);
                    fprintf(fidset(j), '%.3f%c', stop(i), delim);
                endif
			endfor
            % get array of start and stop times for the segments. First one
            % is the total mean
            tsegs = linspace(start(i), stop(i), nseg+1);
            tstart = zeros(nseg+1, 1);
            tstop = zeros(nseg+1, 1);
            tstart(1) = start(i);
            tstop(1) = stop(i);
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
            sstart(sstart==0) = 1;
            sstop(sstop>maxlen) = maxlen;
            for j=1:length(paramlist)
            	val = user.NotANumber;
        		fidinx = func_getfileinx(paramlist{j});
            	C = textscan(paramlist{j}, '%s %s', 'delimiter', '(');
            	param = C{2}{1}(1:end-1);
	           	if (isfield(mdata, param))
                    data = mdata.(param);
                    for p=1:length(sstart)
                        if (length(data)==1 && isnan(data))
                            paramlist_valid(j) = 0;
                        else
                        	warning off;
                            dataseg = data(sstart(p):sstop(p));
                            mdataseg = mean(dataseg(~isnan(dataseg) & ~isinf(dataseg)));
                            if (~isempty(mdataseg) && ~isnan(mdataseg) && ~isinf(mdataseg))
                                val = sprintf('%.3f', mdataseg);
                            end
                        end
                        fprintf(fids(fidinx), '%s%c', val, delim);
                    end
                else
                    if (paramlist_valid(j) == 1)
                        % messages{k} = [messages{k} param ' not found, '];
                        % errorcnt = errorcnt + 1;
                        paramlist_valid(j) = 0;
                    endif
                    for p=1:length(sstart)
                        fprintf(fids(fidinx), '%s%c', val, delim);
                    endfor
                endif
            endfor %j=1:length(paramlist)
        endfor %i=1:length(start)
    endif % useSegments
 %    % TODO EGG stuff
	% % finally, write out new line
    for m=1:length(fidset)
        if (fidset(m) == -1)
            continue;
        else
	        fprintf(fidset(m), '\n');
	    endif
    endfor
	result = 0
end

function fids = writeFileHeaders(output_dir, paramlist, ott, delim)
	TAG = 'OutputToText : ';
	printf('%s writing file headers...', TAG);
	fids = zeros(6,1);
	if (ott.asSingleFile == 1)
		fname = ott.single_filename;
		printf('dumping to single file: %s\n', fname);
		fid = fopen([output_dir ott.dirdelimiter fname], 'wt');
		assert(fid ~= -1, '%s error : unable to open file %s for output.', TAG, fname);
		fids = [fid fid fid fid fid fid];
	else
		printf('dumping to multiple files\n');
		% TODO only write these out if e.g. H1 is present in *.mat file fieldnames
		fid1 = fopen([output_dir ott.dirdelimiter ott.F0CPPE_filename], 'wt');
	    fid2 = fopen([output_dir ott.dirdelimiter ott.Formants_filename], 'wt');
	    fid3 = fopen([output_dir ott.dirdelimiter ott.H_A_filename], 'wt');
	    fid4 = fopen([output_dir ott.dirdelimiter ott.HxHx_filename], 'wt');
	    fid5 = fopen([output_dir ott.dirdelimiter ott.HxAx_filename], 'wt');
	    fids = [fid1 fid2 fid3 fid4 fid5];
	    for i=1:length(fids)
	    	assert(fids(i) ~= -1, '%s error : unable to open file for output.', TAG);
	    endfor
	    % TODO EGG stuff
	    % fidEGG = -1;
	    % fids = [fids fidEGG];
	endif

	numFiles = length(fids);
	numParams = length(paramlist);
	for i=1:numFiles
		assert(fids(i)~=-1, '%s error : unable to open file for output', TAG);
		fprintf(fids(i), 'Filename%c', delim);
		if (ott.includeTextgridLabels == 1)
			fprintf(fids(i), 'Label%c', delim);
		    fprintf(fids(i), 'seg_Start%c', delim);
		    fprintf(fids(i), 'seg_End%c', delim);
		endif
		if (ott.useSegments == 0)
			fprintf(fids(i), 't_ms%c', delim);
		endif
	endfor
	if (numFiles == 1)
		% TODO EGG stuff
		fids = [fids fids fids fids fids -1];
	endif
	if (ott.useSegments == 0)
		for i=1:numParams
			idx = func_getfileinx(paramlist{i});
			C = textscan(paramlist{i}, '%s %s', 'delimiter', '(');
			fprintf(fids(idx), '%s%c', C{2}{1}(1:end-1), delim);
		endfor
		% TODO EGG stuff
		% write out a new line
		fids = unique(fids);
		for i=1:length(fids)
			fprintf(fids(i), '\n');
		endfor
	else
		numSegments = ott.numSegments;
		for i=1:numParams
			idx = func_getfileinx(paramlist{i});
			C = textscan(paramlist{i}, '%s %s', 'delimiter', '(');
			label = C{2}{1}(1:end-1);
			fprintf(fids(idx), '%s_mean%c', label, delim);
			if (numSegments > 1)
				for j=1:numSegments
					segno = sprintf('%3d', j);
					segno = strrep(segno, ' ', '0');
					fprintf(fids(idx), '%s_mean%s%c', label, segno, delim);
				endfor
			endif
		endfor
		% TODO EGG stuff
		% write out a new line
		fids = unique(fids);
		for i=1:length(fids)
			if (fids(i) ~= -1)
				fprintf(fids(i), '\n');
			endif
		endfor
	endif
	printf('done.\n');
end


function paramlist = func_getoutputparameterlist(param)
	% paramlist = func_getoutputparameterlist(param)
	% Input:  param - parameter (optional)
	% Output: paramlist - list of parameters; or
	%         index of the parameter in the list
	% Notes:  Dual purpose function
	%
	% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
	% Copyright UCLA SPAPL 2009

	paramlist = {'H1* (H1c)', ...
	             'H2* (H2c)', ...
	             'H4* (H4c)', ...
	             'A1* (A1c)', ...
	             'A2* (A2c)', ...
	             'A3* (A3c)', ...
	             'H1*-H2* (H1H2c)', ...
	             'H2*-H4* (H2H4c)', ...
	             'H1*-A1* (H1A1c)', ...
	             'H1*-A2* (H1A2c)', ...
	             'H1*-A3* (H1A3c)', ...
	             'CPP (CPP)', ...
	             'Energy (Energy)', ...
	             'HNR05 (HNR05)', ...
	             'HNR15 (HNR15)', ...
	             'HNR25 (HNR25)', ...
	             'HNR35 (HNR35)', ...    
	             'SHR (SHR)', ...
	             'H1 (H1u)', ...
	             'H2 (H2u)', ...
	             'H4 (H4u)', ...
	             'A1 (A1u)', ...
	             'A2 (A2u)', ...
	             'A3 (A3u)', ...
	             'H1-H2 (H1H2u)', ...
	             'H2-H4 (H2H4u)', ...
	             'H1-A1 (H1A1u)', ...
	             'H1-A2 (H1A2u)', ...
	             'H1-A3 (H1A3u)', ...          
	             'F0 - Straight (strF0)', ...
	             'F0 - Snack (sF0)', ...
	             'F0 - Praat (pF0)', ...
	             'F0 - SHR (shrF0)', ...          
	             'F0 - Other (oF0)', ...
	             'F1 - Snack (sF1)', ...
	             'F2 - Snack (sF2)', ...
	             'F3 - Snack (sF3)', ...
	             'F4 - Snack (sF4)', ...
	             'F1 - Praat (pF1)', ...
	             'F2 - Praat (pF2)', ...
	             'F3 - Praat (pF3)', ...
	             'F4 - Praat (pF4)', ...
	             'F1 - Other (oF1)', ...
	             'F2 - Other (oF2)', ...
	             'F3 - Other (oF3)', ...
	             'F4 - Other (oF4)', ...
	             'B1 - Snack (sB1)', ...
	             'B2 - Snack (sB2)', ...
	             'B3 - Snack (sB3)', ...
	             'B4 - Snack (sB4)', ...
	             'B1 - Other (oB1)', ...
	             'B2 - Other (oB2)', ...
	             'B3 - Other (oB3)', ...
	             'B4 - Other (oB4)', ...
	             };
	         
	% user is asking for index to a param
	if (nargin == 1)
	    for k=1:length(paramlist)
	        if (strcmp(paramlist{k}, param))
	            paramlist = k;
	            return;
	        endif
	    endfor
	    paramlist = -1;  % param not found in list
	endif
end
