-- Designer: Cristian Sestito
-- The Row Block (TOP LEVEL)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library xil_defaultlib;
use xil_defaultlib.array_def.all;

entity compute_row is
    generic (
    K: integer := 5;
    S: integer := 2;
    T: integer := 0); 
    port (
    clk: in std_logic;
    rst: in std_logic;
    cei: in std_logic;
    cew: in std_logic;
    I: in std_logic_vector(15 downto 0);
    W: in w_array(K-1 downto 0);
    Q: out p_array(S-1 downto 0));
end compute_row;

architecture arch_row of compute_row is

-- COMPONENTS DECLARATION --

component dsp_PCIN_P is
  port (
  clk: in std_logic;
  rst: in std_logic;
  cea: in std_logic;
  ceb: in std_logic;
  A: in std_logic_vector(24 downto 0);
  B: in std_logic_vector(17 downto 0);
  C: in std_logic_vector(47 downto 0);
  P: out std_logic_vector(47 downto 0));
end component;

component dsp_PCIN_PCOUT is
  port (
  clk: in std_logic;
  rst: in std_logic;
  cea: in std_logic;
  ceb: in std_logic;
  A: in std_logic_vector(24 downto 0);
  B: in std_logic_vector(17 downto 0);
  C: in std_logic_vector(47 downto 0);
  P: out std_logic_vector(47 downto 0));
end component;

component dsp_C0_PCOUT is
  port (
  clk: in std_logic;
  rst: in std_logic;
  cea: in std_logic;
  ceb: in std_logic;
  A: in std_logic_vector(24 downto 0);
  B: in std_logic_vector(17 downto 0);
  C: in std_logic_vector(47 downto 0);
  P: out std_logic_vector(47 downto 0));
end component;

component dsp_C0_P is
  port (
  clk: in std_logic;
  rst: in std_logic;
  cea: in std_logic;
  ceb: in std_logic;
  A: in std_logic_vector(24 downto 0);
  B: in std_logic_vector(17 downto 0);
  C: in std_logic_vector(47 downto 0);
  P: out std_logic_vector(47 downto 0));
end component;

-- SIGNALS DECLARATION --

-- unsigned extension signal for ifmap inputs (from 16 bits to 25 bits)
signal zero_vec: std_logic_vector(8 downto 0) := (others => '0');
signal I_int: std_logic_vector(24 downto 0);

-- signed extension signal for coeff inputs (from 16 bits to 18 bits)
type wext_array is array(natural range <>) of std_logic_vector(1 downto 0); 
signal W_ext: wext_array(K-1 downto 0);
type wint_array is array(natural range <>) of std_logic_vector(17 downto 0);
signal W_int: wint_array(K-1 downto 0); 

-- signals for DSPs' fast internal routing
type int_array is array(natural range <>) of std_logic_vector(47 downto 0);
signal P_reg: int_array((K-S)-1 downto 0); 
signal C_int: int_array(K-1 downto 0); 

begin

-- ifmap input unsigned extension to 25 bits
I_int <= std_logic_vector(unsigned(zero_vec)&unsigned(I));

-- coeff input signed extension to 18 bits
W_ass: for i in 0 to K-1 generate  
    W_ext(i) <= (others => W(i)(15));
    W_int(i) <= std_logic_vector(unsigned(W_ext(i))&unsigned(W(i)));
end generate W_ass;

-- DSPs' internal routing signals assignment
C_ass: for i in 0 to K-1 generate 
    C_ass_1: if i < (K-S) generate 
        C_int(i) <= P_reg(i);
    end generate C_ass_1;
    C_ass_2: if i >= (K-S) generate 
        C_int(i) <= (others => '0');
    end generate C_ass_2;
end generate C_ass;

-- DSPs instantiation
-- Notes for T parameter: T = 0 => dedicated DSPs' fast routing; T = 1 => fabric routing
DSP_g: for i in 0 to K-1 generate
    DSP_g_ovlp: if S < K generate
        DSP_g_1a: if (i < (K-S) and i < S and T = 0) generate 
            DSP1ax: dsp_PCIN_PCOUT port map(clk=>clk,rst=>rst,cea=>cei,ceb=>cew,A=>I_int,B=>W_int(i),C=>C_int(i),P=>Q(i));
        end generate DSP_g_1a;
        DSP_g_1aa: if (i < (K-S) and i < S and T = 1) generate 
            DSP1aax: dsp_PCIN_P port map(clk=>clk,rst=>rst,cea=>cei,ceb=>cew,A=>I_int,B=>W_int(i),C=>C_int(i),P=>Q(i));
        end generate DSP_g_1aa;
        DSP_g_1b: if (i < (K-S) and i >= S) generate
            DSP1bx: dsp_PCIN_PCOUT port map(clk=>clk,rst=>rst,cea=>cei,ceb=>cew,A=>I_int,B=>W_int(i),C=>C_int(i),P=>P_reg(i-S));
        end generate DSP_g_1b;
        DSP_g_1c: if (i >= (K-S) and i < S and T = 0) generate
            DSP1cx: dsp_C0_PCOUT port map(clk=>clk,rst=>rst,cea=>cei,ceb=>cew,A=>I_int,B=>W_int(i),C=>C_int(i),P=>Q(i));
        end generate DSP_g_1c;       
        DSP_g_1cc: if (i >= (K-S) and i < S and T = 1) generate
            DSP1ccx: dsp_C0_P port map(clk=>clk,rst=>rst,cea=>cei,ceb=>cew,A=>I_int,B=>W_int(i),C=>C_int(i),P=>Q(i));
        end generate DSP_g_1cc;
        DSP_g_1d: if (i >= (K-S) and i >= S) generate
            DSP1dx: dsp_C0_PCOUT port map(clk=>clk,rst=>rst,cea=>cei,ceb=>cew,A=>I_int,B=>W_int(i),C=>C_int(i),P=>P_reg(i-S));
        end generate DSP_g_1d;
    end generate DSP_g_ovlp;
    DSP_g_noovlp: if S = K generate
        DSP2x: dsp_C0_P port map(clk=>clk,rst=>rst,cea=>cei,ceb=>cew,A=>I_int,B=>W_int(i),C=>C_int(i),P=>Q(i));
    end generate DSP_g_noovlp;
end generate DSP_g;

end arch_row;

