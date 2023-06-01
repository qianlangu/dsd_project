library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity top is
  port ( 
  clk_in: in std_logic;
  rst_all:in std_logic;
  d:in std_logic_vector (7 downto 0);
  pclk:in std_logic;
  vsync:in std_logic;
  href:in std_logic;
  selection : in std_logic_vector (7 downto 0 );
  cam_on:out std_logic;
  sioc:out std_logic;
  siod:inout std_logic;
  reset:out std_logic;
  pwdn:out std_logic;
  xclk:out std_logic;
  VGA_HSYNC:out std_logic;
  VGA_VSYNC:out std_logic;
  VGA_R:out std_logic_vector ( 3 downto 0);
  VGA_G:out std_logic_vector( 3 downto 0);
  VGA_B:out std_logic_vector( 3 downto 0)
  );
end top;

architecture Behavioral of top is

component capture is
    port (
        clk: in   std_logic;
        vsync: in   std_logic;
        href: in   std_logic;
        d: in   std_logic_vector ( 7 downto 0);
        addr: out  std_logic_vector (17 downto 0);
        do: out  std_logic_vector (11 downto 0);
        o: out  std_logic
    );
end component;

component clk_wiz_0 is
    port (
    clk_in1    :in std_logic;
    reset   :in std_logic;
    clk_out1: out std_logic;
    clk_out2: out std_logic
  );
end component;
  
component blk_mem_gen_0 IS
    port (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
end component;
    
component power_on_delay is
    port ( 
    RST : in std_logic;
    CLK :in std_logic;
    ready:out std_logic;
    pwdn_cam : out std_logic;
    reset_cam:out std_logic);
end component;

component reg_config is
    port (
        clk_25M: in std_logic;
        camera_rstn: in std_logic;
        initial_en: in std_logic;
        reg_conf_done: out std_logic;
        i2c_sclk: out std_logic;
        i2c_sdat: inout std_logic
    );
    end component;
    
    component ov5640_vga is
    port (
        clk25       : in  STD_LOGIC;
        vga_red     : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue    : out STD_LOGIC_VECTOR(3 downto 0);
        vga_hsync   : out STD_LOGIC;
        vga_vsync   : out STD_LOGIC;
        selection : in std_logic_vector (7 downto 0 );
        frame_addr  : out STD_LOGIC_VECTOR(17 downto 0);
        frame_pixel : in  STD_LOGIC_VECTOR(11 downto 0)
    );
end component;
  
  signal clk_24m:std_logic;
  signal clk_25m:std_logic;
  signal o_t:std_logic;
--  signal w:std_logic_vector ( 0 downto 0);
  signal w:std_logic_vector ( 0 downto 0);
  signal dout_t:std_logic_vector ( 11 downto 0 );
  signal addr_t:std_logic_vector (17 downto 0);
  signal reset_t:std_logic;
  signal initial_en_t:std_logic;
  signal rst_n_not:std_logic;
  signal frame_addr_t:std_logic_vector (17 downto 0);
  signal frame_pixel_t:std_logic_vector ( 11 downto 0 ); 
  
begin
    xclk<=clk_25m;
    reset<=reset_t;
    rst_n_not<=not(rst_all);
    
    clk:clk_wiz_0
    port map(
        clk_in1 =>clk_in,
        reset =>rst_n_not,
        clk_out1 =>clk_24m,
        clk_out2 =>clk_25m
    );
    
    power_on_cam: power_on_delay 
        port map(
            RST=> rst_all, 
            CLK=>clk_25m,
            pwdn_cam=> pwdn,
            reset_cam=>reset_t,
            ready=>initial_en_t
            );

     cam_reg_config:reg_config 
           port map(     
                  clk_25M   => clk_25m,
                  camera_rstn   =>reset_t,
                  initial_en    =>initial_en_t,
                  reg_conf_done =>cam_on,
                  i2c_sclk=>sioc,
                  i2c_sdat=>siod
                  );
    
    cam_capture: capture
    port map(
        clk  => pclk,
        vsync => vsync,
        href  => href,
        d     => d,
        addr  => addr_t,
        do  =>dout_t,
        o =>w(0)
    );
    
    mem: blk_mem_gen_0
    port map(
        clka    =>pclk,
        wea     =>w,
        dina    =>dout_t,
        addra   =>addr_t,
        addrb   =>frame_addr_t,
        clkb    =>clk_24m,
        doutb     =>frame_pixel_t
    );
         
     vga: ov5640_vga 
     port map( 
          selection =>selection,
          clk25       =>clk_25m,
          vga_red     =>vga_r,
          vga_green  =>vga_g,
          vga_blue    =>vga_b ,
          vga_hsync   =>vga_hsync,
          vga_vsync   =>vga_vsync,
          frame_addr  =>frame_addr_t,
          frame_pixel =>frame_pixel_t
      );
      
end Behavioral;
