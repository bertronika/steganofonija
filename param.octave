%%%
% Parametri kodirnega postopka
%%%

% Datoteka vhodnega sporočila
sf.en.input_file = "demo/skrivnost.txt";

% Vhodni posnetek, v katerega se kodira sporočilo
sf.en.input_audio = "demo/400Hz30.wav";

% Izhodni posnetek, ki bo vseboval sporočilo
sf.en.output_audio = "demo/skrivnost.wav";


%%%
% Parametri dekodirnega postopka
%%%

% Vhodni posnetek, ki vsebuje sporočilo
sf.de.input_audio = sf.en.output_audio;

% Datoteka dekodiranega sporočila
sf.de.output_file = "demo/sporocilo.txt";

% Uporabi vhodni posnetek za občutljivejše dekodiranje
sf.de.use_input_audio = false;


%%%
% Parametri kodiranja in dekodiranja
%%%

% Velikost okvirjev zvočne datoteke, v katere se kodira sporočilo
sf.param.frame_len = 1024*5;

% Seme generatorja psevdonaključnih števil
sf.param.rand_seed = 1932;

% Ime funkcije za tvorbo psevdonaključnega šuma
sf.param.rand_func = @randn;

% Moč kodiranja sporočila v datoteko
sf.param.strength = 0.024;

% Omogoči Reed-Solomonovo kodiranje
sf.param.rs_enable = false;

% Največje št. napak, ki naj jih RS skuša odpraviti
% (višja vrednost podaljša kodirano sporočilo)
sf.param.rs_correctable_errors = 4;

% Analiziraj podatke in izdelaj grafe
sf.param.create_graphs = false;

% Shrani posamezen graf analize kodiranja v svojo datoteko
sf.param.save_graphs_to_files = false;
