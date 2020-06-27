-- Designer: Cristian Sestito
-- The Adder Tree (TOP LEVEL)

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

entity adder_tree is
    generic (
    TN: integer := 3);
    port (
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    op: in p_array(TN-1 downto 0);
    res: out std_logic_vector(47 downto 0)); 
end adder_tree;

architecture arch_tree of adder_tree is

component dsp_sum_0 is
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    A: in std_logic_vector(29 downto 0);
    B: in std_logic_vector(17 downto 0);
    C: in std_logic_vector(47 downto 0);
    P: out std_logic_vector(47 downto 0));
end component;

component dsp_sum_int is
    generic (
    D: integer := 8);
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    A: in std_logic_vector(29 downto 0);
    B: in std_logic_vector(17 downto 0);
    C: in std_logic_vector(47 downto 0);
    P: out std_logic_vector(47 downto 0));
end component;

component dsp_sum_k is
    generic (
    D: integer := 8);
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    A: in std_logic_vector(29 downto 0);
    B: in std_logic_vector(17 downto 0);
    C: in std_logic_vector(47 downto 0);
    P: out std_logic_vector(47 downto 0));
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

type int_array is array(natural range <>) of std_logic_vector(47 downto 0);
signal Pint: int_array(TN-3 downto 0);
type A_array is array(natural range <>) of std_logic_vector(29 downto 0);
signal A: A_array(TN-2 downto 0);
type B_array is array(natural range <>) of std_logic_vector(17 downto 0);
signal B: B_array(TN-2 downto 0);
signal C0: std_logic_vector(47 downto 0);

begin

C0 <= op(0);
op_ass: for i in 0 to TN-2 generate
    A(i) <= op(i+1)(47 downto 18);
    B(i) <= op(i+1)(17 downto 0);
end generate op_ass;

c3: if TN = 3 generate
    sum0: dsp_sum_0 port map(clk=>clk,rst=>rst,ce=>ce,A=>A(0),B=>B(0),C=>C0,P=>Pint(0));    
    sumk: dsp_sum_k generic map(D=>0) port map(clk=>clk,rst=>rst,ce=>ce,A=>A(1),B=>B(1),C=>Pint(0),P=>res);
end generate c3;
cgt3: if TN > 3 generate
    sum0: dsp_sum_0 port map(clk=>clk,rst=>rst,ce=>ce,A=>A(0),B=>B(0),C=>C0,P=>Pint(0));    
    dsp_g: for i in 0 to TN-2 generate
        sumint: if (i >= 1 and i < TN-2) generate
            sumintt: dsp_sum_int generic map(D=>i-1) port map(clk=>clk,rst=>rst,ce=>ce,A=>A(i),B=>B(i),C=>Pint(i-1),P=>Pint(i));
        end generate sumint;
        sumk: if i = TN-2 generate
            sumkk: dsp_sum_k generic map(D=>i-1) port map(clk=>clk,rst=>rst,ce=>ce,A=>A(TN-2),B=>B(TN-2),C=>Pint(TN-3),P=>res);
        end generate sumk;
    end generate dsp_g;
end generate cgt3;
    
end arch_tree;
