function file_write(buf, file)
	try fid = fopen(file, "w+t");
	catch
		error("Could not open '%s' for writing.", file);
	end_try_catch

	fwrite(fid, buf);
	fclose(fid);
endfunction
