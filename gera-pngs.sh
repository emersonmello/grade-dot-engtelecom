#!/bin/bash
# Emerson Ribeiro de Mello - 2019-10-18

if ! [ $# -eq 2 ]; then
    echo -e "Sintaxe errada. Informe o nome do arquivo de entrada e o arquivo de saida."
    echo -e "Ex: $0 entrada.dot saida.dot\n"
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

gvpr $1 -c -f preprocess.gvpr -o $2

png1=`echo $1 |cut -d "." -f1`
png2=`echo $2 |cut -d "." -f1`

dot $1 -Tpng > $png1.png
dot $2 -Tpng > $png2.png
dot $2 -Tsvg > pagina-html/comissao.svg
