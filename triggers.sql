DROP TABLE IF EXISTS tb_pessoa;

CREATE TABLE IF NOT EXISTS tb_pessoa (
	cod_pessoa SERIAL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL,
	idade INT NOT NULL,
	saldo NUMERIC(10, 2) NOT NULL
);

DROP TABLE IF EXISTS tb_auditoria;

CREATE TABLE IF NOT EXISTS tb_auditoria (
	cod_auditoria SERIAL PRIMARY KEY,
	cod_pessoa INT NOT NULL,
	idade INT NOT NULL,
	saldo_antigo NUMERIC (10, 2),
	saldo_atual NUMERIC(10, 2)
);

CREATE OR REPLACE FUNCTION fn_validador_de_saldo() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.saldo >= 0 THEN
		RETURN NEW;
	ELSE
		RAISE NOTICE 'Valor de saldo R$% inválido', NEW.saldo;
		RETURN NULL;
	END IF;
END;
$$

CREATE TRIGGER tg_validador_de_saldo
BEFORE INSERT OR UPDATE ON tb_pessoa
FOR EACH ROW
EXECUTE PROCEDURE fn_validador_de_saldo()

INSERT INTO tb_pessoa (nome, idade, saldo) VALUES ('João', 20, 100), ('Pedro', 22, -100), ('Maria', 22, 400);

SELECT * FROM tb_pessoa;

CREATE OR REPLACE FUNCTION fn_log_pessoa_insert() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_auditoria (cod_pessoa, idade, saldo_antigo, saldo_atual) VALUES (NEW.cod_pessoa, NEW.idade, NULL, NEW.saldo);
	RETURN NULL;
END;
$$

CREATE OR REPLACE TRIGGER tg_log_pessoa_insert
AFTER INSERT ON tb_pessoa
FOR EACH ROW
EXECUTE PROCEDURE fn_log_pessoa_insert()

INSERT INTO tb_pessoa (nome, idade, saldo) VALUES ('João', 20, 100), ('Pedro', 22, 100), ('Maria', 22, 400);

SELECT * FROM tb_auditoria;

CREATE OR REPLACE FUNCTION fn_log_pessoa_update() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_auditoria (cod_pessoa, nome, idade, saldo_antigo, saldo_atual) VALUES (NEW.cod_pessoa, NEW.nome, NEW.idade, OLD.saldo, NEW.saldo);
	RETURN NEW;
END;
$$

-- 1.1 Adicione uma coluna à tabela tb_pessoa chamada ativo. Ela indica se a pessoa está ativa no sistema ou não. Ela deve ser capaz de armazenar um valor booleano. Por padrão, toda pessoa cadastrada no sistema está ativa. Se necessário, consulte o link: https://www.postgresql.org/docs/current/sql-altertable.html

ALTER TABLE tb_pessoa ADD COLUMN ativo BOOLEAN DEFAULT TRUE;

SELECT * FROM tb_pessoa;

-- 1.2 Associe um trigger de DELETE à tabela. Quando um DELETE for executado, o trigger deve atribuir FALSE à coluna ativo das linhas envolvidas. Além disso, o trigger não deve permitir que nenhuma pessoa seja removida.

CREATE OR REPLACE FUNCTION fn_deleta_pessoa() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE tb_pessoa SET ativo = FALSE WHERE cod_pessoa = OLD.cod_pessoa;
    RETURN NULL;
END;
$$;

CREATE TRIGGER tg_deleta_pessoa
BEFORE DELETE ON tb_pessoa
FOR EACH ROW
EXECUTE PROCEDURE fn_deleta_pessoa();