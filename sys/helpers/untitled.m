% --- refactored for octave compatibility ---    
      A = textscan(C{k}, '%[^=] = %s', 'delimiter', '\n'); 

    if (~isempty(A{1}{1}))
        switch A{1}{1}
            % intervals
            case {'intervals: size '} % we found the start of a new tier, now allocate mem
                tiers = tiers + 1;
                tier_len = str2num(A{2}{1});
                labels{tiers} = cell(tier_len, 1);
                start{tiers}  = zeros(tier_len, 1);
                stop{tiers}   = zeros(tier_len, 1);
                cnt = 1;
                proceed_int = 1;
            case {'xmin '}
                if (proceed_int)
                    start{tiers}(cnt) = str2num(A{2}{1});
                else
                    xmin = str2num(A{2}{1});
                end
            case {'xmax '}
                if (proceed_int)
                    stop{tiers}(cnt) = str2num(A{2}{1});
                else
                    xmax = str2num(A{2}{1});
                end
            case {'text '}
                if (proceed_int)
                    lab = A{2}{1};
                    if (lab(end) ~= '"')
                        lab = lab(1:end-1);
                    end
                    
                    labels{tiers}{cnt} = lab;
                    cnt = cnt + 1;
                    if (cnt > tier_len)
                        proceed_int = 0;
                    end
                end
            % point-sources    
            case {'points: size '} % we found the start of a new tier, now allocate mem
                tiers = tiers + 1;
                tier_len = str2num(A{2}{1});
                labels{tiers} = cell(tier_len, 1);
                start{tiers}  = zeros(tier_len, 1);
                stop{tiers}   = zeros(tier_len, 1);
                cnt = 1;
                proceed_pnt = 1;
            case {'time '}
                if (proceed_pnt)
                    start{tiers}(cnt) = str2num(A{2}{1}) - POINT_BUFFER;
                    stop{tiers}(cnt) = str2num(A{2}{1}) + POINT_BUFFER;
                    
                    if (start{tiers}(cnt) < xmin)
                        start{tiers}(cnt) = xmin;
                    end
                    
                    if (stop{tiers}(cnt) > xmax)
                        stop{tiers}(cnt) = xmas;
                    end
                end
            case {'mark '}
                if (proceed_pnt)
                    lab = A{2}{1};
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
    end
            
end