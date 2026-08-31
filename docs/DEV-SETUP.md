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

(Stdlib: `date`, `fileutils`, `yaml`; `glib2` viene con `gtk3`.)

## Instalación

Dentro de la carpeta del proyecto:

```bash
cd 05 - seguimiento-baterias-pernostock-ltda
mise install          # asegura Ruby 3.2 (usa .ruby-version)
bundle install        # instala las gems en la Ruby de mise
```

## Ejecución

```bash
# App completa (ver problemas conocidos — el arranque original no muestra la ventana principal)
mise exec -- bundle exec ruby main.rbw

# Renderizado de la ventana principal con base de datos demo vacía (prueba de interfaz)
DISPLAY=:0 mise exec -- bundle exec ruby _scripts/dev/prueba_interfaz.rb
```

> La app usa rutas relativas: `NOMBRE_DB = 'base_de_datos.db'` y `BACKUP_PATH`
> se resuelve desde el directorio del script, así que se ejecuta desde la raíz del repo.

## Datos de prueba / demo

- NO usar la base `Copias_de_seguridad/Datos preedeterminados/base_de_datos.db`
  (contiene **datos reales** de PernoStock; se conserva solo como plantilla histórica).
- Para probar se usa una base **vacía** que la app crea al arrancar (`base_de_datos.db`,
  ignorada por git). Con la prueba de interfaz se crean las tablas
  `tabla_de_datos`, `tabla_de_registro`, `indicadores`/`flag_de_creacion_de_tabla`.

## Validación sintáctica

```bash
for f in *.rb *.rbw; do mise exec -- ruby -c "$f"; done
```

Todos los archivos pasan `ruby -c` en este entorno.

## Prueba básica

1. `DISPLAY=:0 mise exec -- bundle exec ruby _scripts/dev/prueba_interfaz.rb`
   → abre la ventana principal "Ventana principal de búsqueda" con DB vacía.
2. Captura en `assets/seguimiento_baterias_ventana_principal.png` (toma real del entorno).

## Problemas conocidos

Clasificación: **BLOQUEANTE** / **IMPORTANTE** / **MENOR** / **HISTÓRICO**

- **BLOQUEANTE — arranque no muestra la ventana principal.**
  `show_loading_window.rb` conecta el `destroy` de la ventana de carga a `exit`
  (línea ~34). `main.rbw` también conecta `destroy` a `create_interface`. Como el
  handler de `exit` se registra primero, a los 5 s la app termina antes de mostrar la
  ventana principal. (Corregible quitando el `exit` del destroy.)
- **IMPORTANTE — segfault al salir.**
  `backup_exit.rb` registra `at_exit { BackupAndExit.backup_exit }`, que abre un
  `Gtk.main` durante la salida del proceso y provoca **segfault**. La prueba de
  interfaz usa `exit!` para evitarlo.
- **MENOR — corregido en este repo DEV:**
  `history_window_interface.rb:7` tenía `require_relative 'history_window_reset_window '`
  (espacio final) → LoadError que impedía arrancar. Se quitó el espacio.
- **HISTÓRICO:** la app fue creada para Windows/RubyDevkit 3.2.2. El monorepo original
  `01 - seguimiento-baterias-pernostock-ltda` queda intacto como archivo histórico.
