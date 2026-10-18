# PC-001 — Prototype de articulación 2D para Godot 4 (v0.1)

**Estado:** PROTOTIPO MECÁNICO / NO ARTE FINAL · **Fecha:** 2026-10-18 · **Personaje:** `pc001_vanguard_lancer` (no canónico).

## Qué ha ocurrido

Se han realizado otras **dos generaciones** intentando corregir la ilustración lateral aislada. Ambas volvieron a producir **láminas de referencia, cuadros y supuestas piezas/frames** en vez de una sola figura con orientación ortogonal inequívoca. **Rechazadas como assets.** El hecho de mostrar una imagen dividida en recuadros no demuestra que exista un rig 2D editable, un atlas homogéneo, transparencia real por pieza o fotogramas consistentes.

**Conclusión:** detener reintentos del mismo modo; seguir sólo mediante **edición visual explícita con referencia de identidad y guía de pose** o intervención manual. No utilizar automáticamente las salidas cambiadas de escudo/armadura/pelo para sustituir el canon visual.

## Artefacto técnico creado

Paquete de conversación `PC001_Godot4_Articulated_Proxy_v0.1.zip`, contiene proyecto Godot 4:
- `project.godot`, `RigTest.tscn` y `RigTest.gd` (GDScript).
- Dibuja **formas geométricas originales de prueba**, no recortes del concepto; ninguna de las imágenes fallidas pasa al runtime.
- Animación procedural/articulada hacia la derecha: idle, anticipación, estocada, contacto, recuperación, reacción de daño.
- Movimientos independientes de **brazo de lanza**, **brazo de escudo**, **piernas articuladas**, **capa** y **trenza**; anclaje de pies sobre plano.
- Emite la señal `attack_contact` una vez; no calcula daño ni modifica HP.
- Controles: Espacio/Intro = ataque; H = daño; R = reiniciar; Q = ocultar texto.

**No ejecutado en Godot en esta sesión:** aquí no hay binario de Godot instalado. Es un punto de partida técnico que el autor debe abrir y probar en Godot 4.2+ antes de asumir compatibilidad de runtime. El paquete binario no se ha insertado automáticamente en GitHub; se entrega por archivo adjunto de conversación.

## Gates honestos

- **C0 identidad:** dirección PC-001 simplificada elegida para la prueba; los detalles de orientación lateral todavía por bloquear.
- **C3 actor ilustrado de perfil:** NO validado.
- **C4 import/rig en Godot:** código de demostración preparado, ejecución NO probada.
- **C5 animación fluida anime:** NO validada: los polígonos sólo demuestran movimiento de segmentos. Aún faltan capas ilustradas, articulaciones correctas, inbetweening y revisión de deformaciones.
- **Resultado útil:** ya existe un **esqueleto mecánico de ataque con evento de contacto** diseñado para recibir piezas separadas cuando haya una ilustración lateral válida.

## Siguiente experimento necesario

1. Preparar **una guía de perfil estricto** sobre el diseño simplificado de PC-001 y obtener una única ilustración aislada, sin paneles ni labels. Mantener mano derecha anatómica/lanza, mano izquierda/escudo, botas planas y paleta aprobada.
2. Separar pintura *real* de cabeza, pelo frontal/posterior, torso, pelvis, brazos, manos, piernas, capa, lanza y escudo, con zonas ocultas reconstruidas y sin costuras.
3. Sustituir gradualmente las piezas geométricas de `RigTest.gd` por `Sprite2D` o `Polygon2D` con texturas reales y pivotes. Se deberán validar occlusiones durante estocada.
4. Ejecutar en Godot, grabar un ataque y un daño, evaluar calidad/peso/coste. Solo entonces valorar Spine/Godot Skeleton2D/otras herramientas y escalado a ejército.

**No se aprueba pixel art, ni se acepta una sprite sheet ficticia como producto real.** Véanse [Character Master](PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md) y [test de recorte previo](PC-001_PROFILE_CUTOUT_BLOCKING_TEST_2026-10-18.md).
