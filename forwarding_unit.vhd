library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forwarding_unit is
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
end forwarding_unit;

architecture behav of forwarding_unit is 
	
begin
	--forward_mux_a <= "10" when (regwrite_exmem = '1' and rd_exmem /= "00000" and rd_exmem = rs1_idex) else
	--				 "01" when (regwrite_memwb = '1' and rd_memwb /= "00000" and rd_memwb = rs1_idex) else
	--				 "10" when regwrite_memwb = '1' and rd_memwb /= "00000" and not (regwrite_exmem = '1' and rd_exmem /= "00000" and (rd_exmem = rs1_idex)) and rd_memwb = rs1_idex else
	--				 "00";
					 
	--forward_mux_b <= "10" when (regwrite_exmem = '1' and rd_exmem /= "00000" and rd_exmem = rs2_idex) else
	--				 "01" when (regwrite_memwb = '1' and rd_memwb /= "00000" and rd_memwb = rs2_idex) else
	--				 "10" when regwrite_memwb = '1' and rd_memwb /= "00000" and not (regwrite_exmem = '1' and rd_exmem /= "00000" and (rd_exmem = rs2_idex)) and rd_memwb = rs2_idex else
	--				 "00";
	
	forward_mux_a <= "10" when (regwrite_exmem = '1' and rd_exmem /= "00000" and rd_exmem = rs1_idex) else
					 "01" when regwrite_memwb = '1' and rd_memwb /= "00000" and not (regwrite_exmem = '1' and rd_exmem /= "00000" and (rd_exmem = rs1_idex)) and rd_memwb = rs1_idex else
					 "00";
					 
	forward_mux_b <= "10" when (regwrite_exmem = '1' and rd_exmem /= "00000" and rd_exmem = rs2_idex) else
					 "01" when regwrite_memwb = '1' and rd_memwb /= "00000" and not (regwrite_exmem = '1' and rd_exmem /= "00000" and (rd_exmem = rs2_idex)) and rd_memwb = rs2_idex else
					 "00";
end behav;