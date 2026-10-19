# Instrucciones para agentes de desarrollo (OpenCode)

Ámbito: TheBioz/RPG-Tactics-3D-Prototype. Leer antes de modificar: docs/GDD.md, docs/ROADMAP.md, docs/engineering/ARCHITECTURE.md, docs/engineering/WORKFLOW.md y el prompt concreto del hito. **El GDD y roadmap v0.1 son borradores**: las opciones ABIERTO o PROPUESTO no son aprobaciones del usuario.

**Directorio único de desarrollo (indicado por el autor):** `C:\Dev\RPG-Tactics-3D-Prototype`. No salir de esa raíz para acceder al PoC, crear proyectos, dejar ZIPs u otros artefactos del juego. Buscar archivos existentes allí y **distinguir presencia en disco de seguimiento por Git** antes de proponer un cambio.

## Reglas de trabajo

1. Inspeccionar el repo y su estado git antes de tocar código. Trabajar en una rama corta, nunca hacer push directo ni merge automático a main. No sobrescribir cambios locales sin permiso.
2. Entregar un plan **antes de codificar** con archivos, responsabilidades, interfaces, pruebas, riesgos y decisiones bloqueantes. No desarrollar características fuera del hito.
3. Mantener los cambios pequeños y trazables. Preferir composición y servicios cohesivos; prohibido crear un God Object, copiar la misma lógica en UI e IA, dependencias circulares o señales que mutan estado arbitrariamente.
4. Domain/rules no debe depender de Godot scenes, HUD, sprites, audio ni cámara. El application layer valida los comandos; las presentaciones leen estado y resultados, nunca calculan daño, turnos o rangos.
5. GDScript tipado, nombres legibles, fallos explícitos y validación de entradas. No asumir que un click, una IA, una carga JSON o un mod son fuentes confiables.
6. En combate/turnos validar permisos, bando, acción disponible, unidad/objetivo existente, límites, ocupación, coste, distancia y duplicados. No permitir estado parcialmente mutado ante error, acciones infinitas ni dobles aplicaciones de daño.
7. Aleatoriedad con semilla/replay; lógica independiente de FPS, animación/hit-stop, audio y cámaras. Nunca activar efectos de gameplay por eventos de VFX.
8. Pruebas de camino feliz, bordes y casos negativos, más regresión por cada bug. Declarar versión Godot, comandos y salidas realmente ejecutadas; no llamar PASS a una escena sin probar.
9. **Revisión intermedia** si >5 archivos de código, aproximadamente >400 líneas modificadas o más de 3 sesiones de trabajo, o antes en cambios críticos. Pausar, compartir diff y tests y esperar review.
10. **Cierre de TODA rama** con PR, checklist, logs y vídeo si es visual. Resolver problemas BLOCKER/MAJOR, ejecutar regresión de nuevo y esperar aprobación explícita del autor para merge.
11. Separar art_source y game assets aprobados; conservar identidad, hash, procedencia y licencia comercial. Sin copiar arte ajeno, sin secretos/tokens/datos privados en repo público.
12. No portar código de RPG-Tactics-Maker por defecto: inspeccionar contratos y aprobar migraciones individualmente.

## Revisión periódica de arquitectura (obligatoria)

- **Toda PR de código:** diff y QA revisados antes del merge, incluidos refactors, bugs y scripts pequeños.
- **Revisión intermedia:** al superar 5 archivos de código, unas 400 líneas, tres sesiones, o ante cualquier cambio de contrato crítico. Pausar y entregar diff; no esperar al final del hito.
- **Auditoría de arquitectura periódica:** al cerrar **cada milestone** o tras **dos PRs de código fusionadas** dentro del mismo milestone, lo que ocurra primero. Evaluar dependencias, duplicación, estado autoritativo, scripts sobrecargados, eventos/señales, pruebas, fallos, exploits y deuda. Documento: [plantilla](docs/engineering/ARCHITECTURE_AUDIT_TEMPLATE.md).
- **Bugs recurrentes o regresiones** activan auditoría anticipada del subsistema afectado; no esconderlos tras arreglos superficiales.
- Registrar decisiones y deuda con severidad, responsable, PR de origen y fecha/hito previsto para resolver. **BLOCKER/MAJOR sin resolver impide fusionar** salvo decisión excepcional documentada y explícitamente aceptada por el autor (nunca para corrupción de estado, secretos, pérdida de datos o tests críticos fallidos).
- Al programar en R2: **un solo proyecto Godot con `project.godot` en la raíz del repositorio**; no crear proyectos anidados. Versionar `*.import` y `*.uid` relevantes junto a sus fuentes, ignorar `.godot/` y artefactos generados sin borrarlos del equipo.

## Respuesta esperada al completar una tarea

ID de hito, rama/commit/PR; archivos y contratos cambiados; qué queda fuera; tests ejecutados con evidencia; riesgos, casos límite y pendientes; Gate propuesto PASS/FAIL/PENDING; siguiente paso acotado. No autoproclamarse code-reviewed ni fusionar sin autorización.
