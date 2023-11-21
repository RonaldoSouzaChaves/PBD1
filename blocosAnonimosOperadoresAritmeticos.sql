DO
$$
DECLARE
	n1 NUMERIC (5,2);
	n2 INTEGER;
	limite_inferior INTEGER := 5;
	limite_superior INTEGER := 17;
BEGIN
	-- 0 <= n1 < 1 (intervalo real)
	n1 := random();
	RAISE NOTICE 'n1: %', n1;
	-- 1 <= n1 < 10 (intervalo real)
	n1 := 1 + random() * 9;
	-- 1 <= n2 < 10 (::int faz type cast) floor arredonda para baixo
	n2 := floor(random() * 9 + 1)::INT;
	RAISE NOTICE 'n2: %', n2;
	-- gerar um valor inteiro entre 5 e 17
	n2:= 5 + floor (random() * limite_superior - limite_inferior + 1))::INT;
END
$$
	

-- DO
-- $$
-- DECLARE
-- 	n1 INTEGER := 5;
-- 	n2 INTEGER := 2;
-- 	n3 NUMERIC (5,2) := 5;
-- 	n4 INTEGER := -5;
-- BEGIN
-- 	--divisão inteira
-- 	RAISE NOTICE '% / % = %', n1, n2, n1 / n2;
-- 	--divisão real
-- 	RAISE NOTICE '% / % = %', n3, n2, to_char(n3 / n2, '99.99');
-- 	--resto da divisão
-- 	RAISE NOTICE '% %% % = %', n1, n2, n1 % n2;
-- 	--exponenciação
-- 	RAISE NOTICE '% ^ % = %', n1, n2, n1 ^ n2;
-- 	--raiz quadrada
-- 	RAISE NOTICE '|/% = %', n1, |/n1;
-- 	--raiz cubica
-- 	RAISE NOTICE '||/% = %', n1, ||/n1;
-- 	--valor absoluto
-- 	RAISE NOTICE '@% = % e @%= %', n1, @n1, n4, @n4;
-- END;

--DO
--$$
--DECLARE
--	codigo INTEGER = 1;
--	nome_completo VARCHAR(200) := 'João Santos';
--	salario NUMERIC(11,2) := 20.5;
--BEGIN
--	RAISE NOTICE 'meu código é %, me chamo % e meu salário é %', codigo, nome_completo, -------salario;
--END;
--$$

-- 1.1 Faça um programa que gere um valor inteiro e o exiba.

DO
$$
DECLARE
	n INTEGER;
BEGIN
	n := floor(random() * 10)::INT;
	RAISE NOTICE 'n: %', n;
END
$$

-- 1.2. Faça um programa que gere um valor real e o exiba
-- random() gera um valor real entre 0 e 1, então está valendo.

DO
$$
DECLARE
	n NUMERIC;
BEGIN
	n := random();
	RAISE NOTICE 'n: %', n;
END
$$

-- 1.3: Faça um programa que gere um valor real no intervalo [20, 30] que representa uma temperatura em graus Celsius. Faça a conversão para Fahrenheit e exiba.

DO
$$
DECLARE
	celsius NUMERIC;
	fahrenheit NUMERIC;
	limiteInferior INTEGER:= 20;
	limiteSuperior INTEGER:= 30;
BEGIN
	celsius:= floor(random() * (limiteSuperior - limiteInferior + 1) + limiteInferior)::int;
	
	fahrenheit := (celsius * 9/5) + 32;
	
	RAISE NOTICE 'temperatura em Cº = %', celsius;
	RAISE NOTICE 'temperatura em Fº = %', fahrenheit;
END
$$

-- 1.4: Faça um programa que gere três valores reais a, b, e c e mostre o valor de delta: aquele que calculamos para chegar às potenciais raízes de uma equação do segundo grau.

DO
$$
DECLARE
	a NUMERIC;
	b NUMERIC;
	c NUMERIC;
	delta NUMERIC;
BEGIN
	a:= floor(random() * 100);
	b:= floor(random() * 100);
	c:= floor(random() * 100);
	
	delta := (b * b) - (4 * a * c);
	
	RAISE NOTICE 'valor de a = %', a;
	RAISE NOTICE 'valor de b = %', b;
	RAISE NOTICE 'valor de c = %', c;
	RAISE NOTICE 'delta = %', delta;
END
$$

-- 1.5: Faça um programa que gere um número inteiro e mostre a raiz cúbica de seu antecessor e a raiz quadrada de seu sucessor.

DO
$$
DECLARE
   numero INTEGER;
   antecessor INTEGER;
   sucessor INTEGER;
   raizCubica NUMERIC;
   raizQuadrada NUMERIC;
BEGIN
   numero := floor(random() * 100);

   antecessor := numero - 1;
   sucessor := numero + 1;

   raizCubica := cbrt(antecessor);
   raizQuadrada := sqrt(sucessor);

   RAISE NOTICE 'número = %', numero;
   RAISE NOTICE 'raiz cúbica do antecessor = %', raizCubica;
   RAISE NOTICE 'raiz quadrada do sucessor = %', raizQuadrada;
END
$$

-- 1.6: Faça um programa que gere medidas reais de um terreno retangular. Gere também um valor real no intervalo [60, 70] que representa o preço por metro quadrado. O programa deve exibir o valor total do terreno.

DO
$$
DECLARE
   largura NUMERIC;
   comprimento NUMERIC;
   area NUMERIC;
   precoM2 NUMERIC;
   valorTotal NUMERIC;
BEGIN
   -- entre 10 e 60 metros
   largura := random() * 50.0 + 10.0;
   -- entre 10 e 60 metros
   comprimento := random() * 50.0 + 10.0;

   area := largura * comprimento;

   -- entre 60 e 70 reais por metro quadrado
   precoM2 := random() * 10.0 + 60.0;

   valorTotal := area * precoM2;

   RAISE NOTICE 'largura do terreno (em metros) = %', largura;
   RAISE NOTICE 'comprimento do terreno (em metros) = %', comprimento;
   RAISE NOTICE 'área do terreno (em metros) = %', area;
   RAISE NOTICE 'preço por metro quadrado (em reais) = %', precoM2;
   RAISE NOTICE 'valor total do terreno (em reais) = %', valorTotal;
END
$$

-- 1.7:  Escreva um programa que gere um inteiro que representa o ano de nascimento de uma pessoa no intervalo [1980, 2000] e gere um inteiro que representa o ano atual no intervalo [2010, 2020]. O programa deve exibir a idade da pessoa em anos. Desconsidere detalhes envolvendo dias, meses, anos bissextos, etc.

DO
$$
DECLARE
   anoNascimento INTEGER;
   anoAtual INTEGER;
   idade INTEGER;
BEGIN
   -- intervalo [1980, 2000]
   anoNascimento := floor(random() * 21) + 1980;

   -- intervalo [2010, 2020]
   anoAtual := floor(random() * 11) + 2010;

   idade := anoAtual - anoNascimento;

   RAISE NOTICE 'ano de nascimento = %', anoNascimento;
   RAISE NOTICE 'ano atual = %', anoAtual;
   RAISE NOTICE 'idade da pessoa = %', idade;
END
$$