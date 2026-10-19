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

## Gestión de revisión

Review BLOCKER, MAJOR, MINOR, SUGGESTION; reportar archivo/línea, impacto y solución. Un milestone largo puede fraccionarse en PR A (import baseline) y PR B (presentation) para revisar antes de acumular deuda.

## Protecciones GitHub recomendadas (pendientes de habilitación por dueño)

En Settings / Branches / rulesets: PR obligatorio para main, bloquear push directo, checks obligatorios cuando existan, resolver threads, exigir revisión. Esta documentación NO habilita técnicamente branch protection; si no permite auto-aprobación en repo solo-dev, aplicar de forma disciplinada revisión en PR sin fingir un segundo revisor humano.

## Directorio local único acordado

**Ruta exclusiva de trabajo:** `C:\Dev\RPG-Tactics-3D-Prototype`. El autor ha reunido todos los materiales allí. OpenCode debe buscar, leer, desarrollar, probar y generar entregables únicamente bajo esa raíz. No solicitar ZIPs o carpetas externas si el material ya está presente. La presencia local de un ZIP/escena **no** implica que se haya versionado: inspeccionar `git status`, decidir la ubicación definitiva de fuentes en `experiments/` y preparar PR antes de mover o borrar nada. El script de referencia antiguo solo se importa con revisión y trazabilidad.

## Estado actual de la prueba de cámara

El paquete RTM_Isometric_Art_PoC_v0_2_billboard_fix.zip y/o su contenido **han sido colocados por el autor en la raíz local o sus subdirectorios**, pero su ruta exacta y estado Git se verificarán durante el diagnóstico. En GitHub, la rama poc/isometric-2d-art-gate solo tenía documentación y un parche en la última comprobación. OpenCode debe examinar fuentes locales antes de proponer importación a experiments/iso_art_gate, con revisión de licencias, sin copiar ciegamente a game/ ni al antiguo Maker.
