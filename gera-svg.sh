#!/bin/bash
# Emerson Ribeiro de Mello - 2019-10-18

if [ $# -lt 1 ]; then
    echo -e "Sintaxe errada.\nInforme o nome do arquivo de entrada DOT e o arquivo de saida SVG."
    echo -e "Ex: $0 engtelecom.dot pagina-html/grade.svg\n"
    echo -e "Ou, se desejar imprimir na tela informe o nome do arquivo de entrada DOT\n"
    echo -e "Ex: $0 engtelecom.dot\n"
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

if [ $# -eq 2 ]; then

    if [ "$1" = "$2" ]; then
        echo "Nome do arquivo de saída não pode ser igual ao nome do arquivo de entrada"
        exit 1
    fi 
    gvpr "$1" -c -f preprocess.gvpr | dot -Tsvg > "$2"
    exit 0
fi

gvpr "$1" -c -f preprocess.gvpr
