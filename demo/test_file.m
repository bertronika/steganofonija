cd ..
clear -g sf; global sf;
sf.en.input_file   = "demo/skrivnost.txt";
sf.en.input_audio  = "demo/400Hz30.wav";
sf.en.output_audio = "demo/skrivnost.wav";
sf.de.use_input_audio = false;

sf.param.frame_len = 1023*5;
sf.param.rand_seed = 1932;
sf.param.rand_func = @randn;
sf.param.strength = 0.015;
sf.param.rs_enable = false;
sf.param.create_graphs = false;
sf.param.save_graphs_to_files = false;

DEMO_MODE = true;

for i = [0.025, 0.02, 0.015, 0.01, 0.009, 0.008, 0.007, 0.006, 0.005, 0.004, 0.003, 0.002, 0.001]
  sf.param.strength = i;
  kodiraj(true);
end

sf.param.strength = 0.025;
disp("#########################################");
for i = [3, 2,1]
  sf.param.frame_len=1023*i;
  kodiraj;
endfor

clear DEMO_MODE
