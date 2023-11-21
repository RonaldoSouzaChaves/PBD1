-- dada uma data no formato ddmmaaaa, verificar se ela é válida

DO
$$
DECLARE
	data INT := 31062021;
	dia INT;
	mes INT;
	ano INT;
	dataValida BOOL := TRUE;
BEGIN
	dia := data / 1000000;
	mes := data % 1000000 / 10000;
	ano := data % 10000;
	RAISE NOTICE 'a data é %/%/%', dia, mes, ano;
	IF ano <= 1 THEN
		RAISE NOTICE 'data inválida';
	ELSE
		CASE
			WHEN mes > 12 OR mes < 1 OR dia > 31 OR dia < 1 THEN
				dataValida := FALSE;
			ELSE
				IF ((mes = 4 OR mes = 6 OR mes = 9 OR mes = 11) AND dia > 30) THEN
					dataValida := TRUE;
				ELSE
					IF mes = 2 THEN
						CASE
							WHEN (ano % 4 = 0 AND ano % 100 <> 0) THEN
								IF dia > 29 THEN
									dataValida := FALSE;
								END IF;
							ELSE
								IF dia > 28 THEN
									dataValida := FALSE;
								END IF;
						END CASE;
					END IF;
				END IF;
		END CASE;
	END IF;
	CASE
		WHEN dataValida THEN
			RAISE NOTICE 'data válida';
		ELSE
			RAISE NOTICE 'data inválida';
	END CASE;
END;
$$

-- DO
-- $$
-- DECLARE
-- 	valor INT := fnValorAleatorioEntre(1, 12);
-- 	mensagem VARCHAR(200);
-- BEGIN
-- 	RAISE NOTICE 'o valor é %', valor;
-- 	CASE valor
-- 		WHEN 1, 3, 5, 7, 9 THEN
-- 			RAISE NOTICE 'impar';
-- 		WHEN 2, 4, 6, 8 THEN
-- 			RAISE NOTICE 'par';
-- 		ELSE 
-- 			RAISE NOTICE 'fora do intervalo';
-- 	END CASE;
-- END;
-- $$

-- DO
-- $$
-- DECLARE
-- 	a INT := fnValorAleatorioEntre(0, 20);
-- 	b INT := fnValorAleatorioEntre(0, 20);
-- 	c INT := fnValorAleatorioEntre(0, 20);
-- 	delta NUMERIC (10, 2);
-- 	raiz1 NUMERIC (10, 2);
-- 	raiz2 NUMERIC (10, 2);
-- BEGIN
-- 	RAISE NOTICE '%x% + %x + % = 0', a, U&'\00B2', b, c;
-- 	IF a = 0 THEN
-- 		RAISE NOTICE 'nao é uma equação de segundo grau';	
-- 	ELSE
-- 		delta := b^2 - 4 * a * c;
-- 		IF delta < 0 THEN
-- 			RAISE NOTICE 'sem raiz';
-- 		ELSIF delta = 0 THEN
-- 			raiz1 := (-b + |/delta) / 2 * a;
-- 			RAISE NOTICE 'há uma raiz: %', raiz1;
-- 		ELSE
-- 			raiz1 := (-b + |/delta) / 2 * a;
-- 			raiz2 := (-b - |/delta) / 2 * a;
-- 			RAISE NOTICE 'há duas raizes: % e %', raiz1, raiz2;
-- 		END IF;
-- 	END IF;
-- END;
-- $$

-- DO
-- $$
-- DECLARE
-- 	valor INT := fnValorAleatorioEntre(1, 100);
-- BEGIN
-- 	IF valor % 2 = 0 THEN
-- 		RAISE NOTICE '% é par', valor;
-- 	ELSE
-- 		RAISE NOTICE '% é ímpar', valor;
-- 	END IF;
-- END;
-- $$

-- DO
-- $$
-- DECLARE
-- 	valor INT;
-- BEGIN
-- 	valor := fnValorAleatorioEntre(1,10);
-- 	RAISE NOTICE 'valor gerado = %', valor;
-- 		IF valor < 20 THEN
-- 			RAISE NOTICE 'sim, % é menor ou igual a 20', valor;
-- 		END IF
-- END;
-- $$

-- SELECT fnValorAleatorioEntre(2,5);

-- CREATE OR REPLACE FUNCTION fnValorAleatorioEntre(limiteInferior INT, limiteSuperior INT) RETURNS INT AS
-- $$
-- BEGIN
-- 	RETURN FLOOR(RANDOM() * (limiteSuperior - limiteInferior + 1) + limiteInferior)::INT;
-- END
-- $$ LANGUAGE plpgsql;

-- NOTA: Para cada exercício, produza duas soluções, uma que utilize apenas IF e suas variações e outra que use apenas CASE e suas variações.

--  Para cada exercício, gere valores aleatórios conforme a necessidade. Use a função abaixo:
CREATE OR REPLACE FUNCTION valor_aleatorio_entre (lim_inferior INT, lim_superior INT) RETURNS INT AS
$$
BEGIN
	RETURN FLOOR(RANDOM() * (lim_superior - lim_inferior + 1) + lim_inferior)::INT;
END;
$$ LANGUAGE plpgsql;
-- lembre-se de executar a função ao menos uma vez antes de usá-la.

-- 1.1 - Faça um programa que exibe se um número inteiro é múltiplo de 3.

-- IFs
DO
$$
DECLARE
	valor INT := valor_aleatorio_entre(1, 100);
BEGIN
	RAISE NOTICE 'O valor gerado é: %', valor;
	IF valor % 3 = 0 THEN
		RAISE NOTICE '% é múltiplo de 3', valor;
	ELSE
		RAISE NOTICE '% não é múltiplo de 3', valor;
	END IF;
END;
$$

-- CASE
DO
$$
DECLARE
	valor INT := valor_aleatorio_entre(1, 100);
	mensagem VARCHAR(200);
BEGIN
	RAISE NOTICE 'O valor gerado é: %', valor;
	CASE
		WHEN valor % 3 = 0 THEN
			RAISE NOTICE '% é múltiplo de 3', valor;
		ELSE
			RAISE NOTICE '% não é múltiplo de 3', valor;
	END CASE;
END;
$$

-- 1.2 - Faça um programa que exibe se um número inteiro é múltiplo de 3 ou de 5.

-- IFs
DO
$$
DECLARE
	valor INT := valor_aleatorio_entre(1, 100);
BEGIN
	RAISE NOTICE 'O valor gerado é: %', valor;
	IF valor % 3 = 0 OR valor % 5 = 0 THEN
		RAISE NOTICE '% é múltiplo de 3 ou 5', valor;
	ELSE
		RAISE NOTICE '% não é múltiplo de 3 ou 5', valor;
	END IF;
END;
$$

-- CASE
DO
$$
DECLARE
	valor INT := valor_aleatorio_entre(1, 100);
	mensagem VARCHAR(200);
BEGIN
	RAISE NOTICE 'O valor gerado é: %', valor;
	CASE
		WHEN valor % 3 = 0 OR valor % 5 = 0 THEN
			RAISE NOTICE '% é múltiplo de 3 ou 5', valor;
		ELSE
			RAISE NOTICE '% não é múltiplo de 3 ou 5', valor;
	END CASE;
END;
$$


-- 1.3 - Faça um programa que opera de acordo com o seguinte menu:

-- Opções:
-- 1 - Soma
-- 2 - Subtração
-- 3 - Multiplicação
-- 4 - Divisão

-- Cada operação envolve dois números inteiros. O resultado deve ser exibido no formato op1 op op2 = res. Exemplo: 2 + 3 = 5.

-- IFs
DO
$$
DECLARE
    opcao INT;
    num1 INT;
    num2 INT;
    resultado INT;
    operador CHAR(1);
BEGIN
    RAISE NOTICE 'Opções:';
    RAISE NOTICE '1 - Soma';
    RAISE NOTICE '2 - Subtração';
    RAISE NOTICE '3 - Multiplicação';
    RAISE NOTICE '4 - Divisão';
    
    opcao := valor_aleatorio_entre(1, 4);
    
    num1 := valor_aleatorio_entre(1, 100);
    num2 := valor_aleatorio_entre(1, 100);

    IF opcao = 1 THEN
        resultado := num1 + num2;
        operador := '+';
    ELSIF opcao = 2 THEN
        resultado := num1 - num2;
        operador := '-';
    ELSIF opcao = 3 THEN
        resultado := num1 * num2;
        operador := '*';
    ELSIF opcao = 4 THEN
        IF num2 = 0 THEN
            RAISE NOTICE 'não é possível dividir por zero';
            resultado := NULL;
        ELSE
            resultado := num1 / num2;
            operador := '/';
        END IF;
    ELSE
        RAISE NOTICE 'opção inválida';
    END IF;
    
    IF resultado IS NOT NULL THEN
        RAISE NOTICE '% % % = %', num1, operador, num2, resultado;
    END IF;
END;
$$;

-- CASE
DO
$$ 
DECLARE
    opcao INT;
    num1 INT;
    num2 INT;
    resultado INT;
BEGIN
    RAISE NOTICE 'Opções:';
    RAISE NOTICE '1 - Soma';
    RAISE NOTICE '2 - Subtração';
    RAISE NOTICE '3 - Multiplicação';
    RAISE NOTICE '4 - Divisão';
    
    opcao := valor_aleatorio_entre(1, 4);
    
    num1 := valor_aleatorio_entre(1, 100);
    num2 := valor_aleatorio_entre(1, 100);
    
    resultado :=
	CASE
        WHEN opcao = 1 THEN num1 + num2
        WHEN opcao = 2 THEN num1 - num2
        WHEN opcao = 3 THEN num1 * num2
		WHEN opcao = 4 AND num2 <> 0 THEN num1 / num2 
        ELSE NULL
    END CASE;
    
	CASE
		WHEN opcao = 4 AND num2 = 0 THEN
			RAISE NOTICE 'não é possível dividir por zero';
		ELSE
		RAISE NOTICE '% % % = %', num1,
			CASE
				WHEN opcao = 1 THEN '+'
				WHEN opcao = 2 THEN '-'
				WHEN opcao = 3 THEN '*'
				ELSE '/'
			END CASE,
			num2, resultado;
	END CASE;
END;
$$;

-- 1.4 - Um comerciante comprou um produto e quer vendê-lo com um lucro de 45% se o valor da compra for menor que R$20. Caso contrário, ele deseja lucro de 30%. Faça um programa que, dado o valor do produto, calcula o valor de venda.

-- IF
DO
$$
DECLARE
    valorCompra NUMERIC;
    valorVenda NUMERIC;
BEGIN
	valorCompra := valor_aleatorio_entre(1, 40);
	
    IF valorCompra < 20.00 THEN
        valorVenda := valorCompra * 1.45;
    ELSE
        valorVenda := valorCompra * 1.30;
    END IF;

	RAISE NOTICE 'valor de compra: R$ %', valorCompra;
    RAISE NOTICE 'valor de venda: R$ %', valorVenda;
END;
$$;

-- CASE
DO
$$
DECLARE
    valorCompra NUMERIC;
    valorVenda NUMERIC;
BEGIN
	valorCompra := valor_aleatorio_entre(1, 40);
	
    CASE
        WHEN valorCompra < 20.00 THEN
            valorVenda := valorCompra * 1.45;
        ELSE
            valorVenda := valorCompra * 1.30;
    END CASE;

    RAISE NOTICE 'valor de compra: R$ %', valorCompra;
    RAISE NOTICE 'valor de venda: R$ %', valorVenda;
END;
$$;

-- 1.5 - Resolva o problema disponível no link a seguir: https://www.beecrowd.com.br/judge/en/problems/view/1048/

-- IF
DO
$$
DECLARE
    salario NUMERIC;
    novoSalario NUMERIC;
    reajusteGanho NUMERIC;
    porcentagemAumento NUMERIC;
BEGIN
	salario := valor_aleatorio_entre(1, 3000);
	
    IF salario <= 400.00 THEN
        novoSalario := salario * 1.15;
        reajusteGanho := novoSalario - salario;
        porcentagemAumento := 15;
    ELSIF salario <= 800.00 THEN
        novoSalario := salario * 1.12;
        reajusteGanho := novoSalario - salario;
        porcentagemAumento := 12;
    ELSIF salario <= 1200.00 THEN
        novoSalario := salario * 1.10;
        reajusteGanho := novoSalario - salario;
        porcentagemAumento := 10;
    ELSIF salario <= 2000.00 THEN
        novoSalario := salario * 1.07;
        reajusteGanho := novoSalario - salario;
        porcentagemAumento := 7;
    ELSE
        novoSalario := salario * 1.04;
        reajusteGanho := novoSalario - salario;
        porcentagemAumento := 4;
    END IF;
    
	--RAISE NOTICE 'salário atual: %', salario;
    RAISE NOTICE 'Novo salario: %', novoSalario;
    RAISE NOTICE 'Reajuste ganho: %', reajusteGanho;
    RAISE NOTICE 'Em percentual: % %%', porcentagemAumento;
END;
$$;

-- CASE
DO
$$
DECLARE
    salario NUMERIC;
    novoSalario NUMERIC;
    reajusteGanho NUMERIC;
    porcentagemAumento NUMERIC;
BEGIN
	salario := valor_aleatorio_entre(1, 3000);
	
    CASE
        WHEN salario <= 400.00 THEN
            novoSalario := salario * 1.15;
            reajusteGanho := novoSalario - salario;
            porcentagemAumento := 15;
        WHEN salario <= 800.00 THEN
            novoSalario := salario * 1.12;
            reajusteGanho := novoSalario - salario;
            porcentagemAumento := 12;
        WHEN salario <= 1200.00 THEN
            novoSalario := salario * 1.10;
            reajusteGanho := novoSalario - salario;
            porcentagemAumento := 10;
        WHEN salario <= 2000.00 THEN
            novoSalario := salario * 1.07;
            reajusteGanho := novoSalario - salario;
            porcentagemAumento := 7;
        ELSE
            novoSalario := salario * 1.04;
            reajusteGanho := novoSalario - salario;
            porcentagemAumento := 4;
    END CASE;
    
	--RAISE NOTICE 'salário atual: %', salario;
    RAISE NOTICE 'Novo salario: %', novoSalario;
    RAISE NOTICE 'Reajuste ganho: %', reajusteGanho;
    RAISE NOTICE 'Em percentual: % %%', porcentagemAumento;
END;
$$;