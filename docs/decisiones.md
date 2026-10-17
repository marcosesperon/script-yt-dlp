# Bitácora de decisiones

## 2026-10-17 — Script de descarga de la cola de vídeos con yt-dlp

### 1. La petición tal como se ha entendido

Un script de shell (`descargar.sh`, en la raíz de THEPROCESS) que:

1. Lee `cola-descargas.txt` por parejas: una línea con el título y la siguiente con la URL `.m3u8`. Lee también la última pareja aunque el fichero no termine en salto de línea.
2. Procesa los vídeos **de uno en uno** y en el orden de la cola.
3. Antes de cada vídeo comprueba si ya existe `descargas/<título>.mp4`. Si existe, lo salta.
4. Si no existe, lo descarga con `yt-dlp` y lo guarda directamente como `descargas/<título>.mp4`, con el título de la línea anterior a la URL.
5. Muestra el progreso en la terminal: un encabezado `Vídeo N/18: <título>` y la barra de progreso de `yt-dlp`.
6. Si un vídeo falla, lo apunta y sigue con el siguiente. Al terminar muestra un resumen: descargados, saltados y fallidos (con su título).
7. Se lanza a mano y en primer plano, cuando quieras. Si se corta (Ctrl+C, cierre de la terminal…), al relanzarlo continúa donde lo dejó: los vídeos completos se saltan y el que estaba a medias se retoma.
8. No modifica `cola-descargas.txt`.

**Confirmación:** confirmada por el usuario el 2026-10-17.

### 2. Preguntas y respuestas

- **P1.** Como el script se podrá lanzar en cualquier momento, ¿cómo sabe qué vídeos ya están descargados para no repetirlos?
  - **R1.** Comprobando si ya existe `descargas/<título>.mp4`. Si existe, se salta. La cola (`cola-descargas.txt`) no se modifica.
- **P2.** Si un vídeo falla (por ejemplo, por un enlace caducado), ¿qué hace el script?
  - **R2.** Lo anota como fallido, sigue con el siguiente y al final muestra un resumen de descargados, saltados y fallidos.
- **P3.** ¿Cómo se lanzará normalmente?
  - **R3.** En la terminal y en primer plano, viendo el progreso. Ctrl+C lo para y al relanzarlo continúa.

### 3. Fuentes analizadas

- `cola-descargas.txt`: 18 vídeos en parejas título/URL `.m3u8` de Wistia. Sin CRLF, sin duplicados y la última línea sin salto final.
- `descargas/`: contiene 2 `.mp4` de una tanda anterior que no aparecen en la cola.
- Herramientas: `yt-dlp` 2026.08.19 y `ffmpeg` (Homebrew, `/opt/homebrew/bin`).

### 4. Decisiones

- Para saber qué está hecho se mira si existe el `.mp4` y no se usa un fichero de registro. **Por qué:** es lo más simple, no toca la cola, y si se borra un vídeo basta con relanzar el script para volver a bajarlo.
- Si un vídeo falla, se sigue con el siguiente y se resume al final. **Por qué:** un enlace caducado no debe bloquear el resto de la cola.
- El script se ejecuta en primer plano con la barra de progreso de `yt-dlp`. **Por qué:** así se ve en todo momento por dónde va, y como cada relanzamiento continúa donde lo dejó, no hace falta nada más elaborado.

### 5. Alternativas descartadas

- **Borrar de la cola cada vídeo descargado:** descartada porque modifica el fichero original y se pierde la lista completa.
- **Fichero de registro aparte:** descartada porque es otro fichero que mantener y puede desincronizarse de lo que hay realmente en disco.
- **Parar en el primer error / reintentar antes de seguir:** descartadas. Se prefiere que la cola avance y ver los fallos juntos al final.
- **Ejecución en segundo plano con log:** descartada por ahora porque basta con lanzarlo en la terminal.

### 6. Pendiente de comprobar

- Que las URLs de Wistia sigan vigentes en el momento de descargar.
- **Prueba real del script:** solo se ha comprobado la sintaxis (`bash -n`). El usuario prefirió hacer él la primera prueba de descarga, así que se canceló la prueba con 2 vídeos en el scratchpad y se borraron sus temporales.
- La cola ha cambiado desde que se analizó: la última entrada es ahora «Copywriting con SUN». No afecta al script, que lee la cola en cada ejecución.

## 2026-10-17 — README.md del script de descarga

### 1. La petición tal como se ha entendido

Crear un `README.md` en la raíz del repositorio que explique para qué sirve `descargar.sh` y cómo funciona, y que pase a ser **la documentación principal** del proyecto:

1. **Contenido:** todo lo que hoy recoge `docs/documentacion.md` (qué hace, formato de la cola, requisitos, comportamiento ante cortes y fallos, variables `COLA` y `DESTINO`, opciones de `yt-dlp`, código de salida, ejemplos de uso y de salida por pantalla), en lenguaje coloquial y sencillo.
2. **Ejemplos genéricos:** como el repositorio es público, sin referencias a la carpeta «THEPROCESS» ni a títulos reales del curso. Se usan títulos y URLs ficticios y se explica que vale para cualquier URL que `yt-dlp` sepa descargar (incluidas las `.m3u8` de Wistia).
3. **`docs/documentacion.md`:** se queda solo con una breve remisión al `README.md`, para no mantener dos versiones.
4. No se toca `descargar.sh` ni `cola-descargas.txt`.
5. **Requisitos e instalación:** el README incluye un apartado con los requisitos y cómo instalar `yt-dlp` y `ffmpeg` con Homebrew (añadido por el usuario al confirmar).

**Confirmación:** confirmada por el usuario el 2026-10-17, con el añadido del punto 5.

### 2. Preguntas y respuestas

- **P1.** Ya existe `docs/documentacion.md` con una explicación detallada. ¿Qué enfoque para el README: resumen con enlace, README completo duplicando contenido, o mover la documentación al README?
  - **R1.** Mover la documentación al README.
- **P2.** ¿Qué se hace entonces con `docs/documentacion.md`: dejarla como remisión, borrarla o dejarla tal cual?
  - **R2.** Dejarla como remisión al README.
- **P3.** El repositorio es público y la documentación menciona «THEPROCESS», Wistia y títulos reales de vídeos. ¿Ejemplos genéricos o mantener las referencias?
  - **R3.** Genéricos.
- **P4.** ¿Se confirma la petición tal como se ha entendido?
  - **R4.** Sí, y además el README debe incluir los requisitos y cómo instalar `ffmpeg` y `yt-dlp` con Homebrew.

### 3. Fuentes analizadas

- `descargar.sh` (commit `50125b9`).
- `docs/documentacion.md` (commit `50125b9`).
- Visibilidad del repositorio en GitHub: pública.

### 4. Decisiones

- El README es la documentación principal. **Por qué:** es lo primero que se ve en GitHub y así hay un único sitio que mantener.
- `docs/documentacion.md` queda como remisión. **Por qué:** evita contenido duplicado y mantiene la ruta de documentación habitual.
- Ejemplos ficticios. **Por qué:** el repositorio es público y no conviene exponer nombres del curso ni de carpetas personales.

### 5. Alternativas descartadas

- **README corto con enlace a `docs/documentacion.md`:** descartada; el usuario prefiere que el README sea la documentación principal.
- **README completo manteniendo también `documentacion.md`:** descartada por duplicar contenido.
- **Borrar `docs/documentacion.md`:** descartada; se prefiere dejar la remisión.
- **Mantener las referencias reales al curso:** descartada por ser un repositorio público.

### 6. Pendiente de comprobar

- `docs/decisiones.md` ya publicado menciona la carpeta y títulos reales del curso; se deja tal cual por ser bitácora.

## 2026-10-17 — Eliminar del historial la documentación anterior

### 1. La petición tal como se ha entendido

Que en el historial de git no quede ningún rastro de la versión anterior de `docs/documentacion.md` (la que tenía la documentación completa, con referencias a la carpeta y a títulos reales del curso). Se reescribe el único commit del repositorio para que ya incluya el `README.md`, la `docs/documentacion.md` reducida a una remisión y esta bitácora, y se sube a GitHub con push forzado.

**Confirmación:** confirmada por el usuario el 2026-10-17.

### 2. Preguntas y respuestas

- **P1.** ¿Se reescribe el único commit con el estado actual y se sube con push forzado?
  - **R1.** Sí, reescribir y subir.

### 3. Fuentes analizadas

- Historial: un único commit (`50125b9`) en `main`, sin otras ramas ni etiquetas en el remoto.
- Repositorio en GitHub: público y sin forks.

### 4. Decisiones

- `git commit --amend` del único commit + `git push --force-with-lease`. **Por qué:** con un solo commit es la forma más simple de que el contenido antiguo no quede en el historial; `--force-with-lease` evita pisar cambios del remoto que no se tengan en local.

### 5. Alternativas descartadas

- **Commit nuevo encima:** descartada porque la versión anterior seguiría en el historial.
- **Herramientas de reescritura (`git filter-repo`, BFG):** descartadas por innecesarias con un solo commit.
- **Reescribir solo en local:** descartada; el usuario quiere que se suba ya.

### 6. Pendiente de comprobar

- GitHub puede seguir mostrando el commit antiguo (`50125b9`) por enlace directo hasta que haga su limpieza interna. Si hiciera falta borrarlo ya, hay que pedírselo al soporte de GitHub.

## 2026-10-17 — Autoría del repositorio con la cuenta personal

### 1. La petición tal como se ha entendido

Que el commit del repositorio figure con la cuenta personal de GitHub del usuario y no quede en el historial de GitHub el correo corporativo. Se configura `marcosesperon@gmail.com` como correo de git **solo en este repositorio**, se reescribe el único commit con esa autoría (autor y committer) y se sube con push forzado.

**Confirmación:** confirmada por el usuario el 2026-10-17.

### 2. Preguntas y respuestas

- **P1.** ¿Qué correo se usa como autor: el noreply de GitHub o un correo personal?
  - **R1.** Correo personal: `marcosesperon@gmail.com`.
- **P2.** ¿El correo se configura solo en este repositorio o en la configuración global de git?
  - **R2.** Sin respuesta explícita; se aplica la opción recomendada (solo en este repositorio).

### 3. Fuentes analizadas

- Commit `6904f25`: autor y committer con el correo corporativo, heredado de `~/.gitconfig`.
- Cuenta de GitHub autenticada en `gh`: `marcosesperon`.

### 4. Decisiones

- `git config user.email` local + `git commit --amend --reset-author` + `git push --force-with-lease`. **Por qué:** con un solo commit basta con reescribirlo; la configuración local evita que los siguientes commits de este repositorio vuelvan a salir con el correo corporativo sin afectar a los proyectos de trabajo.

### 5. Alternativas descartadas

- **Cambiar el correo en la configuración global:** descartada porque los commits de los proyectos de trabajo también saldrían con el correo personal.
- **Noreply de GitHub:** descartada; el usuario prefiere su correo personal.

### 6. Pendiente de comprobar

- Que `marcosesperon@gmail.com` esté dado de alta en la cuenta de GitHub; si no, el commit no se vinculará a la cuenta.
- El commit anterior (`6904f25`, con el correo corporativo) puede seguir accesible por enlace directo hasta la limpieza interna de GitHub.
