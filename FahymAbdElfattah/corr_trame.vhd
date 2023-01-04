--__/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\__| FAHYM ABD ELFATTAH |__/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\__--

--Les registres à décalage identiques SR1 et SR2 font retarder les échantillons de (gFFT_length/2) d?une largeur de 14 bits.
--Le registre à décalage SR3 fait retarder s_int0 de (gGard_length) avec une largeur de 15 bits
--L?opérateur Op1 et Op3 réalise la valeur absolue du signal s_add_0 et res_add_1 respectivement.
--L?opérateur Op2 réalise l?opération d?addition soustraction
--L?opérateur Op4 réalise l?opération d?addition.
--R1, R2 et R4 sont des registres de taille 14 bits
--R3 un registre de taille 19 bits.
--R5 et R6 deux registres de taille 21 bits.




Library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity corr_trame is
	port(
		CLK : in std_logic; -- l'horloge globale
		RSTn : in std_logic; -- le reset global, utilise ou pas
		In_re : in std_logic_vector(13 downto 0); -- la valeur réel d'échantillon en entrée
		Evalue : in std_logic ; 
		Corr_symbole : out std_logic_vector(18 downto 0); -- la corrélation symbole
		Corr_trame : out std_logic_vector(20 downto 0)) ; --la coorélation de trame
end corr_trame;

architecture arch_correlation of corr_trame is 

---------------------------- Le registre à décalage shiftregister1 ----------------------
	COMPONENT shiftregister1 IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			shiftin		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			shiftout		: OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
			taps		: OUT STD_LOGIC_VECTOR (13 DOWNTO 0)
		);
	END COMPONENT;

---------------------------- Le registre à décalage shiftregister2 ----------------------
	COMPONENT shiftregister2 IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			shiftin		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
			shiftout		: OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
			taps		: OUT STD_LOGIC_VECTOR (14 DOWNTO 0)
		);
	END COMPONENT;
	
----------------------------  Les signaux internes ---------------------------------------
	SIGNAL s_in_re : STD_LOGIC_VECTOR(13 downto 0);

	SIGNAL O1 : STD_LOGIC_VECTOR(13 downto 0);
	SIGNAL O2 : STD_LOGIC_VECTOR(13 downto 0);

	SIGNAL s_in_retard0 : STD_LOGIC_VECTOR(13 downto 0);
	SIGNAL s_in_retard1 : STD_LOGIC_VECTOR(13 downto 0);

	SIGNAL s_add_0 : STD_LOGIC_VECTOR(13 downto 0);
	SIGNAL s_add_1 : STD_LOGIC_VECTOR(13 downto 0);

	SIGNAL s_int0 : STD_LOGIC_VECTOR(14 downto 0);
	SIGNAL s_int1 : STD_LOGIC_VECTOR(14 downto 0);
	SIGNAL s_int2 : STD_LOGIC_VECTOR(18 downto 0);
	SIGNAL s_int3 : STD_LOGIC_VECTOR(18 downto 0);
	SIGNAL s_int4 : STD_LOGIC_VECTOR(13 downto 0);
	SIGNAL s_int5 : STD_LOGIC_VECTOR(20 downto 0);
	SIGNAL s_int6 : STD_LOGIC_VECTOR(20 downto 0);
	SIGNAL s_int7 : STD_LOGIC_VECTOR(20 downto 0);
	SIGNAL s_int8 : STD_LOGIC_VECTOR(20 downto 0);
	SIGNAL s_int9 : STD_LOGIC_VECTOR(20 downto 0);

BEGIN


-- ===============================================================================================================
-- ================================================|Bloc 1|=======================================================

--=========================
	
-----------------------     In_re =>[SR1]=> O1  ----------------------------------
	SR1 : shiftregister1 
		PORT MAP (
			clock		=> CLK,
			shiftin		=> In_re,
			shiftout	=> O1,
			taps		=> OPEN
		);

------------------------     O1 =>[SR2]=> O2  --------------------------------------
	SR2 : shiftregister1
		PORT MAP (
			clock		=> CLK,
			shiftin		=> O1,
			shiftout	=> O2,
			taps		=> OPEN
		); 

----------------------     In_re =>[R1]=> s_in_re  ----------------------------------				
	R1 : process (RSTn,CLK)
	begin
		if RSTn = '0' then 
			s_in_re <= (others => '0');
		elsif CLK'event and CLK = '1' then 
			s_in_re <= In_re;
		end if;
	end process;
	
----------------------     O2 =>[R2]=>  s_in_retard0  -----------------------------
	R2 : process (RSTn,CLK)
	begin
		if RSTn = '0' then 
			s_in_retard0 <= (others => '0');
		elsif CLK'event and CLK = '1' then 
			s_in_retard0 <= O2;
		end if;
	end process;
	
----------------------     s_in_retard0|s_in_re =>[+/-]=> s_add_0  --------------------
	s_add_0 <= s_in_retard0 - s_in_re ; 
		
-----------------------     s_add_0 =>[Op.1]=> s_int0  --------------------------------
	OP1 : process(RSTn, CLK)
		 begin
		 if RSTn = '0' then
			 s_int0 <= (others => '0');
		 elsif CLK'event and CLK='1' then
			 if (s_add_0(13)='1') then
				 s_int0 <=  -(s_add_0(13)&s_add_0);
			 else 
				 s_int0 <= (s_add_0(13)&s_add_0);
			 end if;   
		  end if;    
         end process;

-----------------------     s_int0 =>[SR3]=> s_int1  ----------------------------------  
  SR3 : shiftregister2
		PORT MAP (
			clock		=> CLK,
			shiftin		=> s_int0,
			shiftout	=> s_int1,
			taps		=> OPEN
		); 

-----------------------     s_int1|s_int0|s_int3 =>[-/+/+]=> s_int2   ------------------		
	s_int2 <= s_int3 + s_int0 - s_int1; 
		
-----------------------     s_int2 =>[R3]=> s_int3   ------------------------------------
	R3 : process (RSTn,CLK)
	begin
		if RSTn = '0' then 
			s_int3 <= (others => '0');
		elsif CLK'event and CLK = '1' then 
			s_int3 <= s_int2;
		end if;
	end process;
	
--------------------------     s_int3 ==>  Corr_symbole  -------------------------------
	Corr_symbole <= s_int3; -- Les résultats sont stocker dans le fichier corr_symbole.txt 
	
	

-- ===============================================================================================================
-- ================================================|Bloc 2|=======================================================
	
---------------------------     O1 =>[R4]=> s_in_retarad1  ------------------------------
	R4 : process (RSTn,CLK)
	begin
		if RSTn = '0' then 
			s_in_retard1 <= (others => '0');
		elsif CLK'event and CLK = '1' then 
			s_in_retard1 <= O1;
		end if;
	end process;
	
------------------------------     s_in_re|s_in_retarad1 =>[+/-]=> s_add_1  ----------------
	s_add_1 <= s_in_retard1 - s_in_re ;
	
------------------------------    s_add_1 =>[Op.3]=> s_int4  --------------------------------
	OP3 : process(RSTn, CLK)
		 begin
		 if RSTn = '0' then
			 s_int4 <= (others => '0');
		 elsif CLK'event and CLK='1' then
			 if (s_add_1(13)='1') then
				 s_int4 <=  -s_add_1;
			 else 
				 s_int4 <= s_add_1;
			 end if;   
		  end if;    
     end process;
  
--------------------------------     s_int4|s_int7 =>[Op.4]=> s_int5  --------------------------
	s_int5 <= s_int4 + s_int7 ; 
  
--------------------------------     s_int5|0 {evalue} =>[Mlx]=> s_int6  -----------------------
	s_int6 <= s_int5 when evalue = '0' else "000000000000000000000"; 
 
----------------------------------     s_int6 =>[R5]=> s_int7  ------------------------------------
	R5 : process (RSTn,CLK)
	begin
		if RSTn = '0' then 
			s_int7 <= (others => '0');
		elsif CLK'event and CLK = '1' then 
			s_int7 <= s_int6;
		end if;
	end process;
	
---------------------------------     s_int7|s_int9 {evalue} =>[Mlx]=> s_int8  ---------------------
	s_int8 <= s_int9 when evalue = '0' else s_int7; 
	
---------------------------------------     s_int8 =>[R6]=> s_int9  ----------------------------------
	R6 : process (RSTn,CLK)
	begin
		if RSTn = '0' then 
			s_int9 <= (others => '0');
		elsif CLK'event and CLK = '1' then 
			s_int9 <= s_int8;
		end if;
	end process;
	
-------------------------------------------     s_int8 ==> corr_trame  ------------------------------
	corr_trame <= s_int9 ; -- Les résultats sont stocker dans le fichier corr_trame.txt
	
end arch_correlation;
	

