# OpenCode — R3-C: núcleo autoritativo del scheduler proporcional

**Autorización:** implementar el núcleo SWRR para el PoC inicial, según las reglas aprobadas en `docs/engineering/specs/R3-C_ACTIVATION_SCHEDULER.md`.
**Rama:** `feat/r3-c-activation-scheduler`.
**Baseline:** `origin/main` `3c16c90f6117ecc9bfc82cb9acbf3d496678d4a4`.
**Motor:** Godot `4.7.2.stable.official.ed1daf0bf`.

## C1 — checkpoint intermedio obligatorio

1. Antes de modificar, verificar rama/HEAD/status, preservar `.godot/`, PNG privada, su `.import` y `safety/r2-local-baseline`; no reset/clean/stash/rebase ni checkout destructivo.
2. Implementar únicamente estado/snapshot inicial del dominio, cálculo SWRR puro y pruebas de secuencias/desempates/cierre. Mantenerlo sin `Node`, escena, cámara, UI, sprite o FPS.
3. Validar importación y runner R3 en la versión indicada; inspeccionar cambios, mutabilidad de snapshots, consultas repetidas, IDs/versiones de permiso, overflow y casos 0:N/0:0.
4. Commit(s) acotados y PR Draft para review intermedio, solo si la rama y el repositorio lo permiten. **Detenerse y solicitar revisión; no iniciar C2 antes del feedback.**

## C2 — no iniciar sin aprobación del review C1

Después de procesar feedback: añadir consumo ordinario atómico, permisos obsoletos/duplicados, bajas lógicas y transiciones explícitas de ronda; completar tests negativos, snapshots/replay y continuación. Integrar runner R3 y regresión R2 en `.github/workflows/r2-baseline.yml`. No ampliar a combate, IA o UI.

## C3 — cierre, no autorizado por este prompt

Revisar diff, auditar arquitectura, resolver BLOCKER/MAJOR, repetir regresión y pedir aprobación final. No marcar Ready ni fusionar sin aprobación explícita del autor.

En cada checkpoint informar rama/SHA, archivos y contratos, versión/comandos/salidas reales, errores, CI realmente completada, pendientes y Gate PASS/FAIL/PENDING. No declarar R3 completo por terminar el núcleo C1/C2.
