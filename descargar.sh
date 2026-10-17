#!/bin/bash
#
# descargar.sh — Descarga, de uno en uno, los vídeos de cola-descargas.txt
#
# La cola va por parejas de líneas: primero el título y debajo la URL (.m3u8).
# Cada vídeo se guarda como "<título>.mp4" en la carpeta de destino.
# Si el .mp4 ya existe, se salta: así puedes lanzarlo tantas veces como quieras
# y siempre continúa por donde lo dejó.
#
# Uso:   ./descargar.sh
# Opcional: COLA=otra-cola.txt DESTINO=otra-carpeta ./descargar.sh

set -u

# Carpeta donde vive el script, para que funcione lo lances desde donde lo lances
v_dir_script="$(cd "$(dirname "$0")" && pwd)"

# Parámetros (se pueden cambiar con variables de entorno al lanzarlo)
v_cola="${COLA:-$v_dir_script/cola-descargas.txt}"
v_destino="${DESTINO:-$v_dir_script/descargas}"

# Contadores para el resumen final
v_total=0
v_num=0
v_descargados=0
v_saltados=0
v_fallidos=0
v_lista_fallidos=""


# Comprueba que tenemos todo lo necesario antes de empezar
comprobar_requisitos() {
    local v_herramienta
    for v_herramienta in yt-dlp ffmpeg; do
        if ! command -v "$v_herramienta" >/dev/null 2>&1; then
            echo "ERROR: no encuentro '$v_herramienta'. Instálalo con: brew install $v_herramienta"
            exit 1
        fi
    done

    if [ ! -f "$v_cola" ]; then
        echo "ERROR: no encuentro la cola de descargas: $v_cola"
        exit 1
    fi

    mkdir -p "$v_destino"
}


# Cuenta cuántos vídeos hay en la cola (líneas no vacías / 2) para mostrar "N/total"
contar_videos() {
    local v_lineas
    v_lineas=$(grep -c . "$v_cola")
    echo $(( v_lineas / 2 ))
}


# Deja el título listo para usarlo como nombre de fichero:
# la "/" no se puede usar en un nombre, así que la cambiamos por "-"
limpiar_titulo() {
    echo "${1//\//-}"
}


# Descarga un vídeo. Devuelve 0 si ha ido bien y algo distinto si ha fallado.
#   $1 = URL   $2 = nombre del fichero (sin .mp4)
descargar_video() {
    local v_url="$1"
    # yt-dlp usa "%" para sus plantillas, así que lo escapamos por si algún título lo lleva
    local v_plantilla="${2//%/%%}"

    # El "< /dev/null" es importante: sin él yt-dlp se "come" las líneas de la cola
    # que está leyendo el bucle y nos saltaríamos vídeos sin enterarnos.
    yt-dlp \
        --continue \
        --no-overwrites \
        --remux-video mp4 \
        -o "$v_destino/$v_plantilla.%(ext)s" \
        "$v_url" < /dev/null
}


# Muestra el resumen de cómo ha ido todo
mostrar_resumen() {
    echo
    echo "=============================================="
    echo " Resumen"
    echo "=============================================="
    echo " Descargados: $v_descargados"
    echo " Saltados (ya existían): $v_saltados"
    echo " Fallidos: $v_fallidos"
    if [ "$v_fallidos" -gt 0 ]; then
        printf "%b" "$v_lista_fallidos"
    fi
    echo "=============================================="
}


# Si pulsas Ctrl+C paramos del todo (no pasamos al siguiente vídeo) y enseñamos el resumen.
# Lo que estaba a medias se retoma la próxima vez que lances el script.
interrumpido() {
    echo
    echo ">> Interrumpido por el usuario. Al relanzar el script continuará por aquí."
    mostrar_resumen
    exit 130
}


# ---------------------------------------------------------------------------
# Programa principal
# ---------------------------------------------------------------------------

comprobar_requisitos
trap interrumpido INT

v_total=$(contar_videos)
echo "Cola: $v_cola"
echo "Destino: $v_destino"
echo "Vídeos en la cola: $v_total"

# Leemos la cola de dos en dos líneas (título + URL).
# El "|| [ -n ... ]" sirve para no perder la última URL si el fichero no acaba en salto de línea.
while IFS= read -r v_titulo && { IFS= read -r v_url || [ -n "$v_url" ]; }; do
    # Quitamos un posible \r por si la cola se ha editado en Windows
    v_titulo="${v_titulo%$'\r'}"
    v_url="${v_url%$'\r'}"

    # Si hay líneas en blanco sueltas, las ignoramos
    [ -z "$v_titulo" ] && continue

    v_num=$(( v_num + 1 ))
    v_nombre=$(limpiar_titulo "$v_titulo")
    v_fichero="$v_destino/$v_nombre.mp4"

    echo
    echo "----------------------------------------------"
    echo " Vídeo $v_num/$v_total: $v_titulo"
    echo "----------------------------------------------"

    # Si ya está descargado, pasamos al siguiente
    if [ -f "$v_fichero" ]; then
        echo ">> Ya existe, lo salto."
        v_saltados=$(( v_saltados + 1 ))
        continue
    fi

    # Damos por buena la descarga solo si yt-dlp termina bien Y el .mp4 está en su sitio
    if descargar_video "$v_url" "$v_nombre" && [ -f "$v_fichero" ]; then
        echo ">> OK: $v_nombre.mp4"
        v_descargados=$(( v_descargados + 1 ))
    else
        echo ">> FALLO: no se ha podido descargar. Sigo con el siguiente."
        v_fallidos=$(( v_fallidos + 1 ))
        v_lista_fallidos="${v_lista_fallidos}   - ${v_titulo}\n"
    fi
done < "$v_cola"

mostrar_resumen

# Código de salida: 0 si todo bien, 1 si algún vídeo ha fallado
[ "$v_fallidos" -eq 0 ]
