# Prompt OpenCode R2 — Importar el prototipo y probar representación por pitch

**No es una implementación, es un encargo para ejecutar en OpenCode sobre el clon local.** Lee primero AGENTS.md, docs/GDD.md (§5, §15), docs/ROADMAP.md (R0/R2), docs/engineering/ARCHITECTURE.md, docs/engineering/WORKFLOW.md y ADR-0001.

## Objetivo

Resolver el defecto visual del Sprite3D billboard al inclinar cámara hacia topdown, sin abandonar la estética ilustrada ni alterar la simulación táctica. NO hacer combate, IA, scheduler, maker ni animaciones de batalla en este milestone.

## Paso 0 (sin programar aún)

- Verificar git status, remotos, rama y versión Godot de C:\Dev\RPG-Tactics-3D-Prototype. No sobreescribir trabajo local.
- Comprobar que existe el ZIP RTM_Isometric_Art_PoC_v0_2_billboard_fix.zip (o escena previamente extraída); si no, pedir ruta exacta antes de inventar scripts.
- Inspeccionar escena/script de origen; documentar deuda del monolito actual (terreno/cámara/selección/props/HUD juntos).
- Presentar plan mínimo de interfaces, archivos y tests antes de editar. Preparar dos PRs si lo requiere alcance.
- Rama objetivo feat/r2-pitch-presentation a partir de main con gobernanza; no crear proyectos sueltos fuera de Git.

## Entregable A: baseline importado

Incorporar en experiments/iso_art_gate (o estructura equivalente justificada) project.godot, .gd, .tscn, SVGs y QA; conservar código fuente real dentro del repositorio. La PNG de comparación PC-001 es opcional y no entra sin licencia/trazabilidad; ofrecer fallback. Corregir BaseMaterial3D.BILLBOARD_FIXED_Y. Ejecución real Godot headless, pruebas manuales y evidencia, sin integrar como game runtime definitivo.

## Entregable B: presentación por pitch

Extraer responsabilidades del script monolítico:
- CameraController: yaw/pitch/zoom, emite pose.
- PitchPresentationResolver: sin nodos; ISO_FULL, ISO_HYBRID, TOPDOWN, umbrales configurables e histeresis.
- ActorPresenter y PropPresenter: modo visual, token/sprite, pivote pies, sombra/occlusión, blend, y fallback para asset faltante.
- Terreno y selección conservan mismos datos/alturas. **No se modifica el estado táctico** al cambiar pitch.

Probar primero sprite iso + token cenital proxy, luego transición híbrida sin nuevos assets IA. Prohibido presentar una escala vertical simple como solución estética definitiva.

## Quality Gates

- Ejecutar import headless y proyecto interactivo Godot 4 e incluir comandos/salida, versión y errores.
- Tests de umbrales/histeresis al subir y bajar, estabilidad ±1–3°, pitch 30/50/65/78/84, yaw 0/90/180/270, zoom cercano/lejos, alturas, agua, props altos, terreno y picking.
- Mismo actor/posición/selección/facción antes-después; sin doble representación visible ni parpadeos ni sombras desancladas.
- Fallback de textura faltante manejado, ninguna dependencia a red, sin exposición de información oculta.
- Grabación corta y capturas: iso, híbrido y topdown, más conos/árboles que se ven raros.
- Al superar 5 archivos de código / ~400 líneas / 3 sesiones, **parar y pedir review intermedio**.
- Abrir PR, rellenar REVIEW_CHECKLIST, no auto-mergear. Documentar gate técnico vs artístico.

Respuesta del agente: rama/PR/commits; archivos y responsabilidades; comandos de tests+salidas; evidencia; bugs y deuda; PASS/FAIL/PENDING honestos.
