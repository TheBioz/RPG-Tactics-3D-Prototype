# Estado auditado del repositorio — 2026-10-19

- Main ya contiene docs/GDD.md y docs/ROADMAP.md en v0.1: **borradores, no aprobaciones finales**.
- Main conserva pre-GDD y arte PC-001; no incorpora todavía el proyecto Godot isométrico completo.
- Rama poc/isometric-2d-art-gate solo documenta experimento y corrección billboard, no script/assets reales.
- **Actualización comunicada por el autor:** ha colocado todos los materiales en `C:\Dev\RPG-Tactics-3D-Prototype`. OpenCode debe inspeccionar la ruta del PoC y el estado Git local; no puede afirmarse aún que el código esté versionado en GitHub. Todo el trabajo futuro queda restringido a esa raíz.
- El vídeo de usuario demuestra problema real al llegar cerca de vista cenital; ADR-0001 propone modos de presentación por pitch, **pendiente de implementar**.
- Nuevo flujo acordado: OpenCode codifica; desde ChatGPT se prepara prompt, se contrasta con GDD/roadmap y se revisa el diff.
- Branch protection GitHub **pendiente de configurar** manualmente. La gobernanza se propone mediante PR, sin merge directo.

Siguiente hito acotado: importar baseline Godot en la repo → revisión → resolver ISO/HYBRID/TOPDOWN sin mezclarse con gameplay. R1 animación PC-001 en pausa por prioridad R2.
