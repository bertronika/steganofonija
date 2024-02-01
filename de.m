% Steganofonija (AK) - dekodirnik
%
% Terminologija vektorjev:
% x ... izvoren posnetek
% y ... predelan posnetek (s skrito vsebino)
% N ... šum (noise)

function msg = de(input_audio, varargin)
	global FRAME_LEN;
	pkg load signal; % Za funk. 'xcorr()'

	% Naloži vzorce in frekvenco vzorčenja zvočnega posnetka
	[y, fs] = audioread(input_audio); input_audio

	% Drugi argument ni obvezen in podaja izvorni posnetek.
	% Z njim je iskanje sporočila v posnetku znatno olajšano,
	% saj ga lahko odštejemo od predelanega.
	if nargin > 1
		host_audio = varargin{1}
		[x, ~] = audioread(host_audio);
	endif

	% Število vzorcev v zvočnem posnetku
	y_len = numel(y);

	% Število možnih vzorcev, ki jih lahko kodiramo
	embeddable_bits = fix(y_len/FRAME_LEN);

	% Prostor za dekodirano sporočilo
	msg = zeros(embeddable_bits, 1);

	% Tvori vektor psevdo-naključnega šuma
	N = rand_wrapper(y_len, 1);

	pointer = 1;
	for i = 1:(embeddable_bits - 1)
		% Okvir zvočnega posnetka
		frame = y(pointer:(pointer + FRAME_LEN - 1));

		% Okvir šuma enake dolžine kot posnetek
		noise = N(pointer:(pointer + FRAME_LEN - 1));

		% Če imamo izvorni posnetek, ga odštejemo od predelanega.
		% S tem lahko dekodiramo sporočilo, skrito v šumu z zelo
		% majhno jakostjo.
		if nargin > 1
			frame -= x(pointer:(pointer + FRAME_LEN - 1));
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

		pointer += FRAME_LEN;
	endfor

	# save de_msg.txt msg;
	# save -ascii msg_de.txt msg;
endfunction
