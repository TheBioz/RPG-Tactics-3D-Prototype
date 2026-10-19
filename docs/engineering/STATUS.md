# Estado auditado del repositorio — 2026-10-19

- Main ya contiene docs/GDD.md y docs/ROADMAP.md en v0.1: **borradores, no aprobaciones finales**.
- Main conserva pre-GDD y arte PC-001; no incorpora todavía el proyecto Godot isométrico completo.
- Rama poc/isometric-2d-art-gate solo documenta experimento y corrección billboard, no script/assets reales.
- El ZIP RTM_Isometric_Art_PoC_v0_2_billboard_fix.zip es **externo al repositorio** y se ha probado en PC del usuario; contiene código y SVG que deberá importar OpenCode a Git para convertirse en fuente de verdad.
- El vídeo de usuario demuestra problema real al llegar cerca de vista cenital; ADR-0001 propone modos de presentación por pitch, **pendiente de implementar**.
- Nuevo flujo acordado: OpenCode codifica; desde ChatGPT se prepara prompt, se contrasta con GDD/roadmap y se revisa el diff.
- Branch protection GitHub **pendiente de configurar** manualmente. La gobernanza se propone mediante PR, sin merge directo.

Siguiente hito acotado: importar baseline Godot en la repo → revisión → resolver ISO/HYBRID/TOPDOWN sin mezclarse con gameplay. R1 animación PC-001 en pausa por prioridad R2.
