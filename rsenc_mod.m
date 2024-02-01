% Kodiranje vhodne besedilne datoteke prek Reed-Solomonove kode
% v izhodni desetiški vektor.
%
% Prirejeno po funkciji 'rsencof()' iz paketa communications-1.2.6.
% Ta paket mora biti nameščen.

function code = rsenc_mod(msg, t)
	pkg load communications

	is8bit = (max(msg) > 127);

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

	msg_len = numel(msg)
	ncodewords = ceil(msg_len / k);
	npad = k * ncodewords - msg_len;

	msg = reshape([msg ; 4 * ones(npad, 1)], k, ncodewords)';
	msg_gf = gf(msg, m);

	code = rsenc(msg_gf, n, k, "beginning")';
	code_len = ncodewords * n - npad

	% RS kodiranje vektorju doda polnilo, da doseže število
	% elementov najbližji večkratnik števila 2.
	% Mi želimo le sporočilo, brez polnila. Hkrati se izhod
	% še pretvori iz podatkovnega tipa Galoisjevega polja
	% v navaden vektor.
	code = code(1:code_len).x;
endfunction
