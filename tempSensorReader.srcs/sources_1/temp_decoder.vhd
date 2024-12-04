LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; 

ENTITY temp_decoder IS
    PORT (
		DATA_IN : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        DATA_OUT : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END temp_decoder;

ARCHITECTURE Behavioral OF temp_decoder IS
	SIGNAL BCD_digits : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL digit_select : INTEGER := 0;

    
	BEGIN

	  -- Process to calculate the temperature from ADC code
		temp_calc : PROCESS(DATA_IN)
			VARIABLE ADC_Value : INTEGER; 
			VARIABLE temperature_real : REAL := 0.00;   -- Calculated temperature
			VARIABLE temperature_integer  : INTEGER;       
			VARIABLE temperature_tens  : INTEGER; 
			VARIABLE temperature_ones  : INTEGER; 
			VARIABLE temperature_tenths  : INTEGER; 
			VARIABLE temperature_hundredths  : INTEGER; 
			VARIABLE temperature_fraction  : INTEGER;  
             
			BEGIN
				ADC_Value := ABS(TO_INTEGER(SIGNED(DATA_IN(15 downto 3)))); 
				temperature_integer := ADC_Value/16;
				temperature_tens := temperature_integer/10;
				temperature_ones := temperature_integer - (temperature_tens*10);
				temperature_fraction := ADC_Value -(temperature_integer*16);
				temperature_tenths := (temperature_fraction*100)/160;
				temperature_hundredths := (temperature_fraction*100/16) - temperature_tenths*10; 
                
                
                DATA_OUT <= std_logic_vector(to_signed(temperature_tens,4) & 
                to_signed(temperature_ones,4) & 
                to_signed(temperature_tenths,4) &
                to_signed(temperature_hundredths,4));
                
		END PROCESS temp_calc;
        
END Behavioral;
