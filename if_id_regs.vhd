library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_id_regs is
	port(
		clk, clr, regs_en_IFID, flush_sig: in std_logic;
		instruction_in, address_in: in std_logic_vector (31 downto 0);
		instruction_out, address_out: out std_logic_vector (31 downto 0)	
	);
end if_id_regs;

architecture behav of if_id_regs is
begin
	process (clk, clr) 
	begin
		if (clr = '1') then
			instruction_out <= (others => '0');
			address_out <= (others => '0');
		elsif rising_edge(clk) then
			if (flush_sig = '1') then
				instruction_out <= (others => '0');
				address_out <= (others => '0');
			else
				if(regs_en_IFID = '1') then
					instruction_out <= instruction_in;
					address_out <= address_in;
				end if;
			end if;
		end if;
	end process;
end behav;