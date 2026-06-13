module Relatorios where

import Tipos
import Data.List (isInfixOf)

-- Lógica pura de relatórios 

-- 1. Filtra os logs para mostrar apenas os erros (Falhas)
logsDeErro :: [LogEntry] -> [LogEntry]
logsDeErro = filter ehFalha
  where
    ehFalha log = case status log of
        Falha _ -> True
        _       -> False

-- 2. Filtra o histórico de operações de um item específico
-- Busca pelo termo (Nome ou ID) dentro da string de detalhes do log
historicoPorItem :: String -> [LogEntry] -> [LogEntry]
historicoPorItem termo = filter (\log -> termo `isInfixOf` detalhes log)

-- 3. Formata uma lista de logs para exibição no terminal
formatarLogs :: [LogEntry] -> String
formatarLogs [] = "Nenhum registro encontrado."
formatarLogs logs = unlines $ map formatarLog logs
  where
    formatarLog log = 
        "[" ++ show (timestamp log) ++ "] " ++
        "ACAO: " ++ show (acao log) ++ " | " ++
        "DETALHES: " ++ detalhes log ++ " | " ++
        "STATUS: " ++ show (status log)