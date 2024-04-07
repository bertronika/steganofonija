% Demonstracije različnih primerov kodiranj

function primer(n=-1)
	if (n == -1)
		error("Manjka številka primera.\n");
	endif

	clear -g sf; global sf;

	switch (n)
		case "1"
			disp("== Demonstracija kodiranja brez uporabe izvornega posnetka ==\n");
			sf.en.input_file   = "demo/skrivnost.txt";
			sf.en.input_audio  = "demo/400Hz30.wav";
			sf.en.output_audio = "demo/skrivnost1.wav";
			sf.de.dummy = 1;

			sf.param.frame_len = 1024*4;
			sf.param.rand_seed = 1932;
			sf.param.rand_func = @randn;
			sf.param.strength = 0.015;
			sf.param.create_graphs = true;
			kodiraj(true)
		case "2"
			disp("== Demonstracija kodiranja z uporabo izvornega posnetka ==\n");
			sf.en.input_file   = "demo/skrivnost.txt";
			sf.en.input_audio  = "demo/400Hz30.wav";
			sf.en.output_audio = "demo/skrivnost2.wav";
			sf.de.original_audio = true;

			sf.param.frame_len = 1024*4;
			sf.param.rand_seed = 1932;
			sf.param.rand_func = @randn;
			sf.param.strength = 8e-9;
			sf.param.create_graphs = true;
			kodiraj(true)
    case "3"
      disp("== Avtomatizirano testiranje postopka ==\n");
      sf.en.input_file   = "demo/skrivnost.txt";
      sf.en.input_audio  = "demo/400Hz30.wav";
      sf.en.output_audio = "demo/skrivnost.wav";
      sf.de.use_input_audio = false;

      disp("### Testiranje z različnimi jakostmi šuma ###\n")
      sf.param.frame_len = 1023*5;
      sf.param.rand_seed = 1932;
      sf.param.rand_func = @randn;
      sf.param.strength = 0.015;
      sf.param.rs_enable = false;
      sf.param.create_graphs = false;
      sf.param.save_graphs_to_files = false;

      for i = [0.025, 0.02, 0.015, 0.01, 0.009, 0.008, 0.007, 0.006, 0.005, 0.004, 0.003, 0.002, 0.001]
        sf.param.strength = i;
        kodiraj(true);
      endfor

      disp("### Testiranje z različnimi dolžinami okvirja ###\n")
      sf.param.strength = 0.025;

      for i = [3, 2,1]
        sf.param.frame_len=1023*i;
        kodiraj(true);
      endfor
		otherwise
			error("Ta primer ne obstaja\n");
	endswitch
endfunction
