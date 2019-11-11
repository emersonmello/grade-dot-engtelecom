#!/bin/bash
# Emerson Ribeiro de Mello - 2019-11-11

# Esse script pega um conjunto de arquivos .DOCX e gera a cadeia de pré-requisitos com a sintaxe da DOT Language
# As cores para cada nó depende do subdiretório onde o arquivo TXT de cada disciplina está salvo
# ATENÇÃO: esse script depende da seguinte estrutura de diretórios
# ementas
# |-- eixo-amarelo
# |-- eixo-azul
# |-- eixo-cinza
# |-- eixo-laranja
# |-- eixo-marrom
# |-- eixo-roxo
# |-- eixo-verde-claro
# `-- eixo-verde-escuro


if [  $# -ne 2 ]; then
    echo -e "Sintaxe errada.\nInforme o diretório que contém os arquivox .DOCX e o nome do arquivo de saída DOT"
    echo -e "Ex: $0 ementas grade.dot\n"
    exit 1
fi 

if [ ! -d "$1" ]; then
    echo "Diretório de entrada não existe. Informar um diretório válido"
    exit 1
fi

temPandoc=`which pandoc`
if [ -z  "$temPandoc" ]; then
    echo "Esse script depende do pandoc. Por favor, instale o pandoc e garanta que o mesmo esteja no PATH"
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

# Isso está amarrado com os nomes dos subdiretórios do google drive
amarelo="#FFD700" 
azul="#007FFF"
cinza="#808080"
laranja="#FFA343"
marrom="#9F8170"
roxo="#9678B6"
verdeClaro="#77DD77"
verdeEscuro="#339966"

echo >> "$2"

for f in $(find "$1" -name '*.txt' |sort); do

    # pegando linha posterior da palavra SIGLA
    sigla=`grep -i "SIGLA" -A 1  "$f" | grep  -i -v "SIGLA"`
    
    # pegando linha posterior das palavras CARGA HORÁRIA
    ch=`grep -E "^## CARGA HORÁRIA" -A 1  "$f" | grep -v -E "^## CARGA HORÁRIA"`

    # Isso está amarrado com os nomes dos subdiretórios do google drive
    case "$f" in
        *"amarelo"*)
            cor=$amarelo;;
        *"azul"*)
            cor=$azul;;
        *"cinza"*)
            cor=$cinza;;
        *"laranja"*)
            cor=$laranja;;
        *"marrom"*)
            cor=$marrom;;
        *"roxo"*)
            cor=$roxo;;    
        *"verde-claro"*)
            cor=$verdeClaro;;
        *"verde-escuro"*)
            cor=$verdeEscuro;;
        *)
        cor="#fcfcfc";;
    esac

    # para deixar o mesmo número de espaços entre siglas e colchetes
    cont=`expr "$sigla" : '.*'`
    if [ $cont -eq 3 ]; then
        sigla="$sigla "
    fi
    # Vai gerar a seguinte saída: POO [ch=80, color="#339966", id=POO]
    echo -e "$sigla [ch=$ch, color=\"#$cor\", id=$sigla]" >> "$2"

done

# 70% da CH atual, será preenchido pelo preprocess.gvpr
echo "horasTCC [label=\"0000h\",  color=\"#8da3c3\", id=\"horasTCC\"]" >> "$2"

# 60% da CH atual, será preenchido pelo preprocess.gvpr 
echo "horasETO [label=\"0000h\",  color=\"#8da3c3\", id=\"horasETO\"]" >> "$2" 

# ADM tem 1980h como pré-requisito
echo "horas1980 [label=\"1.980h\", color=\"#8da3c3\", id=\"horas1980\"]" >> "$2"

unset IFS; set +f



