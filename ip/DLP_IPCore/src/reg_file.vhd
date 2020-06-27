-- Designer: Cristian Sestito
-- The Register File 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.array_def.all;

entity reg_file is
    generic(
    L: integer := 25; -- registers
    N: integer := 16); -- word size
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    din: in std_logic_vector(N-1 downto 0);
    dout: out wext_array(L-1 downto 0));
end reg_file;

architecture arch_regfile of reg_file is

component reg_param is
    generic (N : integer := 8);     
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    D: in std_logic_vector(N-1 downto 0);
    Q: out std_logic_vector(N-1 downto 0));
end component;

signal dint: wext_array(L downto 0);

begin

dint(0) <= din;

rf: for i in 0 to L-1 generate
    rfg: reg_param generic map(N=>N) port map(clk=>clk,rst=>rst,ce=>ce,D=>dint(i),Q=>dint(i+1));
end generate rf;

dout <= dint(L downto 1);

end arch_regfile;

