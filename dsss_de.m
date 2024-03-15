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
	bitlen = frame_len/1023;
  n = gold(10)(69,:);
  N = zeros(1023*bitlen,1);

  i=1;
  in=1;
  while i<=1023
    for j=0:(bitlen)
      N(in+j)=n(i);
    endfor
    in=in+j;
    i++;
  endwhile
  N = N(1:numel(N)-1);

	pointer = 1;
	for i = 1:(embeddable_bits - 1)
		% Okvir zvočnega posnetka
		frame = y(pointer:(pointer + frame_len - 1));

		% Če imamo izvorni posnetek, ga odštejemo od predelanega.
		% S tem lahko dekodiramo sporočilo, skrito v šumu z zelo
		% majhno jakostjo.
		if (has_source_audio)
			frame -= x(pointer:(pointer + frame_len - 1));
		endif

		% Opravi križno korelacijo med okvirjem vzorcev predelanega posnetka
		% in šumom. Vrednost točno na indeksu velikosti okvirja odloča o
		% logični vrednosti - če je tam korelacija pozitivna, je na tem
		% mestu shranjena enica; sicer ničla.
		[R, ~] = xcorr(frame, N);

		if (R(frame_len) >= 0)
			msg(i) = 1;
		else
			msg(i) = 0;
		endif

		pointer += frame_len;
	endfor
endfunction
