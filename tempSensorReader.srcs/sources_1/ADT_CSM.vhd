LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-- Change the master stiumales process and don't change the slave situilums, Start signal 2Hz
--generic (CLOCKFREQ : natural := 100);                    -- input CLK frequency in MHz
ENTITY ADT_CSM IS
    PORT (
      START : IN std_logic;  
      RESET : IN std_logic; 
      SRST : OUT std_logic;
      DATA_OUT : OUT std_logic_vector(15 DOWNTO 0); 
      CLK : IN std_logic; 
      STB_I : OUT std_logic;
      MSG_I : OUT std_logic; 
      A_I : OUT std_logic_vector(7 DOWNTO 0);
      D_I : OUT std_logic_vector(7 DOWNTO 0);
      DONE_O : IN std_logic;
      ERR_O : IN std_logic;
      D_O : IN std_logic_vector(7 DOWNTO 0)
   ); 
END ADT_CSM;

ARCHITECTURE Behavioral OF ADT_CSM IS

	TYPE state_type IS (INIT, RESET_ACTIVATE, RESET_DEACTIVATE, WAIT_BUS_FREE, START_READ_OPERATION, WAIT_READ_DONE_MSB, WAIT_READ_DONE_LSB, LOAD_MSB, LOAD_LSB);
	SIGNAL present_state, next_state : state_type;
	signal counter : integer := 0;
	signal reset_counter : std_logic := '0';
	CONSTANT addrAD2 : std_logic_vector(6 DOWNTO 0) := "1001011";
	CONSTANT read_bit : std_logic := '1';
	
	BEGIN
	
		A_I <= addrAD2 & read_Bit;
        D_I <= (OTHERS => '0');
		
		clocked : PROCESS(CLK, RESET, START, reset_counter)
			BEGIN
				IF RESET = '1' OR START = '0' THEN
					counter <= 0;
					present_state <= INIT;
				ELSIF rising_edge(CLK) THEN
					IF reset_counter = '1' THEN
						counter <= 0;
					ELSE
                        counter <= counter + 1;
                    END IF;
                    present_state <= next_state;
				END IF;
		END PROCESS clocked;
	
	nextstate : PROCESS(present_state, counter, ERR_O, DONE_O)
		BEGIN
			reset_counter <= '0';
			CASE present_state IS
				WHEN INIT =>
					IF counter >= 10 THEN
						next_state <= RESET_ACTIVATE;
						reset_counter <= '1';
					ELSE
						next_state <= INIT;
					END IF;	
				WHEN RESET_ACTIVATE =>
					IF counter >= 2 THEN
						next_state <= RESET_DEACTIVATE;
						reset_counter <= '1';
					ELSE
						next_state <= RESET_ACTIVATE;
					END IF;
				WHEN RESET_DEACTIVATE =>
					IF counter >= 1200  THEN 
						next_state <= WAIT_BUS_FREE;
						reset_counter <= '1';
					ELSE
						next_state <= RESET_DEACTIVATE;
					END IF;	
				WHEN WAIT_BUS_FREE =>
					IF counter >= 1  THEN 
						next_state <= START_READ_OPERATION;
						reset_counter <= '1';
					ELSE
						next_state <= WAIT_BUS_FREE;
					END IF;		
				WHEN START_READ_OPERATION =>
					IF ERR_O = '1' THEN
						next_state <= WAIT_BUS_FREE;		
				    ELSIF DONE_O = '1' THEN
						next_state <= WAIT_READ_DONE_MSB;
						reset_counter <= '1';
					ELSE
					   next_state <= START_READ_OPERATION;
					END IF;	
				WHEN WAIT_READ_DONE_MSB =>
				    IF counter >= 510  THEN
						next_state <= LOAD_MSB;
						reset_counter <= '1';
				    ELSE
				        next_state <= WAIT_READ_DONE_MSB;
				    END IF;
				WHEN LOAD_MSB =>
					next_state <= WAIT_READ_DONE_LSB;
				WHEN WAIT_READ_DONE_LSB =>
					IF ERR_O = '1' THEN
						next_state <= WAIT_BUS_FREE;
					ELSIF DONE_O = '1' THEN
						next_state <= LOAD_LSB;
					ELSE
						next_state <= WAIT_READ_DONE_LSB;
					END IF;						
		        WHEN OTHERS => 
			END CASE;
	END PROCESS nextstate;

	output : PROCESS(present_state, D_O)
		BEGIN
		-- Default Hard Code Values 
			MSG_I <= '0';
            STB_I <= '0';
            SRST <= '0';
			CASE present_state IS
				WHEN RESET_ACTIVATE =>
					SRST <= '1';
				WHEN RESET_DEACTIVATE =>
					SRST <= '0';
				WHEN WAIT_BUS_FREE =>
					MSG_I <= '1';
					STB_I <= '1';
				WHEN START_READ_OPERATION =>
					MSG_I <= '0';
			        STB_I <= '1';
			    WHEN WAIT_READ_DONE_MSB =>
			        STB_I <= '1';
				WHEN LOAD_MSB =>
				    STB_I <= '0';
					DATA_OUT(15 DOWNTO 8) <= D_O;
				WHEN LOAD_LSB =>
					DATA_OUT(7 DOWNTO 0) <= D_O;   
				WHEN OTHERS =>
			END CASE;
	END PROCESS output;
END Behavioral;