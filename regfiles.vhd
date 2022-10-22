library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_files is
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
end register_files;

architecture behav of register_files is 
	type regfiles is array (0 to 31) of std_logic_vector (31 downto 0);
	signal register_content: regfiles := (others => x"00000000");
	
	
	signal read_address_1_reg, read_address_2_reg : std_logic_vector (4 downto 0);
	
begin
	process (clk) is
	begin
		if rising_edge(clk) then
			if  (write_en = '1') and (not(write_address="00000")) then
				register_content(to_integer(unsigned(write_address))) <= write_data;
			end if;
			read_address_1_reg <= read_address_1;
			read_address_2_reg <= read_address_2;
		end if;
	end process;
	data_out_1 <=  register_content(to_integer(unsigned(read_address_1_reg)));
	data_out_2 <=  register_content(to_integer(unsigned(read_address_2_reg)));
	probe_out_sig <= register_content(15);
end behav;
