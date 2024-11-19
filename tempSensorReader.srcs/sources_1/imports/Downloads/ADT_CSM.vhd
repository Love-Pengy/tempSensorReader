library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Change the master stiumales process and don't change the slave situilums, Start signal 2Hz
--generic (CLOCKFREQ : natural := 100);                    -- input CLK frequency in MHz
entity ADT_CSM is
    Port ( MSG_I  : in STD_LOGIC;                           -- signals message
           STB_I  : in STD_LOGIC;                           --active high which starts an operation
           A_I    : in  STD_LOGIC_VECTOR (7 downto 0);      --address input bus
           D_I    : in  STD_LOGIC_VECTOR (7 downto 0);      --data input bus
           D_O    : inout  STD_LOGIC_VECTOR (7 downto 0);     --data output bus
           DONE_O : out  STD_LOGIC;                         --done status signal
           ERR_O  : out  STD_LOGIC;                         --error status
           CLK    : in std_logic;                           --main clock input
           SRST   : in std_logic;                           --active high reset signal
           SDA    : inout std_logic;                        --TWI SDA
           SCL    : inout std_logic                         --TWI SCL 
		   );
end ADT_CSM;

architecture Behavioral of ADT_CSM is

	TYPE state_type IS (INIT, RESET_ACTIVATE, RESET_DEACTIVATE, WAIT_BUS_FREE, START_READ_OPERATION, WAIT_READ_DONE_MSB, LOAD_MSB, WAIT_READ_DONE_LSB, LOAD_LSB, FINISHED);
	SIGNAL present_state, next_state : state_type;
	signal counter : integer := 0;
	
	begin
		clocked : process(clk, SRST)
			begin
				if SRST = '1' then
					present_state <= INIT;
					counter <= 0;
				elsif rising_edge(clk) then
					present_state <= next_state;
					if present_state = next_state then
						counter <= counter + 1;
					end if;
				end if;
	end process clocked;
	
	
	nextstate : PROCESS(present_state,counter)
		BEGIN
			CASE present_state IS
				WHEN INIT =>
					next_state <= RESET_ACTIVATE;
				WHEN RESET_ACTIVATE =>
					IF counter >= 10 THEN
						next_state <= RESET_DEACTIVATE;
					ELSE
						next_state <= RESET_ACTIVATE;
					END IF;
				WHEN RESET_DEACTIVATE =>
					IF counter >= 2 THEN
						next_state <= WAIT_BUS_FREE;
					ELSE
						next_state <= RESET_DEACTIVATE;
					END IF;
				WHEN WAIT_BUS_FREE =>
					IF counter >= 1200  THEN
						next_state <= START_READ_OPERATION;
					ELSE
						next_state <= WAIT_BUS_FREE;
					END IF;
				WHEN START_READ_OPERATION =>
					IF counter >= 1  THEN
						next_state <= WAIT_READ_DONE_MSB;
					ELSE
						next_state <= START_READ_OPERATION;
					END IF;	
				WHEN WAIT_READ_DONE_MSB =>
					IF DONE_O <= '0'  THEN
						next_state <= LOAD_MSB;
					ELSE
						next_state <= WAIT_READ_DONE_MSB;
					END IF;	
				WHEN LOAD_MSB =>
					IF counter >= 510 THEN
						next_state <= WAIT_READ_DONE_LSB;
					ELSE
						next_state <= LOAD_MSB;
					END IF;	
				WHEN WAIT_READ_DONE_LSB  =>
					IF DONE_O = '0' THEN
						next_state <= LOAD_LSB;
					ELSE
						next_state <= WAIT_READ_DONE_LSB;
					END IF;	
				WHEN LOAD_LSB =>
					next_state <= FINISHED;
				WHEN FINISHED =>
					next_state <= FINISHED;
			END CASE;
	END PROCESS nextstate;

	
	output : PROCESS(present_state,counter)
		BEGIN
			-- Default signal values
			MSG_I <= '0';
			STB_I <= '0';
			SRST <= '0';  -- Ensure RESET signal aligns with testbench name
			A_I <= (others => '0');
			D_I <= (others => '0');
			LED <= (others => '0');
		
			CASE present_state IS
				WHEN INIT =>
					A_I <= addrAD2 & write_Bit;
					D_I <= "00000000";
				WHEN RESET_ACTIVATE =>
					SRST <= '1';
				WHEN RESET_DEACTIVATE =>
					SRST <= '0';
				WHEN WAIT_BUS_FREE =>
					A_I <= addrAD2 & read_Bit;
				WHEN START_READ_OPERATION =>
					MSG_I <= '1';
					STB_I <= '1';
				WHEN WAIT_READ_DONE_MSB =>
					STB_I <= '1';
				WHEN LOAD_MSB =>
					LED(15 downto 8) <= D_O_sig;

				WHEN WAIT_READ_DONE_LSB =>
					STB_I <= '0';
				WHEN LOAD_LSB =>
					LED(7 downto 0) <= D_O_sig;
			END CASE;
	END PROCESS output;
	
end Behavioral;