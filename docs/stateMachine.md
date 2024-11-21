## CONSTANTS
+ addrAD2 = B"1001011"

## INIT

+ set MSG_I, STB_I, and reset sig to 0 
+ set D_I to "0000_0000"
+ set A_I to addrAD2 & write_bit

## after 10 clocks

  + set reset to 1 

## after 2 more clocks 

+ set reset to 0

## after 1200 more clocks

+ set A_I to addrAD2 & read_bit
+ set MSG_I to 1
+ set STB_I to 1

## after 1 more clock

+ set MSG_I to 0 

## after event on DONE_O and DONE_0 is 0 

## wait another 510 clock cycles

+ set STB_I to 0
+ Set output(15 downto 8) to D_O

## wait until event on DONE_O and DONE_O is 0  
+ set output(7 downto 0) = D_O
