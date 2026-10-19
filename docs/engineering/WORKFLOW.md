# Flujo GitHub → OpenCode → revisión → merge

**Fuente de verdad:** main contiene documentación y código revisados. El GDD y roadmap v0.1 contienen decisiones confirmadas y propuestas que aún requieren aprobación.

## Ciclo por hito

1. Vincular tarea a R0–R8 y GDD. Definir qué se entrega y, explícitamente, qué queda fuera.
2. Crear rama corta feat/r2-..., fix/..., chore/r0-... desde main actualizado. Un propósito por rama.
3. Prompt versionado bajo docs/prompts/opencode. OpenCode primero inspecciona y plantea plan/contratos/tests.
4. Codificar por incrementos y probar en paralelo, con commits pequeños. Cualquier cambio fuera de scope vuelve a diseño.
5. **Review intermedio obligatorio** si >5 archivos de código, aproximadamente >400 líneas o >3 sesiones, o riesgo crítico de estado/seguridad. Revisión mediante draft PR o SHA de diff y evidencia. Corregir antes de seguir.
6. Abrir PR; incluir checklist y evidencias reales: Godot import/headless, tests, vídeo/capturas para cámara/arte, resultados y errores conocidos. Revisor inspecciona el diff, no solo la descripción.
7. BLOCKER/MAJOR impiden merge. Tras arreglarlos: repetir tests y revisión de cambios nuevos. Solo merge con aprobación explícita del autor. Actualizar roadmap/gates con pruebas, no por optimismo.

## Gates mínimos

- Arranca/parses en versión Godot reportada, o se indica PENDING si no se ejecutó.
- Tests automatizados para lógica y casos negativos; manual cuando proceda, sin declarar tests inexistentes.
- Integridad: inputs inválidos, acciones duplicadas y state guards del núcleo.
- Arquitectura: sin ciclos, sin reglas tácticas en sprites/HUD, sin nuevos monolitos.
- Cámara: yaw 0/90/180/270; pitch 30/50/65/78/84; zoom, sombras, alturas, occlusión, selección y continuidad.
- Arte: marcar proxy como PROXY, masters y derechos verificados antes de asset comercial.
- Rendimiento: comparativas con hardware y métricas si el PR declara mejoras.

## Auditorías periódicas de mantenimiento

**Cadencia obligatoria, adicional al review de toda PR:** revisar arquitectura al **cierre de cada milestone** o **cada 2 PRs de código fusionadas dentro de un milestone**, lo que suceda antes. En ramas largas, efectuar una revisión intermedia antes de esos límites. En features de gameplay o datos, auditar antes si se detectan duplicaciones, código monolítico, fallos de reglas o dependencias nuevas.

**Proceso:**
1. Registrar en `docs/engineering/audits/` un archivo por auditoría siguiendo [la plantilla](ARCHITECTURE_AUDIT_TEMPLATE.md), en el PR de cierre del hito o un PR específico de mantenimiento. Guardar versiones, commit base y evidencia.
2. Revisar fronteras entre módulos, flujo de estado y señales, complejidad creciente, funciones de responsabilidad mixta, duplicación, seguridad/integridad, pruebas negativas y regresiones.
3. Clasificar hallazgos como BLOCKER / MAJOR / MINOR / SUGGESTION. **BLOCKER/MAJOR bloquean la siguiente integración afectada**; MINOR puede incorporarse a backlog con hito y justificación. Nunca reescribir masivamente sin plan.
4. Rechazar abstracción especulativa: preferir cambios pequeños que reduzcan acoplamiento sin inventar frameworks. Un archivo largo no es un fallo por sí mismo; se revisa cohesión y dependencia.
5. Una auditoría no sustituye la review de cada PR. Cada refactor incluye tests de comportamiento conservado, y los tests realmente ejecutados se distinguen de los pendientes.

**CI y ramas:** automatizar importación Godot headless y tests en GitHub Actions **una vez que se verifique y fije una versión de Godot reproducible**. Para PRs con código/escenas, si no hay editor ejecutable ni evidencia equivalente verificable, gate técnico PENDING y **no merge sin resolverlo o excepción de pruebas acordada expresamente**. Las PRs exclusivamente de documentación no requieren ejecutar Godot si se verifica ese alcance.

**Godot/Git:** mantener un solo `project.godot` en la raíz; `.godot/` y `*.translation` deben ignorarse sin borrar caché local. Conservar las fuentes y metadatos `*.import` y `*.uid` que determinan importación/identidad; no ignorarlos globalmente. Revisar `README.md` modificado y recursos sin seguimiento antes de aplicar staging.

## Gestión de revisión

Review BLOCKER, MAJOR, MINOR, SUGGESTION; reportar archivo/línea, impacto y solución. Un milestone largo puede fraccionarse en PR A (import baseline) y PR B (presentation) para revisar antes de acumular deuda.

## Protecciones GitHub recomendadas (pendientes de habilitación por dueño)

En Settings / Branches / rulesets: PR obligatorio para main, bloquear push directo, checks obligatorios cuando existan, resolver threads, exigir revisión. Esta documentación NO habilita técnicamente branch protection; si no permite auto-aprobación en repo solo-dev, aplicar de forma disciplinada revisión en PR sin fingir un segundo revisor humano.

## Directorio local único acordado

**Ruta exclusiva de trabajo:** `C:\Dev\RPG-Tactics-3D-Prototype`. El autor ha reunido todos los materiales allí. OpenCode debe buscar, leer, desarrollar, probar y generar entregables únicamente bajo esa raíz. No solicitar ZIPs o carpetas externas si el material ya está presente. La presencia local de un ZIP/escena **no** implica que se haya versionado: inspeccionar `git status`, conservar el baseline inicialmente en sus rutas `scenes/`, `scripts/` y `art/` y preparar PR antes de mover o borrar nada. El script de referencia antiguo solo se importa con revisión y trazabilidad.

## Estado y próximos prompts para R2

- [Diagnóstico R2](../prompts/opencode/R2_CAMERA_PRESENTATION.md): **fase de solo lectura ya completada**, conservada como antecedente histórico, no como instrucción permanente.
- [PR A — Baseline Godot](../prompts/opencode/R2_BASELINE_PR_A.md): prompt **condicionado al merge autorizado de PR #1 y a una segunda autorización del autor para comenzar PR A**. Solo versionar y comprobar el único proyecto Godot existente, sin implementar modos adaptativos.
- PR B — Presentación dependiente del pitch: **no autorizada**, se diseña después de la revisión de PR A.

El autor comunicó que los materiales están dentro de `C:\Dev\RPG-Tactics-3D-Prototype`. OpenCode inspeccionó allí `project.godot`, `scenes/`, `scripts/`, `art/` y `.godot/` sin seguimiento Git y `README.md` modificado; no encontró el ZIP. **Es suficiente tomar la escena local como baseline provisional, sin afirmar equivalencia byte a byte con el ZIP.** El import debe respetar las rutas actuales hasta que haya razones para moverlas: *nunca un segundo project.godot*. Si una modificación de rama, merge o checkout afectara los cambios locales, detenerse y preparar preservación explícita antes de tocar nada.

**Versión Godot por verificar:** OpenCode informó de `config/features = ["4.7", "GL Compatibility"]` en el proyecto local, pero no encontró un ejecutable Godot en `PATH` ni una variable `GODOT*`. La presencia de `4.7` **no demuestra** la versión del editor instalado ni compatibilidad con 4.2. Localizar un ejecutable real, registrar `--version` y fijar versión reproducible solo después de ejecutar pruebas; no modificar `config/features` por intuición.
