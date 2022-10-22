library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_ctrl is
	port (
		ALU_control: in std_logic_vector (2 downto 0);
		funct7: in std_logic;
		funct3: in std_logic_vector (2 downto 0);
		ALUop: out std_logic_vector (4 downto 0)
	);
end alu_ctrl;

architecture behav of alu_ctrl is 
begin
	process (ALU_control, funct7, funct3) 
	begin
		if ALU_control = "011" then
			ALUop <= '1'&x"f";
		elsif ALU_control = "010" then
			ALUop <= "10"&funct3;
		elsif ALU_control = "000" and funct7 = '0' then
			ALUop <= "00"&funct3;
		elsif ALU_control = "000" and funct7 = '1' then
			ALUop <= "01"&funct3;
		elsif ALU_control = "000" then
			ALUop <= "00"&funct3;
		elsif ALU_control = "001" and funct7 = '0' and funct3 = "101" then
			ALUop <= "00"&funct3;
		elsif ALU_control = "001" and funct7 = '1' and funct3 = "101" then
			ALUop <= "01"&funct3;
		elsif ALU_control = "001" and funct3 = "101" then
			ALUop <= "00"&funct3;
		elsif ALU_control = "001" then
			ALUop <= "00"&funct3;
		else
			ALUop <= "00000";
		end if;
	end process;
end behav;