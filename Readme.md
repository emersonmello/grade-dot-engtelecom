# Grade da Engenharia de Telecomunicações



- O arquivo [engtelecom.dot](engtelecom.dot) contém o fonte da grade

- Use o *shell script* [gera-ch.sh](gera-ch.sh) para gerar um arquivo .dot com a carga horária e créditos computados.

- Use o *shell script* [gera-pngs.sh](gera-pngs.sh) para gerar 2 arquivos PNG do grafo.

- Instale o pacote graphviz
  - ```shell
    sudo apt install graphviz
    ```
- Gere as imagens da rede curricular    
  - ```shell
    bash gera-pngs.sh engtelecom.dot LOG-co-PRG1.dot
    ```

