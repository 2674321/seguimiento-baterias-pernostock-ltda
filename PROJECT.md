# PROJECT.md — Seguimiento de Baterías

## Nombre

Seguimiento de Baterías

## Empresa / contexto

**PernoStock Ltda.**

> Software histórico recuperado de material de trabajo de PernoStock Ltda.
> (enero–febrero 2024, proyecto de formación en Técnico en Programación).
> Se preserva como referencia histórica; no representa software en uso actual
> por la empresa.

## Estado

- Código histórico recuperado y preparado para entorno DEV en el PC actual: **completo**.
- La interfaz principal se renderiza correctamente en Linux/X11 con una base de datos
  demo vacía, pero la **secuencia de arranque original no muestra la ventana principal**
  por un bug identificado (ver "Problemas conocidos" y `docs/DEV-SETUP.md`).

## Versión

Histórico: **1.0** (proyecto de formación, ene–feb 2024). Documentación original cita
"VER 3.0". Versionado de publicación no determinado (repositorio recuperado).

## Runtime

- Ruby **3.2.x** (originalmente **3.2.2** en Windows/RubyDevkit; reproducible con mise en 3.2).
- GUI: **GTK3** (`gtk3` gem).
- Base de datos: **SQLite** (`sqlite3` gem).
- Sistema operativo originalmente objetivo: **Windows**. En Linux la variante GTK
  funciona con display X11.

## Entrypoint

- `main.rbw` (punto de entrada) → `bundle exec ruby main.rbw`
  (Originalmente: `ruby "Seguimiento baterias/main.rbw"` desde la raíz del monorepo.)

## Repositorio

- Este repo es un **repo DEV independiente** extraído del monorepo histórico
  `01 - seguimiento-baterias-pernostock-ltda` (que permanece intacto como archivo histórico).
- Histórico publicado (monorepo): https://github.com/2674321/seguimiento-baterias-pernostock-ltda
- Este repo independiente aún **no** está publicado en GitHub (decisión pendiente).

## Dependencias (gems)

`gtk3`, `sqlite3`, `write_xlsx`. Stdlib: `date`, `fileutils`, `yaml`; `glib2` viene con `gtk3`.

## Cómo probar

Ver `docs/DEV-SETUP.md`. Resumen:

```bash
cd 05 - seguimiento-baterias-pernostock-ltda
mise install
bundle install
bundle exec ruby main.rbw      # app completa (ver problemas conocidos)
bundle exec ruby _scripts/dev/prueba_interfaz.rb   # renderiza la ventana principal con DB demo
```

## Notas / problemas conocidos

Ver `docs/DEV-SETUP.md` → "Problemas conocidos":
- **BLOQUEANTE:** `show_loading_window.rb` cierra la app con `exit` al destruirse la
  ventana de carga (5 s), antes de mostrar la ventana principal.
- **IMPORTANTE:** `backup_exit.rb` usa `at_exit { BackupAndExit.backup_exit }` que abre un
  `Gtk.main` durante la salida del proceso y provoca **segfault** al cerrar.
- **MENOR:** `history_window_interface.rb` tenía un espacio final en un `require_relative`
  (`'history_window_reset_window '`) — corregido en este repo DEV (necesario para arrancar).
- La app fue diseñada para Windows. En Linux la GUI requiere X11.
