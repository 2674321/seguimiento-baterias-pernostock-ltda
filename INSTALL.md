# Instalación — Seguimiento de Baterías (Pernostock Ltda.)

Aplicación de escritorio **Ruby + GTK3 + SQLite** desarrollada para Windows.

## Requisitos

- Windows 10/11
- [RubyInstaller **Ruby+Devkit 3.2.2-1 (x64)**](https://rubyinstaller.org/downloads/archives/)
- Gemas: `gtk3`, `sqlite3`, `write_xlsx`

## Pasos

1. Instalar Ruby+Devkit (incluye MSYS2; aceptar las opciones por defecto).
2. Instalar las gemas:
   ```bash
   gem install gtk3 sqlite3 write_xlsx
   ```
3. Ejecutar la aplicación:
   ```bash
   ruby "Seguimiento baterias/main.rbw"
   ```
   También funciona con doble clic: la extensión `.rbw` abre sin consola.

## Notas

- La aplicación trabaja sobre una base SQLite (`base_de_datos.db`).
- Las instrucciones originales (feb 2024) están en `Instrucciones de instalación.txt`
  y los instaladores offline en `Instalación/`.
