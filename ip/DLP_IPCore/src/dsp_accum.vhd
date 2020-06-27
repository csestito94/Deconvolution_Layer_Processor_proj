-- Designer: Cristian Sestito
-- DSP for accumulations

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity dsp_accum is
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    A: in std_logic_vector(29 downto 0);
    B: in std_logic_vector(17 downto 0);
    C: in std_logic_vector(47 downto 0);
    P: out std_logic_vector(47 downto 0));
end dsp_accum;

architecture arch_accum of dsp_accum is

begin

DSP48E1_inst: DSP48E1
       generic map (
             -- Feature Control Attributes: Data Path Selection
             A_INPUT =>  "DIRECT",               -- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
             B_INPUT => "DIRECT",               -- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
             USE_DPORT => FALSE,                -- Select D port usage (TRUE or FALSE)
             USE_MULT => "NONE",            -- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
             USE_SIMD => "ONE48",               -- SIMD selection ("ONE48", "TWO24", "FOUR12")
             -- Pattern Detector Attributes: Pattern Detection Configuration
             AUTORESET_PATDET => "NO_RESET",    -- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
             MASK => X"3fffffffffff",           -- 48-bit mask value for pattern detect (1=ignore)
             PATTERN => X"000000000000",        -- 48-bit pattern match for pattern detect
             SEL_MASK => "MASK",                -- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
             SEL_PATTERN => "PATTERN",          -- Select pattern value ("PATTERN" or "C")
             USE_PATTERN_DETECT => "NO_PATDET", -- Enable pattern detect ("PATDET" or "NO_PATDET")
             -- Register Control Attributes: Pipeline Register Configuration
             ACASCREG => 1,                  -- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
             ADREG => 0,                        -- Number of pipeline stages for pre-adder (0 or 1)
             ALUMODEREG => 1,                   -- Number of pipeline stages for ALUMODE (0 or 1)
             AREG => 1,                      -- Number of pipeline stages for A (0, 1 or 2)
             BCASCREG => 1,                   -- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
             BREG => 1,                         -- Number of pipeline stages for B (0, 1 or 2)
             CARRYINREG => 0,                   -- Number of pipeline stages for CARRYIN (0 or 1)
             CARRYINSELREG => 0,                -- Number of pipeline stages for CARRYINSEL (0 or 1)
             CREG => 1,                         -- Number of pipeline stages for C (0 or 1)
             DREG => 0,                         -- Number of pipeline stages for D (0 or 1)
             INMODEREG => 0,                    -- Number of pipeline stages for INMODE (0 or 1)
             MREG => 0,                         -- Number of multiplier pipeline stages (0 or 1)
             OPMODEREG => 0,                    -- Number of pipeline stages for OPMODE (0 or 1)
             PREG => 1                      -- Number of pipeline stages for P (0 or 1)
          )
          port map (
             -- Cascade: 30-bit (each) output: Cascade Ports
             ACOUT => open,                   -- 30-bit output: A port cascade output
             BCOUT => open,                   -- 18-bit output: B port cascade output
             CARRYCASCOUT => open,     -- 1-bit output: Cascade carry output
             MULTSIGNOUT => open,       -- 1-bit output: Multiplier sign cascade output
             PCOUT => open,                   -- 48-bit output: Cascade output
             -- Control: 1-bit (each) output: Control Inputs/Status Bits
             OVERFLOW => open,             -- 1-bit output: Overflow in add/acc output
             PATTERNBDETECT => open, -- 1-bit output: Pattern bar detect output
             PATTERNDETECT => open,   -- 1-bit output: Pattern detect output
             UNDERFLOW => open,           -- 1-bit output: Underflow in add/acc output
             -- Data: 4-bit (each) output: Data Ports
             CARRYOUT => open,             -- 4-bit output: Carry output
             P => P,                           -- 48-bit output: Primary data output
             -- Cascade: 30-bit (each) input: Cascade Ports
             ACIN =>(others => '0'),                     -- 30-bit input: A cascade data input
             BCIN => (others => '0'),                     -- 18-bit input: B cascade input
             CARRYCASCIN => '0',       -- 1-bit input: Cascade carry input
             MULTSIGNIN => '0',         -- 1-bit input: Multiplier sign input
             PCIN => (others => '0'),                     -- 48-bit input: P cascade input
             -- Control: 4-bit (each) input: Control Inputs/Status Bits
             ALUMODE => "0000",               -- 4-bit input: ALU control input
             CARRYINSEL => "000",         -- 3-bit input: Carry select input
             CLK => clk,                       -- 1-bit input: Clock input
             INMODE => "10001",                -- 5-bit input: INMODE control input 
             OPMODE => "0110011",                 -- 7-bit input: Operation mode input
             -- Data: 30-bit (each) input: Data Ports
             A => A,                           -- 30-bit input: A data input
             B => B,                           -- 18-bit input: B data input
             C => C,                           -- 48-bit input: C data input
             CARRYIN => '0',               -- 1-bit input: Carry input signal
             D => (others => '0'),                           -- 25-bit input: D data input
             -- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
             CEA1 => ce,                     -- 1-bit input: Clock enable input for 1st stage AREG
             CEA2 => ce,                     -- 1-bit input: Clock enable input for 2nd stage AREG
             CEAD => ce,                     -- 1-bit input: Clock enable input for ADREG
             CEALUMODE => '1',           -- 1-bit input: Clock enable input for ALUMODE
             CEB1 => ce,                     -- 1-bit input: Clock enable input for 1st stage BREG
             CEB2 => ce,                     -- 1-bit input: Clock enable input for 2nd stage BREG
             CEC => ce,                       -- 1-bit input: Clock enable input for CREG
             CECARRYIN => '1',           -- 1-bit input: Clock enable input for CARRYINREG
             CECTRL => '1',                 -- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
             CED => ce,                       -- 1-bit input: Clock enable input for DREG
             CEINMODE => '1',             -- 1-bit input: Clock enable input for INMODEREG
             CEM => ce,                       -- 1-bit input: Clock enable input for MREG
             CEP => ce,                       -- 1-bit input: Clock enable input for PREG
             RSTA => rst,                     -- 1-bit input: Reset input for AREG
             RSTALLCARRYIN => rst,   -- 1-bit input: Reset input for CARRYINREG
             RSTALUMODE => rst,         -- 1-bit input: Reset input for ALUMODEREG
             RSTB => rst,                     -- 1-bit input: Reset input for BREG
             RSTC => rst,                     -- 1-bit input: Reset input for CREG
             RSTCTRL => rst,               -- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
             RSTD => rst,                     -- 1-bit input: Reset input for DREG and ADREG
             RSTINMODE => rst,           -- 1-bit input: Reset input for INMODEREG
             RSTM => rst,                     -- 1-bit input: Reset input for MREG
             RSTP => rst                   -- 1-bit input: Reset input for PREG
          );


end arch_accum;

