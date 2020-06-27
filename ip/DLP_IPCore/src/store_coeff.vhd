-- Designer: Cristian Sestito
-- The Coefficients Buffer (TOP LEVEL)

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

entity store_coeff is
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
end store_coeff;

architecture arch_coefftop of store_coeff is

component reg_file is
    generic(
    L: integer := 25; 
    N: integer := 16);
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    din: in std_logic_vector(N-1 downto 0);
    dout: out wext_array(L-1 downto 0));
end component;

component coeff_ctrl is
    port(
    clk : in std_logic;
    rst : in std_logic;
    d_valid: in std_logic;
    d_ready: in std_logic;
    d_last: in std_logic;
    k_valid : in std_logic;
    k_last : in std_logic;
    k_ready : out std_logic;
    ce: out std_logic);
end component;

signal ce: std_logic;
signal rstp: std_logic;

signal kernel_int: wext_array((K*K*TM)-1 downto 0);

begin

rstp <= not(rstn);

-- register file instantiation
rf: reg_file generic map(L=>K*K*TM,N=>16*TN) port map(clk=>clk,rst=>rstp,ce=>ce,din=>coeff,dout=>kernel_int);

-- kernels' assignment
kassi: for i in 0 to TM-1 generate
    kassj: for j in 0 to TN-1 generate
        kassl: for l in 0 to K*K-1 generate
            kernel(i)(j)(l) <= kernel_int((K*K)*(TM-1-i)+l)(16*(j+1)-1 downto 16*j);
        end generate kassl;
    end generate kassj;
end generate kassi;

fsm: coeff_ctrl port map(clk=>clk,rst=>rstn,d_valid=>d_valid,d_ready=>d_ready,d_last=>d_last,k_valid=>k_valid,k_last=>k_last,k_ready=>k_ready,ce=>ce);

end arch_coefftop;

