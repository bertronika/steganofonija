function N = rand_wrapper(varargin)
	global sf;

	% Inicializiraj generator psevdo-naključnih števil
	sf.param.rand_func("state", sf.param.rand_seed);

	N = sf.param.rand_func(varargin{:});

	if (strcmp(func2str(sf.param.rand_func), "rand"))
		N -= 0.5;
	endif
endfunction
