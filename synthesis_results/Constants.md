	----------------------------------------------------
    ----------------------------------------------------
    -------------       Cache Constants     ------------
    ----------------------------------------------------
    ----------------------------------------------------
	
	constant int_size: integer := 8;
    
    constant int_cache_count    : integer := 2;
    constant binary_cache_count : integer := 2;
    
    constant binary_cache_depth       : integer := 32;
    constant int_cache_depth          : integer := 32;
    constant i_cache_depth            : integer := 32;

    ----------------------------------------------------
    ----------------------------------------------------
    -------------       PE Constants      --------------
    ----------------------------------------------------
    ----------------------------------------------------
    constant ROT_amount_max : integer := 8; 
    constant ROT_threads    : integer := 1;
    constant XOR_threads    : integer := 1;
    constant PSUM_threads   : integer := 1;
    constant MAJ_threads    : integer := 1;