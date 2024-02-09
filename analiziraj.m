% Časovna in spektralna analiza zvočnih posnetkov

pkg load signal;

if (exist("VALIDATING_CODING", "var") != 1)
	# au1 = "glas/galliard.wav";
	au1 = "demo/400Hz30.wav";
	au2 = "demo/skrivnost.wav";

	[x, fs] = audioread(au1);
	[y, ~] = audioread(au2);
	# x_info = audioinfo(au1);
else
	SAV = sf.param.save_graphs_to_files;
endif

% Izris amplitude dveh posnetkov na en graf v odvisnosti od časa
function draw_amplitude(x, y, fs)
	L = length(x);
	t = (0:L-1) / fs;

	plot(t, y);
	hold on;
	plot(t, x);

	ylabel("Rel. amplituda");
	xlabel("Čas (s)");
	title("Časovni potek amplitude");
	grid on;

	# set(gca, "fontsize", 12);

	[~, hobj, ~, ~] = legend("Predelan", "Izvirni");
	hl = findobj(hobj, "type", "line");
	set(hl, "LineWidth", 2); % Odebeli črte v legendi
endfunction

% Fourierova analiza vseh vzorcev signala
function [ampl_max, freq_max] = draw_whole_spectrum(x, fs, name)
	% Dolžini vzorcev
	N = length(x);
	Nfft = 2^nextpow2(N);

	% Frekvenčni razpon z enosmerno komponento (0 Hz) v sredini
	frequencies = (-Nfft/2:Nfft/2-1) * fs/Nfft;

	% DFT signala (z oknjenjem?)
	% Zamaknjen, da so negativne frek. na levi in pozitivne na desni
	# amplitudes = abs(fftshift(fft(x, Nfft)) / N);
	amplitudes = abs(fftshift(fft(x .* hamming(N), Nfft)) / N);

	semilogy(frequencies/1000, amplitudes);
	# plot(frequencies, 10 * log10(amplitudes));

	xlim([ frequencies(1) frequencies(end) ]/1000);
	xlabel("Frekvenca (kHz)");
	ylabel("Amplituda (dB)");
	title(name); % TODO annotation("textbox") ?
	grid on;

	[ampl_max, ampl_i] = max(10 * log10(amplitudes));
	freq_max = frequencies(ampl_i);
	# printf("%s: maksimum %.2f dB pri %.2f Hz\n", ...
	       # name, ampl_max, freq_max);
endfunction

% Kratkotrajna Fourierova analiza kosov signala (za izris spektrograma)
function draw_spectrogram(x, fs, name)
	# N = 64; % Št. posameznih analiziranih kosov
	step = ceil(50 * fs/1000);
	window = ceil(100 * fs/1000);
	N = 2^nextpow2(window);

	[S, f, t] = specgram(x, N, fs, window, window - step);
	imagesc(t, f/1000, 20*log10(abs(S)));
	set(gca(), "ydir", "normal");
	xlabel("Čas (s)");
	ylabel("Frekvenca (kHz)");
	title(name);
endfunction

# try
# 	clf(2);
# catch
	# pos = get(gcf,'Position');
# 	% x, y, širina, višina
	# set(gcf, 'Position', [pos(1), pos(2), pos(3)*2, pos(4)*2]);
# end_try_catch

close all;

disp("-- Analiza signalov ---------");
tic;

% Če ima posnetek dva kanala, za izdelavo analize izračunaj njuno povprečje
if (channels == 2)
	x_averaged = (x(:,1) + x(:,2))/2;
	y_averaged = (y(:,1) + y(:,2))/2;
else
	x_averaged = x;
	y_averaged = y;
endif

if (numel(x)/fs > 60)
	disp("# Omejujem dolžino posnetkov na 60 s pri FFT analizah");
	x_reduced = x_averaged(1:60 * fs);
	y_reduced = y_averaged(1:60 * fs);
else
	x_reduced = x_averaged;
	y_reduced = y_averaged;
endif

if (SAV)
	H1 = figure("visible", "off");
else
	H1 = figure;
endif
pos = get(H1, 'Position');
set(H1, 'Position', [pos(1), pos(2), pos(3)*1.5, pos(4)]);
draw_amplitude(x_averaged, y_averaged, fs);

if (SAV)
	H2 = figure("visible", "off");
else
	H2 = figure;
	pos = get(H2, 'Position');
	set(H2, 'Position', [pos(1), pos(2), pos(3)*1.5, pos(4)*1.5]);
	subplot(2, 2, 1);
endif
draw_whole_spectrum(x_reduced, fs, "Močnostni spekter izvirnega posnetka");

if (SAV)
	H3 = figure("visible", "off");
else
	subplot(2, 2, 2);
endif
draw_whole_spectrum(y_reduced, fs, "Močnostni spekter predelanega posnetka");

if (SAV)
	H4 = figure("visible", "off");
else
	subplot(2, 2, 3);
endif
draw_spectrogram(x_reduced, fs, "Spektrogram izvirnega posnetka");

if (SAV)
	H5 = figure("visible", "off");
else
	subplot(2, 2, 4);
endif
draw_spectrogram(y_reduced, fs, "Spektrogram predelanega posnetka");

printf("# čas analize = %.3f s\n", toc);

if (SAV)
	img_settings = ["-r80"];

	disp("# shranjujem v slikovne datoteke");
	print(H1, "-r90", "sf_ampl.png");
	print(H2, img_settings, "sf_spekter_x.png");
	print(H3, img_settings, "sf_spekter_y.png");
	print(H4, img_settings, "sf_spektrogram_x.png");
	print(H5, img_settings, "sf_spektrogram_y.png");
endif
