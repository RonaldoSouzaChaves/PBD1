-- 1 Base de dados e criação de tabela: A base a ser utilizada é a 16_Top YouTube Channels Data.csv. Ela deve ser importada para uma base de dados gerenciada pelo PostgreSQL. Os dados devem ser armazenados em uma tabela apropriada para as análises desejadas. Ela deve incluir colunas para todos os campos existentes no arquivo csv, além, é claro, de uma chave primária (de auto incremento).

DROP TABLE youtubers;

CREATE TABLE IF NOT EXISTS youtubers (
	codTopYoutubers SERIAL PRIMARY KEY,
	rank INT,
	youtuber VARCHAR(200),
	subscribers INT,
	videoViews BIGINT,
	videoCount INT,
	category VARCHAR(200),
	started INT
);

SELECT * FROM youtubers;

-- 2 Trigger: Escreva um trigger com as seguintes características: executa antes de operações insert e de operações update; nível row; não admite que quaisquer campos numéricos possuam valor negativo.

CREATE OR REPLACE FUNCTION fnNegativoJamais() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF
		NEW.codtopyoutubers < 0 OR NEW.rank < 0 OR NEW.subscribers < 0 OR NEW.videoviews < 0 OR NEW.videocount < 0 OR NEW.started < 0 THEN
		RAISE NOTICE 'números negativos jamais';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END;
$$;

CREATE OR REPLACE TRIGGER tgNegativoJamais
BEFORE INSERT OR UPDATE ON youtubers
FOR EACH ROW
EXECUTE PROCEDURE fnNegativoJamais();

INSERT INTO youtubers (rank) VALUES (-20);

-- 3 Alter table: Escreva um script que altera a estrutura da tabela de armazenamento de dados de youtubers. Ela deve possuir uma coluna chamada “ativo”. Os valores válidos devem ser 0 e 1. Garanta isso com um “CHECK”. Inclua também um DEFAULT 1.

ALTER TABLE youtubers ADD COLUMN ativo INT DEFAULT 1;

ALTER TABLE youtubers 
ADD CONSTRAINT checkAtivo 
CHECK (ativo = 0 OR ativo = 1);

INSERT INTO youtubers (ativo) VALUES (3);

-- 4 Tabela de log: Escreva um script para criação de uma tabela de log, com as seguintes características: colunas para nome do youtuber, categoria do canal e ano de início, além, é claro, de uma chave primária (de auto incremento).

CREATE TABLE IF NOT EXISTS tbLog (
    codLog SERIAL PRIMARY KEY,
    nomeYoutuber VARCHAR(200),
    categoriaCanal VARCHAR(200),
	anoInicio INT
);

SELECT * FROM tbLog;

-- 5 Trigger: Escreva um trigger com as seguintes características: executa antes de operações delete; nível row; não admite que dados da tabela youtuber sejam removidos; quando uma operação delete acontece, essa tentativa é registrada na tabela de logs, com todos os campos existentes na tabela de logs; O campo ativo passa a valer 0.

CREATE OR REPLACE FUNCTION fnRemocoes() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.ativo = 1 THEN
	INSERT INTO tbLog (nomeYoutuber, categoriaCanal, anoInicio) VALUES (OLD.youtuber,OLD.category,OLD.started);
	UPDATE youtubers SET ativo = 0 WHERE codTopYoutubers = OLD.codTopYoutubers;
    RETURN NULL;
	END IF;
END;
$$;

CREATE OR REPLACE TRIGGER tgRemocoes
BEFORE DELETE ON youtubers
FOR EACH ROW
EXECUTE FUNCTION fnRemocoes();

DELETE FROM youtubers WHERE codTopYoutubers = 1;

select * from tbLog;