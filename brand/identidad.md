# Identidad de sistema — Seguimiento de Baterías

## Nombre oficial

**Seguimiento de Baterías · PernoStock Ltda.**

Alias internos: `SegBat`, `SeguimientoBaterias`

## Logo / Icono

Icono representativo: una batería estilizada con una flecha circular de seguimiento,
representando el rastreo y control del estado de las baterías.

Archivos fuente y derivados:

| Archivo | Descripción |
|---|---|
| `_assets/svg/icono.svg` | Fuente vectorial (escalar sin pérdida) |
| `_assets/png/icono_48.png` | Menú/Cinnamon (48×48) |
| `_assets/png/icono_64.png` | Panel (64×64) |
| `_assets/png/icono_128.png` | HiDPI / preferido (128×128) |
| `_assets/png/icono_256.png` | Reserva / splash (256×256) |

El PNG a 128×128 se usa como ícono de ventana por defecto de la aplicación.

## Paleta de colores

| Rol | Color | Uso |
|---|---|---|
| Batería (cuerpo) | `#374151` | Rectángulo exterior |
| Batería (terminales) | `#6b7280` | Pestañas superiores |
| Carga (relleno) | `#0ea5e9` → `#06b6d4` | Nivel de carga interior |
| Seguimiento (flecha) | `#f59e0b` | Flecha circular / indicador |
| Texto primario | `#111827` | Títulos |
| Texto secundario | `#6b7280` | Subtítulos, notas |
| Fondo | `#f9fafb` | Ventanas principales |

## Aplicación del icono

- **Menú de aplicaciones / escritorio:** PNG instalado en
  `~/.local/share/icons/hicolor/{size}/apps/seguimiento-baterias-pernostock.png`.
- **Ventana principal:** `Gtk::Window.set_default_icon_name("seguimiento-baterias-pernostock")`
  aplicado al iniciar la interfaz.
- **Barra de título:** GTK usa el ícono del tema del sistema automáticamente.

## Nombre del archivo `.desktop`

`seguimiento-baterias-pernostock.desktop` (estándar XDG, sin caracteres especiales).