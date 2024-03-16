% Dekodirni program.
% Deloma povzeto po kodirniku/dekodirniku Akire Tamamorija (GPLv3):
%  <https://gist.github.com/tam17aki/326cf8666338e39d4f5f9cb777e8c6c0>

addpath("util/");

if (!(exist("DEMO_MODE", "var") == 1))
	source("param.octave");
endif

pkg load communications; % Funkcija bi2de()

%%%
% Lokalne funkcije
%%%

% Bit Error Rate
function ber = get_ber(x, y, total)
	assert(numel(x) == numel(y));
	ber = sum(abs(y - x)) / total;
	ber *= 100;
endfunction

% Character Error Rate
function cer = get_cer(x, y)
	total = numel(x);
	assert(total == numel(y));
	c_diff = x - y;
	cer = (numel(c_diff(c_diff != 0))/total) * 100;
endfunction

%%%
% Program
%%%

% Če je spodnja spremenljivka definirana, želimo le validirati
% obstoječa vektorja 'x' (po možnosti tudi 'y'). Sicer
% dekodirnik deluje samostojno - bere eno ali dve vhodni zvočni
% datoteki in zapiše dekodirano sporočilo.
if (exist("VALIDATING_CODING", "var") != 1)
	VALIDATING_CODING = false;
endif

if (!VALIDATING_CODING)
	disp("-- Dekodirni parametri -------");
	printf("frame_len = %d\n", sf.param.frame_len);
	printf("rand_func = %s()\n", func2str(sf.param.rand_func));
	printf("rand_seed = %d\n\n", sf.param.rand_seed);

	% Začni štoparico za meritev časa dekodiranja.
	tic
endif

%%%
disp("-- DSSS dekodiranje ----------");
%%%

if (!VALIDATING_CODING)
	printf("de.input_audio = %s\n", sf.de.input_audio);
	[y, ~] = audioread(sf.de.input_audio);
endif

if (sf.de.use_input_audio)
	if (!VALIDATING_CODING)
		printf("en.input_audio = %s\n", sf.en.input_audio);
		[x, ~] = audioread(sf.en.input_audio);
	endif

	% Dekodiraj sporočilo iz podane kodirane zvočne datoteke
	% in znanega izvirnika.
	msg_recv = dsss_de(y, sf.param.frame_len, x);
else
	% Dekodiraj sporočilo le iz podane zvočne datoteke, izvirnik
	% ni znan.
	msg_recv = dsss_de(y, sf.param.frame_len);
endif

if (VALIDATING_CODING)
	% Izračunaj Bit Error Rate
	BER = get_ber(msg_recv(1:numel(msg_flat)), msg_flat, available_bits);
	printf("bit_error_rate = %.2f %%\n", BER);
endif

% Preoblikuj vektor v matriko z 8 stolpci (po en bajt).
new_msg_size = 2^(nextpow2(numel(msg_recv)));
msg_recv_1 = resize(msg_recv, new_msg_size, 1);
msg_recv_2 = reshape(msg_recv_1, 8, [])';

% Obdrži vse vrstice do prve ničelne
i_of_first_zero_row = ismember(msg_recv_2, [ 0 0 0 0 0 0 0 0 ], "rows");
msg_non_zero = msg_recv_2(1:find(i_of_first_zero_row, 1) - 1, :);

% Pretvori dvojiško matriko sporočila v desetiško.
output_msg = bi2de(msg_non_zero, "left-msb");


%%%
% Opcijsko dekodiraj z Reed-Solomonovo kodo.
%%%
if (sf.param.rs_enable)
	disp("-- RS dekodiranje ------------");
	[output_msg, n_of_errors] = rs_de(output_msg, sf.param.rs_correctable_errors);
	output_msg = output_msg';
	printf("correctable_errors = %d\n", sf.param.rs_correctable_errors);
	n_of_errors
	if (n_of_errors == -1)
		error("RS dekodiranje neuspešno.\n");
	endif

	if (VALIDATING_CODING)
		printf("rs_error_rate = %.2f %%\n", (n_of_errors/numel(input_msg)) * 100);
	endif
endif

if (VALIDATING_CODING)
	CER = get_cer(input_msg_before_rs, output_msg(1:numel(input_msg_before_rs)));
	disp("-- Analiza -------------------");
	printf("message_error_rate = %.2f %%\n", CER);
	printf("extraneous_data = %.2f %%\n", (numel(output_msg)/numel(input_msg_before_rs)) * 100);
	# assert(CER_msg != 100);
endif

% Prikaži čas dekodiranja.
printf("# čas dekodiranja = %.3f s\n", toc);

if (!VALIDATING_CODING)
	% Dekodiranje uspešno, shrani dekodirano sporočilo
	if (isfield(sf.de, "input_audio"))
		file_write(output_msg, sf.de.output_file);
		printf("\nShranjujem novo datoteko ‘%s’.\n", sf.de.output_file);
	endif
else
	disp("\nValidacija kodiranja sporočila uspešna.\n");
endif
