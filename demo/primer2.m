cd ..
source("param.m");

disp("\n== Demonstracija dekodiranja z uporabo izvornega posnetka ==");

sf.en.input_file   = "demo/skrivnost.txt";
sf.en.input_audio  = "demo/400Hz30.wav";
sf.en.output_audio = "demo/skrivnost2.wav";
sf.de.use_input_audio = true;

sf.param.frame_len = 1024*4;
sf.param.rand_seed = 1932;
sf.param.rand_func = @randn;
sf.param.strength = 8e-9;
sf.param.rs_enable = false;
sf.param.create_graphs = true;
sf.param.save_graphs_to_files = false;

DEMO_MODE = true;
kodiraj
clear DEMO_MODE
