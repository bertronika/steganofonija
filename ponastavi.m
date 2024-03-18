source("param.m");

files = cat(1,
            glob("sf_*.png"),
            glob("demo/skrivnost?.wav"),
            {sf.en.output_audio; sf.de.output_file}
);

disp("Brišem izhodne datoteke.")
for n = 1:numel(files)
	f = files{n};
	if (exist(f, "file") == 2)
		disp([" - " f]);
		delete(f);
	endif
endfor
