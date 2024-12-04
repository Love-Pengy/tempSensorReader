-----------------------------------------------------------------------
--  Inputs:
--		CPU_RESETN	Main Reset Signal (active low)
--		SYS_CLK		100MHz onboard system clock
--		AD2_SDA		PmodAD2 I2C interface In/Out data line
--		AD2_SCL		PmodAD2 I2C interface In/Out clock line
--		SCL_ALT_IN	signal to connect to 2nd PmodAD2 I2C clock line
--		SDA_ALT_IN	signal to connect to 2nd PmodAD2 I2C data line
--
--  Outputs:
--		LED			16-bit output to LEDs
--
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- This is the library we need to include for the PULLUP components
-- it should be automatically known to the Vivado tools
Library UNISIM;
use UNISIM.vcomponents.all;

entity SSD_toplevel is
    Port ( CPU_RESETN  : in		STD_LOGIC;
           SYS_CLK     : in		STD_LOGIC;
           AD2_SCL     : inout	STD_LOGIC;
           AD2_SDA     : inout	STD_LOGIC;
           LED         : out	STD_LOGIC_VECTOR(15 downto 0);
           SCL_ALT_IN  : inout	STD_LOGIC;
           SDA_ALT_IN  : inout	STD_LOGIC;
           LED16_G : out STD_LOGIC;
           LED17_R : out STD_LOGIC;
           CA, CB, CC, CD, CE, CF, CG : OUT STD_LOGIC;  -- Cathode signals for segments
           AN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);           -- Anode signals for digits
           DP : OUT STD_LOGIC                       -- Decimal point
           );
end SSD_toplevel;

architecture Structural of SSD_toplevel is

	signal RESET_sig  : std_logic := '0';
	signal START_sig  : std_logic := '0';
	signal MSG_I_sig, slow_1_clk, slow_2_clk, SRST_sig : std_logic;
	signal STB_I_sig  : std_logic;
	signal DONE_O_sig : std_logic;
	signal ERR_O_sig  : std_logic;
	signal A_I_sig    : STD_LOGIC_VECTOR (7 downto 0);
	signal D_I_sig    : STD_LOGIC_VECTOR (7 downto 0);
	signal D_O_sig    : STD_LOGIC_VECTOR (7 downto 0);

	signal LED_sig, DATA_sig  : STD_LOGIC_VECTOR (15 downto 0);

------------------------------------------------------------------------
-- Implementation
------------------------------------------------------------------------
	begin

	-- The PmodAD2 has dual SDA and SCL lines for daisy chaining TWI bus devices. If 
	-- these other pins are brought low accadentially, then the device will refuse to
	-- transmit data. To prevent this, we drive them as high impedance if they are 
	-- connected. If they are disconnected, they are left floating and the system
	-- should still work.
	SDA_ALT_IN <= 'Z';
	SCL_ALT_IN <= 'Z';

	-- CPU_RESETN input is active low, so we need to invert it
	RESET_sig <= not CPU_RESETN;
    
	-- We want to drive the outputs to the TWI interface like we have pull up resistors attached.
	-- So when controller indicates we're high Z, attach the signal to a weak high signal instead.
	PULLUP_SDA: PULLUP PORT MAP ( O=>AD2_SCL );
	PULLUP_SCL: PULLUP PORT MAP ( O=>AD2_SDA );

	-- here is where we need to instantiate the TWI IP core, the TWI Core Controller
	-- state machine, and a clock divider for the 2 Hz clock, as well as any other
	-- components required
	
	CLK_DIV_1 : ENTITY work.clock_divider_1(behavior)
                 PORT MAP(mclk => SYS_CLK, sclk => slow_1_clk);
				 
	CLK_DIV_2 : ENTITY work.clock_divider_2(behavior)
                 PORT MAP(mclk => SYS_CLK, sclk => slow_2_clk);
                 
	LED17_R <= slow_1_clk;
	LED16_G <= slow_2_clk;
	
	ADT : ENTITY work.ADT_CSM(Behavioral)
		PORT MAP(START => slow_1_clk, 
		        RESET => RESET_sig, 
		        SRST => SRST_sig,
		        DATA_OUT => LED_sig,  
		        CLK => SYS_CLK, 
		        STB_I => STB_I_sig,
				MSG_I => MSG_I_sig,
				A_I => A_I_sig, 
				D_I => D_I_sig, 
				DONE_O => DONE_O_sig, 
				ERR_O => ERR_O_sig, 
				D_O => D_O_sig 
				);
		
	 TWICtl : entity work.TWICtl(Behavioral)
	 generic map (CLOCKFREQ => 50)
		port map(MSG_I  => MSG_I_sig,  -- new message
                 STB_I  => STB_I_sig,  -- strobe
                 A_I    => A_I_sig,    -- address input bus
                 D_I    => D_I_sig,    -- data input bus
                 D_O    => D_O_sig,    -- data output bus
                 DONE_O => DONE_O_sig, -- done status signal
                 ERR_O  => ERR_O_sig,  -- error status
                 CLK    => SYS_CLK,    -- Input Clock
                 SRST   => SRST_sig,  -- Reset
                 SDA    => AD2_SDA,    --TWI SDA
                 SCL    => AD2_SCL);   --TWI SCL
	             LED <= LED_sig;		
	
	TEMPDECODER : entity work.temp_decoder(Behavioral)
		port map(DATA_IN  => LED_sig,
				DATA_OUT => DATA_sig);
                 		
	
	 SEVENSEGMENTDISPLAY :  entity work.SevenSegmentLogic(Behavioral)   
	 PORT MAP (CLK => slow_2_clk, 
	           RST => RESET_sig,
	           DATA => DATA_sig,
	           CA2 => CA,
	           CB2 => CB,
	           CC2 => CC,
	           CD2 => CD,
	           CE2 => CE,
	           CF2 => CF,
	           CG2 => CG,
	           AN2 => AN,
	           DP2 => DP);
	             		
end Structural;
