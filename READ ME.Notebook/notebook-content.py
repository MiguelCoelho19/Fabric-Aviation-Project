# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {}
# META }

# MARKDOWN ********************

# # READ ME: Projeto Fabric - Lufthansa API e Aviation Herald

# MARKDOWN ********************

# ## Questões
# - Quantidade de voos
# - Quantidade de voos a partir a horas
# - Quantidades de voos por airlines ao longo do tempo
# - Quantidade de voos por aircraft
# - Percentagem de voos a horas e atrasados por aeroporto
# - Percentagem de voos a horas e atrasados por airline
# - Média da duração dos atrasos
# 
# - Quantidade de Acidentes por airlines
# - Quantidade de Acidentes por localização
# - Quantidade de Acidentes por aircrafts
# - Quantidade de Acidentes ao longo do tempo

# MARKDOWN ********************

# ## Medalhões

# MARKDOWN ********************

# #### Camada Bronze
# ###### Avherald Scrapping Import
# - Feito Semanalmente, 5 páginas ou até atingir informação já obtida,
# - É obtido: Headline type, Headline,
# - Um ficheiro JSON é criado por cada import,
# 
# ###### Lufthansa General Import
# - Feito Mensalmente,
# - Aeroportos: Faro, Lisboa, Porto, Frankfurt, Munique, Dresda,
#     - Lufthansa API não tem informação sobre o aeroporto de Frankfurt, por isso a informação foi adicionada manualmente,
# - Cidades: Faro, Lisboa, Porto, Frankfurt, Munique, Dresda,
# - Todos os países, airlines, aircrafts,
# - Ficheiros JSON existentes serão substituídos por cada import,
# 
# ###### Lufthansa Schedule Import
# - Feito Semanalmente,
# - Todos os Schedules de todas as rotas entre os aeroportos previamente mencionados para todos os dias desta semana,
# - Um ficheiro JSON é criado por cada import,
# 
# ###### Lufthansa Status Import
# - Feito Hora a Hora,
# - Todos os Status de todas as rotas entre os aeroportos previamente mencionados de hoje,
# - Foi adicionado campo com dia e hora de importação,
# - Um ficheiro JSON é criado por cada import,
# 
# Todos os ficheiros JSON estão guardados no lakehouse bronze. Os dados destes ficheiros são depois movidos para tabelas delta.


# MARKDOWN ********************

# #### Camada Prata
# Sempre que é importado novos dados de status, o dataflow de bronze para prata é corrido;
# 
# Para normalizar o modelo de dados, novas tabelas são criadas para as informações:
# - Tipos de headlines,
# - Fusos horários,
# - Tipos de estados de tempo para os voos (ex: se o voo partiu atrasado),
# - Tipos de estados de voos (ex: se o voo foi cancelado),
# - Tipos de voos (ex: se é um voo de carga ou passageiros).
# 
# Principais alterações em cada tabela:
# - Aircrafts
#     - Remover entradas com códigos repetidos ou nomes a nulo,
# - Airlines
#     - Remover entradas com códigos repetidos,
# - Airports
#     - Remover entradas com códigos repetidos,
# - Cities
#     - (Alterações significativas não foram feitas),
# - Countries
#     - (Alterações significativas não foram feitas),
# - Fusos horários
#     - Tabela extraída da tabela das cidades,
#     - Remover informação não relacionada aos fusos horários,
#     - Remover entradas com códigos repetidos,
# - Headlines
#     - Remover entradas com informação repetida ou que sejam da categoria 'News',
#     - Dividir informação por palavras-chave,
# - Tipos de Headlines
#     - Tabela extraída da tabela das headlines,
#     - Remover informação não relacionada aos tipos,
#     - Remover entradas com códigos repetidos,
# - Schedules
#     - Remover entradas com aeroportos que não sejam os selecionados,
#     - Alterar datas/horas para todos os valores estarem em UTC,
#     - Adicionar identificador único,
# - Status
#     - Adicionar identificador da tabela schedules,
#     - Caso a hora de voo não existir usar hora de voo estimada, e caso não existir usar hora de voo planeada (partidas e chegadas),
#     - Remover entradas com aeroportos que não sejam os selecionados,
# - Tipos de estados de tempo para os voos
#     - Tabela extraída da tabela dos status,
#     - Remover informação não relacionada aos tipos,
#     - Remover entradas com códigos repetidos,
# - Tipos de estados de voos
#     - Tabela extraída da tabela dos status,
#     - Remover informação não relacionada aos tipos,
#     - Remover entradas com códigos repetidos,
# - Tipos de voos
#     - Tabela extraída da tabela dos status,
#     - Remover informação não relacionada aos tipos,
#     - Remover entradas com códigos repetidos,
# 
# Todas as tabelas são exportadas para o lakehouse prata.


# MARKDOWN ********************

# #### Camada Ouro
# Sempre que é importado novos dados de status, o dataflow de prata para ouro é corrido;
# 
# Foi adicionado uma nova tabela Date com todas as datas entre a data mais antigo na tabela headlines até à data mais recente da coluna de chegadas da tabela status; 
# 
# Para desnormalizar o modelo de dados, tabelas foram unidas resultando nas seguintes tabelas:
# - Aircrafts,
#     - Id, Nome, Código icao
# - Airlines,
#     - Id, Nome
# - Airports <- Airports + Países + Cidades + Fusos horários,
#     - Id, Latitude, Longitude, Nome, Cidade, Pais, Fuso Horário (UTC Offset), Nome do Fuso Horário
# - Flight Status (tipos de estados de voos),
#     - Id, Nome
# - Headlines <- Headlines + tipos de headlines,
#     - Airline, Localização, Data, Headline, Id do aircraft, Tipo de Headline
# - Flight Types (tipos de voos),
#     - Id, Nome
# - Flights <- status + schedules,
#     - Hora de Partida, Hora de Chegada, Id da airline, Id do aircraft, Id do tipo de voo, Id do tipo de estado do voo, Id do tipo de estado de tempo para a partida, Id do tipo de estado de tempo para a chegada, Id do aeroporto de Partida, Id do aeroporto de Chegada, Hora de partida Planeada, Hora de chegada planeada, Data de Partida, Data de Chegada
# - Flight Time Status (tipos de estados de tempo para os voos),
#     - Id, Nome
# - Dates,
#     - Datas, Ano, Mês, Dia, Chave do mês
# 
# Todas as tabelas são exportadas para o lakehouse ouro.
# 
# No Modelo semântico foram criadas duas Measures:
# - Average Delay Minutes
#     - Média da duração do atraso para os voos marcados como atrasados na partida
# - On Time and Early Flights
#     - Total de voos marcados como ter saído a horas, ou antes da hora


# MARKDOWN ********************

# ## Desafios
# - Carregar ficheiros JSON
# - Definir questões
# - Restrições nas várias ferramentas
