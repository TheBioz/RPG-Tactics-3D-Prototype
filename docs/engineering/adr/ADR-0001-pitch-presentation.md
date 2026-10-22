# ADR-0001: cámara táctica con dos modos explícitos, ISO y TOPDOWN

**Estado de la decisión: ACORDADA POR EL AUTOR (2026-10-22). Implementación PENDIENTE de autorización, pruebas y PR propia.**
**Ámbito:** cámara y representación del mapa táctico R2. Este ADR sustituye la propuesta anterior de tres modos por pitch; no afirma que ISO/TOPDOWN esté implementado.
**Referencias:** [roadmap R2](../../ROADMAP.md), [auditoría R2-B2](../audits/2026-10-22_R2_B2.md), PR [#4](https://github.com/TheBioz/RPG-Tactics-3D-Prototype/pull/4) y [#5](https://github.com/TheBioz/RPG-Tactics-3D-Prototype/pull/5).

## Contexto y evidencia

El PoC Godot usa terreno XYZ con actores y props ilustrados en Sprite3D vertical (`BILLBOARD_FIXED_Y`). La inspección visual comparó cámara **ISO yaw 45°, pitch 50°, zoom 17** con **yaw 90°, pitch 78°, zoom 17** el 2026-10-22. A 50° las siluetas se leen; a 78° personaje, árboles y ruinas se comprimen casi horizontalmente. No es un error de GridModel ni de selección: es una limitación de la representación visual actual. Las capturas se compartieron en conversación; las originales locales no son assets del repositorio.

La propuesta anterior intentaba adaptar automáticamente la presentación mediante ISO_FULL → ISO_HYBRID → TOPDOWN, umbrales e histéresis. El autor eligió **dos vistas explícitas que controla el jugador** para reducir complejidad y evitar el híbrido artificial.

## Decisión acordada

1. **Solo dos modos de presentación:** `ISO` y `TOPDOWN`. El jugador alterna deliberadamente entre ellos; **no** hay cambio automático por pitch.
2. **ISO** mantiene cámara ortográfica giratoria con yaw libre y un rango de inclinación acotado por legibilidad de sprites verticales. La cámara no podrá avanzar hasta los ángulos que los aplastan. Su límite máximo se aprobará tras prueba visual, **no se fija aún**.
3. **TOPDOWN** es una vista ortográfica cenital verdadera, con representación provisional cenital del actor y de objetos altos (tokens, copas/transparencia controlada o variantes dibujadas). No basta inclinar el mismo Sprite3D vertical hasta 90°.
4. **Sin ISO_HYBRID, umbrales de conmutación, histéresis ni PitchPresentationResolver de tres estados.** Puede haber una transición visual breve al alternar, solo si se prueba y no altera reglas ni estado.
5. En ambos modos la **misma coordenada lógica X/Z, altura Y, unidad, selección, ocupación, órdenes y reglas** provienen del mismo modelo/estado. La representación no revela entidades ocultas ni modifica RNG, HP, turnos o pathfinding. `CameraController` no decide casillas ni muta gameplay; el coordinador y `GridView` mantienen el picking validado.
6. Los modos pueden usar distintas presentaciones visuales, pero nunca duplicar el estado lógico del actor.

## Controles: decisión y cuestiones abiertas

- **Conservación acordada:** `Q/E` para giro horizontal; rueda del ratón para zoom; soporte del **botón central pulsado** para controlar la cámara.
- **Propuesta a probar:** arrastre central horizontal → yaw; arrastre central vertical → pitch **solo en ISO**. Ajustar sensibilidad, inversión opcional, conflictos con clic, límites y captura del puntero en QA.
- **Propuesta a confirmar:** tecla `T` y control visible en la UI para ISO ↔ TOPDOWN; reasignación accesible en el futuro.
- **Desplazamiento de cámara WASD**, velocidad, límites de mapa, enfoque fijo o móvil, comportamiento del yaw y zoom al volver desde TOPDOWN, así como control con mando: **pendientes de diseño/validación**. No se deducen de este ADR.
- Los controles heredados R/F, HOME y zoom actual se mantienen hasta que una PR de controles autorizada los cambie; este documento no presupone modificaciones ejecutadas.

## Parámetros orientativos NO congelados

| Parámetro | Referencia de diseño | Estado |
| --- | --- | --- |
| ISO inicial | yaw 45°, pitch 50°, zoom 17 | Baseline implementado en PR #5 |
| ISO pitch mínimo | 25° | Baseline; revisable |
| ISO pitch máximo | **55° candidato**, comprobar 50°/55°/60° | **PROPUESTA**, no aprobado |
| TOPDOWN pitch | 90° real | Objetivo de diseño; orientación cenital específica |
| Conmutación | Manual, no por umbrales | **ACORDADO** |
| Zoom | 8–24 (ortográfico) | Baseline; reajustable por modo |
| Yaw TOPDOWN, zoom por modo, animación | Por decidir | ABIERTO |

**Precaución técnica:** orientar una cámara exactamente cenital mediante `look_at(target, Vector3.UP)` puede degenerar si la dirección es paralela al vector `UP`. La implementación debe definir un eje superior estable/orientación propia para TOPDOWN y probarlo; no reutilizar ciegamente la transformación ISO a 90°.

## Opciones descartadas y compensaciones

- **Descartado:** ISO_FULL → ISO_HYBRID → TOPDOWN automático e histéresis. Reduce código y pipeline artístico, a cambio de ofrecer una conmutación manual clara.
- **Descartado:** inclinar sprites verticales a 78–90° como solución de presentación. El PoC visual demuestra pérdida de silueta.
- **Aceptado:** producir representaciones cenitales mínimas para actores/props; pueden ser proxies inequívocamente temporales, sin declarar gate artístico superado.
- **No decidido:** cuál de los dos modos debe recordar yaw/zoom al alternar ni cuál es la mejor interacción para arrastrar/desplazar.

## Criterios de aceptación para futuras PR (NO implementados aquí)

- Alternar ISO ↔ TOPDOWN mediante entrada deliberada sin cambiar `actor_coordinate`, `selected_coordinate`, celdas ocupadas ni alturas. Raycast/picking y resaltado correctos en **ambas** vistas, incluyendo bordes y diferentes niveles.
- ISO: yaw 0°/90°/180°/270°; probar pitch 25°/50°/55°/60° para **decidir** el límite, y zoom mínimo/máximo. Sin distorsión grave dentro del rango que se apruebe.
- TOPDOWN: orientación cenital real, tokens/props legibles, sombras/oclusiones sin duplicados; fallback visible ante asset faltante y sin error fatal.
- Arrastre MMB: suelta/cancelación, inicio sobre UI, sensibilidad, FPS y selección con clic izquierdo sin interferencia; entradas no finitas no mutan estado.
- Cambio de modo y/o zoom no afecta resolución de turnos, RNG ni estado lógico. No filtraciones de fog-of-war.
- Godot 4.7.2: suite headless/CI, pruebas manuales con capturas o vídeo y revisión del autor antes de congelar parámetros y arte.

## Plan de ejecución y límites

- **Completado:** extracción `GridModel` (PR #3), `GridView` (PR #4) y `CameraController` (PR #5).
- **Por autorizar:** PR documental ADR/roadmap; posteriormente controles de cámara, conmutación y representaciones cenitales como incrementos separados. Evitar mezclar modo TOPDOWN, assets definitivos y pathfinding en un único cambio.
- **Prioridad de producto propuesta, no comprometida:** adelantar R2-05 (rutas/movimiento táctico) antes de pulido artístico cenital avanzado.

La decisión de **dos modos manuales sí está acordada**. Los parámetros, UX precisa, orden de implementación y estándares artísticos restantes **no están aprobados por este ADR**.
