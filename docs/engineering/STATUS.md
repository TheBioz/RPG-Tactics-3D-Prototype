# Estado auditado del repositorio — 2026-10-19

- Main ya contiene docs/GDD.md y docs/ROADMAP.md en v0.1: **borradores, no aprobaciones finales**.
- Main conserva pre-GDD y arte PC-001; no incorpora todavía el proyecto Godot isométrico completo.
- Rama poc/isometric-2d-art-gate solo documenta experimento y corrección billboard, no script/assets reales.
- **Diagnóstico posterior de OpenCode:** encontró en `C:\Dev\RPG-Tactics-3D-Prototype` el `project.godot` raíz, la escena `scenes/IsometricArtTest.tscn`, scripts, `art/`, documentación y `.godot/` como archivos locales sin seguimiento. `README.md` tiene cambios locales no fusionados. La existencia local **no significa** versión en GitHub; el baseline se acepta provisionalmente sin exigir encontrar el ZIP ausente.
- **Versión de Godot:** el proyecto local declara `config/features = ["4.7", "GL Compatibility"]`; no se localizó el ejecutable en `PATH`. Versión instalada, ejecución e importación **PENDING**, no modificar `config/features` por defecto.
- El vídeo de usuario demuestra problema real al llegar cerca de vista cenital; ADR-0001 propone modos de presentación por pitch, **pendiente de implementar**.
- Nuevo flujo acordado: OpenCode codifica; desde ChatGPT se prepara prompt, se contrasta con GDD/roadmap y se revisa el diff.
- Branch protection GitHub **pendiente de configurar** manualmente. La gobernanza se propone mediante PR, sin merge directo.

Siguiente hito acotado: tras aprobación/merge de PR #1, seguir [prompt separado de PR A](../prompts/opencode/R2_BASELINE_PR_A.md) para versionar el baseline **en el proyecto Godot único** y obtener pruebas; revisión PR A obligatoria antes de autorizar los modos ISO/HYBRID/TOPDOWN (PR B). [Prompt R2 diagnóstico](../prompts/opencode/R2_CAMERA_PRESENTATION.md) archivado. R1 animación PC-001 en pausa por prioridad R2.
