constant inst_NOP     : std_logic_vector(3 downto 0) := "0000";
constant inst_BLoad   : std_logic_vector(3 downto 0) := "0001";
constant inst_Iload   : std_logic_vector(3 downto 0) := "0010";
constant inst_Bstore  : std_logic_vector(3 downto 0) := "0011";
constant inst_Istore  : std_logic_vector(3 downto 0) := "0100";
constant inst_XOR     : std_logic_vector(3 downto 0) := "0101";
constant inst_ROT     : std_logic_vector(3 downto 0) := "0110";
constant inst_PSUM    : std_logic_vector(3 downto 0) := "0111";
constant inst_PSStore : std_logic_vector(3 downto 0) := "1000";
constant inst_LSet    : std_logic_vector(3 downto 0) := "1001";
constant inst_MAJ     : std_logic_vector(3 downto 0) := "1010";

constant NOP : std_logic_vector(3 downto 0) := "0000";


execute_state

type execute_state is ( 
						fetch,
						decode,
						NOP_1,
						BLoad_1,  
						ILoad_1,  
						BStore_1, 
						IStore_1,
						XOR_1,
						ROT_1,
						PSUM_1,
						PSStore_1,
						LSet_1,
						MAJ_1,
					   );

elsif opcode = inst_NOP     then
	execute_state <= NOP_1;
elsif opcode = inst_BLoad   then
	execute_state <= BLoad_1;
elsif opcode = inst_Iload   then
	execute_state <= ILoad_1;
elsif opcode = inst_Bstore  then
	execute_state <= BStore_1;
elsif opcode = inst_Istore  then
	execute_state <= IStore_1;
elsif opcode = inst_XOR     then
	execute_state <= XOR_1;
elsif opcode = inst_ROT     then
	execute_state <= ROT_1;
elsif opcode = inst_PSUM    then
	execute_state <= PSUM_1;
elsif opcode = inst_PSStore then
	execute_state <= PSStore_1;
elsif opcode = inst_LSet    then
	execute_state <= LSet_1;
elsif opcode = inst_MAJ     then
	execute_state <= MAJ_1;
else
	execute_state <= NOP_1;
end if;



	inst_NOP     = 4'b0000,
	inst_BLoad   = 4'b0001,
	inst_Iload   = 4'b0010,
	inst_Bstore  = 4'b0011,
	inst_Istore  = 4'b0100,
	inst_XOR     = 4'b0101,
	inst_ROT     = 4'b0110,
	inst_PSUM    = 4'b0111,
	inst_PSStore = 4'b1000,
	inst_LSet    = 4'b1001,
	inst_MAJ     = 4'b1010,