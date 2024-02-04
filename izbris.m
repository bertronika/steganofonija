source("param.octave");

disp("Brišem izhodne datoteke.")

if (exist(sf.en.output_audio, "file") == 2)
	delete(sf.en.output_audio)
endif

if (exist(sf.de.output_file, "file") == 2)
	delete(sf.de.output_file)
endif
