function [buf, buf_len] = file_read(file)
	try fid = fopen(file, "r");
	catch
		error("Could not open '%s' for reading.", file);
	end_try_catch

	[buf, buf_len] = fread(fid);
	fclose(fid);
endfunction
