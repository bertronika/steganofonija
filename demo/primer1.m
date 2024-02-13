% Demonstracija steganofonskega dekodiranja brez uporabe izvornega posnetka

cd ..
source("param.octave");

disp("\n== Demonstracija dekodiranja brez uporabe izvornega posnetka ==");

sf.en.output_audio = "demo/skrivnost1.wav";
sf.de.use_input_audio = false;
sf.param.frame_len = 1024*4;
sf.param.rand_seed = 1932;
sf.param.rand_func = @randn;
sf.param.strength = 0.035;
sf.param.rs_enable = false;
sf.param.save_graphs_to_files = false;

DEMO_MODE = true;
kodiraj
clear DEMO_MODE
