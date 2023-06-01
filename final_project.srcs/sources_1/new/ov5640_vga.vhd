library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov5640_vga is
    port ( 
        selection : in std_logic_vector (7 downto 0 );
        clk25       : in  STD_LOGIC;
        vga_red     : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue    : out STD_LOGIC_VECTOR(3 downto 0);
        vga_hsync   : out STD_LOGIC;
        vga_vsync   : out STD_LOGIC;
        frame_addr  : out STD_LOGIC_VECTOR(17 downto 0);
        frame_pixel : in  STD_LOGIC_VECTOR(11 downto 0)
    );
end ov5640_vga;

architecture Behavioral of ov5640_vga is

   -- Timing constants
   constant hRez       : natural := 640;
   constant hStartSync : natural := 640+16;
   constant hEndSync   : natural := 640+16+96;
   constant hMaxCount  : natural := 800;
   
   constant vRez       : natural := 480;
   constant vStartSync : natural := 480+10;
   constant vEndSync   : natural := 480+10+2;
   constant vMaxCount  : natural := 480+10+2+33;
   
   constant hsync_active : std_logic := '0';
   constant vsync_active : std_logic := '0';

   signal hCounter : unsigned( 9 downto 0) := (others => '0');
   signal vCounter : unsigned( 9 downto 0) := (others => '0');
   signal address  : unsigned(18 downto 0) := (others => '0');
   signal blank    : std_logic := '1';
   signal rst  : std_logic:='0';
   signal RGB :std_logic_vector(11 downto 0);
   signal enable:std_logic;
   signal CLK_25M: std_logic;
begin
   frame_addr <= std_logic_vector(address(18 downto 1));
   CLK_25M<=clk25;
   process(clk25)
   begin
      if rising_edge(clk25) then
         -- Count the lines and rows      
         if hCounter = hMaxCount-1 then
            hCounter <= (others => '0');
            if vCounter = vMaxCount-1 then
               vCounter <= (others => '0');
            else
               vCounter <= vCounter+1;
            end if;
         else
            hCounter <= hCounter+1;
         end if;

         if blank = '0' then
            if selection = "00000001" then
                vga_red   <= frame_pixel( 11 downto 8);
                vga_green <= frame_pixel( 7 downto 4);
                vga_blue  <= frame_pixel( 3 downto 4);
            elsif selection = "00000010" then
                vga_red   <= frame_pixel(11 downto 8);
                vga_green <= frame_pixel( 7 downto 4);
                vga_blue  <= frame_pixel( 11 downto 8);
            elsif selection = "00000100" then
                vga_red   <= frame_pixel( 7 downto 4);
                vga_green <= frame_pixel( 7 downto 4);
                vga_blue  <= frame_pixel( 3 downto 0);         
            elsif selection = "00001000" then
                vga_red   <= frame_pixel( 7 downto 8);
                vga_green <= frame_pixel( 7 downto 4);
                vga_blue  <= frame_pixel( 3 downto 4);
            elsif selection = "00010000" then
                vga_red   <= frame_pixel( 3 downto 0);
                vga_green <= frame_pixel( 3 downto 0);
                vga_blue  <= frame_pixel( 3 downto 0);
            elsif selection = "00100000" then
                vga_red   <= frame_pixel(11 downto 8);
                vga_green <= frame_pixel( 7 downto 10 );
                vga_blue  <= frame_pixel( 3 downto 0);
            elsif selection = "01000000" then
                vga_red   <= frame_pixel(11 downto 8);
                vga_green <= frame_pixel( 7 downto 4);
                vga_blue  <= frame_pixel( 3 downto 5);
            else
                vga_red   <=frame_pixel (11 downto 8);
                vga_green <=frame_pixel( 7 downto 4);
                vga_blue  <=frame_pixel( 3 downto 0);
         end if;

         else
            vga_red   <= (others => '0');
            vga_green <= (others => '0');
            vga_blue  <= (others => '0');
         end if;
   
         if vCounter  >= vRez then
            address <= (others => '0');
            blank <= '1';
            rst<='0';
         else 
            if hCounter  < hRez then
               rst<='1';
               blank <= '0';
               address <= address+1;
            else
               rst<='0';
               blank <= '1';
            end if;
         end if;
   
         if hCounter > hStartSync and hCounter <= hEndSync then
            vga_hSync <= hsync_active;
         else
            vga_hSync <= not hsync_active;
         end if;

         if vCounter >= vStartSync and vCounter < vEndSync then
            vga_vSync <= vsync_active;
         else
            vga_vSync <= not vsync_active;
         end if;
      end if;
   end process;
end Behavioral;
