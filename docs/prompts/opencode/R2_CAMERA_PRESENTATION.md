# Prompt OpenCode R2 — Trabajar exclusivamente en el repositorio local

**Ruta única del proyecto:** `C:\Dev\RPG-Tactics-3D-Prototype`. El autor ha indicado que ha colocado **todos los materiales en esa carpeta**. Toda inspección, documentación, implementación, pruebas, arte y entregables de este hito deben gestionarse **dentro de este árbol**, en subdirectorios apropiados. No exigir, crear, consultar ni asumir carpetas como `C:\Dev\RTM_Isometric_Art_PoC_v0_2_billboard_fix.zip` fuera del proyecto.

**Modo actual: SOLO DIAGNÓSTICO Y PLAN.** No editar archivos, no crear ramas ni commits, no modificar el prototipo ni realizar merges hasta que el autor revise y autorice el plan.

## Referencias obligatorias

Leer, en la versión disponible localmente y respetando su estado de borrador:
- `AGENTS.md`
- `docs/GDD.md` (en especial §§5 y 15)
- `docs/ROADMAP.md` (R0 y R2, especialmente R2-09)
- `docs/engineering/ARCHITECTURE.md`
- `docs/engineering/WORKFLOW.md`
- `docs/engineering/REVIEW_CHECKLIST.md`
- `docs/engineering/adr/ADR-0001-pitch-presentation.md`

La gobernanza nueva está en la rama `chore/r0-engineering-workflow` / PR #1, aún pendiente de merge. **No asumir que `main` ya tiene estos archivos.** Comprobar la rama local y el estado de los cambios sin sobrescribir ni forzar un switch.

## Paso 0 — Inspección sin cambios

1. Confirmar ubicación actual y `git rev-parse --show-toplevel`; verificar que coincide exactamente con `C:\Dev\RPG-Tactics-3D-Prototype`. Revisar `git status --short`, `git branch --show-current`, `git remote -v` y ramas disponibles. **No ejecutar `git clean`, `git reset --hard`, mover/eliminar archivos ni hacer `checkout/switch` si afecta archivos locales.**
2. Inventariar bajo esa misma raíz los archivos de proyecto, `project.godot`, scripts `.gd`, escenas `.tscn`, SVG/PNG, ZIP del PoC, GDD, roadmap y documentación. Distinguir **versionado / modificado / untracked / extraído / empaquetado**. No inferir que un archivo dentro de la carpeta ya está en GitHub.
3. Buscar el prototipo PoC isométrico **solamente dentro de esta raíz** (ZIP o carpeta extraída), incluyendo subcarpetas como `experiments/` o `imports/`. Si hay variantes, indicar rutas exactas y diferencias; priorizar la v0.2 con fix de `BaseMaterial3D.BILLBOARD_FIXED_Y`, sin sobrescribir versiones del autor. **Si faltara, registrar el bloqueo y preguntar antes de inventarlo.**
4. Localizar versión del ejecutable de Godot si está disponible desde el entorno y revisar el error previo `SpriteBase3D.BILLBOARD_FIXED_Y` como antecedente, no como defecto necesariamente presente.
5. Inspeccionar en lectura el script/escena de terreno, cámara, selección, unidad 2D y props. Identificar acoplamientos, problemas de orientación, oclusión, persistencia y posibles regresiones. No dar por buenos módulos que aún no existen.
6. Si hay cambios locales ajenos a esta tarea, **conservarlos intactos** y explicar cómo continuar sin perderlos. Evitar duplicar proyectos `game/` y `experiments/` sin revisión.

## Objetivo funcional del hito (no implementar todavía)

R2 — permitir cámara giratoria isométrica con zoom y alturas XYZ, y adaptar la presentación de personajes y props según pitch cerca de vista topdown. Mantener modelo de cuadrícula, selección y posiciones lógicas independientes del render.

- `CameraController`: yaw/pitch/zoom, salida de pose sin reglas tácticas.
- `PitchPresentationResolver`: lógica comprobable, umbrales e histéresis configurables para `ISO_FULL`, `ISO_HYBRID`, `TOPDOWN`; **umbrales son parámetros de prueba, no decisiones definitivas**.
- `ActorPresenter` y `PropPresenter`: modo de representación, pivote de pies, sombra, fallback de assets y transiciones visuales.
- Mantener picking/terreno separados de cambios de representación; ningún estado lógico se duplica entre modos.
- Antes de abstraer, justificar si esos módulos separados hacen falta realmente. No crear un framework completo ni un nuevo monolito.

## Entregables del plan que debes presentarme antes de programar

1. **Diagnóstico real:** árbol encontrado, Git, Godot, PoC localizado, scripts relevantes, errores/acoplamientos y deuda verificable con archivo/función.
2. **Arquitectura propuesta:** dependencias y responsabilidades concretas, APIs mínimas y dónde vivirá el PoC en el repositorio.
3. **Plan incremental y de ramas:** A) importar/versionar baseline original en la repo y probarlo; revisión del primer PR; B) refactor y modo visual por pitch, con revisión intermedia si el tamaño lo exige. Sin auto-merge.
4. **Plan de tests:** Godot import/headless, regresión del parser anterior, resolver con thresholds e histéresis, yaw 0/90/180/270, pitch 30/50/65/78/84, zoom, altura, props, picking, identidad/posición estable, recurso faltante, ausencia de parpadeo.
5. **Riesgos y medidas anti-bugs/anti-spaghetti:** responsabilidades mezcladas, estados duplicados, referencias inválidas, oclusión, facings, recursos no localizados, visualización indebida de unidades ocultas, cambios destructivos de Git y deuda introducida por refactors.

**Fuera de alcance:** combate, scheduler, Maker, inventario, IA de batalla, animaciones laterales y generación masiva de arte. El arte temporal no equivale a validación de pipeline IA.

## Criterios de futuras entregas (una vez autorizado el plan)

- Todos los archivos de trabajo y pruebas estarán **dentro de `C:\Dev\RPG-Tactics-3D-Prototype`**, con estructura justificada y commits en ramas; no crear ZIPs/proyectos como fuente de verdad fuera de Git.
- Ejecutar tests reales y registrar comandos, entorno, logs y vídeo/capturas; no afirmar PASS si faltan pruebas.
- Review intermedio obligatorio si >5 archivos de código, ~400 líneas modificadas, >3 sesiones o cambios críticos. Review final de cada rama; resolver BLOCKER/MAJOR antes del merge.
- PR descriptivo y checklist, merge solo tras aprobación explícita del autor.

**Tu próxima respuesta debe ser exclusivamente el diagnóstico y plan de cinco apartados. No escribas código aún.**
