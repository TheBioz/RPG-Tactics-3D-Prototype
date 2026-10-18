# PC-001 — Recorte lateral y prueba técnica de movimiento (2026-10-18)

**Estado: test técnico, NO asset aprobado.** Tras un cuarto intento de generación que volvió a dar una lámina compuesta, se extrajo su figura lateral para comprobar transparencia, escala, pivote y timing. La imagen recortada NO coincide exactamente con el diseño simplificado de PC-001: cambian armadura, emblema del escudo y trenza; además la pose es 3/4 lateral, no perfil estrictamente ortográfico. No utilizar como canon.

## Artefactos locales (no subidos al repositorio)

- `PC001_Side_Profile_Tech_Test.zip`: paquete de evaluación con PNG, preview, GIF, manifest y pequeño proyecto Godot 4 aislado; SHA-256: `7cf5f16a73d5aeef8ff4632475bf4c25364b488dad8f892d992fdfd66a1b4348`.
- `assets/pc001_profile_extract_NONCANON.png`: PNG RGBA de 463×1018, SHA-256 `766faa6593afc1bb0775302d3894ecbba9e5c673446a43179156e316c48836b1`.
- `pc001_motion_blocking_NOT_FINAL.gif`: 18 frames, animación de desplazamiento/escalado de **una sola ilustración rígida**, no una animación de brazos, capa ni lanza.
- `Godot_PC001_Battle_Blocking/`: escena de ejemplo con Space/Enter para disparar el movimiento, **no probada dentro de Godot** porque el ejecutable no está disponible en esta sesión.

## Quality Gates

- **PASS técnico de PNG**: formato, alpha real (0–255), aproximadamente 55 % de píxeles transparentes, contenido visible y márgenes; evaluado con `tools/art/validate_actor_png.py --stage runtime`.
- **FAIL artístico**: la referencia sigue siendo un recorte de un collage rechazado y deriva de la identidad elegida.
- **NO VALIDADO**: exactitud de perfil, contorno perfecto sin halos, rig, poses clave y animación fluida, importación/ejecución de Godot. No marcar C3/C4/C5 aprobados.

## Siguiente gate

1. Congelar la imagen simplificada con botas planas como **referencia de identidad**. Producir una única pose lateral aislada usando edición guiada por **imagen + pose**, no prompts de láminas.
2. Validar manos anatómicas, escudo, pelo, capa, armadura, silueta y rostro. No adoptar desviaciones del prototipo recortado.
3. Separar cuerpo/cabeza/brazos/piernas/capa/trenza/escudo/lanza en piezas editables o dibujar poses con continuidad; animar `idle → windup → thrust/contact → recovery`, además de `hurt`.
4. Ejecutar la verdadera animación en Godot con eventos de impacto separados de la lógica de HP; medir retocabilidad, costes y consistencia entre frames.

**Conclusión:** el pipeline de formato y recorte es viable como experimento; el de animación de personajes y fidelidad visual todavía no está demostrado. Evitar generar en masa.
