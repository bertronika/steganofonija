% Dekodiranje vhodnega dvojiškega vektorja prek Reed-Solomonove kode
% v izhodno besedilno datoteko.
%
% Prirejeno po funkciji 'rsdecof()' iz paketa communications-1.2.6.
% Ta paket mora biti nameščen.

function [msg, n_err] = rsdec_mod(code, t)
	pkg load communications

	is8bit = (max(code) > 127);

	if (is8bit)
		m = 8;
		n = 255;
	else
		m = 7;
		n = 127;
		# t = 5;
		# disp("ni 8-bit, t je konst.");
	endif

	k = n - 2 * t;

	code_len = numel(code);
	ncodewords = ceil(code_len / n);
	npad = n * ncodewords - code_len;

	code = reshape([code ; 4 * ones(npad, 1)], n, ncodewords)';
	code_gf = gf(code, m);

	[msg_whole, n_err] = rsdec(code_gf, n, k, "beginning");

	msg_len = ncodewords * k - npad;
	msg = msg_whole(1:msg_len).x;
endfunction
