-- Designer: Cristian Sestito
-- The AXI4-Stream Master Control Unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axis_master_ctrl is
    generic(
    LAT: integer := 7; -- initial latency
    CCsize: integer := 6; -- ceil(log2(W+Wpad))
    ABIN: integer := 11); -- counter depth
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
end axis_master_ctrl;

architecture arch_axismctrl of axis_master_ctrl is

type state_type is (init,wait_stream,reset,start_frame,stream_1,end_line_1,stream_2,end_line_2,stop);
signal curr_state, next_state: state_type := init;

-- Counters signals to control
signal m_en: std_logic;
signal m_rst : std_logic;
signal m_cnt: unsigned(CCsize-1 downto 0); 
signal d_en: std_logic;
signal d_rst : std_logic;
signal d_cnt: unsigned(ABIN-1 downto 0); 

begin

m_counter: process(clk)
begin
    if rising_edge(clk) then
        if m_rst = '1' then
            m_cnt <= (others => '0');
        elsif m_en = '1' then
            m_cnt <= m_cnt+1;
        end if;
    end if;
end process;

d_counter: process(clk)
begin
    if rising_edge(clk) then
        if d_rst = '1' then
            d_cnt <= (others => '0');
        elsif d_en = '1' then
            d_cnt <= d_cnt+1;
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

next_state_logic: process(curr_state,s_valid,s_last,m_ready,m_cnt,last_ch,d_cnt,s_ready,row)
begin
    case curr_state is
        when init =>
            if (last_ch = '1' and row = std_logic_vector(to_unsigned(0,CCsize)) and m_ready = '1' and s_valid = '1' and s_ready = '1') then
                next_state <= wait_stream;
            else
                next_state <= init;
            end if;
        when wait_stream =>
            if s_ready = '1' then
                if m_cnt = to_unsigned((LAT+3)-2,m_cnt'length) then 
                    next_state <= reset;
                else
                    next_state <= wait_stream;
                end if;
            else
                next_state <= wait_stream;
            end if;
        when reset =>
            next_state <= start_frame;
        when start_frame =>
            next_state <= stream_1;
        when stream_1 =>
            if s_last = '1' then
                if m_cnt = unsigned(Wext) then 
                    next_state <= end_line_2;
                else
                    next_state <= stream_2;
                end if;
            else
                if m_cnt = unsigned(Wext) then 
                    next_state <= end_line_1;
                else
                    next_state <= stream_1;
                end if;  
            end if;
        when end_line_1 =>
            if s_last = '1' then
                next_state <= stream_2;
            else
                next_state <= stream_1;
            end if;
        when stream_2 =>
            if m_cnt = unsigned(Wext) then 
                next_state <= end_line_2;
            else
                next_state <= stream_2;
            end if;      
        when end_line_2 =>
            if d_cnt = unsigned(ndata) then
                next_state <= stop;
            else
                next_state <= stream_2;
            end if;
        when stop =>
            if (m_ready = '1' and s_valid = '1') then
                next_state <= start_frame;
            else
                next_state <= stop;
            end if;
    end case;
end process;

output_logic: process(curr_state,m_ready,s_valid)
begin
    case curr_state is
        when init =>
            m_sof <= '0';
            m_valid <= '0';
            m_last <= '0';
            m_en <= '0';
            m_rst <= '1';
            d_en <= '0';
            d_rst <= '1';
        when wait_stream =>
            m_sof <= '0';
            m_valid <= '0';
            m_last <= '0';
            m_en <= (m_ready and s_valid);
            m_rst <= '0';
            d_en <= '0';
            d_rst <= '0';
        when reset =>
            m_sof <= '0';
            m_valid <= '0';
            m_last <= '0';
            m_en <= '1';
            m_rst <= '1';     
            d_en <= '1';
            d_rst <= '1';            
        when start_frame =>
            m_sof <= '1';
            m_valid <= '1';
            m_last <= '0';
            m_en <= (m_ready and s_valid);
            m_rst <= '0';
            d_en <= (m_ready and s_valid);
            d_rst <= '0';
        when stream_1 =>
            m_sof <= '0';
            m_valid <= '1';
            m_last <= '0';
            m_en <= (m_ready and s_valid);
            m_rst <= '0';
            d_en <= (m_ready and s_valid);
            d_rst <= '0';
        when end_line_1 =>
            m_sof <= '0';
            m_valid <= '1';
            m_last <= '1';
            m_en <= '1';
            m_rst <= '1';  
            d_en <= '1';
            d_rst <= '0'; 
        when stream_2 =>
            m_sof <= '0';
            m_valid <= '1';
            m_last <= '0';
            m_en <= m_ready;
            m_rst <= '0';   
            d_en <= m_ready;
            d_rst <= '0';         
        when end_line_2 =>
            m_sof <= '0';
            m_valid <= '1';
            m_last <= '1';
            m_en <= '1';
            m_rst <= '1';         
            d_en <= '1';
            d_rst <= '0';  
        when stop =>
            m_sof <= '0';
            m_valid <= '0';
            m_last <= '0';
            m_en <= '0';
            m_rst <= '1';
            d_en <= '0';
            d_rst <= '1';               
     end case;
end process;

end arch_axismctrl;

