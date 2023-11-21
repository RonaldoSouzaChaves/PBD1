import psycopg as ps2

class Usuario:
    def __init__(self, login, senha):
        self.login = login
        self.senha = senha

def existe(usuario):
    #abre a conexao com o postgresql
    with ps2.connect(
        host='localhost',
        port='5432',
        dbname='20232_pbdi_login_python',
        user='postgres',
        password='123456'
    ) as conexao:
        #obter um cursor
        with conexao.cursor() as cursor:
            #usando o cursor, executar um comando SELECT
            cursor.execute(
                'SELECT * FROM tb_usuario WHERE login = %s AND senha = %s',
                (usuario.login, usuario.senha))
            #usando o cursor, verificar o resultado
            resultado = cursor.fetchone()
            #devolve True or False
            return resultado != None

usuario = Usuario('admin', 'admin')
print(existe(usuario))

def inserir(usuario):
    #abre a conexao com o postgresql
    with ps2.connect(
        host='localhost',
        port='5432',
        dbname='20232_pbdi_login_python',
        user='postgres',
        password='123456'
    ) as conexao:
        print(conexao)
        #obter um cursor
        with conexao.cursor() as cursor:
            #usando o cursor, executar um comando INSERT
            cursor.execute(
                'INSERT INTO tb_usuario (login, senha) VALUES (%s, %s)',
                (usuario.login, usuario.senha))

def menu():
    texto = "1-Login\n2-Logoff\n3-Inserir\n0-Sair: "
    usuario = None
    opcao = int(input(texto))
    
    while opcao != 0:
        if opcao == 1:
            login = input('informe o login: ')
            senha = input('informe a senha: ')
            usuario = Usuario(login,senha)
            #exibir Usuario OK ou Usuário NOK de acordo com o método existe. Use o operador ternário
            print('Usuário OK' if existe(usuario) else 'Usuario NOK')
        #se ele digitar 2, configuramos o usuario como "None" novamente
        elif opcao == 2:
            usuario = None
            print('Logoff OK')
        elif opcao == 3:
            login = input('informe o login: ')
            senha = input('informe a senha: ')
            usuario = Usuario(login,senha)
            inserir(usuario)
        opcao = int(input(texto))
    else:
        print('programa encerrado')

menu()