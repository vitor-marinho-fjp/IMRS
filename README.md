# README - Processamento de Dados TCE e MUNIC

Este é um repositório contendo um script R que processa e combina dados de diferentes fontes para criar um conjunto de dados final. O script realiza as seguintes etapas:

1. Carrega os pacotes necessários, incluindo tidyverse, readxl e writexl.

2. Define uma função para ler os arquivos de dados do MUNIC. Esta função é usada para ler e processar várias planilhas de dados do MUNIC.

3. Lista os dados do MUNIC a serem lidos. Você pode personalizar esta lista para incluir ou excluir planilhas de acordo com suas necessidades.

4. Combina os dados do MUNIC usando o código IBGE7 como chave. Isso cria um único conjunto de dados contendo informações de várias áreas.

5. Renomeia as colunas do conjunto de dados combinado para seguir a nomenclatura do IMRS.

6. Lê os dados do TCE de um arquivo Excel, filtra, junta e formata esses dados de acordo com suas necessidades.

7. Calcula dois índices, X_INDTRANSPGES e X_INDIGITGES, com base em critérios específicos.

8. Exporta o conjunto de dados final em formato Excel para um arquivo chamado "base_imrs_2021.xlsx".

## Pré-requisitos

Certifique-se de ter instalado os seguintes pacotes R antes de executar o script:

- tidyverse
- readxl
- writexl

## Como Usar

1. Clone este repositório em sua máquina local ou faça o download do script R.

2. Certifique-se de que você tem os arquivos de dados do MUNIC e o arquivo "IMRS - esquema da dimensão Gestão_em correspondecia com a base IEGM.xlsx" no mesmo diretório que o script.

3. Abra o script em um ambiente R (por exemplo, RStudio) e execute-o. Certifique-se de que os pacotes pré-requisitos estejam instalados.

4. O script processará os dados, criará o conjunto de dados final e o exportará como "base_imrs_2021.xlsx" no mesmo diretório.

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir problemas (issues) ou enviar pull requests para melhorias ou correções no script.

## Licença

Este projeto está licenciado sob a Licença MIT - consulte o arquivo [LICENSE.md](LICENSE.md) para obter detalhes.

