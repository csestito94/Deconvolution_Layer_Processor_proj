-- Designer: Cristian Sestito
-- The N-bit register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_param is
    generic (N : integer := 8);     
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    D: in std_logic_vector(N-1 downto 0);
    Q: out std_logic_vector(N-1 downto 0));
end reg_param;

architecture arch_reg of reg_param is

begin

reg_proc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            Q <= (others => '0');
        elsif ce = '1' then
            Q <= D;
        end if;
    end if;
end process;

end arch_reg;

