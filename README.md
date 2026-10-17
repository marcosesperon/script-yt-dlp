# script-yt-dlp

Un script de shell para descargar **de uno en uno** una lista de vídeos con [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) y guardarlos como `.mp4` con el título que tú les pongas.

Le das una lista con el título de cada vídeo y su URL, lo lanzas y él solo los va bajando. Si lo paras o se corta, al volver a lanzarlo **sigue por donde iba**: no repite lo que ya está descargado.

Sirve para cualquier URL que `yt-dlp` sepa descargar. Por ejemplo, las listas de reproducción `.m3u8` de Wistia, que es para lo que se hizo.

---

## Índice

- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Cómo se usa](#cómo-se-usa)
- [Cómo funciona por dentro](#cómo-funciona-por-dentro)
- [Parametrización](#parametrización)
- [Ejemplos de uso](#ejemplos-de-uso)
- [Problemas habituales](#problemas-habituales)

---

## Requisitos

| Qué | Para qué |
|-----|----------|
| **macOS** (o Linux) con **bash** | El script es un `.sh` de bash. En macOS viene de serie. |
| **[Homebrew](https://brew.sh)** | Para instalar las dos herramientas siguientes de forma sencilla. |
| **`yt-dlp`** | Es quien descarga realmente los vídeos. |
| **`ffmpeg`** | Lo usa `yt-dlp` para unir los trozos del vídeo y dejarlo como `.mp4`. |

Si falta `yt-dlp` o `ffmpeg`, el script te avisa al arrancar y no hace nada.

## Instalación

### 1. Instalar Homebrew (si no lo tienes)

Comprueba primero si ya lo tienes:

```bash
brew --version
```

Si te dice `command not found`, instálalo con el comando oficial de [brew.sh](https://brew.sh):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Al terminar, el instalador te muestra un par de comandos para añadir `brew` a tu terminal (en Macs con Apple Silicon). Cópialos y ejecútalos, o abre una terminal nueva.

### 2. Instalar `yt-dlp` y `ffmpeg`

```bash
brew install yt-dlp ffmpeg
```

Comprueba que han quedado bien instalados:

```bash
yt-dlp --version
ffmpeg -version
```

### 3. Mantener `yt-dlp` al día

Las webs de vídeo cambian a menudo y `yt-dlp` se actualiza muy seguido para seguirles el ritmo. Si una descarga que antes funcionaba empieza a fallar, lo primero es actualizar:

```bash
brew upgrade yt-dlp
```

### 4. Descargar el script

```bash
git clone https://github.com/marcosesperon/script-yt-dlp.git
cd script-yt-dlp
chmod +x descargar.sh
```

## Cómo se usa

1. **Apunta los vídeos en `cola-descargas.txt`**, por parejas de líneas: el título arriba y la URL debajo.

   ```
   Título Vídeo 1
   https://embed-cloudfront.wistia.com/deliveries/xxx.m3u8
   Título Vídeo 2
   https://embed-cloudfront.wistia.com/deliveries/yyy.m3u8
   ```

2. **Lánzalo:**

   ```bash
   ./descargar.sh
   ```

3. **Recoge los vídeos** en la carpeta `descargas/`, junto al script: `Título Vídeo 1.mp4`, `Título Vídeo 2.mp4`…

## Cómo funciona por dentro

- **Va de uno en uno y en orden.** Lee la cola de arriba abajo y descarga cada vídeo antes de pasar al siguiente.
- **Se puede lanzar las veces que quieras.** Antes de bajar cada vídeo mira si su `.mp4` ya existe en `descargas/` y, si existe, lo salta. Por eso al relanzarlo siempre sigue por donde iba.
- **Si lo cortas a medias** (Ctrl+C, cierre de la terminal…), el script para del todo y te enseña un resumen. La próxima vez, `yt-dlp` retoma el vídeo que estaba a medias en lugar de empezarlo de cero.
- **Si un vídeo falla** (lo normal es que su enlace haya caducado), lo apunta y sigue con el siguiente. Al final verás la lista de los que han fallado.
- **No toca la cola.** Para añadir vídeos basta con añadir más parejas título/URL a `cola-descargas.txt`.
- **Títulos con `/`:** la `/` no se puede usar en un nombre de fichero, así que se cambia por `-`.
- **Colas editadas en Windows:** si el fichero tiene saltos de línea de Windows (CRLF), no pasa nada; el script los limpia. Tampoco importa si la última línea no acaba en salto de línea o si hay líneas en blanco sueltas.

## Parametrización

Por defecto usa `cola-descargas.txt` y la carpeta `descargas/`, los dos junto al script (da igual desde dónde lo lances). Para usar otros, pásalos como variables al lanzarlo:

| Variable  | Para qué sirve                      | Valor por defecto                      |
|-----------|-------------------------------------|----------------------------------------|
| `COLA`    | Fichero con la lista de vídeos      | `cola-descargas.txt` (junto al script) |
| `DESTINO` | Carpeta donde se guardan los `.mp4` | `descargas/` (junto al script)         |

Si la carpeta de destino no existe, el script la crea.

Las opciones de `yt-dlp` están en la función `descargar_video` de `descargar.sh`:

- `--continue`: retoma lo que quedó a medias.
- `--no-overwrites`: nunca pisa un fichero que ya existe.
- `--remux-video mp4`: garantiza que el resultado sea `.mp4`.

**Código de salida:** `0` si todo ha ido bien y `1` si ha fallado algún vídeo. Sirve si algún día lo encadenas con otro script.

## Ejemplos de uso

Lanzarlo normalmente, desde la carpeta del script:

```bash
./descargar.sh
```

Lo que verás por cada vídeo:

```
----------------------------------------------
 Vídeo 3/10: Título Vídeo 3
----------------------------------------------
[download]  42.7% of ~ 310.25MiB at 8.10MiB/s ETA 00:21
```

Y al terminar:

```
==============================================
 Resumen
==============================================
 Descargados: 7
 Saltados (ya existían): 2
 Fallidos: 1
   - Título Vídeo 8
==============================================
```

Usar otra cola u otra carpeta de destino:

```bash
COLA=otra-cola.txt DESTINO=~/Movies/curso ./descargar.sh
```

## Problemas habituales

- **«ERROR: no encuentro 'yt-dlp'» (o `ffmpeg`):** falta instalarlo. Mira el apartado [Instalación](#instalación).
- **Un vídeo falla:** casi siempre es que el enlace ha caducado (los `.m3u8` de Wistia lo hacen). Consigue la URL nueva, cámbiala en la cola y relanza; los que ya estaban descargados se saltan. Si sigue fallando, actualiza `yt-dlp` con `brew upgrade yt-dlp`.
- **Quiero volver a bajar un vídeo:** borra su `.mp4` de `descargas/` y relanza el script.
- **«Permission denied» al lanzarlo:** dale permiso de ejecución con `chmod +x descargar.sh`.
