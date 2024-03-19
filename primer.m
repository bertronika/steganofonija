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
		otherwise
			error("Ta primer ne obstaja\n");
	endswitch

	kodiraj(true)
endfunction
