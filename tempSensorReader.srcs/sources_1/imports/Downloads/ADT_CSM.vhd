library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Change the master stiumales process and don't change the slave situilums, Start signal 2Hz
--generic (CLOCKFREQ : natural := 100);                    -- input CLK frequency in MHz
entity ADT_CSM is
    PORT (
      START : in std_logic;  
      RESET : in std_logic; 
      SRST : out std_logic;
      DATA_OUT : out std_logic_vector(15 downto 0); 
      CLK : in std_logic; 
      STB_I : out std_logic;
      MSG_I : out std_logic; 
      A_I : out std_logic_vector(7 downto 0);
      D_I : out std_logic_vector(7 downto 0);
      DONE_O : in std_logic;
      ERR_O : in std_logic;
      D_O : in std_logic_vector(7 downto 0)
   ); 
end ADT_CSM;

architecture Behavioral of ADT_CSM is

	TYPE state_type IS (INIT, RESET_ACTIVATE, RESET_DEACTIVATE, WAIT_BUS_FREE, START_READ_OPERATION, WAIT_READ_DONE_MSB, WAIT_READ_DONE_LSB, LOAD_MSB, LOAD_LSB);
	SIGNAL present_state, next_state : state_type;
	signal counter : integer := 0;
	signal reset_counter : std_logic := '0';
	CONSTANT addrAD2 : std_logic_vector(6 downto 0) := "1001011";
	CONSTANT read_bit : std_logic := '1';
	CONSTANT write_bit : std_logic := '0'; 
	
	begin
	
		clocked : process(CLK, RESET)
			begin
				if RESET = '1' OR START = '0' then
				   counter <= 0;
                   present_state <= INIT;
				elsif rising_edge(CLK) then
					if reset_counter = '1' then
                         counter <= 0;
                    else
                         counter <= counter + 1;
                     end if;
                     present_state <= next_state;
				end if;
	end process clocked;
	
	
	nextstate : PROCESS(present_state,counter)
		BEGIN
		  reset_counter <= '0';
			CASE present_state IS
				WHEN INIT =>
				IF counter >= 10 THEN
					next_state <= RESET_ACTIVATE;
					reset_counter <= '1';
				else
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
				    next_state <= START_READ_OPERATION;
				    IF DONE_O'event AND DONE_O = '0' THEN
					        next_state <= WAIT_READ_DONE_MSB;
					        reset_counter <= '1';
					end if;
				WHEN WAIT_READ_DONE_MSB =>
				    IF counter >= 510  THEN
						next_state <= LOAD_MSB;
						reset_counter <= '1';
				    else
				        next_state <= WAIT_READ_DONE_MSB;
				    end if;
				WHEN LOAD_MSB =>
					next_state <= WAIT_READ_DONE_LSB;
				WHEN WAIT_READ_DONE_LSB =>
				      next_state <= WAIT_READ_DONE_LSB;
                      IF DONE_O'event AND DONE_O = '0' THEN
                        next_state <= LOAD_LSB;
					  end if;			
		        WHEN others => 
			END CASE;
	END PROCESS nextstate;

	output : PROCESS(present_state,counter)
		BEGIN
		    MSG_I <= '0';
            STB_I <= '0';
            SRST <= '0';
            A_I <= addrAD2 & write_bit;
            D_I <= B"0000_0000";
			CASE present_state IS
				WHEN INIT =>
				WHEN RESET_ACTIVATE =>
					SRST <= '1';
				WHEN RESET_DEACTIVATE =>
					SRST <= '0';
				WHEN WAIT_BUS_FREE =>
					A_I <= addrAD2 & read_Bit;
					MSG_I <= '1';
					STB_I <= '1';
				WHEN START_READ_OPERATION =>
					A_I <= addrAD2 & read_Bit;
			        STB_I <= '1';
					MSG_I <= '0';
			    WHEN WAIT_READ_DONE_MSB =>
			        A_I <= addrAD2 & read_Bit;
			        STB_I <= '1';
				WHEN LOAD_MSB =>
				    STB_I <= '0';
					DATA_OUT(15 downto 8) <= D_O;
		        WHEN WAIT_READ_DONE_LSB =>
				WHEN LOAD_LSB =>
					DATA_OUT(7 downto 0) <= D_O;   
			END CASE;
	END PROCESS output;
	
end Behavioral;