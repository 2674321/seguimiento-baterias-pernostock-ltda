# Seguimiento de Baterías

Sistema de escritorio para la gestión y seguimiento de baterías, desarrollado en
**Ruby 3.2.2 + GTK3 + SQLite** para **Pernostock Ltda**.

> **⚠️ Proyecto antiguo / de formación** (Técnico en Programación, enero–febrero 2024).
> Se publica como referencia histórica; no representa el nivel actual de desarrollo.

## Funcionalidades

- Registro, búsqueda y edición de baterías con validación de entradas
- Historial de operaciones con búsqueda por fecha y orden invertible
- Estadísticas de uso
- Copias de seguridad: manuales, automáticas y temporizadas
- Exportación de la base de datos a Excel
- Manual de usuario integrado (`user_manual.rb`)

## Stack

| Componente | Tecnología |
|---|---|
| Lenguaje | Ruby 3.2.2 |
| GUI | GTK3 |
| Base de datos | SQLite |
| Configuración | YAML |

## Estructura

```
├── Seguimiento baterias/      ← código fuente (~60 módulos)
│   ├── main.rbw               ← punto de entrada
│   ├── user_manual.rb         ← manual de usuario integrado
│   └── ...
├── Instalación/               ← notas de despliegue (README marcado desactualizado)
└── Instrucciones de instalación.txt
```

## Ejecución

Requiere Ruby 3.2.2 con bindings GTK3 (ver `Instrucciones de instalación.txt`):

```bash
ruby "Seguimiento baterias/main.rbw"
```

La aplicación crea/copias su base de datos desde los datos preestablecidos
incluidos en `Seguimiento baterias/Copias_de_seguridad/Datos preedeterminados/`.

## Autor

**Patricio Varela C.** (CA2OPX) · [ORCID 0009-0002-1087-9445](https://orcid.org/0009-0002-1087-9445) · [github.com/2674321](https://github.com/2674321)

## Cita

Si utilizas este trabajo, por favor cítelo — ver [CITATION.cff](CITATION.cff).
