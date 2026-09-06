#!/bin/bash

ENTORNO_DIR="$HOME/EPNro1"
ENTRADA_DIR="$ENTORNO_DIR/entrada"
SALIDA_DIR="$ENTORNO_DIR/salida"
PROCESADO_DIR="$ENTORNO_DIR/procesado"
LOG_FILE="$ENTORNO_DIR/procesado.log"
ENV_FILE="$ENTORNO_DIR/.filename_env"

# Mecanismo de persistencia de la variable FILENAME
if [[ -z "$FILENAME" ]]; then
    if [ -f "$ENV_FILE" ]; then
        FILENAME=$(cat "$ENV_FILE")
    else
        FILENAME="consolidado"
    fi
fi

SALIDA_FILE="$SALIDA_DIR/${FILENAME}.txt"

while true; do
    # Evitamos que la expresión literal *.txt se use como texto si la carpeta está vacía
    shopt -s nullglob
    archivos_txt=("$ENTRADA_DIR"/*.txt)
    
    if [ ${#archivos_txt[@]} -gt 0 ]; then
        for archivo in "${archivos_txt[@]}"; do
            if [ -f "$archivo" ]; then

                cat "$archivo" >> "$SALIDA_FILE"
                
                if [ "$(tail -c1 "$SALIDA_FILE" | wc -l)" -eq 0 ]; then
                    echo "" >> "$SALIDA_FILE"
                fi
                
                nombre_archivo=$(basename "$archivo")
                mv "$archivo" "$PROCESADO_DIR/"
                
                fecha_hora=$(date +"%d/%m/%Y %H:%M:%S")
                echo "$fecha_hora - Procesado archivo $nombre_archivo" >> "$LOG_FILE"
            fi
        done
    fi
    sleep 3
done