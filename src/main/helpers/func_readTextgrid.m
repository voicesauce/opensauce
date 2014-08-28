function [labels, start, stop] = func_readTextgrid(filename)
    % [labels, start, stop] = func_readTextgrid(filename)
    % Input:  filename - textgrid file
    % Output: labels, start, stop - vectors containing textgrid data
    % Notes:  Functions seeks out the "xmin", "xmax", and "text" labels within
    % a textgrid file.
    %
    % Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
    % Copyright UCLA SPAPL 2009

    % Modified by Kate Silverstein 2013-07-23


    % TODO move this field into settings
    POINT_BUFFER = 0.025; % 25 ms buffer on either side of the point

    if (exist(filename, 'file') == 0)
        fprintf('Error: %s not found\n', filename);
        labels = NaN; start = NaN; stop = NaN;
        return;
    end

    fid = fopen(filename, 'rt');
    C = textscan(fid, '%s', 'delimiter', '\n');
    fclose(fid);

    C = C{1};
    tiers = 0;
    proceed_int = 0; % proceed with intervals
    proceed_pnt = 0; % proceed with point-sources
    xmin = 0;
    xmax = 1;

    printf('\n');

    for k=1:length(C)
        % try to read a string in the format: %s = %s
        if (isempty(C{k}))
            continue;
        end

        % intervals
        t = regexp(C{k}, '\s*(intervals[:]\ssize)\s=\s(\d)', 'tokens');
        if (~isempty(t)) % we found the start of a new tier, now allocate memory
            t = t{1};
            tiers = tiers + 1;
            tier_len = str2num(t{2});
            labels{tiers} = cell(tier_len, 1);
            start{tiers} = zeros(tier_len, 1);
            stop{tiers} = zeros(tier_len, 1);
            cnt = 1;
            proceed_int = 1;
        end

        t = regexp(C{k}, '\s*(xmin)\s=\s([.\d]+)', 'tokens');
        if (~isempty(t))
            t = t{1};
            assert (strcmp(t{1}, 'xmin') == 1, 'something went wrong w readtextgrid');
            if (proceed_int)
                start{tiers}(cnt) = str2num(t{2});
            else
                xmin = str2num(t{2});
            end
        end

        t = regexp(C{k}, '\s*(xmax)\s=\s([.\d]+)', 'tokens');
        if (~isempty(t))
            t = t{1};
            assert (strcmp(t{1}, 'xmax') == 1, 'something went wrong w readtextgrid');
            if (proceed_int)
                stop{tiers}(cnt) = str2num(t{2});
            else
                xmax = str2num(t{2});
            end
        end

        t = regexp(C{k}, '\s*(text)\s=\s(["]\w*["])', 'tokens');
        if (~isempty(t))
            t = t{1};
            assert (strcmp(t{1}, 'text') == 1, 'something went wrong w readtextgrid');
            if (proceed_int)
                label = t{2};
                if (label(end) ~= '"')
                    label = label(1:end-1);
                end
                labels{tiers}{cnt} = label;
                cnt = cnt + 1;
                if (cnt > tier_len)
                    proceed_int = 0;
                end
            end
        end

        % point-sources
        t = regexp(C{k}, '\s*(points[:]\ssize)\s=\s(\d)', 'tokens');
        if (~isempty(t))  % we found the start of a new tier, now allocate mem
            printf('using point source\n');
            t = t{1};
            tiers = tiers + 1;
            tier_len = str2num(t{2});
            labels{tiers} = cell(tier_len, 1);
            start{tiers}  = zeros(tier_len, 1);
            stop{tiers}   = zeros(tier_len, 1);
            cnt = 1;
            proceed_pnt = 1;
        end

        t = regexp(C{k}, '.*(time).*=.*([.\d]+)', 'tokens');
        if (~isempty(t))
            t = t{1};
            if (proceed_pnt)
                start{tiers}(cnt) = str2num(t{2}) - POINT_BUFFER;
                stop{tiers}(cnt) = str2num(t{2}) + POINT_BUFFER;
                
                if (start{tiers}(cnt) < xmin)
                    start{tiers}(cnt) = xmin;
                end
                
                if (stop{tiers}(cnt) > xmax)
                    stop{tiers}(cnt) = xmas;
                end
            end
        end

        t = regexp(C{k}, '.*(mark).*=.*(["]?\w+["]?)', 'tokens');
        if (~isempty(t))
            t = t{1};
            if (proceed_pnt)
                lab = t{2};
                if (lab(end) ~= '"')
                    lab = lab(1:end-1);
                end
                
                labels{tiers}{cnt} = lab;
                cnt = cnt + 1;
                if (cnt > tier_len)
                    proceed_pnt = 0;
                end
            end
        end
    end %endfor
end %endfunction






% --- refactored for octave compatibility ---    
%       A = textscan(C{k}, '%[^=] = %s', 'delimiter', '\n'); 

%     if (~isempty(A{1}{1}))
%         switch A{1}{1}
%             % intervals
%             case {'intervals: size '} % we found the start of a new tier, now allocate mem
%                 tiers = tiers + 1;
%                 tier_len = str2num(A{2}{1});
%                 labels{tiers} = cell(tier_len, 1);
%                 start{tiers}  = zeros(tier_len, 1);
%                 stop{tiers}   = zeros(tier_len, 1);
%                 cnt = 1;
%                 proceed_int = 1;
%             case {'xmin '}
%                 if (proceed_int)
%                     start{tiers}(cnt) = str2num(A{2}{1});
%                 else
%                     xmin = str2num(A{2}{1});
%                 end
%             case {'xmax '}
%                 if (proceed_int)
%                     stop{tiers}(cnt) = str2num(A{2}{1});
%                 else
%                     xmax = str2num(A{2}{1});
%                 end
%             case {'text '}
%                 if (proceed_int)
%                     lab = A{2}{1};
%                     if (lab(end) ~= '"')
%                         lab = lab(1:end-1);
%                     end
                    
%                     labels{tiers}{cnt} = lab;
%                     cnt = cnt + 1;
%                     if (cnt > tier_len)
%                         proceed_int = 0;
%                     end
%                 end
%             % point-sources    
%             case {'points: size '} % we found the start of a new tier, now allocate mem
%                 tiers = tiers + 1;
%                 tier_len = str2num(A{2}{1});
%                 labels{tiers} = cell(tier_len, 1);
%                 start{tiers}  = zeros(tier_len, 1);
%                 stop{tiers}   = zeros(tier_len, 1);
%                 cnt = 1;
%                 proceed_pnt = 1;
%             case {'time '}
%                 if (proceed_pnt)
%                     start{tiers}(cnt) = str2num(A{2}{1}) - POINT_BUFFER;
%                     stop{tiers}(cnt) = str2num(A{2}{1}) + POINT_BUFFER;
                    
%                     if (start{tiers}(cnt) < xmin)
%                         start{tiers}(cnt) = xmin;
%                     end
                    
%                     if (stop{tiers}(cnt) > xmax)
%                         stop{tiers}(cnt) = xmas;
%                     end
%                 end
%             case {'mark '}
%                 if (proceed_pnt)
%                     lab = A{2}{1};
%                     if (lab(end) ~= '"')
%                         lab = lab(1:end-1);
%                     end
                    
%                     labels{tiers}{cnt} = lab;
%                     cnt = cnt + 1;
%                     if (cnt > tier_len)
%                         proceed_pnt = 0;
%                     end
%                 end
                
                
%         end
%     end
            
% end            
    



