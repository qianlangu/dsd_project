library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity sobel is
    port (
        clk          : in std_logic;
        rst_n        : in std_logic;
--        data_en      : in std_logic;  --当写入一个数据
        RGB_12bit    : in std_logic_vector(11 downto 0);  --原始数据位12比特的rgb，但我们之取其中的4bit，G
        hCount : in unsigned( 9 downto 0);
        vCount : in unsigned( 9 downto 0);
--        threshold    : in std_logic_vector(3 downto 0);  -- 灰度门限
--        o_VGA_HS     : in std_logic; -- 行同步信号
--        o_VGA_VS     : in std_logic; -- 场同步信号
--        img_edge_en  : out std_logic;
--        img_edge_4bit: out std_logic_vector(3 downto 0);
--        VGA_HS       : out std_logic;
--        VGA_VS       : out std_logic;
        VGA_RGB      : out std_logic_vector(11 downto 0)
    );
end entity sobel;

architecture rtl of sobel is
component c_shift_ram_0 is
  PORT (
    D : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    CLK : IN STD_LOGIC;
    Q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    CE: in std_logic
  );
end component;

--component c_shift_ram_1 is
--  PORT (
--    D : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    CLK : IN STD_LOGIC;
--    Q : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
--  );
--end component;
    signal threshold       : std_logic_vector (5 downto 0):="001010";
    signal data_in_reg     : std_logic_vector( 3 downto 0);
--    signal cnt_row         : unsigned(9 downto 0);
--    signal cnt_col         : unsigned(9 downto 0);
    signal img_edge_4bit : std_logic_vector(3 downto 0);
    signal shift_res_line1 : std_logic_vector(3 downto 0);
    signal shift_res_line2 : std_logic_vector(3 downto 0);
    signal shift_res_line3 : std_logic_vector(3 downto 0);
    signal shift_res_line1_x1 : std_logic_vector(5 downto 0);
    signal shift_res_line1_x2 : std_logic_vector(5 downto 0);
    signal shift_res_line1_x3 : std_logic_vector(5 downto 0);
    signal shift_res_line2_x4 : std_logic_vector(5 downto 0);
    signal shift_res_line2_x5 : std_logic_vector(5 downto 0);
    signal shift_res_line2_x6 : std_logic_vector(5 downto 0);
    signal shift_res_line3_x7 : std_logic_vector(5 downto 0);
    signal shift_res_line3_x8 : std_logic_vector(5 downto 0);
    signal shift_res_line3_x9 : std_logic_vector(5 downto 0);
    signal shift_res_line1_add : std_logic_vector(5 downto 0);
    signal shift_res_line3_add : std_logic_vector(5 downto 0);
    signal shift_res_col1_add : std_logic_vector(5 downto 0);
    signal shift_res_col3_add : std_logic_vector(5 downto 0);
    signal Gy               : std_logic_vector(5 downto 0);
    signal Gx               : std_logic_vector(5 downto 0);
    signal img_edge_6bit_r  : std_logic_vector(5 downto 0);
    signal img_edge_en_r    : std_logic;
    signal img_edge_en_r1   : std_logic;
    signal img_edge_en_r2   : std_logic;
    signal ROW_NUM : integer range 0 to 481 := 480;
    signal COL_NUM : integer range 0 to 641 := 640;
    signal gray_8bit : std_logic_vector(7 downto 0);
    signal VGA_hs_signal: std_logic_vector(0 downto 0);
    signal VGA_hs_out_signal :std_logic_vector(0 downto 0);
    signal VGA_vs_signal: std_logic_vector(0 downto 0);
    signal VGA_vs_out_signal :std_logic_vector(0 downto 0);
begin
--    img_edge_en_r <= '1' when (cnt_col > 1 and cnt_row > 1 and cnt_col<640 and cnt_row <480 ) else '0';
--    data_in_reg <= RGB_12bit(7 downto 4) when (cnt_row > 1) else (others => '0');  --最新加入寄存器的数据
    data_in_reg <= RGB_12bit(7 downto 4);
    VGA_RGB <= (img_edge_4bit & img_edge_4bit & img_edge_4bit) when(hCount > 1 and vCount > 1 and hCount<640 and vCount<480 ) else "000000000000";
--    VGA_hs_signal<=conv_std_logic_vector(o_VGA_HS,1);
--    VGA_HS<= '1' when VGA_hs_out_signal = "1" else '0';
--    VGA_vs_signal<=conv_std_logic_vector(o_VGA_VS,1);
--    VGA_VS<= '1' when VGA_vs_out_signal = "1" else '0';
--    img_edge_en <= img_edge_en_r2;
reg1: c_shift_ram_0 port map(D=>data_in_reg,CLK=>clk,Q=>shift_res_line1,CE=>rst_n);
reg2: c_shift_ram_0 port map(D=>shift_res_line1,CLK=>clk,Q=>shift_res_line2,CE=>rst_n);   
reg3: c_shift_ram_0 port map(D=>shift_res_line2,CLK=>clk,Q=>shift_res_line3,CE=>rst_n);  
--reg4: c_shift_ram_1 port map(D=>VGA_hs_signal,CLK=>clk,Q=>VGA_hs_out_signal);  
--reg5: c_shift_ram_1 port map(D=>VGA_vs_signal,CLK=>clk,Q=>VGA_vs_out_signal);  
 
    
 
--process (clk, rst_n)
--    begin
--        if rst_n = '0' then
--            cnt_col <= (others => '0');
--        elsif rising_edge(clk) then
--            if cnt_col = COL_NUM-1 then
--                cnt_col <= (others => '0');
--            else
--                cnt_col <= cnt_col + 1;
--            end if;
--        end if;
--    end process;

--process (clk, rst_n)
--begin
--    if rst_n = '0' then
--        cnt_row <= (others => '0');
--    elsif rising_edge(clk) then
--        if ( cnt_col = COL_NUM-1) then
--            if (cnt_row = ROW_NUM-1) then
--                cnt_row <= (others => '0');
--            else
--                cnt_row <= cnt_row + 1;
--            end if;
--        end if;
--    end if;
--end process;

process (clk, rst_n)
begin
    if rst_n = '0' then
        shift_res_line1_x1 <= (others => '0');
        shift_res_line1_x2 <= (others => '0');
        shift_res_line1_x3 <= (others => '0');
    elsif rising_edge(clk) then
        shift_res_line1_x3 <= "00" & data_in_reg;
        shift_res_line1_x2 <= shift_res_line1_x3;
        shift_res_line1_x1 <= shift_res_line1_x2;
    end if;
end process;
 
process (clk, rst_n)
begin
    if rst_n = '0' then
        shift_res_line2_x4 <= (others => '0');
        shift_res_line2_x5 <= (others => '0');
        shift_res_line2_x6 <= (others => '0');
    elsif rising_edge(clk) then
        shift_res_line2_x6 <="00" &  shift_res_line1;
        shift_res_line2_x5 <= shift_res_line2_x6;
        shift_res_line2_x4 <= shift_res_line2_x5;
    end if;
end process;   

process (clk, rst_n)
begin
    if rst_n = '0' then
        shift_res_line3_x7 <= (others => '0');
        shift_res_line3_x8 <= (others => '0');
        shift_res_line3_x9 <= (others => '0');
    elsif rising_edge(clk) then
        shift_res_line3_x9 <="00" &  shift_res_line2;
        shift_res_line3_x8 <= shift_res_line3_x9;
        shift_res_line3_x7 <= shift_res_line3_x8;
    end if;
end process;

process (clk, rst_n)
begin
    if rst_n = '0' then
        shift_res_line1_add <= (others =>'0');
    elsif rising_edge(clk) then
        shift_res_line1_add <= shift_res_line1_x1 + shift_res_line1_x3 + (shift_res_line1_x2(5 downto 1)&"0");
    end if;
end process;

process (clk, rst_n)
begin
    if rst_n = '0' then
        shift_res_line3_add <= (others =>'0');
    elsif rising_edge(clk) then
        shift_res_line3_add <= shift_res_line3_x7 + shift_res_line3_x9 + (shift_res_line3_x8(5 downto 1)&"0");
    end if;
end process;

process (clk, rst_n)
begin
    if rst_n = '0' then
        Gy <=(others =>'0');
    elsif rising_edge(clk) then
        if shift_res_line1_add >= shift_res_line3_add then
            Gy <= (shift_res_line1_add - shift_res_line3_add);
        else
            Gy <= (shift_res_line3_add - shift_res_line1_add);
        end if;
    end if;
end process; 

process (clk, rst_n)
begin
    if rst_n = '0' then
        shift_res_col1_add <= (others =>'0');
    elsif rising_edge(clk) then
        shift_res_col1_add <= shift_res_line1_x1 + shift_res_line3_x7 + (shift_res_line2_x4(5 downto 1)&"0");
    end if;
end process;

process (clk, rst_n)
begin
    if rst_n = '0' then
        shift_res_col3_add <= (others =>'0');
    elsif rising_edge(clk) then
        shift_res_col3_add <= shift_res_line1_x3 + shift_res_line3_x9 + (shift_res_line2_x6(5 downto 1)&"0") ;
    end if;
end process;

process (clk, rst_n)
begin
    if rst_n = '0' then
        Gx <= (others =>'0');
    elsif rising_edge(clk) then
        if shift_res_col3_add >= shift_res_col1_add then
            Gx <= shift_res_col3_add - shift_res_col1_add;
        else
            Gx <= shift_res_col1_add - shift_res_col3_add;
        end if;
    end if;
end process;


process (clk, rst_n)
begin
    if rst_n = '0' then
        img_edge_6bit_r <= (others =>'0');
    elsif rising_edge(clk) then
        if Gx + Gy > 63 then
            img_edge_6bit_r <= "111111";
        else
            img_edge_6bit_r <= Gx + Gy;
        end if;
    end if;
end process;
process (clk, rst_n)
begin
    if rst_n = '0' then
        img_edge_4bit <= (others =>'0');
    elsif rising_edge(clk) then
        if img_edge_6bit_r >= threshold then
            img_edge_4bit <= "1111";
        else
            img_edge_4bit <= (others =>'0');
        end if;
    end if;
end process;

process (clk, rst_n)
begin
    if rst_n = '0' then
        img_edge_en_r1 <= '0';
        img_edge_en_r2 <= '0';
    elsif rising_edge(clk) then
        img_edge_en_r1 <= img_edge_en_r;
        img_edge_en_r2 <= img_edge_en_r1;
    end if;
end process;
end rtl;