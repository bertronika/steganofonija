% Kodirni program.

source("param.octave");
addpath("util/");

pkg load communications; % Funkcija de2bi()

global RAND_FUNC RAND_SEED;
RAND_FUNC = sf.param.rand_func;
RAND_SEED = sf.param.rand_seed;

%%%
% Lokalne funkcije
%%%

% Izračunaj, koliko bitov pri nastavljeni velikost okvirjev
% se lahko vgradi v podani zvočni posnetek.
function n = n_of_embeddable_bits(input_audio, frame_len)
	x_info = audioinfo(input_audio);
	x_len = x_info.TotalSamples;
	n = fix(x_len/frame_len);
endfunction

%%%
% Program
%%%

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

% Začni štoparico za meritev časa kodiranja.
tic

%%%
% Opcijsko kodiraj sporočilo z Reed-Solomonovo kodo.
%%%
if (sf.param.rs_enable)
	disp("-- RS kodiranje --------------");
	printf("input_file = %s\n", sf.en.input_file);
	printf("correctable_errors = %d\n", sf.param.rs_correctable_errors);
	printf("msg_len_pre_rs  = %d\n", input_msg_len);
	input_msg = rs_en(input_msg, sf.param.rs_correctable_errors);
	input_msg_len = numel(input_msg);
	printf("msg_len_post_rs = %d\n", input_msg_len);
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

if (!sf.param.rs_enable &&
    rs_en(input_msg, sf.param.rs_correctable_errors, true) * 8 <= available_bits)
	disp("# prostora je dovolj za RS");
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
# x_info  = audioinfo(sf.en.input_audio);

% Vgradi sporočilo v posnetek.
[y, SNR] = dsss_en(x, msg_flat, sf.param.strength, sf.param.frame_len);
printf("SNR = %.2f dB\n", SNR);
# printf("SNR = %d dB, učinkovitost %d bps.", SNR, ---/x_info.Duration);
# BPS = msg_len/duration                  % Bits Per Second

% Prikaži čas kodiranja.
printf("# čas kodiranja = %.3f s\n", toc);

% Preveri uspešnost kodiranja s klicem dekodirnika,
% ki pa bo uspešnost kodiranja le validiral.
VALIDATING_CODING = true;
dekodiraj
VALIDATING_CODING = false;

% Validacija uspešna, shrani vzorce s sporočilom v izhodni posnetek.
audiowrite(sf.en.output_audio, y, fs);
printf("Shranjujem novi posnetek ‘%s’.\n", sf.en.output_audio);
