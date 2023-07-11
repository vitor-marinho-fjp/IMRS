# Carregar pacotes necessários
library(tidyverse)
library(readxl)
library(writexl)

# TCE ---------------------------------------------------------------------

#######NÃO FAZER ALTERAÇÕES#######

# Função para ler os arquivos de dados do MUNIC   
read_munic_data <- function(file_path, sheet_name, column_name) {
  read_excel(file_path, sheet = sheet_name) %>%
    rename(ibge7 = 1) %>%
    select(ibge7, !!rlang::sym(column_name) := !!rlang::sym(column_name))
}

#######NÃO FAZER ALTERAÇÕES#######




# Lista dos dados do MUNIC                     ##Podem ser feitas alterações##
munic_data <- list(
  read_munic_data("MUNIC/Base_MUNIC_2017.xlsx", "Transporte", "MTRA10"),
  read_munic_data("MUNIC/Base_MUNIC_2017.xlsx", "Meio ambiente", "MMAM191"),
  read_munic_data("MUNIC/Base_MUNIC_2020.xlsx", "Meio ambiente", "Mmam10"),
  read_munic_data("MUNIC/Base_MUNIC_2018.xlsx", "Assistência social", "MASS16"),
  read_munic_data("MUNIC/Base_MUNIC_2018.xlsx", "Segurança alimentar", "MSAN05"),
  read_munic_data("MUNIC/Base_MUNIC_2018.xlsx", "Política para mulheres", "MPPM13"),
  read_munic_data("MUNIC/Base_MUNIC_2019.xlsx", "Direitos humanos", "MDHU61"),
  read_munic_data("MUNIC/Base_MUNIC_2019.xlsx", "Direitos humanos", "MDHU18"),
  read_munic_data("MUNIC/Base_MUNIC_2020.xlsx", "Habitação", "Mhab10"),
  read_munic_data("MUNIC/Base_MUNIC_2021.xlsx", "Cultura", "Mcul26"),
  read_munic_data("MUNIC/Base_MUNIC_2021.xlsx", "Cultura", "Mcul19"),
  read_munic_data("MUNIC/Base_MUNIC_2021.xlsx", "Educação", "Medu22"),
  read_munic_data("MUNIC/Base_MUNIC_2021.xlsx", "Saúde", "Msau10")
)

# Juntar os dados do MUNIC usando o ibge7 como chave
munic_data <- Reduce(function(df1, df2) left_join(df1, df2, by = "ibge7"), munic_data)


#Renomear para nomeclatura do IMRS

munic_data <- munic_data %>% rename(
    U_CONSSAU = Msau10,
    U_CONSEDU = Medu22,
    U_CONSCULT = Mcul19,
    U_CONSP = Mcul26,
    U_CONSASOC = MASS16,
    U_CONSTUTELAR =MDHU61 , 
    U_CONSSALIM = MSAN05,
    U_CONSCA = MDHU18,
    U_CONSMULHER = MPPM13,
    U_CONSHAB = Mhab10,
    U_CONSTRANS = MTRA10,
    U_CONSMAMB = Mmam10,
    U_CCONVMAMB = MMAM191,
)




# Base TCE ----------------------------------------------------------------

# Ler o arquivo de metadados
irms_qst <- read_excel("IMRS - esquema da dimensão Gestão_em correspondecia com a base IEGM.xlsx",
                       sheet = "Metadados") %>%
  janitor::clean_names() %>%
  select(1:7)

# Ler o arquivo de dados UC11
UC11_Iegm_FJP <- read_excel("Bases_TCE/IEGM_2021.xlsx", skip = 8) %>%
  janitor::clean_names()

# Renomear colunas no DataFrame de metadados
irms_qst <- irms_qst %>% rename(indice = indice_tce, codigo_da_pergunta = cod_pergunta_tce)

# Filtrar e juntar os DataFrames
df_filtrado <- UC11_Iegm_FJP %>%
  inner_join(irms_qst, by = c("indice", "codigo_da_pergunta"))

# Selecionar colunas relevantes e remover duplicatas e valores NA
base <- df_filtrado %>% select(codigo_ibge, ano = exercicio, codigos, resposta)
base <- distinct(base) %>% na.omit()

# Pivotar o DataFrame para o formato wide
df_wide <- base %>%
  pivot_wider(names_from = codigos, values_from = resposta)

# Substituir strings por categorias "Sim" e "Não"
df_wide <- df_wide %>%
  mutate(X_CONTROLAIPTU = ifelse(X_CONTROLAIPTU %in% c("OS DADOS SÃO ARMAZENADOS DE FORMA ELETRÔNICA EM UM BANCO DE DADOS E SEU CONTEÚDO ESTÁ NA GERÊNCIA DIRETA DO MUNICÍPIO",
                                                       "OS DADOS SÃO ARMAZENADOS DE FORMA EL    
                                                       ETRÔNICA EM UM BANCO DE DADOS E SEU CONTEÚDO ESTÁ NA GERÊNCIA INDIRETA DO MUNICÍPIO, OU SEJA, ESTÁ EM SISTEMAS TERCEIRIZADOS"), "Sim", "Não"),
         X_ARRECADISS = ifelse(X_ARRECADISS == "NÃO FOI IMPLANTADA A NFE", "Não", "Sim"),
         X_PLPROTDEFCIVIL = ifelse(X_PLPROTDEFCIVIL == ' X_PLPROTDEFCIVIL', 'Não', 'Sim'),
         X_PMRESIDUOS = ifelse(X_PMRESIDUOS == c("ESTÁ EM OUTRAS FASES DE ELABORAÇÃO",
                                                 "NÃO REALIZOU O PLANO", "INSTRUMENTO NORMATIVO PUBLICADO OU PROMULGADO",
                                                 "SUBMISSÃO DO TEXTO À CÂMARA DE VEREADORES"), "Não", "Sim"),
         X_ESTOQUESAUDE = ifelse(grepl("Sim", X_ESTOQUESAUDE), "Sim", "Não")
  )


df_wide<- df_wide %>% rename(ibge7 = codigo_ibge)


# Juntando as duas bases --------------------------------------------------

# Juntar os DataFrames do TCE e MUNIC usando o ibge7 como chave
dados <- inner_join(df_wide, munic_data, by = "ibge7")

# Calcular o índice X_INDTRANSPGES
dados$X_INDTRANSPGES <- rowMeans(
  dados[, c("X_SITEATUAL", "X_CONSULMEDUBS", "X_SISTCONTPONTOMED", "X_SISTINFPLANEJ", "X_ARRECADISS",
            "X_CONTROLAIPTU", "X_TECCOMPRASPUB")] == "Sim"
)

# Calcular o índice X_INDIGITGES
dados$X_INDIGITGES <- rowMeans(
  dados[, c("X_LEIACESSOINFOR", "X_DIVULGORÇA", "X_DIVULGESTAOFISCAL", "X_CONTRATOSINTERNET",
            "X_EDITAISLICITA", "X_ATASDIVULG")] == "Sim"
)



##Exportar base em excel
write_xlsx(dados, 'base_imrs_2021.xlsx')

