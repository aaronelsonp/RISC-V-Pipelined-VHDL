library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_ex_regs is
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
end id_ex_regs;

architecture behav of id_ex_regs is
begin
	process (clk, clr) 
	begin
		if (clr = '1') then
			instruction_out <= (others => '0');
			address_out <= (others => '0');
			regs_a_out <= (others => '0');
			regs_b_out <= (others => '0');
			reg_write_en_out <= '0';
			branch_out <= '0';
			mem_write_out <= '0';
			mem_to_reg_out <= '0';
			ALUop_out <= (others => '0');
			operand_a_sel_out <= (others => '0');
			operand_b_sel_out <= '0';
			next_pc_sel_out <= (others => '0');
			byte_mode_out <= (others => '0');
			immediate_out <= (others => '0');
			uj_type_imm_out <= (others => '0');
			sb_type_imm_out <= (others => '0');
			operand_a_mux_sel_out <= (others => '0');
			operand_b_mux_sel_out <= (others => '0');
			wb_mux_sel_out <= (others => '0');
		elsif rising_edge(clk) then
			if (flush_sig = '1') then
				instruction_out <= (others => '0');
				address_out <= (others => '0');
				regs_a_out <= (others => '0');
				regs_b_out <= (others => '0');
				reg_write_en_out <= '0';
				branch_out <= '0';
				mem_write_out <= '0';
				mem_to_reg_out <= '0';
				ALUop_out <= (others => '0');
				operand_a_sel_out <= (others => '0');
				operand_b_sel_out <= '0';
				next_pc_sel_out <= (others => '0');
				byte_mode_out <= (others => '0');
				immediate_out <= (others => '0');
				uj_type_imm_out <= (others => '0');
				sb_type_imm_out <= (others => '0');
				operand_a_mux_sel_out <= (others => '0');
				operand_b_mux_sel_out <= (others => '0');
				wb_mux_sel_out <= (others => '0');
			else
				instruction_out <= instruction_in;
				address_out <= address_in;
				regs_a_out <= regs_a_in;
				regs_b_out <= regs_b_in;
				reg_write_en_out <= reg_write_en_in;
				branch_out <= branch_in;
				mem_write_out <=mem_write_in;
				mem_to_reg_out <= mem_to_reg_in;
				ALUop_out <= ALUop_in;
				operand_a_sel_out <= operand_a_sel_in;
				operand_b_sel_out <= operand_b_sel_in;
				next_pc_sel_out <= next_pc_sel_in;
				byte_mode_out <= byte_mode_in;
				immediate_out <= immediate_in;
				uj_type_imm_out <= uj_type_imm_in;
				sb_type_imm_out <= sb_type_imm_in;
				operand_a_mux_sel_out <= operand_a_mux_sel_in;
				operand_b_mux_sel_out <= operand_b_mux_sel_in;
				wb_mux_sel_out <= wb_mux_sel_in;
			end if;
		end if;
	end process;
end behav;