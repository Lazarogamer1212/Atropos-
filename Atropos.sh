#!/data/data/com.termux/files/usr/bin/bash
# ================================================================
# ATROPOS • SUITE LOCAL
# Git-ready launcher for Termux
# Repository: https://github.com/Lazarogamer1212/Atropos-.git
# ================================================================

set -o pipefail
VERSION="2.0.0"

# ---------- Colores ----------
C='\033[1;36m'; M='\033[1;35m'; G='\033[1;32m'; Y='\033[1;33m'
R='\033[1;31m'; W='\033[1;37m'; D='\033[0;90m'; N='\033[0m'

# ---------- Rutas ----------
SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || printf '%s' "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd -P)"

if [ "$(basename "$SCRIPT_DIR")" = "integración" ] || [ "$(basename "$SCRIPT_DIR")" = "integracion" ]; then
    PROJECT_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd -P)"
else
    PROJECT_DIR="$SCRIPT_DIR"
fi

if command -v git >/dev/null 2>&1; then
    GIT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
    [ -n "$GIT_ROOT" ] && PROJECT_DIR="$GIT_ROOT"
fi

ATROPOS_DIR="$PROJECT_DIR/atropos"
KULSHEDRA_DIR="$PROJECT_DIR/kulshedra"
INTEGRACION_DIR="$PROJECT_DIR/integración"
[ -d "$INTEGRACION_DIR" ] || INTEGRACION_DIR="$PROJECT_DIR/integracion"
PREFIX_BIN="${PREFIX:-/data/data/com.termux/files/usr}/bin"
COMMAND_PATH="$PREFIX_BIN/atropos"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/atropos"
LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/atropos"
REPO_URL="https://github.com/Lazarogamer1212/Atropos-.git"

# ---------- Utilidades ----------
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

pause_screen() {
    printf '\n%sPulsa ENTER para continuar...%s' "$D" "$N"
    read -r
}

run_python() {
    local file="$1"; shift
    if cmd_exists python3; then python3 "$file" "$@"
    elif cmd_exists python; then python "$file" "$@"
    else printf '%s[!] Python no está instalado.%s\n' "$R" "$N"; return 127
    fi
}

version_of() {
    local tool="$1"
    if ! cmd_exists "$tool"; then printf '%sNO DISPONIBLE%s' "$R" "$N"; return; fi
    case "$tool" in
        python3) python3 --version 2>&1 | head -n1 ;;
        node) node --version 2>&1 | head -n1 ;;
        clang++) clang++ --version 2>&1 | head -n1 ;;
        *) "$tool" --version 2>&1 | head -n1 ;;
    esac
}

find_atropos_entry() {
    local candidate
    for candidate in "$ATROPOS_DIR/atropos.py" "$ATROPOS_DIR/main.py" "$ATROPOS_DIR/__main__.py"; do
        if [ -f "$candidate" ]; then printf '%s\n' "$candidate"; return 0; fi
    done
    return 1
}

find_project_marker() {
    [ -d "$PROJECT_DIR/.git" ] || [ -f "$PROJECT_DIR/.git" ]
}

# ---------- Banner ----------
banner() {
    clear 2>/dev/null || true
    printf '%s╔══════════════════════════════════════════════════════════════╗%s\n' "$C" "$N"
    printf '%s║%s                         ATROPOS                            %s║%s\n' "$C" "$M" "$C" "$N"
    printf '%s║%s              SUITE LOCAL DE AUDITORÍA                    %s║%s\n' "$C" "$W" "$C" "$N"
    printf '%s║%s Nmap • Hydra • SQLmap • Atropos • Kulshedra • v%s       %s║%s\n' "$C" "$D" "$VERSION" "$C" "$N"
    printf '%s╚══════════════════════════════════════════════════════════════╝%s\n' "$C" "$N"
    printf '%sRepo: %s%s%s\n' "$D" "$W" "$PROJECT_DIR" "$N"
}

# ---------- Ayuda única ----------
help_menu() {
    banner
    cat <<__HELP__
${W}ATROPOS HELP — REFERENCIA UNIFICADA${N}

${C}COMANDOS${N}
  atropos                       Menú principal
  atropos help                  Esta ayuda
  atropos status                Diagnóstico del entorno
  atropos install               Instala dependencias y registra el comando
  atropos update                Actualiza el clon con git pull
  atropos nmap                  Menú Nmap
  atropos hydra                 Menú Hydra
  atropos sqlmap                Menú SQLmap
  atropos kulshedra             Menú Kulshedra
  atropos atropos [args...]     Ejecuta el Atropos local
  atropos doctor                Alias de status

${C}INSTALACIÓN DESDE GIT${N}
  git clone "$REPO_URL"
  cd Atropos-
  chmod +x atropos.sh
  ./atropos.sh install

  Después: atropos

  El comando global apunta al clon actual. No se copia una versión
  independiente a ~/.atropos; por eso git pull actualiza el código usado.

${C}NMAP — REDES Y SERVICIOS${N}
  nmap [opciones] objetivo
  -sn             Descubrimiento de hosts sin puertos
  -sT             TCP connect scan
  -sS             SYN scan cuando el entorno lo permite
  -sU             UDP scan
  -p 80,443       Puertos concretos
  -p 1-1000       Rango de puertos
  -p-             Todos los puertos TCP
  -F              Escaneo rápido
  -sV             Detección de servicios/versiones
  -O              Intento de detección del sistema operativo
  -A              Funciones combinadas de detección/diagnóstico
  -Pn             Trata el objetivo como activo
  -n              Sin resolución DNS
  -T0 ... -T5     Temporización
  --script NAME   Script NSE
  -oN/-oX/-oG    Formatos de salida

  Ejemplos de laboratorio:
    nmap -sV 192.168.1.10
    nmap -p 22,80,443 192.168.1.10
    nmap -sn 192.168.1.0/24

${C}HYDRA — PRUEBAS DE AUTENTICACIÓN${N}
  hydra [opciones] objetivo servicio
  -l usuario       Usuario único
  -L archivo       Lista de usuarios
  -p contraseña    Contraseña única
  -P archivo       Lista de contraseñas
  -C archivo       Usuario:contraseña
  -s puerto        Puerto alternativo
  -S               TLS/SSL cuando el módulo lo admite
  -t tareas        Tareas paralelas
  -f               Detenerse al encontrar una credencial válida
  -V               Mostrar intentos detallados
  -o archivo       Guardar resultados
  -4 / -6          Forzar IPv4/IPv6
  -I / -R          Ignorar/continuar restauración

  Solo utilízalo en sistemas propios o expresamente autorizados.

${C}SQLMAP — AUDITORÍA DE SQL INJECTION${N}
  sqlmap [opciones]
  -u URL                 Objetivo HTTP
  -r archivo             Petición HTTP guardada
  -m archivo             Múltiples objetivos
  -p parámetro           Limitar parámetros
  --data="a=1&b=2"       Datos POST
  --cookie="..."         Cookie HTTP
  --headers="..."        Cabeceras adicionales
  --method=POST          Método HTTP
  --forms                Analizar formularios
  --crawl=PROFUNDIDAD    Rastreo controlado
  --level=1..5           Nivel de pruebas
  --risk=1..3            Riesgo de pruebas
  --threads=N            Concurrencia
  --batch                Valores predeterminados
  --banner               Información del DBMS cuando esté disponible
  --current-db           Base de datos actual cuando sea posible
  --dbs                  Bases de datos cuando sea posible
  --tables               Tablas del contexto seleccionado
  --columns              Columnas de una tabla
  -hh                    Ayuda extensa

  Ejemplo de laboratorio:
    sqlmap -u "http://127.0.0.1/item?id=1"

${C}ATROPOS LOCAL${N}
  Se busca automáticamente:
    $ATROPOS_DIR/atropos.py
    $ATROPOS_DIR/main.py
    $ATROPOS_DIR/__main__.py

  Los argumentos posteriores a 'atropos atropos' se conservan.

${C}KULSHEDRA${N}
  atropos kulshedra
  Ejecuta archivos .kul con bloques @python, @javascript/@js o @cpp/@c++.

${C}ESTRUCTURA ESPERADA${N}
  Atropos-/
  ├── atropos/
  ├── kulshedra/
  ├── integración/     (opcional)
  ├── atropos.sh       (o integración/atropos.sh)
  └── README.md        (recomendado)

${Y}SEGURIDAD${N}
  Nmap, Hydra y SQLmap pueden afectar sistemas reales. Utiliza la suite
  únicamente sobre objetivos propios o con autorización explícita.
__HELP__
    pause_screen
}

# ---------- Diagnóstico ----------
status() {
    local no_pause="${1:-0}" tool
    banner
    printf '\n%sESTADO DEL PROYECTO%s\n\n' "$W" "$N"
    printf '%-22s: %s\n' "Versión" "$VERSION"
    printf '%-22s: %s\n' "Proyecto" "$PROJECT_DIR"
    printf '%-22s: ' "Git"
    if find_project_marker; then
        printf '%sOK%s\n' "$G" "$N"
        if cmd_exists git; then
            printf '%-22s: %s\n' "Branch" "$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || printf 'desconocida')"
            printf '%-22s: %s\n' "Commit" "$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'desconocido')"
        fi
    else printf '%sNO ES CLON GIT%s\n' "$Y" "$N"; fi

    printf '%-22s: ' "Atropos"
    if find_atropos_entry >/dev/null 2>&1; then printf '%sOK%s (%s)\n' "$G" "$N" "$(find_atropos_entry)"
    else printf '%sNO DETECTADO%s\n' "$R" "$N"; fi

    printf '%-22s: ' "Kulshedra"
    [ -d "$KULSHEDRA_DIR" ] && printf '%sOK%s\n' "$G" "$N" || printf '%sNO DETECTADA%s\n' "$Y" "$N"
    printf '%-22s: ' "Integración"
    [ -d "$INTEGRACION_DIR" ] && printf '%sOK%s\n' "$G" "$N" || printf '%sOPCIONAL/NO DETECTADA%s\n' "$Y" "$N"
    printf '%-22s: ' "Comando global"
    [ -x "$COMMAND_PATH" ] && printf '%sINSTALADO%s -> %s\n' "$G" "$N" "$COMMAND_PATH" || printf '%sNO INSTALADO%s\n' "$Y" "$N"

    printf '\n%sHERRAMIENTAS%s\n' "$W" "$N"
    for tool in nmap hydra sqlmap python3 node clang++ git curl wget; do
        printf '%-22s: ' "$tool"
        if cmd_exists "$tool"; then printf '%s%s%s\n' "$G" "$(version_of "$tool")" "$N"
        else printf '%sNO DISPONIBLE%s\n' "$R" "$N"; fi
    done
    [ "$no_pause" = "1" ] || pause_screen
}

create_structure() {
    mkdir -p "$ATROPOS_DIR" "$KULSHEDRA_DIR" "$CONFIG_DIR" "$LOG_DIR"
}

# ---------- Registro Git-friendly ----------
register_command() {
    mkdir -p "$PREFIX_BIN" || { printf '%s[!] No se pudo crear %s%s\n' "$R" "$PREFIX_BIN" "$N"; return 1; }
    cat > "$COMMAND_PATH" <<__LAUNCHER__
#!/data/data/com.termux/files/usr/bin/bash
# ATROPOS launcher — points to the current Git clone.
exec bash "$SCRIPT_PATH" "\$@"
__LAUNCHER__
    chmod +x "$COMMAND_PATH"
    printf '%s[✓] Comando registrado:%s %s\n' "$G" "$N" "$COMMAND_PATH"
    printf '%s[✓] Fuente:%s %s\n' "$G" "$N" "$SCRIPT_PATH"
}

install_dependencies() {
    banner; create_structure
    if ! cmd_exists pkg; then
        printf '%s[!] Este instalador está preparado para Termux.%s\n' "$R" "$N"; pause_screen; return 1
    fi
    printf '%s[+] Actualizando índices de Termux...%s\n' "$C" "$N"
    pkg update -y || printf '%s[!] pkg update devolvió un error.%s\n' "$Y" "$N"

    printf '%s[+] Instalando herramientas...%s\n' "$C" "$N"
    local packages=(nmap hydra sqlmap python nodejs clang git curl wget) failed= package
    for package in "${packages[@]}"; do
        if pkg install -y "$package" >/dev/null 2>&1; then printf '  %s✓%s %s\n' "$G" "$N" "$package"
        else printf '  %s✗%s %s\n' "$R" "$N" "$package"; failed+=("$package"); fi
    done
    register_command || { pause_screen; return 1; }
    printf '\n'
    if [ "${#failed[@]}" -eq 0 ]; then printf '%s[✓] Entorno preparado correctamente.%s\n' "$G" "$N"
    else printf '%s[!] Paquetes pendientes: %s%s\n' "$Y" "${failed[*]}" "$N"; fi
    printf '%s[+] Ejecuta: atropos status%s\n' "$C" "$N"
    pause_screen
}

update_repo() {
    banner
    if ! find_project_marker; then
        printf '%s[!] Este directorio no parece un clon Git:%s\n%s\n' "$R" "$N" "$PROJECT_DIR"
        printf '%s    git clone %s%s\n' "$D" "$REPO_URL" "$N"; pause_screen; return 1
    fi
    if ! cmd_exists git; then printf '%s[!] Git no está instalado.%s\n' "$R" "$N"; pause_screen; return 1; fi
    printf '%s[+] Actualizando repositorio...%s\n' "$C" "$N"
    if git -C "$PROJECT_DIR" pull --ff-only; then
        printf '\n%s[✓] Repositorio actualizado.%s\n' "$G" "$N"
        printf '%s[+] El comando global ya utiliza este clon.%s\n' "$C" "$N"
    else
        printf '\n%s[!] git pull no pudo completarse automáticamente.%s\n' "$Y" "$N"
        printf '%s    Revisa: git -C "%s" status%s\n' "$D" "$PROJECT_DIR" "$N"
    fi
    pause_screen
}

# ---------- Ejecutores ----------
execute_atropos() {
    local entry rc
    entry="$(find_atropos_entry)" || {
        printf '%s[!] No existe atropos.py, main.py ni __main__.py en:%s\n    %s\n' "$R" "$N" "$ATROPOS_DIR"
        pause_screen; return 1
    }
    banner
    printf '%s[+] Ejecutando Atropos local:%s %s\n\n' "$C" "$N" "$entry"
    (cd "$(dirname "$entry")" && run_python "$entry" "$@")
    rc=$?
    printf '\n%s[+] Código de salida:%s %s\n' "$D" "$N" "$rc"
    pause_screen
    return "$rc"
}

run_command_with_pause() {
    "$@"; local rc=$?
    printf '\n%sCódigo de salida: %s%s\n' "$D" "$rc" "$N"; pause_screen; return "$rc"
}

# ---------- Menús ----------
menu_nmap() {
    while true; do
        banner; printf '%sNMAP%s\n\n' "$M" "$N"
        printf '%s1%s) Rápido\n%s2%s) Todos los puertos TCP\n%s3%s) Servicios/versiones\n%s4%s) Diagnóstico avanzado\n%s5%s) Argumentos personalizados\n%s6%s) Volver\n\n' "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G"
        printf 'Opción: '; read -r op
        case "$op" in
            1) read -rp 'Objetivo: ' target; run_command_with_pause nmap "$target" ;;
            2) read -rp 'Objetivo: ' target; run_command_with_pause nmap -p- "$target" ;;
            3) read -rp 'Objetivo: ' target; run_command_with_pause nmap -sV "$target" ;;
            4) read -rp 'Objetivo: ' target; run_command_with_pause nmap -A "$target" ;;
            5) read -rp "Argumentos (sin escribir 'nmap'): " -a args; run_command_with_pause nmap "${args[@]}" ;;
            6) return 0 ;;
            *) printf '%sOpción inválida.%s\n' "$R" "$N"; sleep 1 ;;
        esac
    done
}

menu_hydra() {
    while true; do
        banner; printf '%sHYDRA%s\n\n' "$M" "$N"
        printf '%s1%s) SSH autorizado\n%s2%s) FTP autorizado\n%s3%s) Argumentos personalizados\n%s4%s) Volver\n\n' "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G"
        printf 'Opción: '; read -r op
        case "$op" in
            1) read -rp 'Objetivo autorizado: ' target; read -rp 'Usuario: ' user; read -rp 'Diccionario: ' passlist; run_command_with_pause hydra -l "$user" -P "$passlist" "ssh://$target" ;;
            2) read -rp 'Objetivo autorizado: ' target; read -rp 'Usuario: ' user; read -rp 'Diccionario: ' passlist; run_command_with_pause hydra -l "$user" -P "$passlist" "ftp://$target" ;;
            3) read -rp "Argumentos (sin escribir 'hydra'): " -a args; run_command_with_pause hydra "${args[@]}" ;;
            4) return 0 ;;
            *) printf '%sOpción inválida.%s\n' "$R" "$N"; sleep 1 ;;
        esac
    done
}

menu_sqlmap() {
    while true; do
        banner; printf '%sSQLMAP%s\n\n' "$M" "$N"
        printf '%s1%s) URL local/de laboratorio\n%s2%s) Petición HTTP desde archivo\n%s3%s) Formularios\n%s4%s) Argumentos personalizados\n%s5%s) Volver\n\n' "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G"
        printf 'Opción: '; read -r op
        case "$op" in
            1) read -rp 'URL: ' url; run_command_with_pause sqlmap -u "$url" ;;
            2) read -rp 'Archivo de petición: ' req; run_command_with_pause sqlmap -r "$req" ;;
            3) read -rp 'URL: ' url; run_command_with_pause sqlmap -u "$url" --forms ;;
            4) read -rp "Argumentos (sin escribir 'sqlmap'): " -a args; run_command_with_pause sqlmap "${args[@]}" ;;
            5) return 0 ;;
            *) printf '%sOpción inválida.%s\n' "$R" "$N"; sleep 1 ;;
        esac
    done
}

# ---------- Kulshedra ----------
kulshedra_launcher() {
    local file="$1" tmp lang line rc
    [ -f "$file" ] || { printf '%s[!] No existe: %s%s\n' "$R" "$file" "$N"; return 1; }
    tmp="$(mktemp -d "${TMPDIR:-${PREFIX:-/data/data/com.termux/files/usr}/tmp}/kulshedra.XXXXXX")" || return 1
    lang=''; : > "$tmp/code"

    cleanup_kulshedra() { rm -rf "$tmp"; }
    run_block() {
        [ -s "$tmp/code" ] || return 0
        case "$lang" in
            python) run_python "$tmp/code" ;;
            javascript) if cmd_exists node; then node "$tmp/code"; else printf '%s[!] Node.js no está instalado.%s\n' "$R" "$N"; return 127; fi ;;
            cpp) if cmd_exists clang++; then clang++ "$tmp/code" -o "$tmp/program" && "$tmp/program"; else printf '%s[!] clang++ no está instalado.%s\n' "$R" "$N"; return 127; fi ;;
            *) printf '%s[!] Bloque sin lenguaje reconocido.%s\n' "$Y" "$N" ;;
        esac
        : > "$tmp/code"
    }

    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            '@python'*) run_block; lang='python' ;;
            '@javascript'*|'@js'*) run_block; lang='javascript' ;;
            '@cpp'*|'@c++'*) run_block; lang='cpp' ;;
            *) printf '%s\n' "$line" >> "$tmp/code" ;;
        esac
    done < "$file"
    run_block; rc=$?; cleanup_kulshedra; return "$rc"
}

menu_kulshedra() {
    while true; do
        banner; printf '%sKULSHEDRA%s\n\n' "$M" "$N"
        printf '%s1%s) Ejecutar archivo .kul\n%s2%s) Crear ejemplo\n%s3%s) Volver\n\n' "$G" "$G" "$G" "$G" "$G" "$G"
        printf 'Opción: '; read -r op
        case "$op" in
            1) read -rp 'Archivo .kul: ' file; run_command_with_pause kulshedra_launcher "$file" ;;
            2) create_structure; cat > "$KULSHEDRA_DIR/ejemplo.kul" <<'__KUL__'
@python
print("Hola desde Kulshedra")
__KUL__
               printf '%s[✓] Creado:%s %s\n' "$G" "$N" "$KULSHEDRA_DIR/ejemplo.kul"; pause_screen ;;
            3) return 0 ;;
            *) printf '%sOpción inválida.%s\n' "$R" "$N"; sleep 1 ;;
        esac
    done
}

menu_main() {
    create_structure
    while true; do
        banner; printf '%sMENÚ PRINCIPAL%s\n\n' "$M" "$N"
        printf '%s1%s) Configurar dependencias\n%s2%s) Nmap\n%s3%s) Hydra\n%s4%s) SQLmap\n%s5%s) Atropos\n%s6%s) Kulshedra\n%s7%s) Estado\n%s8%s) Ayuda completa\n%s9%s) Actualizar desde Git\n%s0%s) Salir\n\n' "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G" "$G"
        printf 'Opción: '; read -r op
        case "$op" in
            1) install_dependencies ;; 2) menu_nmap ;; 3) menu_hydra ;; 4) menu_sqlmap ;;
            5) execute_atropos ;; 6) menu_kulshedra ;; 7) status ;; 8) help_menu ;; 9) update_repo ;;
            0) printf '%sCerrando ATROPOS.%s\n' "$G" "$N"; return 0 ;;
            *) printf '%sOpción inválida.%s\n' "$R" "$N"; sleep 1 ;;
        esac
    done
}

# ---------- CLI ----------
main() {
    local command="${1:-menu}"
    shift || true
    case "$command" in
        help|ayuda|--help|-h) help_menu ;;
        status|doctor) status ;;
        install|setup) install_dependencies ;;
        update|upgrade) update_repo ;;
        menu) menu_main ;;
        nmap) menu_nmap ;;
        hydra) menu_hydra ;;
        sqlmap) menu_sqlmap ;;
        kulshedra) menu_kulshedra ;;
        atropos|run) execute_atropos "$@" ;;
        *) execute_atropos "$command" "$@" ;;
    esac
}

main "$@"
