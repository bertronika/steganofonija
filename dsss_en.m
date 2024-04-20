## -*- texinfo -*-
## @deftypefn {} {[@var{y}, @var{SNR}] =} dsss_en (@var{x}, @var{msg}, @var{strength}, @var{frame_len})
## Z metodo DSSS[1] kodiraj sporočilo @var{msg} v vektor @var{x}.
##
## Podati je potrebno jakost kodiranja  @var{strength} in dolžina okvirja
## @var{frame_len}, v katerega se kodira posamezen bit sporočila.
##
## Izhodni vrednosti sta kodiran vektor @var{y} in razmerje signal-šum
## @var{SNR} v dB.
##
## [1]: Direct Sequence Spread Spectrum
##
## @seealso{dsss_en}
## @end deftypefn

function [y, SNR, eff] = dsss_en(x, msg, strength, frame_len)
	if (nargin == 0)
		error("dsss_en() je funkcija, ne samostojen skript.\n")
	endif
	narginchk(4, 4);

	% Terminologija vektorjev:
	% x ... izvoren posnetek
	% y ... predelan posnetek (s skrito vsebino)
	% N ... šum (noise)

	x_len = numel(x);

	% Število možnih vzorcev, ki jih lahko kodiramo
	embeddable_bits = fix(x_len/frame_len);

	% Tvori vektor psevdo-naključnega šuma z izbrano jakostjo
	N = rand_wrapper(x_len, 1) * strength;

	% Dolžina sporočila za vgradnjo
	msg_len = numel(msg);

	% Vektor predelanega posnetka
	y = x;

	% Vgrajevanje sporočila v predelan posnetek 'y'.
	% Postopek poteka na posameznih okvirjih velikosti 'frame_len'.
	pointer = 1;
	for i = 1:(embeddable_bits - 1)
	# for i = 1:(numel(msg) - 1)
		% Okvir zvočnega posnetka
		frame = x(pointer:(pointer + frame_len - 1));

		% Okvir šuma enake dolžine kot posnetek
		noise = N(pointer:(pointer + frame_len - 1));

		% Dvojiško enico kodiraj kot dodatek šuma; ničlo kot odvzem
		if (i <= msg_len && msg(i) == 1)
			frame += noise;
		else
			frame -= noise;
		endif

		% Dobljeno mešanico vloži v nov vektor predelanega posnetka
		y(pointer:(pointer + frame_len - 1)) = frame;

		pointer += frame_len;
	endfor

	% Statistika po kodiranju
	SNR = 10 * log10(sumsq(x)/sumsq(x - y)); % Signal to Noise Ratio
	eff = (msg_len/embeddable_bits) * 100;   % Izkoristek posnetka
endfunction
