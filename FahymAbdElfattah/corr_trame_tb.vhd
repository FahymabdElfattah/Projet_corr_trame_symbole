-- =====================================| fichier VHDL de test bench |====================================== --


LIBRARY ieee  ; 
library std;
use std.textio.ALL;
USE ieee.std_logic_1164.all  ; 
USE ieee.numeric_std.all; 

ENTITY corr_trame_tb  IS 
END ; 
 
ARCHITECTURE corr_trame_tb_arch OF corr_trame_tb IS
  SIGNAL In_re    :  std_logic_vector (13 downto 0)  := (others => '0'); 
  SIGNAL corr_s   :  std_logic_vector (18 downto 0)  ; 
  SIGNAL corr_t   :  std_logic_vector (20 downto 0)  ; 
  SIGNAL Evalue   :  STD_LOGIC  ; 
  SIGNAL CLK      :  STD_LOGIC  ; 
  SIGNAL RSTn     :  STD_LOGIC  ; 

  COMPONENT corr_trame  
    PORT ( 
      corr_symbole : out std_logic_vector(18 downto 0);
	    corr_trame : out std_logic_vector(20 downto 0);	
	    In_re 	: in std_logic_vector(13 downto 0);
	    Evalue  : in STD_LOGIC ; 
      CLK  : in STD_LOGIC ; 
      RSTn  : in STD_LOGIC ); 
  END COMPONENT ; 
  COMPONENT timer is
   port (RSTn : in std_logic;
      CLK  : in std_logic;
      Evalue : out std_logic);
   end component;
   
BEGIN
   
  DUT  : corr_trame  
    PORT MAP ( 
      In_re   => In_re  ,
      corr_symbole   => corr_s,
      corr_trame => corr_t,
      Evalue   => Evalue  ,
      CLK   => CLK  ,
      RSTn   => RSTn   ) ; 

timer0 : timer
port map (RSTn => RSTn,
      CLK  => CLK,
      Evalue => Evalue);
      
RSTn 		<= '0', '1' after 5 ns;
      
P: process
begin
  clk <= '0';
  wait for 10 ns;
  clk <= '1';
  wait for 10 ns;
end process P;

LECTURE : process
  variable L,M	: LINE;
  file ENTREE	 : TEXT open READ_MODE is	"in_re5_chan2.txt"; --fichier des échantillons |
  file SORTIE_t	 : TEXT open WRITE_MODE is	"corr_trame.txt"; -- fichier du résultats du deuxième bloc
  file SORTIE_s : TEXT open WRITE_MODE is	"corr_symbole.txt"; --fichier du résultats du premiére bloc 
  variable A	: integer := 0;
 
begin
  while not endfile(ENTREE) loop
    wait for 10 ns;
    READLINE(ENTREE, L);
    READ(L,A);
    in_re 		<= std_logic_vector(TO_SIGNED(A,14)) after 2 ns;
    wait for 10 ns; 
    WRITE(M,to_INTEGER(SIGNED(corr_s))	,LEFT, 8);
    WRITELINE(SORTIE_s, M);
	  WRITE(M,to_INTEGER(SIGNED(corr_t))	,LEFT, 8);
	  WRITELINE(SORTIE_t, M);
	 end loop;
   wait;
end process LECTURE;      
END ; 


