CREATE TABLE IF NOT EXISTS tb_conta (
	cod_conta SERIAL PRIMARY KEY,
	nome VARCHAR(200),
	saldo NUMERIC(10, 2)
);

INSERT INTO tb_conta (nome, saldo) VALUES ('João', 200), ('Maria', 200), ('Pedro', 200), ('Cristina', 200), ('Fernanda', 200);

BEGIN;

UPDATE tb_conta saldo = saldo + 50 WHERE nome = 'Cristina';

UPDATE tb_conta SET saldo = saldo + 50 WHERE nome = 'Cristina';

ROLLBACK;

BEGIN;
UPDATE tb_conta SET saldo = saldo + 50 WHERE nome = 'Cristina';
COMMIT;

BEGIN;
UPDATE tb_conta SET saldo = saldo + 250 WHERE nome = 'Maria';
COMMIT;

BEGIN;
UPDATE tb_conta SET saldo = saldo - 250 WHERE nome = 'Fernanda';
COMMIT;

SELECT * FROM tb_conta;

BEGIN;
UPDATE tb_conta SET saldo = 500;

SAVEPOINT saldos_em_500;

UPDATE tb_conta SET saldo = saldo - 100 WHERE nome = 'Fernanda';

UPDATE tb_conta SET saldo = saldo + 100 WHERE nome = 'Maria';

SAVEPOINT fernanda_para_maria;

UPDATE tb_conta SET saldo = saldo - 50 WHERE nome = 'Maria';

UPDATE tb_conta SET saldo = saldo + 50 WHERE nome = 'Cristina';

ROLLBACK TO fernanda_para_maria;
COMMIT;

SELECT * FROM tb_conta;