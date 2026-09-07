#!/bin/bash

DIR_HOME="$HOME/EPNro1"
DIR_ENTRADA="$DIR_HOME/entrada"
DIR_SALIDA="$DIR_HOME/salida"
DIR_PROCESADO="$DIR_HOME/procesado"
LOG_FILE="$DIR_PROCESADO/procesado.log"


# PARÁMETRO OPTATIVO: -d (Desinstalar / Limpiar Entorno)
if [[ "$1" == "-d" ]]; then
    echo "Modo limpieza activado (-d)..."
    
    PIDS=$(pgrep -f "consolidar.sh")
    if [[ -n "$PIDS" ]]; then
        echo "Finalizando procesos en background (PID: $PIDS)..."
        kill -9 $PIDS 2>/dev/null
    else
        echo "No se encontraron procesos 'consolidar.sh' en ejecución."
    fi

    if [[ -d "$DIR_HOME" ]]; then
        rm -rf "$DIR_HOME"
        echo "Directorio $DIR_HOME eliminado correctamente."
    else
        echo "El directorio $DIR_HOME no existe."
    fi

    echo "Limpieza finalizada."
    exit 0
fi


# VERIFICACIÓN DE LA VARIABLE DE ENTORNO 'FILENAME'
if [[ -z "$FILENAME" ]]; then
    echo "ERROR CRÍTICO: La variable de entorno 'FILENAME' no está definida."
    echo "Por favor, defínala antes de ejecutar el script. Ejemplo:"
    echo "  export FILENAME=\"alumnos\""
    exit 1
fi

FILE_SALIDA="$DIR_SALIDA/${FILENAME}.txt"


# MENÚ INTERACTIVO (OPCIONES 1 A 7)
while true; do
    echo -e "\n=================================================="
    echo "          MENÚ PRINCIPAL - PROYECTO BASH          "
    echo "=================================================="
    echo "1) Crear entorno"
    echo "2) Correr proceso"
    echo "3) Listar alumnos ordenados por número de padrón"
    echo "4) Mostrar las 10 notas más altas"
    echo "5) Buscar alumno por número de padrón"
    echo "6) Visualizar log"
    echo "7) Salir"
    echo "=================================================="
    read -p "Seleccione una opción [1-7]: " opcion

    case $opcion in
        1)
            # Opción 1: Crear estructura de directorios
            mkdir -p "$DIR_ENTRADA" "$DIR_SALIDA" "$DIR_PROCESADO"
            echo "Entorno creado exitosamente en: $DIR_HOME"
            ;;

        2)
            # Opción 2: Correr proceso consolidar.sh en background
            if [[ ! -f "$DIR_HOME/consolidar.sh" ]]; then
                echo "ERROR: No se encontró el script 'consolidar.sh' dentro de $DIR_HOME."
                echo "Por favor, genere o coloque el archivo en $DIR_HOME antes de ejecutar el proceso."
            else
                if pgrep -f "consolidar.sh" > /dev/null; then
                    echo "El proceso 'consolidar.sh' ya se encuentra ejecutándose en background."
                else
                    nohup bash "$DIR_HOME/consolidar.sh" > /dev/null 2>&1 &
                    echo "Proceso 'consolidar.sh' iniciado exitosamente en background."
                fi
            fi
            ;;

        3)
            # Opción 3: Listar alumnos ordenados por padrón (columna 1, numérico)
            if [[ -f "$FILE_SALIDA" ]]; then
                echo "--- Listado de alumnos ordenados por Padrón ---"
                sort -n -k1,1 "$FILE_SALIDA"
            else
                echo "No existe el archivo de salida $FILE_SALIDA."
            fi
            ;;

        4)
            # Opción 4: Mostrar las 10 notas más altas (columna 4, numérico descendente)
            if [[ -f "$FILE_SALIDA" ]]; then
                echo "--- Las 10 notas más altas ---"
                sort -t' ' -k4,4nr "$FILE_SALIDA" | head -n 10
            else
                echo "No existe el archivo de salida $FILE_SALIDA."
            fi
            ;;

        5)
            # Opción 5: Buscar datos por número de padrón
            if [[ -f "$FILE_SALIDA" ]]; then
                read -p "Ingrese el número de padrón a buscar: " padron
                if [[ -z "$padron" ]]; then
                    echo "El padrón no puede estar vacío."
                else
                    RESULTADO=$(grep -E "^$padron[[:space:]]" "$FILE_SALIDA")
                    if [[ -n "$RESULTADO" ]]; then
                        echo "--- Datos del alumno encontrado ---"
                        echo "$RESULTADO"
                    else
                        echo "No se encontraron registros para el padrón $padron."
                    fi
                fi
            else
                echo "No existe el archivo de salida $FILE_SALIDA."
            fi
            ;;

        6)
            # Opción 6: Visualizar el archivo de log
            if [[ -f "$LOG_FILE" ]]; then
                echo "--- Contenido del Log ($LOG_FILE) ---"
                cat "$LOG_FILE"
            else
                echo "El archivo de log aún no existe o no contiene registros."
            fi
            ;;

        7)
            # Opción 7: Salir del programa
            echo "Saliendo del sistema..."
            break
            ;;

        *)
            echo "Opción inválida. Intente con un número del 1 al 7."
            ;;
    esac
done