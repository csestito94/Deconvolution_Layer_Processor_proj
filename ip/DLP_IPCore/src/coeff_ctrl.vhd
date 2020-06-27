-- Designer: Cristian Sestito
-- Control Unit for the Coefficients Buffer

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity coeff_ctrl is
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
end coeff_ctrl;

architecture arch_fsm of coeff_ctrl is

type state_type is (init,first_packet,wait_fmap,read_packet,pause_1,pause_2);
signal curr_state, next_state : state_type;
    
begin

state_reg_proc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '0' then
            curr_state <= init;
         else
            curr_state <= next_state;
        end if;
    end if;
end process;

next_state_logic: process(curr_state,k_valid,k_last,d_valid,d_ready,d_last) 
begin
    case curr_state is
        when init =>
            if k_valid = '1' then
                next_state <= first_packet;
            else
                next_state <= init;
            end if;    
        when first_packet =>
            if k_last = '1' then
                if d_valid = '1' then
                    next_state <= read_packet;
                else
                    next_state <= wait_fmap;
                end if;
            else
                next_state <= first_packet;
            end if;
        when wait_fmap =>
            if d_valid = '1' then
                next_state <= read_packet;
            else
                next_state <= wait_fmap;
            end if;
        when read_packet =>
            if k_last = '1' then
                next_state <= pause_1;
            else
                next_state <= read_packet;
            end if;
        when pause_1 =>
            if d_last = '1' then
                next_state <= pause_2;
            else
                next_state <= pause_1;
            end if;
        when pause_2 =>
            if (d_valid = '1' and d_ready = '1') then
                next_state <= read_packet;
            else
                next_state <= pause_2;
            end if;
    end case;
end process;

output_logic: process(curr_state,k_valid)
begin
    case curr_state is
        when init =>
            k_ready <= '0';
            ce <= '0';
        when first_packet =>
            k_ready <= k_valid;
            ce <= k_valid;
        when wait_fmap => 
            k_ready <= '0';
            ce <= '0';
        when read_packet =>
            k_ready <= k_valid;
            ce <= k_valid;
        when pause_1 =>
            k_ready <= '0';
            ce <= '0';
        when pause_2 =>
            k_ready <= '0';
            ce <= '0';                                                       
    end case;
end process;

end arch_fsm;

