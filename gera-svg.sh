#!/bin/bash
# Emerson Ribeiro de Mello - 2019-10-18

if ! [ $# -eq 2 ]; then
    echo -e "Sintaxe errada. Informe o nome do arquivo de entrada DOT e o arquivo de saida SVG."
    echo -e "Ex: $0 engtelecom.dot pagina-html/grade.svg\n"
    exit 1
fi

if [ ! -f preprocess.gvpr ]; then
    echo "Arquivo 'preprocess.gvpr' com regras de processamento não foi encontrado."
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Arquivo $1 não foi encontrado."
    exit 1
fi 

if [ "$1" = "$2" ]; then
    echo "Nome do arquivo de saída não pode ser igual ao nome do arquivo de entrada"
    exit 1
fi 

gvpr "$1" -c -f preprocess.gvpr | dot -Tsvg > "$2"
