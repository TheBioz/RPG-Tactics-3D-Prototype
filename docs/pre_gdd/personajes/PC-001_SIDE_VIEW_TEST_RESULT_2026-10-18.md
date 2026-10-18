# PC-001 — Test de generación lateral: tres rechazos

**Fecha:** 2026-10-18  
**Experimento:** producir **un único actor lateral de cuerpo entero**, anime 2D ilustrado **no pixel**, a partir de la identidad de PC-001.  
**Resultado:** **FAIL**. Ninguna salida pasa la prueba. No se han producido sprites de combate utilizables; no afirmar progreso de C3/C4/C5.  
**Fuente de diseño:** [Character Master](PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md) y [próxima prueba de animación](PC-001_PROXIMA_PRUEBA_ANIMACION_2D.md).

## Requisito solicitado

- **Solo una guerrera**, completamente visible, **estrictamente de perfil** y mirando a la derecha.
- Arte **anime 2D ilustrado**, sin estética pixel art ni 3D; proporciones de **actor lateral de cuerpo entero**, no mini-sprite de mapa.
- Identidad estable: trenza rubio ceniza, ojos azul verdoso, pecas, armadura azul acero simplificada, capa granate, cuello gris, botas de combate **planas**.
- Lanza en **mano anatómica derecha**, escudo azul circular en **izquierda**, broche de capa en hombro anatómico izquierdo. Comprobar coherencia de orientación sin volteos falsos.
- Un objeto por imagen, sin retratos secundarios, turnarounds, paletas, cuadros, diagramas, textos ni colecciones de animaciones.
- Para concept lateral, fondo neutro limpio; para derivado final Godot, actor aislado con PNG **RGBA y alpha real**, sin suelo, sombra pintada en textura ni fondo.
- Pose base de combate con pies en una línea de suelo estable, separación suficiente de arma/escudo/capa para posterior rig o draw-over.

## Resultados observados (conservados como rechazos, NO como canon)

| ID | Imagen generada | Falla principal |
| --- | --- | --- |
| C3-TRY-01 | \`a_clean_high_resolution_sprite_character_design_s.png\` (1536 × 1024) | Hoja de producción con paneles/texto, retrato, múltiples sprites **pixel art**. No es actor único ni perfil aislado. |
| C3-TRY-02 | \`a_clean_concept_art_sprite_reference_sheet_in_a.png\` (1536 × 1024) | Hoja mixta de vistas, detalle, ataques y sección **pixel art**; no contiene asset lateral aislado de alta resolución. |
| C3-TRY-03 | \`a_clean_character_design_spec_sheet_style_image_fo.png\` (1536 × 1024) | Repite collage técnico e incluso define «Pixel Art 2D»; contradice explícitamente la biblia visual. |

Hashes SHA-256 registrados (sólo para identificar el fichero concreto; las imágenes no se han subido automáticamente al repositorio):
- TRY-01: \`364a84f07926fa377efc045d8ad002c18bc9d08ba4f143b8a4bdb99d24d1553a\`
- TRY-02: \`514f669eeb07becca9f768672d6d0a753fcf220ea0ad0f34f6cfa59aa7fd349b\`
- TRY-03: \`1ddecf5096ea805ac11fc8ab4a20e2781b3dcfa37759f8d70982e60efe57ec0a\`

**Diagnóstico:** los intentos de generación libre están mezclando formatos históricos del antiguo RPG Tactics Maker (pixel art, sheets de animación, retrato 192×192) con las indicaciones actuales del proyecto. No corregir con más instrucciones textuales sobre una misma conversación sin control de referencia/composición.

## Ruta de recuperación: un output por vez

1. **Congelar referencia:** usar el concepto limpio aprobado como dirección en \`hoja_de_personaje_caballera_lancera.png\` (SHA-256 \`eeeffa30e8bf51a4c7df590dab76ea576c30cc66a78e0a4c32f3bef82e7d4d10\`). Su status aún es **referencia provisional**, no asset/runtime.
2. **Crear plantilla de pose** lateral *una figura* (puede ser dibujo de bloque/silueta de prueba). Pie izquierdo/derecho, lanza/escudo y punto de pivote inequívocos. Validar que el soporte de IA admite guía de pose o composición *además de* imagen de personaje.
3. **Edición de imagen controlada / referencia visual**, no una petición de hoja de diseño. Mantener fijos cara/vestido/colores y exigir un único cuerpo perfil derecho. Si el generador introduce elementos secundarios, detener e inspeccionar por qué.
4. **Revisión humana C3-A (concepto):** arte anime no pixel; plano perfil verdadero; proporciones, asimetrías, ausencia de texto/otras figuras; botas sin tacón. No seguir a más poses si falla.
5. **Separación del personaje y alpha:** generar/extraer cuerpo aislado, quitar fondo, revisar contorno, evitar alpha falso. Para el derivado runtime ejecutar \`python tools/art/validate_actor_png.py path.png --stage runtime\`.
6. **Sólo después:** pose \`idle\`, \`windup\`, \`contact\`, \`recovery\` y \`hurt\` controladas y/o composición de piezas con rig 2D; comparar continuidad entre estados. Preparar una escena Godot aislada para resolver un ataque con hit event independiente del cálculo.
7. Si dos iteraciones guiadas siguen fallando, **cambiar de proveedor/método o intervenir manualmente** sobre un boceto guiado. No producir un lote de sprites ni gastar el presupuesto a ciegas.

## Límite de automatización

El validador PNG de este repositorio verifica **solo requisitos mecánicos** de archivo (formato, alpha, márgenes). **No detecta automáticamente** estilo anime, composición con un único personaje, dirección anatómica, silueta, manos correctas, calidad de dibujado o consistencia temporal. Esos criterios quedan como review manual en C0/C3.

## Estado

- **No aprobado:** ninguna de las tres imágenes.
- **C0:** diseño piloto como dirección visual suficientemente definido, aceptación de la **imagen maestra exacta** y refinamientos técnicos aún condicionados.
- **C3/C4/C5:** no iniciados en runtime; cero assets jugables.
- **Próximo entregable válido:** una sola pose de **perfil lateral no pixel** antes de intentar animación.
