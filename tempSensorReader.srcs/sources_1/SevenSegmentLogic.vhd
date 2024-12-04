library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  

entity SevenSegmentLogic is
    Port (
        clk      : in  std_logic;
        rst    : in  std_logic;
        SW2       : in  std_logic_vector(15 downto 0);
        CA2, CB2, CC2, CD2, CE2, CF2, CG2 : out std_logic;  -- Cathode signals for segments
        AN2 : out std_logic_vector(7 downto 0);           -- Anode signals for digits
        DP2      : out std_logic                       -- Decimal point
    );
end SevenSegmentLogic;

architecture Behavioral of SevenSegmentLogic is
    signal BCD_digits : std_logic_vector(3 downto 0);
    signal digit_select : integer := 0;

    -- Look-Up Table for BCD to 7-segment decoding
    type BCD_lookup_type is array(0 to 15) of std_logic_vector(6 downto 0);
    constant BCD_lookup : BCD_lookup_type := (
        "0000001", -- 0
        "1001111", -- 1
        "0010010", -- 2
        "0000110", -- 3
        "1001100", -- 4
        "0100100", -- 5
        "0100000", -- 6
        "0001111", -- 7
        "0000000", -- 8
        "0000100", -- 9
        "1111111", -- Blank for values 10-15
        "1111111",
        "1111111",
        "1111111",
        "1111111",
        "1111111"
    );

begin

    -- Main process for display multiplexing and 7-segment encoding
    process(clk, rst)
        variable BCD_digits_temp : std_logic_vector(3 downto 0);
    begin
        if rst = '1' then
            digit_select <= 0;
            AN2 <= (others => '1');
            CA2 <= '1';  CB2 <= '1'; CC2 <= '1'; CD2 <= '1'; CE2 <= '1'; CF2 <= '1'; CG2 <= '1'; DP2 <= '1';
        elsif rising_edge(clk) then
            -- Switch between each digit
            case digit_select is
                when 0 =>
                    BCD_digits <= SW2(3 downto 0);
					BCD_digits_temp := SW2(3 downto 0);
					AN2 <= (0 => '0', others => '1');
					digit_select <= 1;
				when 1 =>
                    BCD_digits <= SW2(7 downto 4);
					BCD_digits_temp := SW2(7 downto 4);
					AN2 <= (1 => '0', others => '1');
                    digit_select <= 2;
                when 2 =>
                    BCD_digits <= SW2(11 downto 8);
					BCD_digits_temp := SW2(11 downto 8);
					AN2 <= (2 => '0', others => '1');
                    digit_select <= 3;
                when others =>
                    BCD_digits <= SW2(15 downto 12);
					BCD_digits_temp := SW2(15 downto 12);
					AN2 <= (3 => '0', others => '1');
                    digit_select <= 0;	
            end case;

            -- Display corresponding 7-segment pattern
            (CA2, CB2, CC2, CD2, CE2, CF2, CG2) <= BCD_lookup(to_integer(unsigned(BCD_digits_temp)));

            -- Control the decimal point
            if digit_select = 2 then
                DP2 <= '0';
            else
                DP2 <= '1';
            end if;
        end if;
    end process;
end Behavioral;
