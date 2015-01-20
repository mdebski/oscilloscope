library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package common is
  subtype DIGIT is unsigned(3 downto 0);
  type DIGIT_ARRAY is array (natural range <>) of DIGIT;
  type STATE_TYPE is (EVERY, ONCE, ONCE_PROBING, ONCE_DONE);
end common;

package body common is
end common;
