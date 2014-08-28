function [h,fh]=func_GetHarmonics(data,f_est,Fs)
	% this function is used from 1/8/09 onwards - optimization used
%--------------------------------------------------------------------------
	    %printf('FUNC_GETHARMONICS...\n');
	% find harmonic magnitudes in dB of time signal x
	% around a frequency estimate f_est
	% Fs, sampling rate
	% x,  input row vector (is truncated to the first 25ms)
	% df_range, optional, default +-5% of f_est

	df = 0.1;     % search around f_est in steps of df (in Hz)
	df_range = round(f_est*df); % search range (in Hz)

	f_min = f_est - df_range;
	f_max = f_est + df_range;

	f = @(x)func_EstMaxVal(x, data, Fs);


	options = optimset('Display', 'off');
	%options = optimset('Display', 'off', 'OutputFcn', []);
	% fn = fieldnames(options);
	% for k=1:length(fn)
	%     printf('opt( %s )\n', fn{k});
	% end
	% return;


	%[x, val, exitflag, output] = fmincon(f, f_est, [], [], [], [], f_min, f_max, [], options);
	%[x, val, exitflag, output] = fminsearchbnd(f, f_est, f_min, f_max, options); 

	[x, val, exitflag, output] = fminsearchbnd2(f, f_est, f_min, f_max);


	h = -1 * val;
	fh = x;
end %endfunction



function val = func_EstMaxVal(x, data, Fs)
	% x is the F0 estimate
	n = 0:length(data)-1;
	v = exp(-1i*2*pi*x*n/Fs);
	val = -1 * 20*log10(abs(data * v'));
end %endfunction