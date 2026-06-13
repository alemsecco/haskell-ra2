module Main where

-- Importa os arquivos 
import Tipos
import Logica
import Relatorios

import qualified Data.Map as Map
import Data.Time.Clock (UTCTime, getCurrentTime)
import System.IO
import Control.Exception (catch, IOException, evaluate)
import Text.Read (readMaybe)


-- TRATAMENTO DE EXCEÇÃO E LEITURA 

tratandoErroLeitura :: IOException -> IO String
tratandoErroLeitura _ = return ""

-- Lê o arquivo e força o fechamento imediato para evitar "file is locked"
lerArquivoEstrito :: FilePath -> IO String
lerArquivoEstrito caminho = catch (do
    conteudo <- readFile caminho
    -- O 'evaluate (length conteudo)' obriga o Haskell a varrer o arquivo 
    -- até o final (EOF), o que automaticamente fecha e destrava o arquivo.
    _ <- evaluate (length conteudo) 
    return conteudo
  ) tratandoErroLeitura


-- PERSISTÊNCIA DE DADOS E LOGS

salvarEstado :: Inventario -> LogEntry -> IO ()
salvarEstado inv logEntry = do
    writeFile "Inventario.dat" (show inv)
    appendFile "Auditoria.log" (show logEntry ++ "\n")

registrarFalhaLog :: LogEntry -> IO ()
registrarFalhaLog logEntry =
    appendFile "Auditoria.log" (show logEntry ++ "\n")


-- FUNÇÕES AUXILIARES DE I/O

lerEntrada :: String -> IO String
lerEntrada prompt = do
    putStr prompt
    hFlush stdout
    getLine

processarResultado :: AcaoLog -> UTCTime -> Inventario -> Either String ResultadoOperacao -> IO ()
processarResultado acao tempo invAtual resultado = case resultado of
    Right (novoInv, logGerado) -> do
        salvarEstado novoInv logGerado
        putStrLn "\n>>> Sucesso! Operacao realizada e salva no disco."
        loop novoInv
    Left erroMsg -> do
        let logFalha = LogEntry tempo acao erroMsg (Falha erroMsg)
        registrarFalhaLog logFalha
        putStrLn $ "\n>>> FALHA: " ++ erroMsg
        loop invAtual


-- LOOP INTERATIVO

loop :: Inventario -> IO ()
loop inv = do
    putStrLn "\n==============================="
    putStrLn "    SISTEMA DE INVENTARIO"
    putStrLn "==============================="
    putStrLn "1. Adicionar novo item"
    putStrLn "2. Remover quantidade de um item"
    putStrLn "3. Atualizar quantidade de um item"
    putStrLn "4. Buscar item"
    putStrLn "5. Relatorios"
    putStrLn "6. Sair"
    
    opcao <- lerEntrada "Escolha uma opcao: "
    tempoAtual <- getCurrentTime

    case opcao of
        "1" -> do
            idItem <- lerEntrada "ID do Item: "
            nomeItem <- lerEntrada "Nome do Item: "
            qtdStr <- lerEntrada "Quantidade inicial: "
            catItem <- lerEntrada "Categoria: "
            
            case readMaybe qtdStr :: Maybe Int of
                Just qtd -> do
                    let novoItem = Item idItem nomeItem qtd catItem
                    processarResultado Add tempoAtual inv (addItem tempoAtual novoItem inv)
                Nothing -> do
                    putStrLn "\n>>> ERRO: A quantidade deve ser um numero inteiro."
                    loop inv

        "2" -> do
            idItem <- lerEntrada "ID do Item para remocao: "
            qtdStr <- lerEntrada "Quantidade a remover: "
            
            case readMaybe qtdStr :: Maybe Int of
                Just qtd -> 
                    processarResultado Remove tempoAtual inv (removeItem tempoAtual idItem qtd inv)
                Nothing -> do
                    putStrLn "\n>>> ERRO: A quantidade deve ser um numero inteiro."
                    loop inv

        "3" -> do
            idItem <- lerEntrada "ID do Item para atualizar: "
            qtdStr <- lerEntrada "Nova quantidade total: "
            
            case readMaybe qtdStr :: Maybe Int of
                Just qtd -> 
                    processarResultado Update tempoAtual inv (updateQty tempoAtual idItem qtd inv)
                Nothing -> do
                    putStrLn "\n>>> ERRO: A quantidade deve ser um numero inteiro."
                    loop inv

        "4" -> do
            idItem <- lerEntrada "ID do Item que deseja buscar: "
            case buscarItem idItem inv of
                Right itemEncontrado -> do
                    putStrLn $ "\n>>> ITEM ENCONTRADO: " ++ show itemEncontrado
                    let logBusca = LogEntry tempoAtual Add ("Busca pelo item " ++ idItem) Sucesso
                    appendFile "Auditoria.log" (show logBusca ++ "\n")
                    loop inv
                Left erroMsg -> do
                    let logFalha = LogEntry tempoAtual QueryFail erroMsg (Falha erroMsg)
                    registrarFalhaLog logFalha
                    putStrLn $ "\n>>> FALHA: " ++ erroMsg
                    loop inv

        "5" -> do
            putStrLn "\n--- Módulo de Relatórios ---"
            putStrLn "A. Historico de um Item"
            putStrLn "B. Relatorio de Erros (Falhas)"
            
            subOpcao <- lerEntrada "Escolha o relatorio (A/B): "
            
            conteudoLog <- lerArquivoEstrito "Auditoria.log"
            
            let linhasLog = lines conteudoLog
                logsCarregados = map read linhasLog :: [LogEntry]
            
            case subOpcao of
                "A" -> do
                    termo <- lerEntrada "Digite o nome ou ID do item para buscar no historico: "
                    let logsFiltrados = historicoPorItem termo logsCarregados
                    putStrLn "\n>>> HISTORICO DO ITEM:"
                    putStrLn $ formatarLogs logsFiltrados
                    loop inv
                "B" -> do
                    let erros = logsDeErro logsCarregados
                    putStrLn "\n>>> RELATORIO DE ERROS ENCONTRADOS:"
                    putStrLn $ formatarLogs erros
                    loop inv
                _ -> do
                    putStrLn "\n>>> Opcao de relatorio invalida."
                    loop inv

        "6" -> putStrLn "\nEncerrando o sistema. Ate logo!"

        _ -> do
            putStrLn "\n>>> Opcao invalida. Tente novamente."
            loop inv


-- INICIALIZAÇÃO DO SISTEMA

main :: IO ()
main = do
    conteudoInv <- lerArquivoEstrito "Inventario.dat"
    _ <- lerArquivoEstrito "Auditoria.log"

    let invInicial = if conteudoInv == ""
                     then Map.empty
                     else read conteudoInv :: Inventario

    putStrLn $ "\nSistema iniciado. " ++ show (Map.size invInicial) ++ " item(ns) carregado(s) da memoria."
    loop invInicial