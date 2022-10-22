library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity immgen is
	port (
		inst: in std_logic_vector (31 downto 0);
		s_type_imm: out std_logic_vector (31 downto 0);
		sb_type_imm: out std_logic_vector (31 downto 0);
		u_type_imm: out std_logic_vector (31 downto 0);
		uj_type_imm: out std_logic_vector (31 downto 0);
		i_type_imm: out std_logic_vector (31 downto 0)
	);
end immgen;

architecture behav of immgen is 
begin
	s_type_imm <= std_logic_vector(resize(signed(inst(31 downto 25)&inst(11 downto 7)),32)); 
	sb_type_imm <= std_logic_vector(resize(signed(inst(31)&inst(7)&inst(30 downto 25)&inst(11 downto 8)&'0'),32));
	u_type_imm <= std_logic_vector(inst(31)&inst(30 downto 20)&inst(19 downto 12))&x"000";
	uj_type_imm <= std_logic_vector(resize(signed(inst(31)&inst(19 downto 12)&inst(20)&inst(30 downto 25)&inst(24 downto 21)&'0'),32));
	i_type_imm <= std_logic_vector(resize(signed(inst(31 downto 20)),32));
end behav;

