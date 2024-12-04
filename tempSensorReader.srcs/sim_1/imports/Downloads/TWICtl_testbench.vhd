library ieee;
use ieee.std_logic_1164.all;

entity TWI_testbench is
end TWI_testbench;

architecture behavior of TWI_testbench is

	-- This procedure waits for N number of falling edges on the specified
	-- clock signal
	
	procedure waitclocks(signal clock : std_logic;
                       N : INTEGER) is
		begin
			for i in 1 to N loop
				wait until clock'event and clock='0';	-- wait on falling edge
			end loop;
	end waitclocks;

  signal CLK_sig, RESET_sig, SRST_sig : std_logic := '0';					-- signals to connect to the TWI
  signal SCL_sig, MSG_I_sig, STB_I_sig, DONE_O_sig, ERR_O_sig, SDA_sig, slow_clk : std_logic; 
  signal A_I_sig, D_I_sig,  D_O_sig : STD_LOGIC_VECTOR (7 downto 0);
  signal DATA_OUT_sig    : STD_LOGIC_VECTOR(15 downto 0);	-- 16-bit "result" of 2-byte read from TMP
  
  constant Tperiod : time := 10 ns;         -- 100 MHz clock

  
  begin
  
	-- This process generates the 100 MHz system clock
	
    process(CLK_sig)
      begin
        CLK_sig <= not CLK_sig after Tperiod/2;
    end process;
  
	-- This process simulates the state machine that drives the TWI controller to perform the bus
	-- master operations. These include a configuration register write, followed by a two-byte
	-- data register read. This process drives all of the non-TWI bus inputs to the TWI controller,
	-- (except the 100 MHz system clock) which includes:
	-- MSG_I --new message input to signal multi-byte transfer
    -- STB_I --strobe to start TWI bus cycle
    -- A_I   --address input bus
    -- D_I   --data input bus
	
	  CLK_DIV : ENTITY work.clock_divider(behavior)
                 PORT MAP(mclk => CLK_sig, sclk => slow_clk);

	master_stimulus : ENTITY work.ADT_CSM(Behavioral)
		PORT MAP(START => slow_clk, 
		        RESET => RESET_sig, 
		        SRST => SRST_sig,
		        DATA_OUT => DATA_OUT_sig,  
		        CLK => CLK_sig, 
		        STB_I => STB_I_sig,
				MSG_I => MSG_I_sig,
				A_I => A_I_sig, 
				D_I => D_I_sig, 
				DONE_O => DONE_O_sig, 
				ERR_O => ERR_O_sig, 
				D_O => D_O_sig 
				);

	-- This process the TMP slave device on the TWI bus. It drives the SDA signal to '0' at the appropriate
	-- times to furnish an "ACK" signal to the TWI master device and '0' and 'H' at appropriate times to 
	-- simulate the data being returned from the TMP over the TWI bus.
	
	slave_stimulus : process
      begin
		SDA_sig <= 'H';						-- not driven
		SCL_sig <= 'H';						-- not driven

										-- First address write
		waitclocks(SCL_sig, 9);			-- wait for transmission time
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);			-- wait for ack time
		SDA_sig <= 'H';

		SDA_sig <= 'H';					-- MSB (upper byte)
		waitclocks(SCL_sig, 1);	
		SDA_sig <= 'H'; -- change from 0 to H
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';					-- LSB
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';					-- Release bus

		
		waitclocks(SCL_sig, 1);			
		SDA_sig <= '0';					-- MSB (lower byte)
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';					-- LSB (lower byte)
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';

        
										-- Second address write
		waitclocks(SCL_sig, 10);			-- wait for transmission time
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);			-- wait for ack time
		SDA_sig <= 'H';

		SDA_sig <= 'H';					-- MSB (upper byte)
		waitclocks(SCL_sig, 1);	
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0'; -- change from H to 0
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H'; -- change from 0 to H
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';					-- LSB
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';					-- Release bus

		
		waitclocks(SCL_sig, 1);			
		SDA_sig <= '0';					-- MSB (lower byte)
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';  
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';					-- LSB (lower byte)
		waitclocks(SCL_sig, 1);
        SDA_sig <= 'H';
	
	
									-- Thrid address write
		waitclocks(SCL_sig, 10);			-- wait for transmission time
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);			-- wait for ack time
		SDA_sig <= 'H';

		SDA_sig <= 'H';					-- MSB (upper byte)
		waitclocks(SCL_sig, 1);	
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';					-- LSB
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';					-- Release bus

		
		waitclocks(SCL_sig, 1);			
		SDA_sig <= '0';					-- MSB (lower byte)
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= 'H';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';  -- change from H to 0
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';
		waitclocks(SCL_sig, 1);
		SDA_sig <= '0';					-- LSB (lower byte)
		waitclocks(SCL_sig, 1);
        SDA_sig <= 'H';

        wait; -- stop the process to avoid an infinite loop

	end process slave_stimulus;

 
    -- this is the component instantiation for the
    -- DUT - the device we are testing
    DUT : entity work.TWICtl(Behavioral)
		port map(MSG_I  => MSG_I_sig,  -- new message
                 STB_I  => STB_I_sig,  -- strobe
                 A_I    => A_I_sig,    -- address input bus
                 D_I    => D_I_sig,    -- data input bus
                 D_O    => D_O_sig,    -- data output bus
                 DONE_O => DONE_O_sig, -- done status signal
                 ERR_O  => ERR_O_sig,  -- error status
                 CLK    => clk_sig,    -- Input Clock
                 SRST   => SRST_sig,  -- Reset
                 SDA    => SDA_sig,    --TWI SDA
                 SCL    => SCL_sig);   --TWI SCL
											-- address write (write)
end behavior;