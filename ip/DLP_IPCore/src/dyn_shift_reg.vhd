-- Designer: Cristian Sestito
-- Dynamic-length FIFO

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity dyn_shift_reg is
    generic(
    N: integer := 48);
    port(
    CLK: in std_logic;
    CE: in std_logic;
    A: in std_logic_vector(4 downto 0);
    D: in std_logic_vector(N-1 downto 0);
    Q: out std_logic_vector(N-1 downto 0));  
end dyn_shift_reg;

architecture arch_shift_reg of dyn_shift_reg is

signal Q_int: std_logic_vector(N-1 downto 0);

begin

   -- SRLC32E: 32-bit variable length shift register LUT
   --          with clock enable (Mapped to a SliceM LUT6)
   --          Artix-7
   -- Xilinx HDL Language Template, version 2017.4

sr_gen: for i in 0 to N-1 generate
   SRLC32E_inst : SRLC32E
   generic map (
      INIT => X"00000000")
   port map (
      Q => Q(i),        -- SRL data output
      Q31 => open,          -- SRL cascade output pin
      A => A,               -- 5-bit shift depth select input
      CE => CE,             -- Clock enable input
      CLK => CLK,           -- Clock input
      D => D(i)             -- SRL data input
   );

   -- End of SRLC32E_inst instantiation
   
end generate sr_gen;

end arch_shift_reg;
