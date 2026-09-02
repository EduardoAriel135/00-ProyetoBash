#!/bin/bash

# Directorio base dentro de la carpeta personal del usuario
HOME_DIR="$HOME/EPNro1"
ENTRADA_DIR="$HOME_DIR/entrada"
SALIDA_DIR="$HOME_DIR/salida"
PROCESADO_DIR="$HOME_DIR/procesado"
LOG_FILE="$HOME_DIR/procesado.log"

# Si la variable FILENAME no esta definida, se usa un valor por defecto
if [ -z "$FILENAME" ]; then
    FILENAME="alumnos"
fi

SALIDA_FILE="$SALIDA_DIR/${FILENAME}.txt"

# Bucle infinito para revisar periodicamente la carpeta 'entrada'
while true; do
    # Verifica si existen archivos con extension .txt en la carpeta entrada
    if ls "$ENTRADA_DIR"/*.txt >/dev/null 2>&1; then
        for archivo in "$ENTRADA_DIR"/*.txt; do
            # Validar que sea un archivo regular
            if [ -f "$archivo" ]; then
                nombre_base=$(basename "$archivo")
                
                # Adjunta toda su informacion al final de FILENAME.txt
                cat "$archivo" >> "$SALIDA_FILE"
                
                # Mueve el archivo procesado a la carpeta 'procesado'
                mv "$archivo" "$PROCESADO_DIR/"
                
                # Registra la operacion en el archivo log con la fecha y hora actual
                fecha_hora=$(date +"%d/%m/%Y %H:%M:%S")
                echo "$fecha_hora - Procesado archivo $nombre_base" >> "$LOG_FILE"
            fi
        done
    fi
    # Espera 5 segundos antes de volver a chequear
    sleep 5
done