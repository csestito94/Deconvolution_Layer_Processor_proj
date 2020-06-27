----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.04.2020 10:09:22
-- Design Name: 
-- Module Name: array_def - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package array_def is 

    constant K : integer := 5;
    constant TN : integer := 3;
    constant TM : integer := 2;
    
    type wext_array is array (natural range <>) of std_logic_vector (16*TN-1 downto 0);
    type w_array is array (natural range <>) of std_logic_vector (15 downto 0);
    type wg_array is array (natural range <>) of w_array(K*K-1 downto 0);
    type ker_array is array (natural range <>) of wg_array(TN-1 downto 0);
    type p_array is array (natural range <>) of std_logic_vector (47 downto 0);
    type q_array is array (natural range <>) of std_logic_vector (35 downto 0);

end array_def;

package body array_def is
end array_def;

