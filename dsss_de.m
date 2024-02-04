## -*- texinfo -*-
## @deftypefn  {} {@var{msg} =} dsss_de (@var{y}, @var{frame_len})
## @deftypefnx {} {@var{msg} =} dsss_de (@var{y}, @var{frame_len}, @var{x})
## Z metodo DSSS[1] dekodiraj sporočilo iz vektorja @var{y}.
##
## Podana more biti dolžina okvirjev @var{frame_len}, s katero je bilo sporočilo
## kodirano.
##
## Dekodiranje je mnogo zaneslivejše in občutlivejše, če je podan izvorni vektor
## @var{x}, v katerega je bilo sporočilo kodirano.
##
## Izhodna vrednost je besedilni niz @var{msg}.
##
## [1]: Direct Sequence Spread Spectrum
##
## @seealso{dsss_de}
## @end deftypefn

function msg = dsss_de(y, frame_len, x=NaN)
	if (nargin == 0)
		error("dsss_de() je funkcija, ne samostojen skript.\n")
	endif
	narginchk(2, 3);

	% Terminologija vektorjev:
	% x ... izvoren posnetek
	% y ... predelan posnetek (s skrito vsebino)
	% N ... šum (noise)

	pkg load signal; % Za funk. 'xcorr()'

	% Tretji argument ni obvezen in podaja izvorni posnetek.
	% Z njim je iskanje sporočila v posnetku znatno olajšano,
	% saj ga lahko odštejemo od predelanega.
	has_source_audio = !isnan(x);

	% Število vzorcev v zvočnem posnetku
	y_len = numel(y);

	% Število možnih vzorcev, ki jih lahko kodiramo
	embeddable_bits = fix(y_len/frame_len);

	% Prostor za dekodirano sporočilo
	msg = zeros(embeddable_bits, 1);

	% Tvori vektor psevdo-naključnega šuma
	N = rand_wrapper(y_len, 1);

	pointer = 1;
	for i = 1:(embeddable_bits - 1)
		% Okvir zvočnega posnetka
		frame = y(pointer:(pointer + frame_len - 1));

		% Okvir šuma enake dolžine kot posnetek
		noise = N(pointer:(pointer + frame_len - 1));

		% Če imamo izvorni posnetek, ga odštejemo od predelanega.
		% S tem lahko dekodiramo sporočilo, skrito v šumu z zelo
		% majhno jakostjo.
		if has_source_audio
			frame -= x(pointer:(pointer + frame_len - 1));
		endif

		% Opravi križno korelacijo med okvirjem predelanega posnetka
		% in šumom. Za tem najdi indeks največjega vzorca korelacijskega
		% vektorja - mesto, kjer je podobnost največja. Če je tam vrednost
		% korelacije pozitivna, je na tem mestu shranjena enica; sicer ničla.
		[R, ~] = xcorr(frame, noise);
		[~, maxp] = max(abs(R));

		if R(maxp) >= 0
			msg(i) = 1;
		else
			msg(i) = 0;
		endif

		pointer += frame_len;
	endfor
endfunction
