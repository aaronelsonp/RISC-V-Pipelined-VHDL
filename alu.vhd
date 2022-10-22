library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port (
		ALUop_in: in std_logic_vector (4 downto 0);
		operand_a: in std_logic_vector (31 downto 0);
		operand_b: in std_logic_vector (31 downto 0);
		result_out: out std_logic_vector (31 downto 0);
		ALU_branch_sig: out std_logic
	);
end alu;

architecture behav of alu is
	signal lt, eq, neq, gt, lt_u, gt_u, gte, gte_u: std_logic_vector (31 downto 0);
begin
	
	process (operand_a, operand_b, ALUop_in, lt, eq, neq, gt, gte, gte_u, lt_u, gt_u) 
	begin
		case ALUop_in is
			when "00000" => result_out <= std_logic_vector(unsigned(operand_a) + unsigned(operand_b));
								 ALU_branch_sig <= '0';
			when "00001" => result_out <= std_logic_vector(shift_left((unsigned(operand_a)), to_integer(unsigned(operand_b(4 downto 0)))));
								 ALU_branch_sig <= '0';
			when "00010" => result_out <= lt;
								 ALU_branch_sig <= '0';
			when "00011" => result_out <= lt_u;
								 ALU_branch_sig <= '0';
			when "00100" => result_out <= operand_a xor operand_b;
								 ALU_branch_sig <= '0';
			when "00101" => result_out <= std_logic_vector(shift_right((unsigned(operand_a)), to_integer(unsigned(operand_b(4 downto 0)))));
							    ALU_branch_sig <= '0';
			when "00110" => result_out <= operand_a or operand_b;
								 ALU_branch_sig <= '0';
			when "00111" => result_out <= operand_a and operand_b;
								 ALU_branch_sig <= '0';
			when "01000" => result_out <= std_logic_vector(unsigned(operand_a) - unsigned(operand_b));
								 ALU_branch_sig <= '0';
			when "01101" => result_out <= std_logic_vector(shift_right((signed(operand_a)), to_integer(unsigned(operand_b(4 downto 0)))));
								 ALU_branch_sig <= '0';
			when "10000" => result_out <= eq;
								 ALU_branch_sig <= eq(0);--
			when "10001" => result_out <= neq; --
								 ALU_branch_sig <= neq(0);
			when "10100" => result_out <= lt; --
								 ALU_branch_sig <= lt(0);
			when "10101" => result_out <= gte; --
								 ALU_branch_sig <= gte(0); 
			when "10110" => result_out <= lt_u; --
								 ALU_branch_sig <= lt_u(0);
			when "10111" => result_out <= gte_u; --
								 ALU_branch_sig <= gte_u(0);
			when "11111" => result_out <= operand_a;
								 ALU_branch_sig <= '0';
			when others => result_out <= (others => '0');
								ALU_branch_sig <= '0';
		end case;
	end process;
	
	gte <= x"00000001" when (signed(operand_a) >= signed (operand_b)) else x"00000000";
	gte_u <= x"00000001" when (unsigned(operand_a) >= unsigned (operand_b)) else x"00000000";
	lt <= x"00000001" when (signed(operand_a) < signed (operand_b)) else x"00000000";
	eq <= x"00000001" when (signed(operand_a) = signed (operand_b)) else x"00000000";
	neq <= x"00000001" when (signed(operand_a) /= signed (operand_b)) else x"00000000";
	gt <= x"00000001" when (signed(operand_a) > signed (operand_b)) else x"00000000";
	lt_u <= x"00000001" when (unsigned(operand_a) < unsigned (operand_b)) else x"00000000";
	gt_u <= x"00000001" when (unsigned(operand_a) > unsigned (operand_b)) else x"00000000";
end behav;
