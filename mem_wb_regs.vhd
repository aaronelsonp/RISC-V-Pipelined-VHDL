library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_wb_regs is
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
end mem_wb_regs;

architecture behav of mem_wb_regs is
begin
	process (clk)
	begin
		if rising_edge(clk) then
			ALU_out <= ALU_in;
			datamem_out <= datamem_in;
			wb_mux_out <= wb_mux_in;
			reg_write_out <= reg_write_in;
			regs_address_out <= regs_address_in;
			wb_mux_sel_out <= wb_mux_sel_in;
			address_out <= address_in;
		end if;
	end process;
end behav;