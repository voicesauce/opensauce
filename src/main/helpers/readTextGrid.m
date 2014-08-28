function [labels, start, stop] = readTextGrid(filename)
	tgf = '';
	if(nargin == 0)
		tgf = '/Users/kate/speech-tech/voice-sauce/vs-octave/tests/sounds/textgrid/hmong_f4_40_a.TextGrid';
	else
		tgf = filename;
	end

	POINT_BUFFER = 0.025;

	assert (exist(tgf, 'file') ~= 0, 'error: text grid file [%s] not found', tgf);

	fid = fopen(tgf, 'rt');
	C = textscan(fid, '%s', 'delimiter', '\n');
	fclose(fid);

	C = C{1};
	tiers = 0;
	tier_len = 0;
	proceed_int = 0;
	proceed_pnt = 0;
	xmin = 0;
	xmax = 1;
	cnt = 0;

	for k=1:length(C)
		%printf('C{K} = [[  %s  ]]\n\n', C{k});

		if (isempty(C{k}))
			continue;
		end

		[m, t] = regexp(C{k}, '\s*(intervals[:]\ssize)\s=\s(\d)', 'match', 'tokens'); 
		if (~isempty(m)) % found start of new tier
			%printf('new interval:\n');
			t = t{1};
			tiers = tiers + 1;
			tier_len = str2num(t{2});
			labels{tiers} = cell(tier_len, 1);
			start{tiers} = zeros(tier_len, 1);
			stop{tiers} = zeros(tier_len, 1);
			cnt = 1;
			proceed_int = 1;
		end

		[m, t] = regexp(C{k}, '\s*(xmax|xmin)\s=\s([.\d]+)', 'match', 'tokens');
		if (~isempty(m)) % found xmax
			t = t{1};
			fname = t{1};
			val = t{2};
%			printf('fname = "%s"\n', fname);
%			printf('val = "%s"\n', val);
			xm = 0;
			if (strcmp(val, '0'))
				xm = 0.0;
				%printf('==> %s val == 0\n', fname);
			else
				xm = str2double(val);
			end

			switch fname
			case 'xmin'
				if (proceed_int)
					start{tiers}(cnt) = xm;
				else
					xmin = xm;
				end
			case 'xmax'
				if (proceed_int == 1)
					stop{tiers}(cnt) = xm;
				else
					xmax = xm;
				end
			end
		end

		[m, t] = regexp(C{k}, '\s*(text)\s=\s(["]\w*["])', 'match', 'tokens');
		if (~isempty(m))
			t = t{1};
			label = t{2};
			%printf('label = [%s]\n', label);
			labels{tiers}{cnt} = label;
			cnt = cnt + 1;
			if (cnt > tier_len)
				proceed_int = 0;
			end
		end

		[m, t] = regexp(C{k}, '\s*(points[:]\ssize)\s=\s(\d)', 'match', 'tokens');
		if (~isempty(m))
			printf('USING POINT-SOURCES: NEED TO DEBUG THIS.\n\n');
			t = t{1};
			tiers = tiers + 1;
			tier_len = str2num(t{2});
			labels{tiers} = cell(tier_len, 1);
			start{tiers} = zeros(tier_len, 1);
			stop{tiers} = zeros(tier_len, 1);
			cnt = 1;
			proceed_pnt = 1;
		end

		[m, t] = regexp(C{k}, '.*(time).*=.*([.\d]+)', 'match', 'tokens');
		if (~isempty(m))
			t = t{1};
			val = num2double(t{2});
			if (proceed_pnt == 1)
				start{tiers}(cnt) = val - POINT_BUFFER;
				stop{tiers}(cnt) = val + POINT_BUFFER;

				if (start{tiers}(cnt) < xmin)
					start{tiers}(cnt) = xmin;
				end

				if (stop{tiers}(cnt) > xmax)
					stop{tiers}(cnt) = xmax;
				end
			end
		end

		[m, t] = regexp(C{k}, '.*(mark).*=.*(["]?\w+["]?)', 'match', 'tokens');
		if (~isempty(m))
			t = t{1};
			label = t{2};
			labels{tiers}{cnt} = label;
			cnt = cnt + 1;
			if (cnt > tier_len)
				proceed_pnt = 0;
			end
		end
	end
end



	
	

