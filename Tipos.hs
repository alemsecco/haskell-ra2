module Tipos where

import Data.Map (Map)
import Data.Time.Clock (UTCTime)

-- item: Registro basico do dominio
data Item = Item {
    itemID     :: String,
    nome       :: String,
    quantidade :: Int,
    categoria  :: String
} deriving (Show, Read, Eq)

-- inventario: Estrutura de dados para armazenar os itens
type Inventario = Map String Item

-- acaoLog: Tipo de dado algebrico (ADT) para as acoes
data AcaoLog = Add
             | Remove
             | Update
             | QueryFail
             deriving (Show, Read, Eq)

-- statusLog: ADT para o resultado da operacao
data StatusLog = Sucesso
               | Falha String
               deriving (Show, Read, Eq)

-- logEntry: Registro completo para auditoria
data LogEntry = LogEntry {
    timestamp :: UTCTime,
    acao      :: AcaoLog,
    detalhes  :: String,
    status    :: StatusLog
} deriving (Show, Read, Eq)

-- O resultado de uma operacao bem-sucedida sempre devolve o inventario atualizado e o log.
type ResultadoOperacao = (Inventario, LogEntry)
