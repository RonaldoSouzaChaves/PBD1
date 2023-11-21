-- 1: base de dados e criação de tabela

CREATE TABLE winemag(
	codWine SERIAL PRIMARY KEY,
	country VARCHAR(200),
	description VARCHAR(5000),
	points INT,
	price NUMERIC(6, 2)
);

SELECT * FROM winemag;

-- 2: cursor não vinculado
DO
$$
DECLARE
	cur_cursor REFCURSOR;
	v_pais VARCHAR(200);
	v_preco_medio NUMERIC(6,2);
	v_tabela VARCHAR(200) := 'winemag';
BEGIN
	OPEN cur_cursor FOR EXECUTE
		format('SELECT country as pais, AVG(price) as preco_medio FROM %s WHERE country IS NOT NULL GROUP BY country', v_tabela);
	LOOP
		FETCH cur_cursor INTO v_pais, v_preco_medio;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '%, %', v_pais, v_preco_medio;
	END LOOP;
	CLOSE cur_cursor;
END;
$$

-- 3: cursor vinculado

DO
$$
DECLARE
	cur_vinculado CURSOR FOR
		SELECT country AS pais, MAX(description) AS maior_descricao FROM winemag WHERE country is NOT NULL GROUP BY country;
	v_pais VARCHAR(200);
	v_maior_descricao VARCHAR(5000);
BEGIN
	OPEN cur_vinculado;
	LOOP
		FETCH cur_vinculado INTO v_pais, v_maior_descricao;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '%: %', v_pais, v_maior_descricao;
	END LOOP;
	CLOSE cur_vinculado;
END;
$$

-- 4 armazenamento dos resultados

CREATE TABLE tabelaResultante(
	id SERIAL PRIMARY KEY,
	nome_pais VARCHAR(200),
	preco_medio NUMERIC(6,2),
	descricao_mais_longa VARCHAR(5000)
);

DO
$$
DECLARE
	v_pais VARCHAR(200);
	cur_cursor REFCURSOR;
	v_preco_medio NUMERIC(6,2);
	v_maior_descricao VARCHAR(5000);
	v_tabela VARCHAR(200) := 'winemag';
BEGIN
	OPEN cur_cursor FOR EXECUTE
		format('SELECT country as pais, AVG(price) as preco_medio, MAX(description) AS maior_descricao FROM %s WHERE country IS NOT NULL GROUP BY country', v_tabela);
	LOOP
		FETCH cur_cursor INTO v_pais, v_preco_medio, v_maior_descricao;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE '%: %, %', v_pais, v_preco_medio, v_maior_descricao;
		INSERT INTO tabelaResultante (nome_pais, preco_medio, descricao_mais_longa) VALUES (v_pais, v_preco_medio, v_maior_descricao);
	END LOOP;
	CLOSE cur_cursor;
END;
$$

SELECT * FROM tabelaResultante;