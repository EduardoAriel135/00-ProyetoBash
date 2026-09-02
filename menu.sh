#!/bin/bash

# Rutas del entorno de trabajo
HOME_DIR="$HOME/EPNro1"
ENTRADA_DIR="$HOME_DIR/entrada"
SALIDA_DIR="$HOME_DIR/salida"
PROCESADO_DIR="$HOME_DIR/procesado"
LOG_FILE="$HOME_DIR/procesado.log"

# Manejo del parametro optativo -d
if [ "$1" == "-d" ]; then
    echo "=== MODO DESTRUCCION / LIMPIEZA ==="
    
    # 1. Matar procesos en background asociados a consolidar.sh
    pids=$(pgrep -f "consolidar.sh")
    if [ -n "$pids" ]; then
        kill -9 $pids 2>/dev/null
        echo "Proceso(s) de consolidacion finalizado(s) [PID: $pids]."
    else
        echo "No se encontraron procesos de consolidacion en segundo plano."
    fi
    
    # 2. Borrar la estructura de la carpeta EPNro1 en el HOME
    if [ -d "$HOME_DIR" ]; then
        rm -rf "$HOME_DIR"
        echo "El entorno '$HOME_DIR' ha sido eliminado correctamente."
    else
        echo "El directorio '$HOME_DIR' no existe."
    fi
    
    exit 0
fi

if [ -z "$FILENAME" ]; then
    FILENAME="alumnos"
fi

SALIDA_FILE="$SALIDA_DIR/${FILENAME}.txt"

while true; do
    echo "=========================================="
    echo "       MENU DE GESTION - FIUBA IDS        "
    echo "=========================================="
    echo "1) Crear entorno"
    echo "2) Correr proceso de consolidacion"
    echo "3) Mostrar alumnos ordenados por padron"
    echo "4) Mostrar las 10 notas mas altas"
    echo "5) Buscar alumno por padron"
    echo "6) Visualizar log de procesos"
    echo "7) Salir"
    echo "=========================================="
    read -p "Seleccione una opcion (1-7): " opcion

    case $opcion in
        1)
            echo -e "\n--- Opcion 1: Crear entorno ---"
            mkdir -p "$ENTRADA_DIR" "$SALIDA_DIR" "$PROCESADO_DIR"
            
            cp "$(dirname "$0")/consolidar.sh" "$HOME_DIR/consolidar.sh" 2>/dev/null
            chmod +x "$HOME_DIR/consolidar.sh" 2>/dev/null
            
            echo "Directorio $HOME_DIR creado con exito junto a sus subcarpetas:"
            echo "- $ENTRADA_DIR"
            echo "- $SALIDA_DIR"
            echo "- $PROCESADO_DIR"
            ;;
            
        2)
            echo -e "\n--- Opcion 2: Correr proceso ---"
            if [ ! -f "$HOME_DIR/consolidar.sh" ]; then
                echo "Error: Primero debe crear el entorno (Opcion 1)."
            else
                # Verificar si ya esta ejecutandose para no duplicarlo
                if pgrep -f "consolidar.sh" >/dev/null; then
                    echo "El proceso de consolidacion ya se encuentra ejecutandose en background."
                else
                    # Ejecucion del proceso en segundo plano (background)
                    nohup bash "$HOME_DIR/consolidar.sh" >/dev/null 2>&1 &
                    echo "Proceso consolidar.sh iniciado con exito en segundo plano [PID: $!]."
                fi
            fi
            ;;
            
        3)
            echo -e "\n--- Opcion 3: Alumnos ordenados por padron ---"
            if [ -f "$SALIDA_FILE" ]; then
                echo "Listado de alumnos ordenado por Padron (numerico ascendente):"
                echo "-------------------------------------------------------------"
                # sort -n -k1 ordena numericamente por la columna 1 (Nro_Padron)
                sort -n -k1 "$SALIDA_FILE"
            else
                echo "El archivo $SALIDA_FILE no existe en la carpeta salida."
            fi
            ;;
            
        4)
            echo -e "\n--- Opcion 4: Las 10 notas mas altas ---"
            if [ -f "$SALIDA_FILE" ]; then
                echo "Top 10 Notas mas altas:"
                echo "-------------------------------------------------------------"
                # sort -k4,4nr ordena numericamente y descendente por la columna 4 (Nota)
                sort -k4,4nr "$SALIDA_FILE" | head -n 10
            else
                echo "El archivo $SALIDA_FILE no existe en la carpeta salida."
            fi
            ;;
            
        5)
            echo -e "\n--- Opcion 5: Buscar datos por padron ---"
            if [ -f "$SALIDA_FILE" ]; then
                read -p "Ingrese el numero de padron a buscar: " padron
                if [ -n "$padron" ]; then
                    resultado=$(grep -w "^$padron" "$SALIDA_FILE")
                    if [ -n "$resultado" ]; then
                        echo "-------------------------------------------------------------"
                        echo "Resultado obtenido: $resultado"
                    else
                        echo "No se encontraron registros asociadas al padron $padron."
                    fi
                else
                    echo "El padron ingresado no es valido."
                fi
            else
                echo "El archivo $SALIDA_FILE no existe en la carpeta salida."
            fi
            ;;
            
        6)
            echo -e "\n--- Opcion 6: Visualizar log ---"
            if [ -f "$LOG_FILE" ]; then
                echo "Contenido del archivo de log ($LOG_FILE):"
                echo "-------------------------------------------------------------"
                cat "$LOG_FILE"
            else
                echo "Aun no se ha registrado ningun evento en el log."
            fi
            ;;
            
        7)
            echo "¡Saliendo del sistema!"
            break
            ;;
            
        *)
            echo "Opcion invalida. Intente de nuevo."
            ;;
    esac
    echo -e "\n"
done
