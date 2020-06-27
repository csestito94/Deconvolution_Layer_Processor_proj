-- Designer: Cristian Sestito
-- The Deconvolution Unit (TOP LEVEL)

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

entity compute_top is
    generic (
    K: integer := 5;
    S: integer := 2);
    port (
    clk: in std_logic;
    rst: in std_logic;
    cei: in std_logic;
    cew: in std_logic;
    sr_depth: in std_logic_vector(4 downto 0); 
    I: in std_logic_vector(15 downto 0);
    W: in w_array((K*K)-1 downto 0);
    Q: out p_array((S*S)-1 downto 0));
end compute_top;

architecture arch_compute of compute_top is

-- COMPONENTS DECLARATION --

component compute_row is
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
end component;

component dyn_shift_reg is
    generic(
    N: integer := 48);
    port(
    CLK: in std_logic;
    CE: in std_logic;
    A: in std_logic_vector(4 downto 0);
    D: in std_logic_vector(N-1 downto 0);
    Q: out std_logic_vector(N-1 downto 0));  
end component;

component reg_param is
    generic (N : integer := 8);     
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    D: in std_logic_vector(N-1 downto 0);
    Q: out std_logic_vector(N-1 downto 0));
end component;

component dsp_add is
  port (
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    A: in std_logic_vector(29 downto 0);
    B: in std_logic_vector(17 downto 0);
    C: in std_logic_vector(47 downto 0);
    P: out std_logic_vector(47 downto 0));
end component;

-- SIGNALS DECLARATION --

-- 2D signals for coefficients 
type wint_array is array(natural range <>) of w_array(K-1 downto 0);
signal W_int: wint_array(K-1 downto 0); 

-- internal signals for provisional results
type int_array is array(natural range <>) of p_array(S-1 downto 0);
signal P_int: int_array(K-1 downto 0);
signal P_reg: int_array(K-1 downto 0);
signal C_int: int_array((K-S)-1 downto 0);
signal S_int: int_array(K-1 downto 0);
signal Q_int: int_array(S-1 downto 0);
signal Q_reg: p_array(S*S-1 downto 0);

begin

-- coefficients arrangement 
W_ass_i: for i in 0 to K-1 generate
    W_ass_j: for j in 0 to K-1 generate
        W_int(i)(j) <= W((i*K)+j);
    end generate W_ass_j;
end generate W_ass_i;

-- row blocks arrangement 
CR_g: for j in 0 to K-1 generate
    CR_ga: if j < (K-S) generate
        CRax: compute_row 
        generic map(K=>K,S=>S,T=>0) port map(clk=>clk,rst=>rst,cei=>cei,cew=>cew,I=>I,W=>W_int(j),Q=>P_int(j));
    end generate CR_ga;
    CR_gb: if j >= (K-S) generate
        CRbx: compute_row generic map(K=>K,S=>S,T=>1) port map(clk=>clk,rst=>rst,cei=>cei,cew=>cew,I=>I,W=>W_int(j),Q=>P_int(j));
    end generate CR_gb;
end generate CR_g;

-- pipeline for row blocks not involved in the row overlapping process
R_g_i: for i in 0 to K-1 generate
    R_g_ii: if i >= (K-S) generate
        R_g_j: for j in 0 to S-1 generate
            Rx: reg_param generic map(N=>48) port map(clk=>clk,rst=>rst,ce=>cei,D=>P_int(i)(j),Q=>P_reg(i)(j));
        end generate R_g_j;
    end generate R_g_ii;
end generate R_g_i;

-- DSPs for row overlapping
DSP_g_i: for i in 0 to (K-S)-1 generate
    DSP_g_j: for j in 0 to S-1 generate   
        DSP1x: dsp_add port map(clk=>clk,rst=>rst,ce=>cei,A=>C_int(i)(j)(47 downto 18),B=>C_int(i)(j)(17 downto 0),C=>P_int(i)(j),P=>S_int(i)(j));
    end generate DSP_g_j;
end generate DSP_g_i;

-- Row FIFOs input assignement
Sint_ass_i: for i in 0 to K-1 generate
    Sint_ass_j: for j in 0 to S-1 generate
        Sint_r: if i >= (K-S) generate
            S_int(i)(j) <= P_reg(i)(j);
        end generate Sint_r;
    end generate Sint_ass_j;
end generate Sint_ass_i;

-- Row FIFOs instantiation
SR_g_i: for i in 0 to (K-S)-1 generate
    SR_g_j: for j in 0 to S-1 generate
        SRx: dyn_shift_reg generic map(N=>48) port map(CLK=>clk,CE=>cei,A=>sr_depth,D=>S_int(i+S)(j),Q=>C_int(i)(j));
    end generate SR_g_j;
end generate SR_g_i;

-- internal outputs assignement
Q_ass_i: for i in 0 to S-1 generate
    Q_ass_j: for j in 0 to S-1 generate
        Q_ass1: if i < (K-S) generate            
            Q_int(i)(j) <= S_int(i)(j);
        end generate Q_ass1;
        Q_ass2: if i >= (K-S) generate
            Q_int(i)(j) <= P_reg(i)(j);
        end generate Q_ass2;
    end generate Q_ass_j;
end generate Q_ass_i;

-- outputs assignement
Q_reg_i: for i in 0 to S-1 generate
    Q_reg_j: for j in 0 to S-1 generate
        Q((i*S)+j) <= Q_int(i)(j);
    end generate Q_reg_j;
end generate Q_reg_i;

end arch_compute;

