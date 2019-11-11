#!/bin/bash
# Emerson Ribeiro de Mello - 2019-11-11

# Esse script pega um conjunto de arquivos .DOCX e gera a cadeia de pré-requisitos com a sintaxe da DOT Language

if [  $# -ne 2 ]; then
    echo -e "Sintaxe errada.\nInforme o diretório que contém os arquivox .DOCX e o nome do arquivo de saída DOT"
    echo -e "Ex: $0 ementas grade.dot\n"
    exit 1
fi 

if [ ! -d "$1" ]; then
    echo "Diretório de entrada não existe. Informar um diretório válido"
    exit 1
fi

# definindo delimitador de campos para newline
IFS=$'\n'; set -f
for f in $(find "$1" -name '*.docx'); do

    arquivoTxT="$f.txt" 

    # convertendo de DOCX para TXT
    pandoc -s "$f" -t plain -o "$arquivoTxT"

    # removendo linhas em branco
    arqTemp="$arquivoTxT.$$"
    awk 'NF' "$arquivoTxT" > "$arqTemp"
    mv "$arqTemp" "$arquivoTxT"

    # pegando linha posterior da palavra SIGLA
    sigla=`grep -i "SIGLA" -A 1  "$arquivoTxT" | grep  -i -v "SIGLA"`

    # pegando linha posterior da palavra PRÉ-REQUISITOS
    prereq=`grep -i "PRÉ-REQUISITOS" -A 1  "$arquivoTxT" | grep  -i -v "PRÉ-REQUISITOS"`
    
    # verificando se tem pré-requisito
    if [[ ! $prereq =~ "#" ]]; then 
        echo "{$prereq} -> $sigla" >> "$2"
    else
        echo "{} -> $sigla" >> "$2"
    fi

    # pegando linha posterior da palavra  CO-REQUISITOS
    coreq=`grep -i "CO-REQUISITOS" -A 1  "$arquivoTxT" | grep  -i -v "CO-REQUISITOS"`
    
    # verificando se tem co-requisito
    if [[ ! $coreq =~ "#" ]]; then 
        echo "{$coreq} -> $sigla [color=\"#FF0000\" constraint=false]" >> "$2"
    fi

done
unset IFS; set +f

