-- Designer: Cristian Sestito
-- The Deconvolution Layer Processor (TOP LEVEL)

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

entity DECONV_LAYER_TOP is
    port(
    -- signals from AXILITE
    last_ch: in std_logic;
    sr_depth: in std_logic_vector(4 downto 0);
    MDPTH: in std_logic_vector(10 downto 0);
    W: in std_logic_vector(5 downto 0);
    Wext: in std_logic_vector(5 downto 0);
    Pad: in std_logic_vector(6 downto 0);
    ndata: in std_logic_vector(10 downto 0);
    -- input activations interface signals
    s00_axis_aclk: in std_logic;
    s00_axis_aresetn: in std_logic;
    s00_axis_tready: out std_logic;
    s00_axis_tdata: in std_logic_vector(47 downto 0);
    s00_axis_tlast: in std_logic;
    s00_axis_tvalid: in std_logic;
    -- coefficients interface signals
    s01_axis_aclk: in std_logic;
    s01_axis_aresetn: in std_logic;
    s01_axis_tready: out std_logic;
    s01_axis_tdata: in std_logic_vector(63 downto 0);
    s01_axis_tlast: in std_logic;
    s01_axis_tvalid: in std_logic; 
    -- output activations interface signals
    m00_axis_aclk: in std_logic;
    m00_axis_aresetn: in std_logic;
    m00_axis_tvalid: out std_logic;
    m00_axis_tdata: out std_logic_vector(127 downto 0);
    m00_axis_tlast: out std_logic;
    m00_axis_tready: in std_logic;
    m00_axis_tuser: out std_logic); 
end DECONV_LAYER_TOP;

architecture arch_DCTOP of DECONV_LAYER_TOP is

component deconv_top is
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
end component;

component store_coeff is
    generic(
    TM: integer := 2;
    K: integer := 5;
    TN: integer := 3);
    port(
    clk: in std_logic;
    rstn: in std_logic;
    d_valid: in std_logic;
    d_ready: in std_logic;
    d_last: in std_logic;
    k_valid: in std_logic;
    k_last: in std_logic;
    coeff: in std_logic_vector(16*TN-1 downto 0);
    k_ready: out std_logic;
    kernel: out ker_array(TM-1 downto 0));
end component;

component axis_slave_ctrl is
    generic(
    CCsize: integer := 6; 
    CPsize: integer := 7); 
    port(
    clk: in std_logic;
    rst: in std_logic;
    W: in std_logic_vector(CCsize-1 downto 0);
    Wext: in std_logic_vector(CCsize-1 downto 0);
    Pad: in std_logic_vector(CPsize-1 downto 0);
    m_ready: in std_logic;
    s_valid: in std_logic;
    s_last: in std_logic;
    s_ready: out std_logic;
    en_pipe: out std_logic;
    d_sel: out std_logic;
    en_coeff: out std_logic;
    row: out std_logic_vector(CCsize-1 downto 0));
end component;

component axis_master_ctrl is
    generic(
    LAT: integer := 7; 
    CCsize: integer := 6; 
    ABIN: integer := 11); 
    port(
    clk: in std_logic;
    rst: in std_logic;
    Wext: in std_logic_vector(CCsize-1 downto 0);
    ndata: in std_logic_vector(ABIN-1 downto 0);
    row: in std_logic_vector(CCsize-1 downto 0);
    last_ch: in std_logic;
    s_valid: in std_logic;
    s_ready: in std_logic;
    s_last: in std_logic;
    m_ready: in std_logic;
    m_sof: out std_logic;
    m_valid: out std_logic;
    m_last: out std_logic);
end component;

signal filt0: wg_array(2 downto 0);
signal filt1: wg_array(2 downto 0);
signal en_pipe: std_logic;
signal cew: std_logic;
signal rstp: std_logic;
signal d_sel: std_logic;
signal dint: w_array(2 downto 0);
signal qint0: w_array(3 downto 0);
signal qint1: w_array(3 downto 0);

signal sready_int: std_logic;
signal row_int: std_logic_vector(5 downto 0);

begin

sc: store_coeff 
generic map(
TM => 2,
K => 5,
TN => 3) 
port map(
clk => s01_axis_aclk,
rstn => s01_axis_aresetn,
d_valid => s00_axis_tvalid,
d_ready => sready_int,
d_last => s00_axis_tlast,
k_valid => s01_axis_tvalid,
k_last => s01_axis_tlast,
coeff => s01_axis_tdata(47 downto 0),
k_ready => s01_axis_tready,
kernel(0) => filt0,
kernel(1) => filt1);

rstp <= not(s00_axis_aresetn);
dint(0) <= s00_axis_tdata(15 downto 0);
dint(1) <= s00_axis_tdata(31 downto 16);
dint(2) <= s00_axis_tdata(47 downto 32);

dc1: deconv_top 
generic map(
TN => 3,
K => 5,
S => 2,
ABIN => 11,
LAT => 6)
port map(
clk => s00_axis_aclk,
rst => rstp,
cei => en_pipe,
cew => cew,
s_valid => s00_axis_tvalid,
last_ch => last_ch,
MDPTH => MDPTH,
d_sel => d_sel,
sr_depth => sr_depth,
d => dint,
w => filt0,
q => qint0);

dc2: deconv_top 
generic map(
TN => 3,
K => 5,
S => 2,
ABIN => 11,
LAT => 6)
port map(
clk => s00_axis_aclk,
rst => rstp,
cei => en_pipe,
cew => cew,
s_valid => s00_axis_tvalid,
last_ch => last_ch,
MDPTH => MDPTH,
d_sel => d_sel,
sr_depth => sr_depth,
d => dint,
w => filt1,
q => qint1);

axis_s: axis_slave_ctrl
generic map(
CCsize => 6,
CPsize => 7)
port map(
clk => s00_axis_aclk,
rst => s00_axis_aresetn,
W => W,
Wext => Wext,
Pad => Pad,
m_ready => m00_axis_tready,
s_valid => s00_axis_tvalid,
s_last => s00_axis_tlast,
s_ready => sready_int,
en_pipe => en_pipe,
d_sel => d_sel,
en_coeff => cew,
row => row_int);

axis_m: axis_master_ctrl
generic map(
LAT => 6,
CCsize => 6,
ABIN => 11)
port map(
clk => m00_axis_aclk,
rst => m00_axis_aresetn,
Wext => Wext,
ndata => ndata,
row => row_int,
last_ch => last_ch,
s_valid => s00_axis_tvalid,
s_ready => sready_int,
s_last => s00_axis_tlast,
m_ready => m00_axis_tready,
m_sof => m00_axis_tuser,
m_valid => m00_axis_tvalid,
m_last => m00_axis_tlast);

m00_axis_tdata <= qint1(3) & qint1(2) & qint1(1) & qint1(0) & qint0(3) & qint0(2) & qint0(1) & qint0(0);

s00_axis_tready <= sready_int;

end arch_DCTOP;

