-- tabela de clientes
CREATE TABLE IF NOT EXISTS tb_cliente (
	cod_cliente SERIAL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL
);

SELECT * FROM tb_cliente;

-- tabela de pedidos
CREATE TABLE IF NOT EXISTS tb_pedido (
	cod_pedido SERIAL PRIMARY KEY,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	status VARCHAR DEFAULT 'aberto',
	cod_cliente INT NOT NULL,
	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES tb_cliente(cod_cliente)
);

SELECT * FROM tb_pedido;

-- tabela de tipos de itens
CREATE TABLE IF NOT EXISTS tb_tipo_item (
	cod_tipo SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL
);

-- inserção de itens na tabela acima
INSERT INTO tb_tipo_item (descricao) VALUES ('Bebida'), ('Comida');

SELECT * FROM tb_tipo_item;

-- tabela de itens
CREATE TABLE IF NOT EXISTS tb_item (
	cod_item SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL,
	valor NUMERIC (10, 2) NOT NULL,
	cod_tipo INT NOT NULL,
	CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES tb_tipo_item(cod_tipo)
);

-- inserção de itens na tabela acima
INSERT INTO tb_item (descricao, valor, cod_tipo) VALUES ('Refrigerante', 7, 1), ('Suco', 8, 1), ('Hamburguer', 12, 2), ('Batata frita', 9, 2);

SELECT * FROM tb_item;

-- tabela de relação de itens por pedido
CREATE TABLE IF NOT EXISTS tb_item_pedido (
	cod_item_pedido SERIAL PRIMARY KEY,
	cod_item INT,
	cod_pedido INT,
	CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES tb_item (cod_item),
	CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES tb_pedido (cod_pedido)
);

SELECT * FROM tb_item_pedido;

-- procedure que cadastra clientes
CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente (IN nome VARCHAR(200), IN codigo INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
	IF codigo IS NULL THEN
		INSERT INTO tb_cliente (nome) VALUES (nome);
	ELSE
		INSERT INTO tb_cliente (codigo, nome) VALUES (codigo, nome);
	END IF;
END;
$$

-- chamada de procedure acima
CALL sp_cadastrar_cliente ('João da Silva');
CALL sp_cadastrar_cliente ('Maria Santos');

SELECT * FROM tb_cliente;

-- procedure e bloco anonimo que criam um pedido ainda sem itens (abre a comanda)
CREATE OR REPLACE PROCEDURE sp_criar_pedido (OUT cod_pedido INT, cod_cliente INT)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_pedido (cod_cliente) VALUES (cod_cliente);
	SELECT LASTVAL() INTO cod_pedido;
END;
$$

DO
$$
DECLARE
	cod_pedido INT;
	cod_cliente INT;
BEGIN
	SELECT c.cod_cliente FROM tb_cliente c WHERE nome LIKE 'João da Silva' INTO cod_cliente;
	CALL sp_criar_pedido (cod_pedido, cod_cliente);
	RAISE NOTICE 'Código do pedido recém criado: %', cod_pedido;
END;
$$

-- procedure que adciona itens a um pedido
CREATE OR REPLACE PROCEDURE sp_adicionar_item_a_pedido (IN cod_item INT, IN cod_pedido INT)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_item_pedido (cod_item, cod_pedido) VALUES ($1, $2);
	UPDATE tb_pedido p SET data_modificacao = CURRENT_TIMESTAMP WHERE p.cod_pedido = $2;
END;
$$

-- chamada da procedure acima
CALL sp_adicionar_item_a_pedido (1, 1);

SELECT * FROM tb_item_pedido;
SELECT * FROM tb_pedido;

-- procedure e bloco anonimo que calculam o valor total de um pedido
CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido (IN p_cod_pedido INT, OUT valor_total INT)
LANGUAGE plpgsql
AS $$
BEGIN
	SELECT SUM(valor) FROM tb_pedido p INNER JOIN tb_item_pedido ip ON p.cod_pedido = ip.cod_pedido INNER JOIN tb_item i ON i.cod_item = ip.cod_item WHERE p.cod_pedido = $1 INTO $2;
END;
$$

DO $$
DECLARE
	valor_total INT;
BEGIN
	CALL sp_calcular_valor_de_um_pedido(1, valor_total);
	RAISE NOTICE 'Total do pedido %: R$%', 1, valor_total;
END;
$$

-- procedure e bloco anonimo que fecham a comanda
CREATE OR REPLACE PROCEDURE sp_fechar_pedido (IN valor_a_pagar INT, IN cod_pedido INT)
LANGUAGE plpgsql
AS $$
DECLARE
	valor_total INT;
BEGIN
	CALL sp_calcular_valor_de_um_pedido (cod_pedido, valor_total);
		IF valor_a_pagar < valor_total THEN
			RAISE 'R$% insuficiente para pagar a conta de R$%', valor_a_pagar, valor_total;
		ELSE
			UPDATE tb_pedido p SET data_modificacao = CURRENT_TIMESTAMP, status = 'fechado' WHERE p.cod_pedido = $2;
	END IF;
END;
$$

DO $$
BEGIN
	CALL sp_fechar_pedido(200, 1);
END;
$$

SELECT * FROM tb_pedido;

-- procedure e bloco anonimo que calculam um eventual troco
CREATE OR REPLACE PROCEDURE sp_calcular_troco (OUT troco INT, IN valor_a_pagar INT, IN valor_total INT)
LANGUAGE plpgsql
AS $$
BEGIN
	troco := valor_a_pagar - valor_total;
END;
$$

DO
$$
DECLARE
	troco INT;
	valor_total INT;
	valor_a_pagar INT := 100;
BEGIN
	CALL sp_calcular_valor_de_um_pedido(1, valor_total);
	CALL sp_calcular_troco (troco, valor_a_pagar, valor_total);
	RAISE NOTICE 'A conta foi de R$% e você pagou %, portanto, seu troco é de R$%.', valor_total, valor_a_pagar, troco;
END;
$$

-- procedure e bloco anonimo que apontam quais notas e moedas usar para devolver o eventual troco
CREATE OR REPLACE PROCEDURE sp_obter_notas_para_compor_o_troco (OUT resultado VARCHAR(500), IN troco INT)
LANGUAGE plpgsql
AS $$
DECLARE
	notas200 INT := 0;
	notas100 INT := 0;
	notas50 INT := 0;
	notas20 INT := 0;
	notas10 INT := 0;
	notas5 INT := 0;
	notas2 INT := 0;
	moedas1 INT := 0;
BEGIN
	notas200 := troco / 200;
	notas100 := troco % 200 / 100;
	notas50 := troco % 200 % 100 / 50;
	notas20 := troco % 200 % 100 % 50 / 20;
	notas10 := troco % 200 % 100 % 50 % 20 / 10;
	notas5 := troco % 200 % 100 % 50 % 20 % 10 / 5;
	notas2 := troco % 200 % 100 % 50 % 20 % 10 % 5 / 2;
	moedas1 := troco % 200 % 100 % 50 % 20 % 10 % 5 % 2;
	resultado := concat (
		'Notas de 200: ',
		notas200 || E'\n',
		'Notas de 100: ',
		notas100 || E'\n',
		'Notas de 50: ',
		notas50 || E'\n',
		'Notas de 20: ',
		notas20 || E'\n',
		'Notas de 10: ',
		notas10 || E'\n',
		'Notas de 5: ',
		notas5 || E'\n',
		'Notas de 2: ',
		notas2 || E'\n',
		'Moedas de 1: ',
		moedas1 || E'\n'
		);
END;
$$

DO
$$
DECLARE
	resultado VARCHAR(500);
	troco INT := 43;
BEGIN
	CALL sp_obter_notas_para_compor_o_troco (resultado, troco);
	RAISE NOTICE '%', resultado;
END;
$$

-- 1.1 Adicione uma tabela de log ao sistema do restaurante. Ajuste cada procedimento para que ele registre a data em que a operação aconteceu e o nome do procedimento executado.

CREATE TABLE IF NOT EXISTS tb_log (
    cod_log SERIAL PRIMARY KEY,
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nome_procedimento VARCHAR(200) NOT NULL
);

SELECT * FROM tb_log;

CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente (IN nome VARCHAR(200), IN codigo INT DEFAULT NULL)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_log (nome_procedimento) VALUES ('sp_cadastrar_cliente');
    IF codigo IS NULL THEN
        INSERT INTO tb_cliente (nome) VALUES (nome);
    ELSE
        INSERT INTO tb_cliente (codigo, nome) VALUES (codigo, nome);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_criar_pedido (OUT cod_pedido INT, cod_cliente INT)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_log (nome_procedimento) VALUES ('sp_criar_pedido');
	INSERT INTO tb_pedido (cod_cliente) VALUES (cod_cliente);
	SELECT LASTVAL() INTO cod_pedido;
END;
$$

CREATE OR REPLACE PROCEDURE sp_adicionar_item_a_pedido (IN cod_item INT, IN cod_pedido INT)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_log (nome_procedimento) VALUES ('sp_adicionar_item_a_pedido');
	INSERT INTO tb_item_pedido (cod_item, cod_pedido) VALUES ($1, $2);
	UPDATE tb_pedido p SET data_modificacao = CURRENT_TIMESTAMP WHERE p.cod_pedido = $2;
END;
$$

CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido (IN p_cod_pedido INT, OUT valor_total INT)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_log (nome_procedimento) VALUES ('sp_calcular_valor_de_um_pedido');
	SELECT SUM(valor) FROM tb_pedido p INNER JOIN tb_item_pedido ip ON p.cod_pedido = ip.cod_pedido INNER JOIN tb_item i ON i.cod_item = ip.cod_item WHERE p.cod_pedido = $1 INTO $2;
END;
$$

CREATE OR REPLACE PROCEDURE sp_fechar_pedido (IN valor_a_pagar INT, IN cod_pedido INT)
LANGUAGE plpgsql
AS $$
DECLARE
	valor_total INT;
BEGIN
	INSERT INTO tb_log (nome_procedimento) VALUES ('sp_fechar_pedido');
	CALL sp_calcular_valor_de_um_pedido (cod_pedido, valor_total);
		IF valor_a_pagar < valor_total THEN
			RAISE 'R$% insuficiente para pagar a conta de R$%', valor_a_pagar, valor_total;
		ELSE
			UPDATE tb_pedido p SET data_modificacao = CURRENT_TIMESTAMP, status = 'fechado' WHERE p.cod_pedido = $2;
	END IF;
END;
$$

CREATE OR REPLACE PROCEDURE sp_calcular_troco (OUT troco INT, IN valor_a_pagar INT, IN valor_total INT)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_log (nome_procedimento) VALUES ('sp_calcular_troco');
	troco := valor_a_pagar - valor_total;
END;
$$

CREATE OR REPLACE PROCEDURE sp_obter_notas_para_compor_o_troco (OUT resultado VARCHAR(500), IN troco INT)
LANGUAGE plpgsql
AS $$
DECLARE
	notas200 INT := 0;
	notas100 INT := 0;
	notas50 INT := 0;
	notas20 INT := 0;
	notas10 INT := 0;
	notas5 INT := 0;
	notas2 INT := 0;
	moedas1 INT := 0;
BEGIN
	INSERT INTO tb_log (nome_procedimento) VALUES ('sp_obter_notas_para_compor_o_troco');
	notas200 := troco / 200;
	notas100 := troco % 200 / 100;
	notas50 := troco % 200 % 100 / 50;
	notas20 := troco % 200 % 100 % 50 / 20;
	notas10 := troco % 200 % 100 % 50 % 20 / 10;
	notas5 := troco % 200 % 100 % 50 % 20 % 10 / 5;
	notas2 := troco % 200 % 100 % 50 % 20 % 10 % 5 / 2;
	moedas1 := troco % 200 % 100 % 50 % 20 % 10 % 5 % 2;
	resultado := concat (
		'Notas de 200: ',
		notas200 || E'\n',
		'Notas de 100: ',
		notas100 || E'\n',
		'Notas de 50: ',
		notas50 || E'\n',
		'Notas de 20: ',
		notas20 || E'\n',
		'Notas de 10: ',
		notas10 || E'\n',
		'Notas de 5: ',
		notas5 || E'\n',
		'Notas de 2: ',
		notas2 || E'\n',
		'Moedas de 1: ',
		moedas1 || E'\n'
		);
END;
$$

-- 1.2 Adicione um procedimento ao sistema do restaurante. Ele deve receber um parâmetro de entrada (IN) que representa o código de um cliente e exibir, com RAISE NOTICE, o total de pedidos que o cliente tem.

CREATE OR REPLACE PROCEDURE sp_total_pedidos_cliente (IN codigo_cliente INT)
LANGUAGE plpgsql
AS $$
DECLARE
    total_pedidos INT;
BEGIN
    SELECT COUNT(*) INTO total_pedidos FROM tb_pedido WHERE cod_cliente = codigo_cliente;
    RAISE NOTICE 'O cliente com código % possui % pedidos.', codigo_cliente, total_pedidos;
END;
$$;

-- 1.3 Reescreva o exercício 1.2 de modo que o total de pedidos seja armazenado em uma variável de saída (OUT).

DROP PROCEDURE sp_total_pedidos_cliente(INT);
CREATE OR REPLACE PROCEDURE sp_total_pedidos_cliente (IN codigo_cliente INT, OUT total_pedidos INT)
LANGUAGE plpgsql
AS $$
BEGIN
    total_pedidos := 0;
    SELECT COUNT(*) INTO total_pedidos FROM tb_pedido WHERE cod_cliente = codigo_cliente;
	RAISE NOTICE 'O cliente com código % possui % pedidos.', codigo_cliente, total_pedidos;
END;
$$;

-- 1.4 Adicione um procedimento ao sistema do restaurante. Ele deve receber um parâmetro de entrada e saída (INOUT). Na entrada, o parâmetro possui o código de um cliente e, na saída, o parâmetro deve possuir o número total de pedidos realizados pelo cliente.
CREATE OR REPLACE PROCEDURE sp_total_pedidos_cliente_inout (INOUT codigo_cliente INT)
LANGUAGE plpgsql
AS $$
DECLARE
    total_pedidos INT;
BEGIN
    total_pedidos := 0;
    SELECT COUNT(*) INTO total_pedidos FROM tb_pedido WHERE cod_cliente = codigo_cliente;
    codigo_cliente := total_pedidos;
    RAISE NOTICE 'O cliente com código % possui % pedidos.', codigo_cliente, total_pedidos;
END;
$$;


-- 1.5 Adicione um procedimento ao sistema do restaurante. Ele deve receber um parâmetro VARIADIC contendo nomes de pessoas, fazer uma inserção na tabela de clientes para cada nome recebido e receber um parâmetro de saída que contém o seguinte texto: “Os clientes: Pedro, Ana, João etc foram cadastrados”. Evidentemente, o resultado deve conter os nomes que de fato foram enviados por meio do parâmetro VARIADIC.
CREATE OR REPLACE PROCEDURE sp_cadastrar_varios_clientes (VARIADIC nomes_cliente VARCHAR(200)[])
LANGUAGE plpgsql
AS $$
DECLARE
    mensagem_saida VARCHAR(500) := 'Os clientes: ';
    nome_cliente VARCHAR(200);
    i INT;
BEGIN
    FOR i IN 1..array_length(nomes_cliente, 1) LOOP
        nome_cliente := nomes_cliente[i];
        INSERT INTO tb_cliente (nome) VALUES (nome_cliente);
        mensagem_saida := mensagem_saida || nome_cliente || ', ';
    END LOOP;
    RAISE NOTICE '% foram cadastrados.', mensagem_saida;
END;
$$;

-- 1.6 Para cada procedimento criado, escreva um bloco anônimo que o coloca em execução.

-- 1.2
DO $$
DECLARE
    codigo_cliente INT := 1;
BEGIN
    CALL sp_total_pedidos_cliente(codigo_cliente);
END;
$$;

-- 1.3
DO $$
DECLARE
    codigo_cliente INT := 1;
    total_pedidos INT;
BEGIN
    CALL sp_total_pedidos_cliente(codigo_cliente, total_pedidos);
END;
$$;

-- 1.4
DO $$
DECLARE
    codigo_cliente INT := 1;
BEGIN
    CALL sp_total_pedidos_cliente_inout(codigo_cliente);
END;
$$;

-- 1.5
DO $$
DECLARE
    nomes_cliente VARCHAR(200)[] := ARRAY['Pedro', 'Ana', 'João'];
    mensagem_saida VARCHAR(500);
BEGIN
    CALL sp_cadastrar_varios_clientes(VARIADIC nomes_cliente);
END;
$$;