# Sistema de Inventário em Haskell

**Pontifícia Universidade Católica do Paraná (PUCPR)**  
**Disciplina:** Programação Lógica e Funcional   

**Integrantes do Grupo:**
1. Alex Menegatti Secco - GitHub: [@alemsecco](https://github.com/alemsecco)
2. Bruno Betiatto Alves - GitHub: [@Brunobetiatto](https://github.com/Brunobetiatto)
3. Mariana de Castro - GitHub: [@maricastroo](https://github.com/maricastroo)
4. Vitor Rodrigues Izidoro - GitHub: [@Vitor-Izidoro](https://github.com/Vitor-Izidoro)

## Ambiente de Execução
**Link para o código executável:** https://onlinegdb.com/oHbG4vAH7

## Como Compilar e Executar
1. Acesse o link do ambiente de execução acima.
2. Clique no botão "Run" (GDB/Repl.it).
3. O sistema carregará automaticamente o estado anterior (se existir).
4. Utilize os números do menu no terminal para interagir com o sistema.

## Exemplo de Uso dos Comandos

Ao iniciar o programa, o menu principal será exibido. Para interagir, digite o número correspondente à opção desejada e pressione `Enter`.

**Exemplo: Adicionando um Item**
1. No menu principal, digite `1` e pressione `Enter`.
2. O sistema solicitará os dados passo a passo:
   - `ID do Item:` (Ex: 001)
   - `Nome do Item:` (Ex: Monitor)
   - `Quantidade inicial:` (Ex: 20)
   - `Categoria:` (Ex: Eletronicos)
3. O sistema confirmará a operação: `>>> Sucesso! Operacao realizada e salva no disco.`

**Exemplo: Gerando um Relatório**
1. No menu principal, digite `5` (Relatórios) e pressione `Enter`.
2. No submenu, digite `A` para buscar o histórico de um item (opção deve ser digitada em maiúscula).
3. Digite o termo de busca (Ex: `Monitor` ou `001`).
4. O sistema listará todas as ações (adição, remoção, atualização) vinculadas a esse item, extraídas do `Auditoria.log`.

## Documentação dos Cenários de Teste Manuais
O sistema foi populado com 10 itens iniciais para validação das lógicas de estoque e persistência.

### Cenário 1: Persistência de Estado (Sucesso)
- **Passos executados:** O programa foi iniciado sem arquivos `.dat` e `.log`. Três itens foram adicionados via menu. O programa foi encerrado e reiniciado.

```
Sistema iniciado. 0 item(ns) carregado(s) da memoria.

===============================
    SISTEMA DE INVENTARIO
===============================
1. Adicionar novo item
2. Remover quantidade de um item
3. Atualizar quantidade de um item
4. Buscar item
5. Relatorios
6. Sair
Escolha uma opcao: 1
ID do Item: 001
Nome do Item: caneta
Quantidade inicial: 4
Categoria: papelaria

>>> Sucesso! Operacao realizada e salva no disco.

===============================
    SISTEMA DE INVENTARIO
===============================
1. Adicionar novo item
2. Remover quantidade de um item
3. Atualizar quantidade de um item
4. Buscar item
5. Relatorios
6. Sair
Escolha uma opcao: 1
ID do Item: 002
Nome do Item: teclado
Quantidade inicial: 10
Categoria: eletronicos

>>> Sucesso! Operacao realizada e salva no disco.

===============================
    SISTEMA DE INVENTARIO
===============================
1. Adicionar novo item
2. Remover quantidade de um item
3. Atualizar quantidade de um item
4. Buscar item
5. Relatorios
6. Sair
Escolha uma opcao: 1
ID do Item: 003
Nome do Item: jaqueta
Quantidade inicial: 6
Categoria: roupas

>>> Sucesso! Operacao realizada e salva no disco.

===============================
    SISTEMA DE INVENTARIO
===============================
1. Adicionar novo item
2. Remover quantidade de um item
3. Atualizar quantidade de um item
4. Buscar item
5. Relatorios
6. Sair
Escolha uma opcao: 6

Encerrando o sistema. Ate logo!
```

- **Resultado:** Os arquivos `Inventario.dat` e `Auditoria.log` foram criados no disco. Ao reiniciar, o sistema exibiu a mensagem de carregamento de 3 itens com sucesso. A busca confirmou a presença dos dados em memória.

Auditoria.log:
```
LogEntry {timestamp = 2026-06-13 03:02:29.17060807 UTC, acao = Add, detalhes = "Adicionado item: caneta", status = Sucesso}
LogEntry {timestamp = 2026-06-13 03:02:44.90499465 UTC, acao = Add, detalhes = "Adicionado item: teclado", status = Sucesso}
LogEntry {timestamp = 2026-06-13 03:03:04.726056082 UTC, acao = Add, detalhes = "Adicionado item: jaqueta", status = Sucesso}
```
Inventario.dat:
```
fromList [("001",Item {itemID = "001", nome = "caneta", quantidade = 4, categoria = "papelaria"}),("002",Item {itemID = "002", nome = "teclado", quantidade = 10, categoria = "eletronicos"}),("003",Item {itemID = "003", nome = "jaqueta", quantidade = 6, categoria = "roupas"})]
```

### Cenário 2: Erro de Lógica (Estoque Insuficiente)
- **Passos executados:** Foi adicionado um item "teclado" (ID: 002) com 10 unidades. Em seguida, foi solicitada a remoção de 15 unidades deste item.
- **Resultado:** O sistema bloqueou a operação e exibiu a mensagem de erro clara no terminal (`Erro: Estoque insuficiente...`). O inventário não foi alterado (permaneceu com 10) e a falha foi registrada no arquivo de auditoria.

```
Sistema iniciado. 3 item(ns) carregado(s) da memoria.

===============================
    SISTEMA DE INVENTARIO
===============================
1. Adicionar novo item
2. Remover quantidade de um item
3. Atualizar quantidade de um item
4. Buscar item
5. Relatorios
6. Sair
Escolha uma opcao: 2
ID do Item para remocao: 002
Quantidade a remover: 15

>>> FALHA: Erro: Estoque insuficiente para remover a quantidade solicitada.
```

### Cenário 3: Geração de Relatório de Erros
- **Passos executados:** Após o Cenário 2, acessamos o menu de relatórios (Opção 5) e executamos o subcomando `B` (Relatório de Erros).
- **Resultado:** A função `logsDeErro` processou o `Auditoria.log` e listou com sucesso a entrada registrada no cenário anterior, confirmando o status `Falha Estoque insuficiente para remover a quantidade solicitada.`.

```
===============================
    SISTEMA DE INVENTARIO
===============================
1. Adicionar novo item
2. Remover quantidade de um item
3. Atualizar quantidade de um item
4. Buscar item
5. Relatorios
6. Sair
Escolha uma opcao: 5

--- Módulo de Relatórios ---
A. Historico de um Item
B. Relatorio de Erros (Falhas)
Escolha o relatorio (A/B): B

>>> RELATORIO DE ERROS ENCONTRADOS:
[2026-06-13 03:12:23.72604834 UTC] ACAO: Remove | DETALHES: Erro: Estoque insuficiente para remover a quantidade solicitada. | STATUS: Falha "Erro: Estoque insuficiente para remover a quantidade solicitada."
```

