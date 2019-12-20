#!/bin/bash
# Emerson Ribeiro de Mello - 2019-12-20

# Recebe como entrada: 
# - arquivo com o grafo
# - arquivo com a lista de siglas das disciplinas. Uma sigla por linha
# - diretório onde será gerados os arquivos png
# Gera como saída um arquivo .png para sigla contida no arquivo de entrada

############################################################################
#                                ATENÇÃO
############################################################################
# Esse script depende de um arquivo .dot de forma que a disciplina tenha
# a propriedade ch= logo na primeira posição. Exemplo:
#
# POO  [ch=80, color="#339966", id=POO ]
#
############################################################################

regras="gvpr-scripts/supreprocess.gvpr"

if [ $# -ne 2 ]; then
    echo -e "Sintaxe errada.\nInforme o nome do arquivo de entrada DOT,\ne o nome do diretório de saída.\n"
    echo -e "Ex: $0 engtelecom.dot arquivos-png\n"
    exit 1
fi 

if [ ! -f "$regras" ]; then
    echo "Arquivo $regras com regras de processamento não foi encontrado."
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Arquivo $1 não foi encontrado."
    exit 1
fi 

mkdir -p "$2"

# filtrando somente as linhas com ch= e removendo os espaços em branco que podem estar no início da linha
disciplinas=`cat saida.dot | grep "ch=" |  sed -e 's/^[ \t]*//' | cut -d " " -f1`

for linha in $disciplinas; do
    gvpr "$1" -f "gvpr-scripts/supreprocess.gvpr" -a "$linha" | dot -Tpng > "$2/$linha.png"
done