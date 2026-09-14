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

- Código histórico recuperado, **auditado y estabilizado**.
- La interfaz principal se renderiza correctamente en Linux/X11 (`main.rbw` arranca
  completo; prueba de interfaz con DB demo vacía disponible).
- Bugs de arranque y salida resueltos; mensajería y validaciones consolidados. Detalle
  completo en `docs/AUDITORIA.md`.

## Versión

Histórico: **1.0** (proyecto de formación, ene–feb 2024). Documentación original citaba
"VER 3.0". Versionado de publicación no determinado (repositorio recuperado).

## Runtime

- Ruby **3.2.x** (originalmente **3.2.2** en Windows/RubyDevkit; reproducible con mise en 3.2).
- GUI: **GTK3** (`gtk3` gem).
- Base de datos: **SQLite** (`sqlite3` gem).
- Sistema operativo originalmente objetivo: **Windows**. En Linux la variante GTK
  funciona con display X11.

## Entrypoint

- `main.rbw` (punto de entrada) → `bundle exec ruby main.rbw`.

## Repositorio

- Este repo pasó a ser la versión **plana** publicada del proyecto:
  <https://github.com/2674321/seguimiento-baterias-pernostock-ltda>
- El antiguo monorepo histórico (con los demás proyectos en subcarpetas) queda
  preservado en la rama `historico-monorepo-2024` del mismo repositorio.

## Dependencias (gems)

`gtk3`, `sqlite3`, `write_xlsx`. Stdlib: `date`, `fileutils`, `yaml`, `time`; `glib2` viene con `gtk3`.

## Cómo probar

Ver `docs/DEV-SETUP.md`. Resumen:

```bash
cd 15_seguimiento-baterias-pernostock-ltda
mise install
bundle install
bundle exec ruby main.rbw      # app completa
DISPLAY=:0 mise exec -- bundle exec ruby _scripts/dev/prueba_interfaz.rb   # ventana principal con DB demo
```

## Notas

- El repositorio NO contiene datos reales de PernoStock (ver `docs/DEV-SETUP.md`).
- Artefactos de runtime (`base_de_datos.db`, `configuracion.yaml`, `archivo.yaml`,
  copias de seguridad, etc.) se regeneran y están ignorados por git.