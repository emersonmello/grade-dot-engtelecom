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


cabecalho="
digraph EngTelecom {
    layout = dot
    label =\"Engenharia de Telecomunicações\"
    labelloc = t
    pad=\"0.5\"
    graph [nodesep=0.3, ranksep=1.3, fontname=\"helvetica Neue Ultra Light\", fontcolor=\"#000000\", fontsize=25]
    node [shape=\"circle\", width=\".8\", style=\"filled\", labelloc=c, fontname=\"helvetica Neue Ultra Light bold\", fixedsize=true]
    edge [color=\"#000000\", penwidth=\"2\", fontname=\"helvetica Neue Ultra Light\"]
"

echo -e "$cabecalho" >> "$2"
echo -e "\n    // Pré-requisitos\n" >> "$2"

# definindo delimitador de campos para newline
IFS=$'\n'; set -f
for f in $(find "$1" -name '*.docx' | sort); do

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
    prereq=`grep -i "PRÉ-REQUISITOS" -A 1  "$arquivoTxT" | grep  -i -v "PRÉ-REQUISITOS" | sed 's/,/ /g'`
    # ordenando a lista de pre-requisitos e removendo espaços extras
    prereq=`echo $prereq |tr " " "\n" |sort|tr "\n" " " | awk '$1=$1'` 

    # verificando se tem pré-requisito
    if [[ ! $prereq =~ "#" ]]; then
        echo "    {$prereq} -> $sigla" >> "$2"
    else
        echo "    {} -> $sigla" >> "$2"
    fi

    # pegando linha posterior da palavra  CO-REQUISITOS
    coreq=`grep -i "CO-REQUISITOS" -A 1  "$arquivoTxT" | grep  -i -v "CO-REQUISITOS"`

    # verificando se tem co-requisito
    if [[ ! $coreq =~ "#" ]]; then
        echo "    {$coreq} -> $sigla [color=\"#FF0000\" constraint=false]" >> "$2"
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

echo -e "\n    // Propriedades dos nós\n">> "$2"

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
    echo -e "    $sigla [ch=$ch, color=\"$cor\", id=$sigla]" >> "$2"

done
unset IFS; set +f

# 70% da CH atual, será preenchido pelo preprocess.gvpr
echo "    horasTCC [label=\"horasTCC\",  color=\"#8da3c3\", id=\"horasTCC\"]" >> "$2"

# 60% da CH atual, será preenchido pelo preprocess.gvpr
echo "    horasETO [label=\"horasETO\",  color=\"#8da3c3\", id=\"horasETO\"]" >> "$2"

# ADM tem 1980h como pré-requisito
echo "    horas1980 [label=\"1.980h\", color=\"#8da3c3\", id=\"horas1980\"]" >> "$2"


echo -e "\n    // Fases\n" >> "$2"


for fase in `seq 1 10`; do
    linha="
    subgraph cluster_fase$fase {
        label = \"Fase $fase\"
        style=\"rounded\"
        bgcolor= \"#e6e6e6\"
        color = lightgrey
        
        // Disciplinas da fase

    }"
    echo -e "$linha" >> "$2"
done

# fechando grafo
echo -e "}\n" >> "$2"
