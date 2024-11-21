## CONSTANTS
+ addrAD2 = B"1001011"
+ read_bit = '1'
+ write_bit = '0'

## {INIT} (GOTO RESET_ACTIVATE)

+ set MSG_I, STB_I, and SRST sig to 0 
+ set D_I to "0000_0000"
+ set A_I to addrAD2 & write_bit

## {RESET ACTIVATE} after 10 clocks (GOTO RESET_DEACTIVATE)

  + set reset to 1 

## {RESET DEACTIVATE} after 2 more clocks (GOTO WAIT_BUS_FREE)

+ set reset to 0

## {WAIT_BUS_FREE} after 1200 more clocks (GOTO START_READ_OPERATION)

+ set A_I to addrAD2 & read_bit
+ set MSG_I to 1
+ set STB_I to 1

## {START_READ_OPERATION} after 1 more clock (GOTO WAIT_READ_DONE_MSB)

+ set MSG_I to 0 

## {WAIT_READ_DONE_MSB} after event on DONE_O and DONE_0 is 0  (GOTO LOAD_MSB)

## {LOAD_MSB} wait another 510 clock cycles (GOTO LOAD_LSB)

+ set STB_I to 0
+ Set output(15 downto 8) to D_O

## {LOAD_LSB} wait until event on DONE_O and DONE_O is 0 (GOTO INIT)
+ set output(7 downto 0) = D_O
