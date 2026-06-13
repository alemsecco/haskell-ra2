module Logica where

-- Importa o arquivo do Aluno 1
import Tipos

import qualified Data.Map as Map
import Data.Time.Clock (UTCTime)

-- 1. Lógica para Adicionar Item
addItem :: UTCTime -> Item -> Inventario -> Either String ResultadoOperacao
addItem tempo atualItem inv =
    let idItem = itemID atualItem
    in if Map.member idItem inv
       then Left "Erro: Item ja existe no inventario. Use a atualizacao."
       else
           let novoInv = Map.insert idItem atualItem inv
               logEntry = LogEntry tempo Add ("Adicionado item: " ++ nome atualItem) Sucesso
           in Right (novoInv, logEntry)

-- 2. Lógica para Remover Quantidade de um Item
removeItem :: UTCTime -> String -> Int -> Inventario -> Either String ResultadoOperacao
removeItem tempo idRemover qtdRemover inv =
    case Map.lookup idRemover inv of
        Nothing -> Left "Erro: Item nao encontrado no inventario."
        Just itemAtual ->
            if qtdRemover <= 0
            then Left "Erro: Quantidade para remocao deve ser maior que zero."
            else if quantidade itemAtual < qtdRemover
                 then Left "Erro: Estoque insuficiente para remover a quantidade solicitada."
                 else
                    let novaQuantidade = quantidade itemAtual - qtdRemover
                        itemAtualizado = itemAtual { quantidade = novaQuantidade }
                        novoInv =
                            if novaQuantidade == 0
                            then Map.delete idRemover inv
                            else Map.insert idRemover itemAtualizado inv
                        logEntry = LogEntry tempo Remove ("Removidas " ++ show qtdRemover ++ " unidade(s) de: " ++ nome itemAtual) Sucesso
                    in Right (novoInv, logEntry)

-- 3. Lógica para Atualizar a Quantidade de um Item
updateQty :: UTCTime -> String -> Int -> Inventario -> Either String ResultadoOperacao
updateQty tempo idAtualizar novaQuantidade inv =
    case Map.lookup idAtualizar inv of
        Nothing -> Left "Erro: Item nao encontrado no inventario."
        Just itemAtual ->
            if novaQuantidade < 0
            then Left "Erro: Quantidade atualizada nao pode ser negativa."
            else
                let itemAtualizado = itemAtual { quantidade = novaQuantidade }
                    novoInv =
                        if novaQuantidade == 0
                        then Map.delete idAtualizar inv
                        else Map.insert idAtualizar itemAtualizado inv
                    logEntry = LogEntry tempo Update ("Atualizada quantidade de " ++ nome itemAtual ++ " para " ++ show novaQuantidade) Sucesso
                in Right (novoInv, logEntry)

-- 4. Lógica para Consultar um Item no Inventário
buscarItem :: String -> Inventario -> Either String Item
buscarItem idBusca inv =
    case Map.lookup idBusca inv of
        Nothing -> Left "Erro: Item nao encontrado no inventario."
        Just itemEncontrado -> Right itemEncontrado
