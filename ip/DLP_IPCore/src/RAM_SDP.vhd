-- Designer: Cristian Sestito
-- Simple Dual Port RAM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM_SDP is
    generic(
    DBIN: integer := 11; -- address word size
    N: integer := 48); -- data word size
    port(
    clk: in std_logic;
    ena: in std_logic;
    enb: in std_logic;
    wea: in std_logic;
    addra: in std_logic_vector(DBIN-1 downto 0);
    addrb: in std_logic_vector(DBIN-1 downto 0);
    dia: in std_logic_vector(N-1 downto 0);
    dob: out std_logic_vector(N-1 downto 0));
end RAM_SDP;

architecture arch_ram of RAM_SDP is

type ram_type is array(2**DBIN-1 downto 0) of std_logic_vector(N-1 downto 0);
signal RAM: ram_type := (others => (others => '0'));

begin

wr_proc: process(clk)
begin
    if rising_edge(clk) then
        if ena = '1' then
            if wea = '1' then
                RAM(to_integer(unsigned(addra))) <= dia;
            end if;
        end if;
    end if;
end process;

rd_proc: process(clk)
begin
    if rising_edge(clk) then
        if enb = '1' then
            dob <= RAM(to_integer(unsigned(addrb)));
        end if;
    end if;
end process;

end arch_ram;

