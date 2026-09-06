#!/bin/bash
# =====================================================================
# Proyecto Fase 1 Bash - Introducción al Desarrollo de Software (IDS)
# Script Principal: menu.sh
# =====================================================================

ENTORNO_DIR="$HOME/EPNro1"
ENTRADA_DIR="$ENTORNO_DIR/entrada"
SALIDA_DIR="$ENTORNO_DIR/salida"
PROCESADO_DIR="$ENTORNO_DIR/procesado"
LOG_FILE="$ENTORNO_DIR/procesado.log"
PID_FILE="$ENTORNO_DIR/.consolidar.pid"
ENV_FILE="$ENTORNO_DIR/.filename_env"

# Manejo del parámetro optativo -d (Desinstalación y Limpieza)
if [[ "$1" == "-d" ]]; then
    echo "=================================================="
    echo " Iniciando desinstalación y limpieza del entorno... "
    echo "=================================================="
    
    # 1. Finalizar procesos en background
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            echo "[✓] Proceso consolidar.sh (PID $PID) finalizado de manera limpia."
        else
            echo "[-] El PID registrado ($PID) ya no se encuentra activo."
        fi
        rm -f "$PID_FILE"
    else
        echo "[-] No se encontró un archivo de registro PID activo."
    fi
    
    # Detener cualquier otra instancia huérfana de consolidar.sh por seguridad
    PIDS_REMANENTES=$(pgrep -f "consolidar.sh")
    if [ -n "$PIDS_REMANENTES" ]; then
        echo "[!] Deteniendo procesos remanentes en segundo plano..."
        kill $PIDS_REMANENTES 2>/dev/null
    fi

    # 2. Borrar estructura de directorios
    if [ -d "$ENTORNO_DIR" ]; then
        rm -rf "$ENTORNO_DIR"
        echo "[✓] Directorio de entorno '$ENTORNO_DIR' eliminado por completo."
    else
        echo "[-] El directorio de entorno '$ENTORNO_DIR' no existe actualmente."
    fi
    echo "=================================================="
    echo "Limpieza completada con éxito."
    exit 0
fi

# Verificación de la variable de entorno FILENAME
if [[ -z "$FILENAME" ]]; then
    echo "⚠️ ADVERTENCIA: La variable de ambiente FILENAME no está definida."
    read -p "Por favor, ingrese el nombre del archivo de salida (sin .txt): " input_filename
    if [[ -z "$input_filename" ]]; then
        echo "Error: El nombre de archivo no puede ser nulo."
        exit 1
    fi
    FILENAME="$input_filename"
fi

export FILENAME
if [ -d "$ENTORNO_DIR" ]; then
    echo "$FILENAME" > "$ENV_FILE"
fi

SALIDA_FILE="$SALIDA_DIR/${FILENAME}.txt"

# Función de Interfaz
mostrar_menu() {
    echo ""
    echo "=================================================="
    echo "      SISTEMA DE GESTIÓN - PROYECTO BASH"
    echo "      Archivo de Consolidación: ${FILENAME}.txt"
    echo "=================================================="
    echo " 1) Crear entorno (EPNro1, entrada, salida, procesado)"
    echo " 2) Correr proceso de consolidación en background"
    echo " 3) Mostrar alumnos ordenados por número de padrón"
    echo " 4) Mostrar las 10 notas más altas del listado"
    echo " 5) Buscar datos de alumno por número de padrón"
    echo " 6) Visualizar log de procesamiento"
    echo " 7) Salir"
    echo "=================================================="
    echo -n "Seleccione una opción [1-7]: "
}

# Bucle del Menú de Opciones
while true; do
    mostrar_menu
    read -r opcion
    echo ""

    case "$opcion" in
        1)
            echo "[*] Creando el entorno de directorios..."
            mkdir -p "$ENTRADA_DIR"
            mkdir -p "$SALIDA_DIR"
            mkdir -p "$PROCESADO_DIR"
            
            
            echo "$FILENAME" > "$ENV_FILE"
            
            
            cat << 'EOF' > "$ENTORNO_DIR/consolidar.sh"


#!/bin/bash
# =====================================================================
# Script de consolidación en background - consolidar.sh
# =====================================================================

ENTORNO_DIR="$HOME/EPNro1"
ENTRADA_DIR="$ENTORNO_DIR/entrada"
SALIDA_DIR="$ENTORNO_DIR/salida"
PROCESADO_DIR="$ENTORNO_DIR/procesado"
LOG_FILE="$ENTORNO_DIR/procesado.log"
ENV_FILE="$ENTORNO_DIR/.filename_env"

# Reestablecer FILENAME si se inicia fuera de la shell principal
if [[ -z "$FILENAME" ]]; then
    if [ -f "$ENV_FILE" ]; then
        FILENAME=$(cat "$ENV_FILE")
    else
        FILENAME="consolidado"
    fi
fi

SALIDA_FILE="$SALIDA_DIR/${FILENAME}.txt"

while true; do
    shopt -s nullglob
    archivos_txt=("$ENTRADA_DIR"/*.txt)
    
    if [ ${#archivos_txt[@]} -gt 0 ]; then
        for archivo in "${archivos_txt[@]}"; do
            if [ -f "$archivo" ]; then
                # Adjuntar la información al archivo consolidado final
                cat "$archivo" >> "$SALIDA_FILE"
                
                # Garantizar que haya un salto de línea limpio al final para que no se peguen registros
                if [ "$(tail -c1 "$SALIDA_FILE" | wc -l)" -eq 0 ]; then
                    echo "" >> "$SALIDA_FILE"
                fi
                
                # Mover el archivo procesado de forma segura
                nombre_archivo=$(basename "$archivo")
                mv "$archivo" "$PROCESADO_DIR/"
                
                # Registrar el log con el formato oficial
                fecha_hora=$(date +"%d/%m/%Y %H:%M:%S")
                echo "$fecha_hora - Procesado archivo $nombre_archivo" >> "$LOG_FILE"
            fi
        done
    fi
    sleep 3
done
EOF

            chmod +x "$ENTORNO_DIR/consolidar.sh"
            echo "[✓] Entorno de directorios creado exitosamente en '$ENTORNO_DIR'."
            echo "[✓] Archivo 'consolidar.sh' generado con permisos de ejecución."
            ;;
            
        2)
            if [ ! -d "$ENTORNO_DIR" ]; then
                echo "[X] Error: Primero debe crear el entorno usando la Opción 1."
                continue
            fi

            if [ -f "$PID_FILE" ]; then
                PID_REGISTRADO=$(cat "$PID_FILE")
                if kill -0 "$PID_REGISTRADO" 2>/dev/null; then
                    echo "[!] El proceso de consolidación ya está corriendo en segundo plano (PID: $PID_REGISTRADO)."
                    continue
                fi
            fi
            
            echo "$FILENAME" > "$ENV_FILE"
            echo "[*] Iniciando el proceso de consolidación..."
            
            nohup "$ENTORNO_DIR/consolidar.sh" > /dev/null 2>&1 &
            NUEVO_PID=$!
            echo "$NUEVO_PID" > "$PID_FILE"
            
            echo "[✓] Proceso iniciado con éxito en segundo plano con PID $NUEVO_PID."
            echo "    Monitoreando periódicamente archivos '.txt' en '$ENTRADA_DIR'."
            ;;
            
        3)
            if [ -f "$SALIDA_FILE" ]; then
                echo "=================================================="
                echo "   LISTADO DE ALUMNOS ORDENADOS POR PADRÓN"
                echo "=================================================="
                sort -n "$SALIDA_FILE"
                echo "=================================================="
            else
                echo "[X] Error: El archivo '${FILENAME}.txt' no existe en la carpeta 'salida'."
                echo "    Asegúrese de haber corrido la consolidación con archivos de entrada."
            fi
            ;;
            
        4)
            if [ -f "$SALIDA_FILE" ]; then
                echo "=================================================="
                echo "           LAS 10 NOTAS MÁS ALTAS"
                echo "=================================================="
                awk 'NF > 0 {print $NF, $0}' "$SALIDA_FILE" | sort -rn | head -n 10 | cut -d' ' -f2-
                echo "=================================================="
            else
                echo "[X] Error: El archivo '${FILENAME}.txt' no existe."
            fi
            ;;
            
        5)
            if [ -f "$SALIDA_FILE" ]; then
                read -p "Ingrese el número de padrón a buscar: " padron_buscado
                if [[ -z "$padron_buscado" ]]; then
                    echo "[!] El padrón no puede ser una cadena vacía."
                else
                    resultado=$(awk -v p="$padron_buscado" '$1 == p' "$SALIDA_FILE")
                    if [[ -n "$resultado" ]]; then
                        echo ""
                        echo "--------------------------------------------------"
                        echo "Resultados obtenidos para el padrón '$padron_buscado':"
                        echo "--------------------------------------------------"
                        echo "$resultado"
                        echo "--------------------------------------------------"
                    else
                        echo "[-] No se encontraron registros con el padrón '$padron_buscado'."
                    fi
                fi
            else
                echo "[X] Error: El archivo de salida aún no ha sido creado."
            fi
            ;;
            
        6)
            if [ -f "$LOG_FILE" ]; then
                echo "=================================================="
                echo "            LOG DE PROCESAMIENTO"
                echo "=================================================="
                cat "$LOG_FILE"
                echo "=================================================="
            else
                echo "[-] El archivo de log 'procesado.log' aún no tiene registros."
            fi
            ;;
            
        7)
            echo "Saliendo del sistema de gestión. ¡Éxitos en la cursada!"
            break
            ;;
            
        *)
            echo "[!] Opción incorrecta. Ingrese un valor válido entre 1 y 7."
            ;;
    esac
done