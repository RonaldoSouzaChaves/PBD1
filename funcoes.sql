CREATE TABLE tb_cliente (
	cod_cliente SERIAL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL
);

INSERT INTO tb_cliente (nome) VALUES ('João Santos'), ('Maria Andrade');

SELECT * FROM tb_cliente;

CREATE TABLE tb_tipo_conta (
	cod_tipo_conta SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL
);

INSERT INTO tb_tipo_conta (descricao) VALUES ('Conta Corrente'), ('Conta Poupança');

SELECT * FROM tb_tipo_conta;

CREATE TABLE tb_conta (
	cod_conta SERIAL PRIMARY KEY,
	status VARCHAR(200) NOT NULL DEFAULT 'aberta',
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_ultima_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	saldo NUMERIC(10, 2) NOT NULL DEFAULT 1000 CHECK (saldo >= 1000),
	cod_cliente INT NOT NULL,
	cod_tipo_conta INT NOT NULL,
	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES tb_cliente(cod_cliente),
	CONSTRAINT fk_tipo_conta FOREIGN KEY (cod_tipo_conta) REFERENCES tb_tipo_conta(cod_tipo_conta)
);

SELECT * FROM tb_conta;

DROP FUNCTION IF EXISTS fn_abrir_conta;

CREATE OR REPLACE FUNCTION fn_abrir_conta (IN p_cod_cli INT, IN p_saldo NUMERIC(10, 2), IN p_cod_tipo_conta INT) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_conta (cod_cliente, saldo, cod_tipo_conta) VALUES ($1, $2, $3);
	RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
	RETURN FALSE;
END;
$$

DO $$
DECLARE
	v_cod_cliente INT := 1;
	v_saldo NUMERIC (10, 2) := 500;
	v_cod_tipo_conta INT := 1;
	v_resultado BOOLEAN;
BEGIN
SELECT fn_abrir_conta (v_cod_cliente, v_saldo, v_cod_tipo_conta) INTO v_resultado;
	RAISE NOTICE '%', format('Conta com saldo R$%s%s foi aberta', v_saldo, CASE WHEN v_resultado THEN '' ELSE ' não' END);
	v_saldo := 1000;
	SELECT fn_abrir_conta (v_cod_cliente, v_saldo, v_cod_tipo_conta) INTO v_resultado;
	RAISE NOTICE '%', format('Conta com saldo R$%s%s foi aberta', v_saldo, CASE WHEN v_resultado THEN '' ELSE ' não' END);
END;
$$

DROP ROUTINE IF EXISTS fn_depositar;

CREATE OR REPLACE FUNCTION fn_depositar (IN p_cod_cliente INT, IN p_cod_conta INT, IN p_valor NUMERIC(10, 2)) RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
DECLARE
	v_saldo_resultante NUMERIC(10, 2);
BEGIN
	UPDATE tb_conta SET saldo = saldo + p_valor WHERE cod_cliente = p_cod_cliente AND cod_conta = p_cod_conta;
	SELECT saldo FROM tb_conta c WHERE c.cod_cliente = p_cod_cliente AND c.cod_conta = p_cod_conta INTO v_saldo_resultante;
	RETURN v_saldo_resultante;
END;
$$

DO $$
DECLARE
	v_cod_cliente INT := 1;
	v_cod_conta INT := 2;
	v_valor NUMERIC(10, 2) := 200;
	v_saldo_resultante NUMERIC (10, 2);
BEGIN
	SELECT fn_depositar (v_cod_cliente, v_cod_conta, v_valor) INTO v_saldo_resultante;
	RAISE NOTICE '%', format('Após depositar R$%s, o saldo resultante é de R$%s', v_valor, v_saldo_resultante);
END;
$$

-- 1.1 Escreva a seguinte função: nome: fn_consultar_saldo; recebe: código de cliente, código de conta; devolve: o saldo da conta especificada.

CREATE OR REPLACE FUNCTION fn_consultar_saldo(IN p_cod_cliente INT, IN p_cod_conta INT) RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_saldo NUMERIC(10, 2);
BEGIN
    SELECT saldo INTO v_saldo FROM tb_conta WHERE cod_cliente = p_cod_cliente AND cod_conta = p_cod_conta;
    IF FOUND THEN
        RETURN v_saldo;
    ELSE
        RETURN NULL;
    END IF;
END;
$$;

-- 1.2 Escreva a seguinte função: nome: fn_transferir; recebe: código de cliente remetente, código de conta remetente, código de cliente, destinatário, código de conta destinatário, valor da transferência; devolve: um booleano que indica se a transferência ocorreu ou não. Uma transferência somente pode acontecer se nenhuma conta envolvida ficar no negativo.

CREATE OR REPLACE FUNCTION fn_transferir(
    IN p_cod_cliente_remetente INT,
    IN p_cod_conta_remetente INT,
    IN p_cod_cliente_destinatario INT,
    IN p_cod_conta_destinatario INT,
    IN p_valor_transferencia NUMERIC(10, 2)
) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_saldo_remetente NUMERIC(10, 2);
    v_saldo_destinatario NUMERIC(10, 2);
BEGIN
    SELECT saldo INTO v_saldo_remetente FROM tb_conta
	WHERE cod_cliente = p_cod_cliente_remetente AND cod_conta = p_cod_conta_remetente;
    SELECT saldo INTO v_saldo_destinatario FROM tb_conta
	WHERE cod_cliente = p_cod_cliente_destinatario AND cod_conta = p_cod_conta_destinatario;
	IF
	 	v_saldo_remetente >= p_valor_transferencia AND v_saldo_destinatario + p_valor_transferencia >= 0
	THEN
		UPDATE tb_conta SET saldo = saldo - p_valor_transferencia
		WHERE cod_cliente = p_cod_cliente_remetente AND cod_conta = p_cod_conta_remetente;
        UPDATE tb_conta SET saldo = saldo + p_valor_transferencia
        WHERE cod_cliente = p_cod_cliente_destinatario AND cod_conta = p_cod_conta_destinatario;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;

-- 1.3 Escreva blocos anônimos para testar cada função.

-- 1.1:
DO $$
DECLARE
    v_cod_cliente INT := 1;
    v_cod_conta INT := 2;
    v_saldo NUMERIC(10, 2);
BEGIN
    SELECT fn_consultar_saldo(v_cod_cliente, v_cod_conta) INTO v_saldo;
    IF v_saldo IS NOT NULL THEN
        RAISE NOTICE 'cliente: % - conta: % - saldo: R$%', v_cod_cliente, v_cod_conta, v_saldo;
    ELSE
        RAISE NOTICE 'cliente: % - conta: % - conta não encontrada', v_cod_cliente, v_cod_conta;
    END IF;
END;
$$;

-- 1.2:
-- criando outra conta pra testar
DO $$
DECLARE
	v_cod_cliente INT := 2;
	v_saldo NUMERIC (10, 2) := 1000;
	v_cod_tipo_conta INT := 1;
	v_resultado BOOLEAN;
BEGIN
SELECT fn_abrir_conta (v_cod_cliente, v_saldo, v_cod_tipo_conta) INTO v_resultado;
	RAISE NOTICE '%', format('Conta com saldo R$%s%s foi aberta', v_saldo, CASE WHEN v_resultado THEN '' ELSE ' não' END);
	v_saldo := 1000;
	SELECT fn_abrir_conta (v_cod_cliente, v_saldo, v_cod_tipo_conta) INTO v_resultado;
	RAISE NOTICE '%', format('Conta com saldo R$%s%s foi aberta', v_saldo, CASE WHEN v_resultado THEN '' ELSE ' não' END);
END;
$$
-- testando fn_transferir
DO $$
DECLARE
    v_cod_cliente_remetente INT := 1;
    v_cod_conta_remetente INT := 2;
    v_cod_cliente_destinatario INT := 2;
    v_cod_conta_destinatario INT := 3;
    v_valor_transferencia NUMERIC(10, 2) := 100;
    v_saldo_remetente NUMERIC(10, 2);
    v_saldo_destinatario NUMERIC(10, 2);
	v_resultado BOOLEAN;
BEGIN
    SELECT fn_transferir(
        v_cod_cliente_remetente,
        v_cod_conta_remetente,
        v_cod_cliente_destinatario,
        v_cod_conta_destinatario,
        v_valor_transferencia
    ) INTO v_resultado;

    IF v_resultado THEN
        SELECT saldo INTO v_saldo_remetente FROM tb_conta WHERE cod_cliente = v_cod_cliente_remetente AND cod_conta = v_cod_conta_remetente;
        SELECT saldo INTO v_saldo_destinatario FROM tb_conta WHERE cod_cliente = v_cod_cliente_destinatario AND cod_conta = v_cod_conta_destinatario;
        RAISE NOTICE 'Transferência de R$%s realizada', v_valor_transferencia;
        RAISE NOTICE 'Novo saldo do remetente (cliente %, conta %): R$%', v_cod_cliente_remetente, v_cod_conta_remetente, v_saldo_remetente;
        RAISE NOTICE 'Novo saldo do destinatário (cliente %, conta %): R$%', v_cod_cliente_destinatario, v_cod_conta_destinatario, v_saldo_destinatario;
    ELSE
        RAISE NOTICE 'Transferência de R$%s não realizada', v_valor_transferencia;
    END IF;
END;
$$;