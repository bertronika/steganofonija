% Steganofonija (AK) - kodirnik
%
% Terminologija vektorjev:
% x ... izvoren posnetek
% y ... predelan posnetek (s skrito vsebino)
% N ... šum (noise)

function en(input_audio, msg, output_audio)
	global FRAME_LEN STRENGTH;

	% Naloži vzorce, frekvenco vzorčenja in metapodatke
	% vhodnega zvočnega posnetka.
	[x, fs] = audioread(input_audio); input_audio
	x_info  = audioinfo(input_audio);
	x_len    = x_info.TotalSamples; % Št. vzorcev v posnetku
	duration = x_info.Duration      % Trajanje posnetka (s)
	channels = x_info.NumChannels

	% Število možnih vzorcev, ki jih lahko kodiramo
	embeddable_bits = fix(x_len/FRAME_LEN);

	% Tvori vektor psevdo-naključnega šuma
	N = rand_wrapper(x_len, 1);

	N *= STRENGTH;
	# N = fwht(N);

	% Vektor predelanega posnetka
	y = zeros(FRAME_LEN * embeddable_bits, 1);

	% Dolžina sporočila za vgradnjo
	msg_len = numel(msg);

	% Vgrajevanje sporočila v predelan posnetek 'y'.
	% Postopek poteka na posameznih okvirjih velikosti 'FRAME_LEN'.
	pointer = 1;
	for i = 1:(embeddable_bits - 1)
	# for i = 1:(numel(msg) - 1)
		% Okvir zvočnega posnetka
		frame = x(pointer:(pointer + FRAME_LEN - 1));

		% Okvir šuma enake dolžine kot posnetek
		noise = N(pointer:(pointer + FRAME_LEN - 1));

		% Dvojiško enico kodiraj kot dodatek šuma; ničlo kot odvzem
		if i <= msg_len && msg(i) == 1
			frame += noise;
		else
			frame -= noise;
		endif

		% Dobljeno mešanico vloži v nov vektor predelanega posnetka
		# y(1 + (FRAME_LEN * (i - 1)):FRAME_LEN * i) = frame;
		y(pointer:(pointer + FRAME_LEN - 1)) = frame;

		pointer += FRAME_LEN;
	endfor

	y_len = numel(y);

	% Dolžine zvočnega posnetka je morda večja od prostora za sporočilo,
	% zato prilepi preostanek vzorcev iz izvirnega posnetka
	y = [y; x(y_len:x_len - 1)];

	audiowrite(output_audio, y, fs); output_audio

	# save en_msg.txt msg_orig;
	# save -ascii msg_en.txt msg;

	% Statistika po kodiranju
	SNR = 10 * log10(sumsq(x)/sumsq(x - y)) % Signal to Noise Ratio
	BPS = msg_len/duration                  % Bits Per Second
endfunction
