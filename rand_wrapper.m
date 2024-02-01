function N = rand_wrapper(varargin)
	global RAND_FUNC RAND_SEED;

	% Inicializiraj generator psevdo-naključnih števil
	RAND_FUNC("state", RAND_SEED);

	N = RAND_FUNC(varargin{:});

	if strcmp(func2str(RAND_FUNC), "rand")
		N -= 0.5;
	endif
endfunction
