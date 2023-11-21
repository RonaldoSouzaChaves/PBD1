CREATE TABLE tbUsuario(
	codUsuario SERIAL PRIMARY KEY,
	login VARCHAR(200) NOT NULL,
	senha VARCHAR(200) NOT NULL
);
	
INSERT INTO tbUsuario (login, senha) VALUES ('admin', 'admin'), ('joao', '123456');

SELECT * FROM tbUsuario;