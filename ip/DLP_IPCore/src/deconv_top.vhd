-- Designer: Cristian Sestito
-- The Deconvolution Engine + The Accumulation Logic (TOP LEVEL)

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

entity deconv_top is
    generic(
    TN: integer := 3;
    K: integer := 5;
    S: integer := 2;
    ABIN: integer := 11;
    LAT: integer := 7);
    port(
    clk: in std_logic;
    rst: in std_logic;
    cei: in std_logic;
    cew: in std_logic;
    s_valid: in std_logic;
    last_ch: in std_logic;
    MDPTH: in std_logic_vector(ABIN-1 downto 0);
    d_sel: in std_logic;
    sr_depth: in std_logic_vector(4 downto 0);
    d: in w_array(TN-1 downto 0); 
    w: in wg_array(2 downto 0);
    q: out w_array(3 downto 0));
end deconv_top;

architecture arch_dctop of deconv_top is

component compute_top is
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
end component;

component adder_tree is
    generic (
    TN: integer := 3);
    port (
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    op: in p_array(TN-1 downto 0);
    res: out std_logic_vector(47 downto 0)); 
end component;

component accum_top is
    generic(
    ABIN: integer := 11; 
    LAT: integer := 7); 
    port(
    clk: in std_logic;
    rst: in std_logic;
    s_valid: in std_logic;
    ce: in std_logic;
    last_ch: in std_logic; 
    MDPTH: in std_logic_vector(ABIN-1 downto 0);
    I: in std_logic_vector(47 downto 0);
    Q: out std_logic_vector(15 downto 0));
end component;

-- mux out signals
signal dint: w_array(TN-1 downto 0);

-- DUs' outputs
type pg_array is array (natural range <>) of p_array(S*S-1 downto 0); 
signal dc_out: pg_array(TN-1 downto 0); 

-- ATs' inputs
type pgg_array is array (natural range <>) of p_array(TN-1 downto 0); 
signal pat: pgg_array(S*S-1 downto 0);

-- ATs' outputs
type tree_array is array (natural range <>) of std_logic_vector(47 downto 0);
signal tree_res: tree_array(S*S-1 downto 0); 

begin

-- input mux 
with d_sel select 
    dint <= (others => (others => '0')) when '0',
            d                           when others;

-- DUs' instantiation
dcs: for i in 0 to TN-1 generate 
    dcx: compute_top generic map(K=>K,S=>S)
    port map(clk=>clk,rst=>rst,cei=>cei,cew=>cew,sr_depth=>sr_depth,I=>dint(i),W=>w(i),Q=>dc_out(i));
end generate dcs;

-- adder trees' inputs assignment
at_assi: for i in 0 to S*S-1 generate
    at_assj: for j in 0 to TN-1 generate
        pat(i)(j) <= dc_out(j)(i);
    end generate at_assj;
end generate at_assi;

-- adder trees' instantiation
ats: for i in 0 to S*S-1 generate
    atsx: adder_tree generic map(TN=>TN) port map(clk=>clk,rst=>rst,ce=>cei,op=>pat(i),res=>tree_res(i));
end generate ats;

-- accumulators' instantiation
accs: for i in 0 to S*S-1 generate 
    accx: accum_top generic map(ABIN=>ABIN,LAT=>LAT)
        port map(clk=>clk,rst=>rst,s_valid=>s_valid,ce=>cei,last_ch=>last_ch,MDPTH=>MDPTH,I=>tree_res(i),Q=>q(i));
end generate accs;

end arch_dctop;

