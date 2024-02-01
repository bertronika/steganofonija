# clearvars;
pkg load communications;
global FRAME_LEN STRENGTH RAND_SEED RAND_FUNC;

addpath("util/");

MESSAGE = "sporočilo.txt";
# HOST_AUDIO  = "400Hz.flac";
# HOST_AUDIO  = "440Hz.wav";
# HOST_AUDIO  = "glas/400Hz60tiho.wav";
HOST_AUDIO = "glas/galliard.wav";

% 8192; 0.006 randn
# 6144; 0.007 randn
RAND_SEED = 1932;
FRAME_LEN = 1024*8

% fl 7
# RAND_FUNC = @rand
# STRENGTH = 0.09

% 440Hz    rs off, fl 2,  st 0.07
% 400Hz60  rs on,  fl 7,  st 0.028
% galliard rs off, fl 12, st 0.025

RAND_FUNC = @randn
STRENGTH = 0.028

% 440Hz60tiho rs on, fl 4, st 8.1e-11 Šumi.
# STRENGTH = 8.1e-9

%%%
% Nastavitve za Reed-Solomonovo kodiranje
%%%

ENABLE_RS = true;
# ENABLE_RS = false;

% Največje št. napak, ki naj jih skušamo odpraviti.
% Višja vrednost podaljša kodirano sporočilo.
N_OF_CORRECTABLE_ERRORS = 8;


%%%
% Lokalne funkcije
%%%

function n = n_of_embeddable_bits(input_audio)
	global FRAME_LEN;
	x_info = audioinfo(input_audio);
	x_len = x_info.TotalSamples;
	n = fix(x_len/FRAME_LEN);
endfunction

function ber = get_ber(x, y, total)
	assert(numel(x) == numel(y));
	ber = sum(abs(y - x)) / total;
	ber *= 100;
endfunction

function cer = get_cer(x, y)
	total = numel(x);
	assert(total == numel(y));
	c_diff = x - y;
	cer = (numel(c_diff(c_diff != 0))/total) * 100;
endfunction


%%%
% Program
%%%

[host_dir, host_name, host_ext] = fileparts(HOST_AUDIO);
if isempty(host_dir)
	host_dir = ".";
endif
STEG_AUDIO = [host_dir "/" host_name "_st" host_ext];
decoded_message_file = [host_dir "/" host_name ".txt"];

% Izračunaj, koliko bitov pri nastavljenem FRAME_LEN
% se lahko vgradi v podani zvočni posnetek.
HOST_AUDIO
available_bits = n_of_embeddable_bits(HOST_AUDIO);

% Naloži izvorno besedilno sporočilo
[input_msg, input_msg_len] = file_read(MESSAGE); MESSAGE


%%%
% Opcijsko kodiraj z Reed-Solomonovo kodo. Pozor - ta
% sporočilo znatno poveča.
%%%

input_msg_before_rs = input_msg; % Shrani izvirnik pred RS kodiranjem

if ENABLE_RS
	disp("-- RS kodiranje --------------");
	input_msg = rsenc_mod(input_msg, N_OF_CORRECTABLE_ERRORS);
endif

% Izračunaj, koliko bitov bo zahtevalo dano sporočilo
needed_bits = numel(input_msg) * 8
available_bits

% Če je zahtevanih bitov preveč, zaustavi
if needed_bits > available_bits
	if ENABLE_RS
		warning("RS kodiranje je vklopljeno.\n")
	endif
	error("Sporočilo je preveliko za vgradnjo v posnetek.\n");
endif

% Pretvori desetiški vektor sporočila v dvojiškega
input_msg_bin = de2bi(input_msg, 8, "left-msb")';

% Po vrsticah splošči matriko v vektor
msg_send = input_msg_bin(:);


%%%
% Vgradi sporočilo v zvočni posnetek, pridobi SNR.
%%%

disp("-- DSSS kodiranje ------------");
en(HOST_AUDIO, msg_send, STEG_AUDIO);


%%%
% Preberi sporočilo iz zvočnega posnetka.
%%%

disp("-- DSSS dekodiranje ----------");
msg_recv = de(STEG_AUDIO); % izvirnik neznan
# msg_recv = de(STEG_AUDIO, HOST_AUDIO); % izvirnik znan

% Izračunaj Bit Error Rate
BER = get_ber(msg_recv(1:numel(msg_send)), msg_send, available_bits)

% Preoblikuj vektor nazaj v matriko z 8 stolpci (po eno dvojiško število).
new_msg_size = 2^(nextpow2(numel(msg_recv)));
msg_recv_1 = resize(msg_recv, new_msg_size, 1);
msg_recv_2 = reshape(msg_recv_1, 8, [])';

% Pretvori dvojiški vektor sporočila v desetiškega
output_msg_padded = bi2de(msg_recv_2, "left-msb");

% Odvzemi ničelne vrednosti
output_msg = output_msg_padded(output_msg_padded != 0); % TODO podloži drugo kot 0 - funk. NA


%%%
% Opcijsko dekodiraj z Reed-Solomonovo kodo.
%%%

output_msg_before_rs = output_msg; % Shrani izvirnik pred RS dekodiranjem

if ENABLE_RS
	disp("-- RS dekodiranje ------------");
	[output_msg, n_err] = rsdec_mod(output_msg, N_OF_CORRECTABLE_ERRORS);
	output_msg = output_msg';
	n_err
	assert(n_err != -1);
	RS_ER = (n_err/numel(input_msg)) * 100
endif

% Izračunaj Character Error Rate
CER_all = get_cer(resize(input_msg_before_rs, numel(output_msg), 1), output_msg)
CER_msg = get_cer(input_msg_before_rs, output_msg(1:numel(input_msg_before_rs)))

assert(CER_msg != 100);

% Zapiši dekodirano sporočilo
file_write(output_msg, decoded_message_file); decoded_message_file
