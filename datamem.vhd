library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- byte addressable data memory 

entity data_memory IS
	port (
		clk: in std_logic;
		data: in std_logic_vector (31 downto 0);
		address: in std_logic_vector (12 downto 0);
		write_en: in std_logic;
		byte_mode: in std_logic_vector (2 downto 0);
		q: out std_logic_vector (31 downto 0):= x"00000000"
	);
end data_memory;

architecture behav of data_memory IS
	type mem is array(0 to 2048) of std_logic_vector(7 downto 0);
	signal ram_byte0 : mem:=(
		others => x"00"
	);
	signal ram_byte1 : mem:=(
		others => x"00"
	);
	signal ram_byte2 : mem:=(
		others => x"00"
	);
	signal ram_byte3 : mem:=(
		others => x"00"
	);
	signal addr_byte0, addr_byte1, addr_byte2, addr_byte3, addr, addr_plus_one:integer:=0;
	signal wr_data_byte0, wr_data_byte1, wr_data_byte2, wr_data_byte3: std_logic_vector (7 downto 0);
	signal rd_data_byte0, rd_data_byte1, rd_data_byte2, rd_data_byte3: std_logic_vector (7 downto 0);
	signal starting_byte: std_logic_vector (1 downto 0); 
	signal internal_en_sig: std_logic_vector (3 downto 0);
	
begin
	--Byte mode, 000 word, 001 signed hw, 010 unsign hw, 011 signed byte, 100 unsigned byte
	--Byte mode, 010 word, 001 signed hw, 101 unsign hw, 000 signed byte, 100 unsigned byte
	starting_byte <= address (1 downto 0);
	addr <= to_integer(unsigned(address(12 downto 2))); 
	addr_plus_one <= to_integer(unsigned(address(12 downto 2)))+1;
	
	addr_byte3 <= addr;
	addr_byte2 <= addr_plus_one when (byte_mode = "010" and starting_byte = "11")
						else addr;
	addr_byte1 <= addr_plus_one when (byte_mode = "010" and starting_byte(1) = '1')
						else addr;
	addr_byte0 <= addr_plus_one when ((byte_mode = "010" and (starting_byte(1) = '1' or starting_byte(0)= '1')) or ((byte_mode = "001" or byte_mode = "101") and starting_byte = "11"))
						else addr;
	
	wr_data_byte3 <= data(31 downto 24) when (byte_mode = "010" and starting_byte = "00") else 
						data(23 downto 16) when (byte_mode = "010" and starting_byte = "01") else
						data(15 downto 8) when (byte_mode = "010" and starting_byte = "10") else
						data(7 downto 0) when (byte_mode = "010" and starting_byte = "11") else
						data(15 downto 8) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "10") else
						data(7 downto 0) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "11") else
						data(7 downto 0); -- when ((byte_mode ="000" or byte_mode = "100") and starting_byte = "11");
	
	wr_data_byte2 <= data(23 downto 16) when (byte_mode = "010" and starting_byte = "00") else 
						data(15 downto 8) when (byte_mode = "010" and starting_byte = "01") else
						data(7 downto 0) when (byte_mode = "010" and starting_byte = "10") else
						data(31 downto 24) when (byte_mode = "010" and starting_byte = "11") else
						data(15 downto 8) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "01") else
						data(7 downto 0) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "10") else
						data(7 downto 0); -- when ((byte_mode ="000" or byte_mode = "100") and starting_byte = "10");
	
	wr_data_byte1 <= data(15 downto 8) when (byte_mode = "010" and starting_byte = "00") else 
						data(7 downto 0) when (byte_mode = "010" and starting_byte = "01") else
						data(31 downto 24) when (byte_mode = "010" and starting_byte = "10") else
						data(23 downto 16) when (byte_mode = "010" and starting_byte = "11") else
						data(15 downto 8) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "00") else
						data(7 downto 0) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "01") else
						data(7 downto 0); -- when ((byte_mode ="000" or byte_mode = "100") and starting_byte = "01");
	
	wr_data_byte0 <= data(7 downto 0) when (byte_mode = "010" and starting_byte = "00") else 
						data(31 downto 24) when (byte_mode = "010" and starting_byte = "01") else
						data(23 downto 16) when (byte_mode = "010" and starting_byte = "10") else
						data(15 downto 8) when (byte_mode = "010" and starting_byte = "11") else
						data(7 downto 0) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "00") else
						data(15 downto 8) when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "11") else
						data(7 downto 0); -- when ((byte_mode ="000" or byte_mode = "100") and starting_byte = "00");
	
	internal_en_sig <= "1111" when (byte_mode = "010") else
						"0011" when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "00") else
						"0110" when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "01") else
						"1100" when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "10") else
						"1001" when ((byte_mode = "001" or byte_mode = "101") and starting_byte = "11") else
						"0001" when ((byte_mode = "000" or byte_mode = "100") and starting_byte = "00") else
						"0010" when ((byte_mode = "000" or byte_mode = "100") and starting_byte = "01") else
						"0100" when ((byte_mode = "000" or byte_mode = "100") and starting_byte = "10") else
						"1000"; -- when ((byte_mode = "000" or byte_mode = "100") and starting_byte = "11");
	
	write_read: process (clk)
	begin
		if rising_edge(clk) then
			-- write process
			if write_en = '1' then
				if internal_en_sig(3) = '1' then
					ram_byte3(addr_byte3) <= wr_data_byte3;
				end if;
				if internal_en_sig(2) = '1' then
					ram_byte2(addr_byte2) <= wr_data_byte2;
				end if;
				if internal_en_sig(1) = '1' then
					ram_byte1(addr_byte1) <= wr_data_byte1;
				end if;
				if internal_en_sig(0) = '1' then
					ram_byte0(addr_byte0) <= wr_data_byte0;
				end if;
			end if;
			rd_data_byte3 <= ram_byte3(addr_byte3);
			rd_data_byte2 <= ram_byte2(addr_byte2);
			rd_data_byte1 <= ram_byte1(addr_byte1);
			rd_data_byte0 <= ram_byte0(addr_byte0);
		end if;
	end process;
	
	q <= rd_data_byte3 & rd_data_byte2 & rd_data_byte1 & rd_data_byte0 when (byte_mode = "010" and starting_byte = "00") else -- word
			rd_data_byte0 & rd_data_byte3 & rd_data_byte2 & rd_data_byte1 when (byte_mode = "010" and starting_byte = "01") else
			rd_data_byte1 & rd_data_byte0 & rd_data_byte3 & rd_data_byte2 when (byte_mode = "010" and starting_byte = "10") else
			rd_data_byte2 & rd_data_byte1 & rd_data_byte0 & rd_data_byte3 when (byte_mode = "010" and starting_byte = "11") else
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte1 & rd_data_byte0)),32)) when (byte_mode = "001" and starting_byte = "00") else -- signed halfword
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte2 & rd_data_byte1)),32)) when (byte_mode = "001" and starting_byte = "01") else
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte3 & rd_data_byte2)),32)) when (byte_mode = "001" and starting_byte = "10") else
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte0 & rd_data_byte3)),32)) when (byte_mode = "001" and starting_byte = "11") else
			x"0000" & rd_data_byte1 & rd_data_byte0 when (byte_mode = "101" and starting_byte = "00") else -- unsigned halfword
			x"0000" & rd_data_byte2 & rd_data_byte1 when (byte_mode = "101" and starting_byte = "01") else
			x"0000" & rd_data_byte3 & rd_data_byte2 when (byte_mode = "101" and starting_byte = "10") else
			x"0000" & rd_data_byte0 & rd_data_byte3 when (byte_mode = "101" and starting_byte = "11") else
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte0)),32)) when (byte_mode ="000" and starting_byte = "00") else -- signed byte
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte1)),32)) when (byte_mode ="000" and starting_byte = "01") else
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte2)),32)) when (byte_mode ="000" and starting_byte = "10") else
			std_logic_vector(resize(signed(std_logic_vector'(rd_data_byte3)),32)) when (byte_mode ="000" and starting_byte = "11") else
			x"000000" & rd_data_byte0 when (byte_mode = "100" and starting_byte = "00") else -- unsigned byte
			x"000000" & rd_data_byte1 when (byte_mode = "100" and starting_byte = "01") else
			x"000000" & rd_data_byte2 when (byte_mode = "100" and starting_byte = "10") else
			x"000000" & rd_data_byte3; -- when (byte_mode = "100" and starting_byte = "11") 
end behav;
