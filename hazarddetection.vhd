library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity hazarddetect is
port(
	opcode: in std_logic_vector (6 downto 0);
	memread_IDEX: in std_logic;
	rs1_IFID, rs2_IFID: in std_logic_vector (4 downto 0);
	rd_IDEX: in std_logic_vector (4 downto 0);
	pc_en: out std_logic := '1';
	regs_en_IFID: out std_logic := '1';
	ctrl_mux_en: out std_logic := '1'
);
end hazarddetect;
architecture behav of hazarddetect is
begin
	process(opcode, memread_IDEX, rd_IDEX, rs1_IFID, rs2_IFID) begin
		if (memread_IDEX = '1' and (opcode = "0110111" or opcode = "0100011" or opcode="0000011" or opcode="0010011" or opcode="0010111") and (rs1_IFID = rd_IDEX)) then
			regs_en_IFID <= '0';
			pc_en <= '0';
			ctrl_mux_en <= '0';
		elsif (memread_IDEX = '1' and (rs1_IFID = rd_IDEX or rs2_IFID = rd_IDEX)) then
			regs_en_IFID <= '0';
			pc_en <= '0';
			ctrl_mux_en <= '0';
		else
			regs_en_IFID <= '1';
			pc_en <= '1';
			ctrl_mux_en <= '1';
		end if;
	end process;
end behav;