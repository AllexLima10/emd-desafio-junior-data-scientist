# 1 Quantos chamados foram abertos no dia 01/04/2023?
SELECT 
  COUNT(id_chamado)
 FROM `datario.adm_central_atendimento_1746.chamado` 
 WHERE data_particao = "2023-04-01";


# 2 Qual o tipo de chamado que teve mais teve chamados abertos no dia 01/04/2023?
SELECT
  tipo,
  COUNT(id_chamado) AS numero_chamados
FROM `datario.adm_central_atendimento_1746.chamado` 
 WHERE data_particao = "2023-04-01"
GROUP BY tipo
ORDER BY COUNT(id_chamado) DESC
LIMIT 1;


# 3 Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

SELECT
  b.nome,
  COUNT(id_chamado) AS numero_chamados
FROM `datario.adm_central_atendimento_1746.chamado` as c LEFT JOIN `datario.dados_mestres.bairro` as b ON c.id_bairro = b.id_bairro
 WHERE data_particao = "2023-04-01" AND b.nome IS NOT NULL
GROUP BY b.nome
ORDER BY COUNT(id_chamado) DESC
LIMIT 3;



# 4 Qual o nome da subprefeitura com mais chamados abertos nesse dia?
SELECT
  b.subprefeitura,
  COUNT(id_chamado) AS numero_chamados
FROM `datario.adm_central_atendimento_1746.chamado` as c LEFT JOIN `datario.dados_mestres.bairro` as b ON c.id_bairro = b.id_bairro
 WHERE data_particao = "2023-04-01" AND b.subprefeitura IS NOT NULL
GROUP BY b.subprefeitura
ORDER BY COUNT(id_chamado) DESC
LIMIT 1;




# 5 Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?

SELECT *
FROM `datario.adm_central_atendimento_1746.chamado` as c LEFT JOIN `datario.dados_mestres.bairro` as b ON c.id_bairro = b.id_bairro
 WHERE data_particao = "2023-04-01" AND b.subprefeitura IS  NULL
LIMIT 10;


# 6 Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?

SELECT COUNT(*) as Numero_chamados
FROM `datario.adm_central_atendimento_1746.chamado` 
WHERE data_particao >= "2022-01-01" AND data_particao <= "2023-12-31" AND tipo = "Perturbação do sossego";

# 7 Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio).
SELECT *
FROM `datario.adm_central_atendimento_1746.chamado` as c LEFT JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` as e ON (c.data_inicio BETWEEN e.data_inicial AND e.data_final)
WHERE data_particao >= "2022-01-01" AND data_particao <= "2023-12-31" AND c.tipo = "Perturbação do sossego" AND e.evento IS NOT NULL 
LIMIT 10;


# 8 Quantos chamados desse subtipo foram abertos em cada evento?
SELECT e.evento, COUNT(*)
FROM `datario.adm_central_atendimento_1746.chamado` as c LEFT JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` as e ON (c.data_inicio BETWEEN e.data_inicial AND e.data_final)
WHERE data_particao >= "2022-01-01" AND data_particao <= "2023-12-31" AND c.tipo = "Perturbação do sossego" AND e.evento IS NOT NULL
GROUP BY e.evento;

# 9 Qual evento teve a maior média diária de chamados abertos desse subtipo?
SELECT e.evento, COUNT(*) / DATE_DIFF(MAX(e.data_final), MAX(e.data_inicial), DAY)AS Media_diaria
FROM `datario.adm_central_atendimento_1746.chamado` as c LEFT JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` as e ON (c.data_inicio BETWEEN e.data_inicial AND e.data_final)
WHERE data_inicio >= "2022-01-01" AND data_inicio <= "2023-12-31" AND c.tipo = "Perturbação do sossego" AND e.evento IS NOT NULL
GROUP BY e.evento
ORDER BY Media_diaria DESC
LIMIT 1;

# 10 Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.

SELECT 
    COALESCE(e.evento, 'Sem Evento') AS evento, 
    COUNT(*) / 
    CASE 
        WHEN MAX(e.data_final) IS NOT NULL AND MAX(e.data_inicial) IS NOT NULL 
        THEN DATE_DIFF(MAX(e.data_final), MIN(e.data_inicial), DAY)
        ELSE 715 
    END AS Media_diaria
FROM `datario.adm_central_atendimento_1746.chamado` as c LEFT JOIN `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos` as e ON (c.data_inicio BETWEEN e.data_inicial AND e.data_final)
WHERE data_inicio >= "2022-01-01" AND data_inicio <= "2023-12-31" AND c.tipo = "Perturbação do sossego" 
GROUP BY e.evento
ORDER BY Media_diaria DESC;
