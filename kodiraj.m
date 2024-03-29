% Kodirni program.
% Deloma povzeto po kodirniku/dekodirniku Akire Tamamorija (GPLv3):
%  <https://gist.github.com/tam17aki/326cf8666338e39d4f5f9cb777e8c6c0>

function kodiraj(custom_sf=false)
	addpath("util/");

	global sf;

	% Spremenljivke za "izvoz" drugim funkcijam.
	global input_msg_text available_bits msg_flat x y fs channels;

	if (!custom_sf)
		source("param.m");
	endif

	pkg load communications; % Funkcija de2bi()

	disp("-- Kodirni parametri ---------");
	printf("frame_len = %d\n", sf.param.frame_len);
	printf("rand_func = %s()\n", func2str(sf.param.rand_func));
	printf("rand_seed = %d\n", sf.param.rand_seed);
	printf("strength  = %d\n\n", sf.param.strength);

	% Naloži izvorno besedilno sporočilo v vrstični vektor
	% z desetiškimi vrednostmi črk.
	% Ker sporočilo lahko vsebuje večbajtne (Unicode)
	% znake, ga preberi z
	%   printf("%c", char(input_msg))
	[input_msg, input_msg_len] = file_read(sf.en.input_file);
	input_msg_text = input_msg;

	% Začni štoparico za meritev časa kodiranja.
	tic

	input_msg_before_rs = input_msg; % Shrani izvirnik sporočila

	%%%
	% Opcijsko kodiraj sporočilo z Reed-Solomonovo kodo.
	%%%
	if (isfield(sf.param, "rs_correctable_errors"))
		disp("-- RS kodiranje --------------");
		printf("input_file = %s\n", sf.en.input_file);
		printf("correctable_errors = %d\n", sf.param.rs_correctable_errors);
		printf("msg_len_pre_rs  = %d\n", input_msg_len);
		input_msg = rs_en(input_msg, sf.param.rs_correctable_errors);
		input_msg_len = numel(input_msg);
		printf("msg_len_post_rs = %d\n", input_msg_len);
		disp("-- Analiza -------------------");
	else
		disp("-- Analiza -------------------");
		printf("input_file = %s\n", sf.en.input_file);
		input_msg_len
	endif

	% Izračunaj, koliko bitov bo zahtevalo dano sporočilo.
	needed_bits = input_msg_len * 8

	% Izračunaj, koliko bitov pri nastavljeni velikosti okvirja
	% se lahko vgradi v podani zvočni posnetek.
	available_bits = n_of_embeddable_bits(sf.en.input_audio, sf.param.frame_len)

	% Če je zahtevanih bitov preveč, zaustavi program.
	if (needed_bits > available_bits)
		disp("");
		error("Sporočilo je preveliko za vgradnjo v posnetek.\n");
	endif

	if (!isfield(sf.param, "rs_correctable_errors") &&
	    rs_en(input_msg, 4, true) * 8 <= available_bits)
		disp("# prostora je dovolj za RS pri 4 napakah");
	endif

	% Pretvori desetiški vektor sporočila v dvojiško matriko,
	% s po enim bajtom v enem 8-bitnem stolpcu.
	msg_bin = de2bi(input_msg, 8, "left-msb")';

	% Po stolpcih splošči matriko nazaj v vektor.
	msg_flat = msg_bin(:);

	%%%
	disp("-- DSSS kodiranje ------------");
	%%%

	printf("input_audio = %s\n", sf.en.input_audio);

	% Naloži vzorce vhodnega posnetka.
	[x, fs] = audioread(sf.en.input_audio);
	x_info  = audioinfo(sf.en.input_audio);
	duration = x_info.Duration
	channels = x_info.NumChannels

	% Izračunaj št. bitov sporočila na sekundo posnetka
	BPS = needed_bits/duration

	% Vgradi sporočilo v posnetek. Morebitno dvostolpčno dvokanalno
	% matriko splošči v vektor.
	[y, SNR, eff] = dsss_en(x(:), msg_flat, sf.param.strength, sf.param.frame_len);

	printf("SNR = %.2f dB\n", SNR);
	printf("efficiency = %.2f %%\n", eff);

	% Prikaži čas kodiranja.
	printf("# čas kodiranja = %.3f s\n", toc);

	% Če izvorni posnetek vsebuje dva kanala, preoblikuj
	% sploščen vektor nazaj v dvostolpčno matriko
	if (channels == 2)
		y = reshape(y, numel(y)/2, 2);
	endif

	% Preveri uspešnost kodiranja s klicem dekodirnika,
	% ki pa bo uspešnost kodiranja le validiral.
	dekodiraj(true, true)
	if (isfield(sf.param, "create_graphs") && sf.param.create_graphs == true)
		analiziraj
	endif

	% Validacija uspešna, shrani vzorce s sporočilom v izhodni posnetek.
	if (isfield(sf.en, "output_audio"))
		audiowrite(sf.en.output_audio, y, fs);
		printf("\nShranjujem novi posnetek ‘%s’.\n", sf.en.output_audio);
	endif
endfunction

%%%
% Lokalne funkcije
%%%

% Izračunaj, koliko bitov pri nastavljeni velikost okvirjev
% se lahko vgradi v podani zvočni posnetek.
function n = n_of_embeddable_bits(input_audio, frame_len)
	x_info = audioinfo(input_audio);
	x_len = x_info.TotalSamples * x_info.NumChannels;
	n = fix(x_len/frame_len);
endfunction
