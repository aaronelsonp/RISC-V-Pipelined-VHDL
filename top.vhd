library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port (
		clr_in: in std_logic;
		clk_in: in std_logic;
		read_en: in std_logic;
		seg: out std_logic_vector (7 downto 0);
		dig: out std_logic_vector (3 downto 0);
		tx_out: out std_logic
	);
end top;

architecture behav of top is
	
	component program_counter is
		port (
			clk, clr, pc_en: in std_logic;
			address_in: in std_logic_vector(31 downto 0);
			address_out: out std_logic_vector(31 downto 0)
		);
	end component program_counter;

	component progmem IS
		port
		(
			clk: in std_logic  := '1';
			address: in std_logic_vector (29 downto 0);
			instruction_out: out std_logic_vector (31 downto 0)
		);
	end component progmem;
	
	component if_id_regs is
		port(
			clk, clr, regs_en_IFID, flush_sig: in std_logic;
			instruction_in, address_in: in std_logic_vector (31 downto 0);
			instruction_out, address_out: out std_logic_vector (31 downto 0)	
		);
	end component if_id_regs;
	
	component hazarddetect is
		port(
			opcode: in std_logic_vector (6 downto 0);
			memread_IDEX: in std_logic;
			rs1_IFID, rs2_IFID: in std_logic_vector (4 downto 0);
			rd_IDEX: in std_logic_vector (4 downto 0);
			pc_en: out std_logic := '1';
			regs_en_IFID: out std_logic := '1';
			ctrl_mux_en: out std_logic := '1'
		);
	end component hazarddetect;
	
	component register_files is
		port (
			clk, write_en: in std_logic;
			read_address_1: in std_logic_vector(4 downto 0);
			read_address_2: in std_logic_vector(4 downto 0);
			write_address: in std_logic_vector(4 downto 0);
			write_data: in std_logic_vector(31 downto 0);
			data_out_1: out std_logic_vector(31 downto 0);
			data_out_2: out std_logic_vector(31 downto 0);
			probe_out_sig: out std_logic_vector(31 downto 0)
		);
	end component register_files;

	component control_unit is
		port (
			opcode: in std_logic_vector(6 downto 0);
			mem_write, branch, reg_write, mem_to_reg, load_en: out std_logic;
			wb_mux_sel: out std_logic_vector (1 downto 0);
			operand_a_sel: out std_logic_vector (1 downto 0);
			operand_b_sel: out std_logic;
			next_pc_sel: out std_logic_vector (1 downto 0);
			extend_sel: out std_logic_vector (1 downto 0);
			ALU_op: out std_logic_vector(2 downto 0)
		);
	end component control_unit;
	
	component alu_ctrl is
		port (
			ALU_control: in std_logic_vector (2 downto 0);
			funct7: in std_logic;
			funct3: in std_logic_vector (2 downto 0);
			ALUop: out std_logic_vector (4 downto 0)
		);
	end component alu_ctrl;
	
	component immgen is
		port (
			inst: in std_logic_vector (31 downto 0);
			s_type_imm: out std_logic_vector (31 downto 0);
			sb_type_imm: out std_logic_vector (31 downto 0);
			u_type_imm: out std_logic_vector (31 downto 0);
			uj_type_imm: out std_logic_vector (31 downto 0);
			i_type_imm: out std_logic_vector (31 downto 0)
		);
	end component immgen;
	
	component id_ex_regs is
		port(
			clk, clr, flush_sig: in std_logic; 
			instruction_in: in std_logic_vector (31 downto 0);
			address_in, regs_a_in, regs_b_in: in std_logic_vector (31 downto 0);
			reg_write_en_in, branch_in, mem_write_in, mem_to_reg_in: in std_logic;
			ALUop_in: in std_logic_vector (4 downto 0);
			operand_a_sel_in: in std_logic_vector (1 downto 0);
			operand_b_sel_in: in std_logic;
			next_pc_sel_in: in std_logic_vector (1 downto 0);
			byte_mode_in: in std_logic_vector (2 downto 0);
			immediate_in: in std_logic_vector (31 downto 0);
			uj_type_imm_in, sb_type_imm_in: in std_logic_vector (31 downto 0);
			operand_a_mux_sel_in: in std_logic_vector (1 downto 0);
			operand_b_mux_sel_in: in std_logic_vector (1 downto 0);
			wb_mux_sel_in: in std_logic_vector (1 downto 0);
			instruction_out: out std_logic_vector (31 downto 0);
			address_out, regs_a_out, regs_b_out: out std_logic_vector (31 downto 0);
			reg_write_en_out, branch_out, mem_write_out, mem_to_reg_out: out std_logic;
			ALUop_out: out std_logic_vector (4 downto 0);
			operand_a_sel_out: out std_logic_vector (1 downto 0);
			operand_b_sel_out: out std_logic;
			next_pc_sel_out: out std_logic_vector (1 downto 0);
			byte_mode_out: out std_logic_vector (2 downto 0);
			immediate_out: out std_logic_vector (31 downto 0);
			uj_type_imm_out, sb_type_imm_out: out std_logic_vector (31 downto 0);
			operand_a_mux_sel_out: out std_logic_vector (1 downto 0);
			operand_b_mux_sel_out: out std_logic_vector (1 downto 0);
			wb_mux_sel_out: out std_logic_vector (1 downto 0)
		);
	end component id_ex_regs;
	
	component alu is
		port (
			ALUop_in: in std_logic_vector (4 downto 0);
			operand_a: in std_logic_vector (31 downto 0);
			operand_b: in std_logic_vector (31 downto 0);
			result_out: out std_logic_vector (31 downto 0);
			ALU_branch_sig: out std_logic
		);
	end component alu;
	
	component forwarding_unit is
		port (
			rs1_idex: in std_logic_vector(4 downto 0);
			rs2_idex: in std_logic_vector(4 downto 0);
			rd_exmem: in std_logic_vector(4 downto 0);
			rd_memwb: in std_logic_vector(4 downto 0);
			regwrite_exmem: in std_logic;
			regwrite_memwb: in std_logic;
			forward_mux_a: out std_logic_vector (1 downto 0);
			forward_mux_b: out std_logic_vector (1 downto 0)
		);
	end component forwarding_unit;
	
	component ex_mem_regs is
		port(
			clk: in std_logic; 
			ALU_in: in std_logic_vector (31 downto 0);
			byte_mode_in: in std_logic_vector (2 downto 0);
			mem_write_in: in std_logic;
			reg_write_in: in std_logic;
			regs_address_in: in std_logic_vector (4 downto 0);
			datamem_data_in: in std_logic_vector (31 downto 0);
			wb_mux_in: in std_logic;
			wb_mux_sel_in: in std_logic_vector (1 downto 0);
			address_in: in std_logic_vector (31 downto 0);
			ALU_out: out std_logic_vector (31 downto 0);
			byte_mode_out: out std_logic_vector (2 downto 0);
			mem_write_out: out std_logic;
			reg_write_out: out std_logic;
			regs_address_out: out std_logic_vector (4 downto 0);
			datamem_data_out: out std_logic_vector (31 downto 0);
			wb_mux_out: out std_logic;
			wb_mux_sel_out: out std_logic_vector (1 downto 0);
			address_out: out std_logic_vector (31 downto 0)
		);
	end component ex_mem_regs;
	
	component data_memory IS
		port (
			clk: in std_logic;
			data: in std_logic_vector (31 downto 0);
			address: in std_logic_vector (12 downto 0);
			write_en: in std_logic;
			byte_mode: in std_logic_vector (2 downto 0);
			q: out std_logic_vector (31 downto 0):= x"00000000"
		);
	end component data_memory;

	component mem_wb_regs is
		port(
			clk: in std_logic; 
			ALU_in: in std_logic_vector (31 downto 0);
			datamem_in: in std_logic_vector (31 downto 0);
			wb_mux_in: in std_logic;
			reg_write_in: in std_logic;
			regs_address_in: in std_logic_vector (4 downto 0);
			wb_mux_sel_in: in std_logic_vector (1 downto 0);
			address_in: in std_logic_vector (31 downto 0);
			ALU_out: out std_logic_vector (31 downto 0);
			datamem_out: out std_logic_vector (31 downto 0);
			wb_mux_out: out std_logic;
			reg_write_out: out std_logic;
			regs_address_out: out std_logic_vector (4 downto 0);
			wb_mux_sel_out: out std_logic_vector (1 downto 0);
			address_out: out std_logic_vector (31 downto 0)
		);
	end component mem_wb_regs;

	component sevenseg is
		port (
			clk: in std_logic;
			data_in: in std_logic_vector (31 downto 0);
			seg: out std_logic_vector (7 downto 0);
			dig: out std_logic_vector (3 downto 0)
		);
	end component sevenseg;
	
	component bin2bcd is
		port ( 
		  input:      in   std_logic_vector (15 downto 0);
		  ones:       out  std_logic_vector (3 downto 0);
		  tens:       out  std_logic_vector (3 downto 0);
		  hundreds:   out  std_logic_vector (3 downto 0);
		  thousands:  out  std_logic_vector (3 downto 0)
		);
	end component bin2bcd;
	
	component hex2ascii is
		port(
			input: in std_logic_vector (3 downto 0);
			output: out std_logic_vector (7 downto 0);
			next_out: in std_logic
		);
	end component hex2ascii;
	signal pc_in_sig, pc_out_sig, pc_out_sig_IFID, pc_out_sig_IDEX, pc_out_sig_EXMEM, pc_out_sig_MEMWB: std_logic_vector (31 downto 0):= x"00000000"; --pc 
	signal instruction, instruction_IFID, instruction_IDEX: std_logic_vector (31 downto 0); --progmem
	
	--==========================================================================================================
	-- Register Files Signals
	--==========================================================================================================
	signal write_address_IDEX, write_address_EXMEM, write_address_MEMWB: std_logic_vector(4 downto 0); 
	signal data_out_0_sig, data_out_0_sig_IDEX: std_logic_vector (31 downto 0); 
	signal data_out_1_sig, data_out_1_sig_IDEX: std_logic_vector (31 downto 0); 

	
	--==========================================================================================================
	-- Control Unit Signals
	--==========================================================================================================
	signal reg_write_en_sig, reg_write_en_sig_IDEX, reg_write_en_sig_EXMEM, reg_write_en_sig_MEMWB: std_logic; 
	signal branch_sig, branch_sig_IDEX: std_logic; 
	signal mem_write_sig, mem_write_sig_IDEX, mem_write_sig_EXMEM: std_logic; 
	signal mem_to_reg_sig, mem_to_reg_sig_IDEX, mem_to_reg_sig_EXMEM, mem_to_reg_sig_MEMWB: std_logic; 
	signal operand_b_sel_sig, operand_b_sel_sig_IDEX: std_logic; 
	signal load_en_sig, load_en_sig_IDEX: std_logic; 
	signal wb_mux_sel_sig, wb_mux_sel_sig_IDEX, wb_mux_sel_sig_EXMEM, wb_mux_sel_sig_MEMWB: std_logic_vector (1 downto 0);
	signal ALUop_sig, ALUop_sig_IDEX: std_logic_vector (4 downto 0);
	signal operand_a_sel_sig, operand_a_sel_sig_IDEX, next_pc_sel_sig, next_pc_sel_sig_IDEX: std_logic_vector (1 downto 0);
	signal byte_mode_sig, byte_mode_sig_IDEX, byte_mode_sig_EXMEM: std_logic_vector (2 downto 0); 
	signal immediate_sig, immediate_sig_IDEX: std_logic_vector (31 downto 0); 
	signal s_type_imm_sig, u_type_imm_sig, i_type_imm_sig, uj_type_imm_sig, uj_type_imm_sig_IDEX, sb_type_imm_sig, sb_type_imm_sig_IDEX: std_logic_vector (31 downto 0); 
	signal extend_sel_sig: std_logic_vector (1 downto 0);
	signal opcode_sig: std_logic_vector (6 downto 0);
	signal ALU_control_sig: std_logic_vector (2 downto 0);
	signal operand_a_sig, operand_b_sig, operand_a_forward_sig, operand_b_forward_sig, ALU_out_sig, ALU_out_sig_EXMEM, ALU_out_sig_MEMWB: std_logic_vector (31 downto 0); -- ALU signals
	signal funct7_sig: std_logic;
	signal funct3_sig: std_logic_vector (2 downto 0);
	
	--==========================================================================================================
	-- Jump and Branch Signals
	--==========================================================================================================	
	signal jump_sig, jalr_sig: std_logic_vector (31 downto 0); 
	signal ALU_branch_sig, jump_flag: std_logic;

	
	signal datamem_data_sig, datamem_out_sig, datamem_out_sig_MEMWB: std_logic_vector (31 downto 0); -- Data Memory signals
	signal wb_mux_out: std_logic_vector (31 downto 0); -- mux writeback
	
	signal operand_a_mux_sel_sig, operand_a_mux_sel_sig_IFID, operand_b_mux_sel_sig, operand_b_mux_sel_sig_IFID: std_logic_vector (1 downto 0);
	--==========================================================================================================
	-- Flush Signal, Edge Detector, Hazard Detection
	--==========================================================================================================	
	signal flush_detect : std_logic := '0'; -- flush edge detector, double clock speed
	signal flush_rising_edge : std_logic;
	signal flush_sig, flush_sig_idex, flush_sig_EXMEM: std_logic;
	signal pc_en_sig, regs_en_IFID_sig, ctrl_mux_en_sig: std_logic:= '1';
	--==========================================================================================================
	-- Clock Divider and clr
	--==========================================================================================================	
	signal count, count0, count1: integer:=1;
	signal tmp: std_logic := '0';
	signal clk, clk_inverse, clk_2x: std_logic; 
	signal clr: std_logic;
	--
	-- seven segments
	--
	signal probe_out_sig: std_logic_vector (31 downto 0);
	signal bcd_sig: std_logic_vector (31 downto 0); -- binary to bcd for 7-segments
	signal ones_sig, tens_sig, hundreds_sig, thousands_sig: std_logic_vector(3 downto 0); --binary to bcd for 7-segments

begin
	-- clk divider
	clr <= not clr_in;
	
	process (clk_in, clr)
		begin
		if(clr='1') then
			count0 <=1;
			clk<='0';
		elsif rising_edge(clk_in) then 
			count0 <= count0+1;
			if (count0 = 250) then
				clk <= not clk;
				count0 <= 1;
			end if;
		end if;
	end process;
	
	
	clk_inverse <= not clk; -- for data memory, falling edge
	--==========================================================================================================
	-- Seven segments
	--==========================================================================================================
	sevenseg1: sevenseg port map (clk_in, bcd_sig, seg, dig);
	bin2bcd1: bin2bcd port map (probe_out_sig(15 downto 0), ones_sig, tens_sig, hundreds_sig, thousands_sig);
	bcd_sig <= x"0000"&thousands_sig&hundreds_sig&tens_sig&ones_sig;
	
	
	--==========================================================================================================
	-- IF Stage
	--==========================================================================================================
	
	pc0: program_counter port map (clk, clr, pc_en_sig, pc_in_sig, pc_out_sig); -- in IF
	progmem0: progmem port map (clk, pc_out_sig(31 downto 2), instruction); -- in IF, aligned access only
	
	pc_mux: 
		with next_pc_sel_sig_IDEX select pc_in_sig <=
			std_logic_vector(unsigned(pc_out_sig) + to_unsigned(4, 32)) when "00",
			jump_sig when "01",
			std_logic_vector(unsigned(uj_type_imm_sig_IDEX) + unsigned(pc_out_sig_IDEX)) when "10", -- JAL target
			jalr_sig when "11",
			(others => 'X') when others;
	
	--==========================================================================================================
	-- IF/ID Stage
	--==========================================================================================================
	IFID_regs: if_id_regs port map (clk, clr, regs_en_IFID_sig, flush_sig, instruction, pc_out_sig, instruction_IFID, pc_out_sig_IFID);
	
	opcode_sig <= instruction_IFID(6 downto 0);
	funct7_sig <= instruction_IFID(30);
	funct3_sig <= instruction_IFID(14 downto 12);
	
	regfiles0: register_files port map (clk_inverse, reg_write_en_sig_MEMWB, instruction_IFID(19 downto 15), instruction_IFID(24 downto 20), write_address_MEMWB, wb_mux_out, data_out_0_sig, data_out_1_sig, probe_out_sig); -- in IFID
	
	ctrl0: control_unit port map (opcode_sig, mem_write_sig, branch_sig, reg_write_en_sig, mem_to_reg_sig, load_en_sig, wb_mux_sel_sig, operand_a_sel_sig, operand_b_sel_sig, next_pc_sel_sig, extend_sel_sig, ALU_control_sig); -- in IFID
	
	aluctrl0: alu_ctrl port map (ALU_control_sig, funct7_sig, funct3_sig, ALUop_sig);
	byte_mode_sig <= instruction_IFID(14 downto 12) when load_en_sig = '1' or mem_write_sig = '1' else (others => '0'); 	--Byte mode, 000 word, 001 signed hw, 010 unsign hw, 011 signed byte, 100 unsigned byte
	
	immgen0: immgen port map (instruction_IFID, s_type_imm_sig, sb_type_imm_sig, u_type_imm_sig, uj_type_imm_sig, i_type_imm_sig);
	
	immgen_mux:
	with extend_sel_sig select immediate_sig <=
		i_type_imm_sig when "00",
		u_type_imm_sig when "01",
		s_type_imm_sig when "10",
		(others => 'X') when others;
	
	
	
	hazarddetect0: hazarddetect port map(opcode_sig, mem_to_reg_sig_IDEX, instruction_IFID(19 downto 15), instruction_IFID(24 downto 20), instruction_IDEX(11 downto 7), pc_en_sig, regs_en_IFID_sig, ctrl_mux_en_sig);
	
	--==========================================================================================================
	-- ID/EX Stage
	--==========================================================================================================
	IDEX_regs: id_ex_regs port map (clk, clr, flush_sig_idex, instruction_IFID, pc_out_sig_IFID, data_out_0_sig, data_out_1_sig, reg_write_en_sig, branch_sig, mem_write_sig, mem_to_reg_sig, ALUop_sig, operand_a_sel_sig, operand_b_sel_sig, next_pc_sel_sig, byte_mode_sig, immediate_sig, uj_type_imm_sig, sb_type_imm_sig, operand_a_mux_sel_sig_IFID, operand_b_mux_sel_sig_IFID, wb_mux_sel_sig,
									instruction_IDEX, pc_out_sig_IDEX, data_out_0_sig_IDEX, data_out_1_sig_IDEX, reg_write_en_sig_IDEX, branch_sig_IDEX, mem_write_sig_IDEX, mem_to_reg_sig_IDEX, ALUop_sig_IDEX, operand_a_sel_sig_IDEX, operand_b_sel_sig_IDEX, next_pc_sel_sig_IDEX, byte_mode_sig_IDEX, immediate_sig_IDEX, uj_type_imm_sig_IDEX, sb_type_imm_sig_IDEX, operand_a_mux_sel_sig, operand_b_mux_sel_sig, wb_mux_sel_sig_IDEX);
	
	jump_target: -- this is for branching
		jump_flag <= '1' when instruction_IDEX(6 downto 0) = "1100111" else
					 '1' when instruction_IDEX(6 downto 0) = "1101111" else
					 '0';
		-- ALU_branch_sig <= '1' when (ALUop_sig_IDEX(4 downto 3) = "10") and (ALU_out_sig = x"00000001") else '0'; -- in IDEX
		with ALU_branch_sig and branch_sig_IDEX select jump_sig <=
			std_logic_vector(unsigned(pc_out_sig) + to_unsigned(4, 32)) when '0',
			std_logic_vector(unsigned(sb_type_imm_sig_IDEX) + unsigned(pc_out_sig_IDEX)) when '1',
			(others => 'X') when others;
	
	jalr_target:
		--jalr_sig <= std_logic_vector(unsigned(data_out_0_sig_IDEX) + unsigned(immediate_sig_IDEX)) and x"fffffffc"; -- aligned access only
		jalr_sig <= std_logic_vector(unsigned(operand_a_forward_sig) + unsigned(immediate_sig_IDEX)) and x"fffffffc"; -- aligned access only
	
	alu0: alu port map (ALUop_sig_IDEX, operand_a_forward_sig, operand_b_sig, ALU_out_sig, ALU_branch_sig);
	
	--forward_unit0: forwarding_unit port map (instruction_IDEX(19 downto 15), instruction_IDEX(24 downto 20), write_address_EXMEM, write_address_MEMWB, reg_write_en_sig_EXMEM, reg_write_en_sig_MEMWB, operand_a_mux_sel_sig, operand_b_mux_sel_sig);
	forward_unit0: forwarding_unit port map (instruction_IFID(19 downto 15), instruction_IFID(24 downto 20), instruction_IDEX(11 downto 7), write_address_EXMEM, reg_write_en_sig_IDEX, reg_write_en_sig_EXMEM, operand_a_mux_sel_sig_IFID, operand_b_mux_sel_sig_IFID);
	
	operand_a_sig <= data_out_0_sig_IDEX when operand_a_sel_sig_IDEX = "00" else
					pc_out_sig_IDEX when operand_a_sel_sig_IDEX = "01" else
					std_logic_vector(unsigned(pc_out_sig_IDEX) + to_unsigned(4, 32)) when operand_a_sel_sig_IDEX = "10" else
					x"00000000"; -- when operand_a_sel_sig_IDEX = "11"
					
	operand_b_sig <= operand_b_forward_sig when operand_b_sel_sig_IDEX = '0' else
					immediate_sig_IDEX; -- when operand_b_sel_sig_IDEX = '1';
	
	with operand_a_mux_sel_sig select operand_a_forward_sig <= -- operand a mux
		operand_a_sig when "00",
		wb_mux_out when "01",
		ALU_out_sig_EXMEM when "10",
		(others => 'X') when others;
	
	with operand_b_mux_sel_sig select operand_b_forward_sig <= -- operand a mux
		data_out_1_sig_IDEX when "00",
		ALU_out_sig_EXMEM  when "10",
		wb_mux_out when "01",
		(others => 'X') when others;
	

	flush_sig <=  jump_flag or ALU_branch_sig;
	flush_sig_idex <= flush_sig or not ctrl_mux_en_sig;
	--==========================================================================================================
	-- EX/MEM Stage
	--==========================================================================================================

	EXMEM_regs: ex_mem_regs port map (clk, ALU_out_sig, byte_mode_sig_IDEX, mem_write_sig_IDEX, reg_write_en_sig_IDEX, instruction_IDEX(11 downto 7), operand_b_forward_sig, mem_to_reg_sig_IDEX, wb_mux_sel_sig_IDEX, pc_out_sig_IDEX,
										ALU_out_sig_EXMEM, byte_mode_sig_EXMEM, mem_write_sig_EXMEM, reg_write_en_sig_EXMEM, write_address_EXMEM, datamem_data_sig, mem_to_reg_sig_EXMEM, wb_mux_sel_sig_EXMEM, pc_out_sig_EXMEM);
	
	datamem_0: data_memory port map (clk_inverse, datamem_data_sig, ALU_out_sig_EXMEM(12 downto 0), mem_write_sig_EXMEM, byte_mode_sig_EXMEM, datamem_out_sig);
	flush_detect <= flush_sig_EXMEM when rising_edge(clk_2x) else '0'; 
	--flush_rising_edge <= not flush_detect and flush_sig_EXMEM; 
	
	--==========================================================================================================
	-- MEM/WB Stage
	--==========================================================================================================
	MEMWB_regs: mem_wb_regs port map (clk, ALU_out_sig_EXMEM, datamem_out_sig, mem_to_reg_sig_EXMEM, reg_write_en_sig_EXMEM, write_address_EXMEM, wb_mux_sel_sig_EXMEM, pc_out_sig_EXMEM,
									ALU_out_sig_MEMWB, datamem_out_sig_MEMWB, mem_to_reg_sig_MEMWB, reg_write_en_sig_MEMWB, write_address_MEMWB, wb_mux_sel_sig_MEMWB, pc_out_sig_MEMWB);
									
	wb_mux_out <= ALU_out_sig_MEMWB when wb_mux_sel_sig_MEMWB = "00" else 
				  datamem_out_sig_MEMWB when wb_mux_sel_sig_MEMWB = "01" else
				  std_logic_vector(unsigned(pc_out_sig_MEMWB) + to_unsigned(4, 32)) when wb_mux_sel_sig_MEMWB = "11" else
				  x"00000000";
					
end behav;