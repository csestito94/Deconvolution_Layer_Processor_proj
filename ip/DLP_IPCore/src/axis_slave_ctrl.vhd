-- Designer: Cristian Sestito
-- The AXI4-Stream Slave control unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axis_slave_ctrl is
    generic(
    CCsize: integer := 6; -- ceil(log2(Wext))
    CPsize: integer := 7); -- ceil(log2(Pad))
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
end axis_slave_ctrl;

architecture arch_axissctrl of axis_slave_ctrl is

type state_type is (init,first_data,read_stream,pause,incr_row,wait_stream,stop);
signal curr_state, next_state: state_type := init;

-- col counter signals
signal col_en: std_logic;
signal col_rst : std_logic;
signal col_cnt: unsigned(CCsize-1 downto 0); 

-- row counter signals
signal row_en: std_logic;
signal row_rst : std_logic;
signal row_cnt: unsigned(CCsize-1 downto 0); 

-- pad counter signals
signal pad_en: std_logic;
signal pad_rst: std_logic;
signal pad_cnt: unsigned(CPsize-1 downto 0);

begin

col_counter: process(clk)
begin
    if rising_edge(clk) then
        if col_rst = '1' then
            col_cnt <= (others => '0');
        elsif col_en = '1' then
            col_cnt <= col_cnt+1;
        end if;
    end if;
end process;

row_counter: process(clk)
begin
    if rising_edge(clk) then
        if row_rst = '1' then
            row_cnt <= (others => '0');
        elsif row_en = '1' then
            row_cnt <= row_cnt+1;
        end if;
    end if;
end process;

pad_counter: process(clk)
begin
    if rising_edge(clk) then
        if pad_rst = '1' then
            pad_cnt <= (others => '0');
        elsif pad_en = '1' then
            pad_cnt <= pad_cnt+1;
        end if;
    end if;
end process;

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

next_state_logic: process(curr_state,m_ready,s_valid,s_last,col_cnt,pad_cnt)
begin
    case curr_state is
        when init =>
            if (m_ready = '1' and s_valid = '1') then
                next_state <= first_data;
            else
                next_state <= init;
            end if;
        when first_data =>
            next_state <= read_stream;
        when read_stream =>
            if s_last = '1' then
                next_state <= wait_stream;
            else
                if col_cnt = unsigned(W) then 
                    next_state <= pause;
                else
                    next_state <= read_stream;
                end if;
            end if;     
        when pause =>
            if col_cnt = unsigned(Wext) then
                next_state <= incr_row;
            else
                next_state <= pause;
            end if;
        when incr_row =>
            next_state <= read_stream;
        when wait_stream =>
            if pad_cnt = unsigned(Pad) then 
                if (m_ready = '1' and s_valid = '1') then
                    next_state <= first_data;
                else
                    next_state <= stop;
                end if;
            else
                next_state <= wait_stream;
            end if;
        when stop =>
            if (m_ready = '1' and s_valid = '1') then
                next_state <= first_data;
            else
                next_state <= stop;
            end if;
    end case;
end process;

output_logic: process(curr_state,m_ready,s_valid)
begin
    case curr_state is
        when init =>
            s_ready <= '0';
            en_pipe <= '0';
            d_sel <= '0';
            en_coeff <= '0';
            col_rst <= '1';
            col_en <= '0';
            row_rst <= '1';
            row_en <= '0';
            pad_rst <= '1';
            pad_en <= '0';
        when first_data =>
            s_ready <= (m_ready and s_valid); 
            en_pipe <= (m_ready and s_valid);
            d_sel <= '1';
            en_coeff <= '1';
            col_rst <= '0';
            col_en <= (m_ready and s_valid);
            row_rst <= '0';
            row_en <= '0';    
            pad_rst <= '1';
            pad_en <= '0';
        when read_stream =>
            s_ready <= (m_ready and s_valid); 
            en_pipe <= (m_ready and s_valid);
            d_sel <= '1';
            en_coeff <= '0';
            col_rst <= '0';
            col_en <= (m_ready and s_valid);
            row_rst <= '0';
            row_en <= '0';    
            pad_rst <= '1';
            pad_en <= '0';            
        when pause =>            
            s_ready <= '0';
            en_pipe <= (m_ready and s_valid);
            d_sel <= '0';
            en_coeff <= '0';
            col_rst <= '0';
            col_en <= (m_ready and s_valid);
            row_rst <= '0';
            row_en <= '0';   
            pad_rst <= '1';
            pad_en <= '0'; 
        when incr_row =>
            s_ready <= '0';
            en_pipe <= (m_ready and s_valid);
            d_sel <= '0';
            en_coeff <= '0';
            col_rst <= '1';
            col_en <= (m_ready and s_valid);
            row_rst <= '0';
            row_en <= '1';   
            pad_rst <= '1';
            pad_en <= '0';             
        when wait_stream =>
            s_ready <= '0';
            en_pipe <= m_ready;
            d_sel <= '0';
            en_coeff <= '0';
            col_rst <= '1';
            col_en <= '1';
            row_rst <= '1';
            row_en <= '0';  
            pad_rst <= '0';
            pad_en <= m_ready;  
        when stop =>
            s_ready <= '0';
            en_pipe <= m_ready;
            d_sel <= '0';
            en_coeff <= '0';
            col_rst <= '1';
            col_en <= '0';
            row_rst <= '1';
            row_en <= '0';
            pad_rst <= '1';
            pad_en <= '0';
    end case;
end process;

row <= std_logic_vector(row_cnt);

end arch_axissctrl;

