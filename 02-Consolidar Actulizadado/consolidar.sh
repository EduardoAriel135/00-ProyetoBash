#!/bin/bash

# Script en Background: consolidar.sh
DIR_HOME="$HOME/EPNro1"
DIR_ENTRADA="$DIR_HOME/entrada"
DIR_SALIDA="$DIR_HOME/salida"
DIR_PROCESADO="$DIR_HOME/procesado"
LOG_FILE="$DIR_PROCESADO/procesado.log"


while true; do
    if [[ -d "$DIR_ENTRADA" && -n "$FILENAME" ]]; then
        FILE_SALIDA="$DIR_SALIDA/${FILENAME}.txt"
        shopt -s nullglob
        archivos=("$DIR_ENTRADA"/*.txt)
        shopt -u nullglob

        if [[ ${#archivos[@]} -gt 0 ]]; then
            for archivo in "${archivos[@]}"; do
                if [[ -f "$archivo" ]]; then
                    # 1. Consolidar el contenido al final de FILENAME.txt
                    cat "$archivo" >> "$FILE_SALIDA"
                    echo "" >> "$FILE_SALIDA"
                    sed -i '/^$/d' "$FILE_SALIDA"

                    # 2. Registrar en el log
                    NOMBRE_BASE=$(basename "$archivo")
                    FECHA_HORA=$(date "+%d/%m/%Y %H:%M:%S")
                    echo "$FECHA_HORA - Procesado archivo $NOMBRE_BASE" >> "$LOG_FILE"

                    # 3. Mover archivo original a la carpeta procesado
                    mv "$archivo" "$DIR_PROCESADO/"
                fi
            done
        fi
    fi

    # Esperar 5 segundos antes de volver a escanear
    sleep 5
done