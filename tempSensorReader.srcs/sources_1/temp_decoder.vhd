LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL; 

ENTITY temp_decoder IS
    PORT (
		DATA_IN : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		SW2 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        DATA_OUT : OUT  STD_LOGIC_VECTOR(19 DOWNTO 0)
        );
END temp_decoder;

ARCHITECTURE Behavioral OF temp_decoder IS

	BEGIN

	  -- Process to calculate the temperature from ADC code
		temp_calc : PROCESS(DATA_IN,SW2)
			VARIABLE ADC_Value : INTEGER; 
			VARIABLE temperature_integer  : INTEGER; 
			VARIABLE temperature_hundreds  : INTEGER;       
			VARIABLE temperature_tens  : INTEGER; 
			VARIABLE temperature_ones  : INTEGER; 
			VARIABLE temperature_tenths  : INTEGER; 
			VARIABLE temperature_hundredths  : INTEGER; 
			VARIABLE temperature_fraction  : INTEGER; 
             
			BEGIN 
			    ADC_Value := ABS(TO_INTEGER(SIGNED(DATA_IN(15 downto 3))));
			    
				IF SW2 = X"0001" THEN -- Fahrenheit 
					temperature_integer := INTEGER((ADC_Value/16)* 2 + 32);
					temperature_fraction := ADC_Value - INTEGER(((temperature_integer - 32) / 2) * 16);
					temperature_fraction := INTEGER((temperature_fraction) * 2); 
			    ELSIF SW2 = X"0002" THEN -- Kelvin
			         temperature_integer := INTEGER((ADC_Value/16) + 273);
			         temperature_fraction := ADC_Value - INTEGER(((temperature_integer - 273)) * 16);
			         temperature_fraction := INTEGER((temperature_fraction));
			    ELSIF SW2 = X"0003" THEN -- Rankine 
					temperature_integer := INTEGER((ADC_Value/16)* 2 + 492);
					temperature_fraction := ADC_Value - INTEGER(((temperature_integer - 492) / 2) * 16);
					temperature_fraction := INTEGER((temperature_fraction) * 2); 
				ELSE -- Celsius 
					temperature_integer := INTEGER((ADC_Value/16));
					temperature_fraction := ADC_Value - (temperature_integer*16); 
				END IF;
				
				temperature_hundreds := temperature_integer/100;
				temperature_tens := temperature_integer/10 - (INTEGER(temperature_integer/100) * 10);
				temperature_ones := temperature_integer - (INTEGER(temperature_integer/10) * 10);
                temperature_tenths := (temperature_fraction*10/16) - (INTEGER((temperature_fraction*10/16)/10) * 10);
				temperature_hundredths := (temperature_fraction*100/16) - (INTEGER((temperature_fraction*100/16)/10) * 10);
                
                DATA_OUT <= std_logic_vector(to_signed(temperature_hundreds,4) &
                to_signed(temperature_tens,4) & 
                to_signed(temperature_ones,4) & 
                to_signed(temperature_tenths,4) &
                to_signed(temperature_hundredths,4));
                
		END PROCESS temp_calc; 
END Behavioral;
