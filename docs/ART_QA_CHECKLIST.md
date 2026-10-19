# Art QA — Isometric 2D x 3D Gate 0.1

**Aprobación:** PENDIENTE DE VÍDEO / CAPTURA DE GODOT. No marcar PASS solo por compilar script.

| Test | Qué observar | Estado inicial |
|---|---|---|
| 01. Importar escena sin errores | proyecto Godot abre, importa SVG, genera mapa | pendiente |
| 02. Cámara orbitando 360° | Sprite se mantiene vertical y cercano a su anclaje al girar yaw | pendiente |
| 03. Pitch 30–70° | No rota a un plano tendido ni se deforma gravemente | pendiente |
| 04. Zoom lejos/cerca | Silueta/escudo/capa reconocibles a tamaño de mapa | pendiente |
| 05. Diferencia alturas | sombra y pies sobre casilla correcta en niveles 0,1,2 | pendiente |
| 06. Oclusión | muro/árbol/acantilado delante ocultan de forma plausible | pendiente |
| 07. Props 2D | árboles, arbustos y ruinas no muestran vistas físicamente contradictorias | pendiente |
| 08. Colisión selección | raycast selecciona la altura correcta, incluso con zoom/orbita | pendiente |
| 09. Comparación PC-001 | V alterna conceptual original vs proxy mini; indicar qué encaja | pendiente |
| 10. Performance / maps | NO APTO para medición de mapa grande en esta versión | fuera de alcance |

## Observaciones del autor

Anotar 3 capturas mínimo: iso 45°, rotada 180°, nivel alto zoom cercano. Adjuntar un vídeo si aparecen problemas de facing, parallax vertical, clipping o anclajes.

**Decisión que pretende desbloquear:** saber si merece la pena invertir en **ilustración 2D de personajes para cámaras XYZ**; no comparar motores ni decidir una dirección técnica definitiva sin pruebas visuales.
