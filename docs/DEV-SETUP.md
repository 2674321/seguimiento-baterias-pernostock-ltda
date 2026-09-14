# DEV-SETUP.md — Seguimiento de Baterías (PernoStock Ltda.)

Guía para reproducir el entorno de desarrollo y ejecutar Seguimiento de Baterías en el
PC actual (Linux con X11), usando **mise** para la versión de Ruby.

> Software histórico recuperado de material de trabajo de **PernoStock Ltda.**
> No representa software en uso actual por la empresa.

## Requisitos

- Linux con display X11 (probado en `DISPLAY=:0`).
- GTK3 + librerías nativas de desarrollo (para build de `gtk3` y `sqlite3` gems):
  ```bash
  sudo apt install libgtk-3-dev libgirepository1.0-dev libsqlite3-dev build-essential pkg-config
  ```
  (En este PC ya están presentes: `libgtk-3-dev` 3.24 y `libsqlite3-dev` 3.45.)
- [mise](https://mise.jdx.dev) instalado.

## Versión de Ruby

- **Requerida:** Ruby 3.2.x (original: **3.2.2** en Windows, según `Instrucciones de instalación.txt`).
- **Instalada por mise:** Ruby 3.2.11 (resuelta por `.ruby-version` = `3.2`).

## Versión de gems

Definidas en `Gemfile`:

| Gem | Finalidad |
|---|---|
| `gtk3` | Interfaz gráfica GTK3 |
| `sqlite3` | Base de datos SQLite |
| `write_xlsx` | Exportación de la base a Excel |

(Stdlib: `date`, `fileutils`, `yaml`, `time`; `glib2` viene con `gtk3`.)

## Instalación

Dentro de la carpeta del proyecto:

```bash
cd 15_seguimiento-baterias-pernostock-ltda
mise install          # asegura Ruby 3.2 (usa .ruby-version)
bundle install        # instala las gems en la Ruby de mise
```

## Ejecución

```bash
# App completa (arranca: ventana de carga → ventana principal)
mise exec -- bundle exec ruby main.rbw

# Renderizado de la ventana principal con base de datos demo vacía (prueba de interfaz)
DISPLAY=:0 mise exec -- bundle exec ruby _scripts/dev/prueba_interfaz.rb
```

> La app usa rutas relativas: `NOMBRE_DB = 'base_de_datos.db'`, así que se ejecuta
> desde la raíz del repo.

## Datos de prueba / demo

- NO usar la base `Copias_de_seguridad/Datos preedeterminados/base_de_datos.db`
  (contiene **datos reales** de PernoStock; se conserva solo como plantilla histórica).
- Para probar se usa una base **vacía** que la app crea al arrancar (`base_de_datos.db`,
  ignorada por git). Con el arranque se crean las tablas `tabla_de_datos`,
  `tabla_de_registro` y `flag_de_creacion_de_tabla`.

## Validación sintáctica

```bash
for f in *.rb *.rbw; do mise exec -- ruby -c "$f"; done
```

Todos los archivos pasan `ruby -c` en este entorno.

## Prueba básica

1. `DISPLAY=:0 mise exec -- bundle exec ruby _scripts/dev/prueba_interfaz.rb`
   → abre la ventana principal "Ventana principal de búsqueda" con DB vacía y devuelve 0.
2. `bundle exec ruby main.rbw` → secuencia completa de arranque (ventana de carga, luego
   ventana principal), sin errores y sin segfault al salir.
3. Captura en `assets/seguimiento_baterias_ventana_principal.png` (toma real del entorno).

## Datos de runtime que se regeneran

Ignorados por git (`.gitignore`): `base_de_datos.db`, `Ultima_operacion.yaml`,
`Ultima_copia_de_seguridad_automatica.yaml`, `counter.yaml`, `configuracion.yaml`,
`archivo.yaml`, `datos.xlsx`, `Copias_de_seguridad/*`, `archivos_guardados/`.

## Problemas conocidos (resueltos)

Resueltos en la estabilización de 2026; se documentan por trazabilidad:

- **Arranque no mostraba la ventana principal:** el `destroy` de la ventana de carga
  ejecutaba `exit`, terminando la app a los 5 s antes de mostrar la interfaz.
- **Segfault al salir:** `at_exit { BackupAndExit.backup_exit }` abría un `Gtk.main`
  durante la salida y provocaba segfault.
- **NameError `Mesaa`** al eliminar un registro de historial.
- **Crash en estadísticas** al agrupar por "MODELO" cuando había filas nulas.
- **Redefiniciones múltiples** de helpers de mensaje (`show_message`, `show_message_window`,
  `mostrar_ventana_de_error`, `handle_search_error`) que causaban "method redefined warnings"
  y mensajes duplicados.
- **`Gtk.main` anidados** dentro de callbacks (`calendario.rb`, `date_search_window.rb`,
  `configuracion_cop_seg.rb`) que congelaban la interfaz.
- **`require_relative 'history_window_reset_window '`** (espacio final) → LoadError.
- **Deprecaciones `Gtk::Stock::*`** reemplazadas por etiquetas de texto.

Resumen completo en `docs/AUDITORIA.md`.