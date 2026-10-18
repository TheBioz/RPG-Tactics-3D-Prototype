# PC-001 — Vanguard Lancer | Character Master v0.1

**Fecha:** 2026-10-18  
**Estado:** **diseño piloto propuesto y documentado**, pendiente de que el autor **apruebe una imagen maestra**. No es un personaje canónico, ni un asset producido o validado.  
**Producto:** RPG-Tactics-3D-Prototype — 3D táctico limitado a mapas XYZ y cámara libre; personajes 2D ilustrados; retratos tipo Fire Emblem y combates laterales 2D de cuerpo entero.  
**ID estable del experimento:** `pc001_vanguard_lancer` (no reutilizar `einherjar_lancer_001` como identidad narrativa o asset canónico).  
**Función:** Golden Character / primer test del pipeline IA y animación. **No autoriza un gasto ni implica elegir herramientas**.

## 0. Procedencia y qué se adapta

Adaptación a la visión nueva del material aportado por el autor: **RTM AI Art Factory v0.1**, su **Golden Character 001** (`einherjar_lancer_001`) y **192x192 Portrait Creator Steps** del RPG-Tactics-Maker anterior. Se reutilizan concepto de personaje-patrón, canon visual, master inmutable, controles de identidad, separación entre fuentes/runtime, Quality Gates y trazabilidad; **no** se traslada como obligación la producción pixel art de 192×192, un actor fijo de cuatro direcciones, ni las resoluciones de producción propuestas por el proyecto anterior.

Las tres imágenes `*CONCEPT.png` del ZIP anterior son **bocetos de exploración no aprobados**, no referencias maestras ni arte apto para runtime. No se copian automáticamente a este repositorio público. Esta ficha **no confirma aún una ilustración de canon**.

## 1. Objetivo y restricciones del piloto

Demostrar que **la misma persona** puede producirse coherentemente en:

1. **Retrato narrativo:** busto anime de alta legibilidad, varias expresiones.
2. **Unidad de mapa:** mini-anime dibujado para billboard corregido con cámara isométrica libre en terreno 3D XYZ.
3. **Actor de combate lateral:** 2D, cuerpo completo, perfil, animable con poses coherentes para acciones básicas.

**Evaluar también** complejidad de lanza, escudo, capa, pelo y armadura. Este piloto deliberadamente estresa las asimetrías; no usarlo para afirmar que todas las clases y personajes ya se podrán producir automáticamente.

## 2. Identidad física y emocional — especificación de trabajo, pendiente de validación visual

| Campo | Dirección del piloto |
| --- | --- |
| Rol / silueta | Lancera de infantería media, especialista frontal/defensiva; nunca mago ni tanque de placas enormes. |
| Aspecto | Mujer adulta joven (edad aparente orientativa 20–28), atlética, competente y serena. |
| Estilo | Anime de fantasía heroico y sobrio; raíces culturales nórdicas discretas; **no** estética exclusivamente vikinga, ni foto/hiperrealismo ni pixel art. |
| Rostro | Ovalado ligeramente anguloso; mandíbula suave; expresión neutral confiada; ojos expresivos pero no infantiles. |
| Piel / ojos | Piel clara con pecas sutiles; ojos azul verdoso. |
| Pelo | Rubio ceniza, trenzado, masas limpias y silueta identificable; no decenas de mechones finos. |
| Armadura | Media de acero azul frío/navy, placas simplificables y ornamentación moderada. |
| Accesorios | Cuello de piel gris mate, correas de cuero marrón, pequeñas piezas de latón envejecido. |
| Capa | Granate apagado, volumen controlado; no debe tapar piernas/manos ni impedir separar capas para animación. |
| Lanza | Una lanza larga de hoja tipo `leaf-blade`, silueta distinguible a escala de mapa. |
| Escudo | Uno redondo azul oscuro con motivo geométrico **original**, simple, dorado/latón y reproducible. |

**Paleta semántica provisional:** `STEEL_BLUE`, `NAVY`, `AGED_BRASS`, `BURGUNDY`, `LEATHER_BROWN`, `GREY_FUR`, `ASH_BLONDE`, `BLUE_GREEN_EYES`, `SKIN_LIGHT_FRECKLES`. **No son códigos HEX ni una paleta final aprobada**: congelar colores medidos después de seleccionar la imagen maestra.

### Asimetrías físicas propuestas para bloquear en C0

- **Lanza: mano derecha anatómica.**
- **Escudo: mano izquierda anatómica.**
- **Broche de capa: hombro izquierdo anatómico.**
- El motivo del escudo, la trenza, cierres y piezas de armadura asimétricas **no pueden cambiar de lado** entre imágenes.
- Documentar siempre izquierda/derecha **del personaje**, no del observador. Guardar una guía frontal/perfil/espalda cuando C0 se apruebe.
- Para animaciones laterales mirando en ambas direcciones, **no voltear horizontalmente a ciegas** si eso falsea el equipo; comprobar opciones de renderización y variantes laterales antes de imponerlas.

Las asignaciones anteriores son parte del **diseño piloto propuesto**, no un canon de mundo: pueden corregirse durante revisión C0 sin afectar ART-001…ART-019.

## 3. Contratos de representación (sin resoluciones definitivas)

| Representación | Master / contenido mínimo | Validación |
| --- | --- | --- |
| **Canon** | Imagen maestra aprobada de cuerpo entero, ficha de rostro, peinado, paleta y asimetrías; vistas adicionales guiadas para verificar equipo, sin prometer turnaround IA perfecto. | Identidad y física coherentes; registrar versión/hash. |
| **Portrait** | Busto de referencia **neutral**, después `angry` y `hurt` derivados mediante edición controlada. | Mismos ojos, rostro, cabello, collar, encuadre e iluminación base. |
| **Map** | `idle_master`; pequeño ciclo/prototipo `move`; pies/pivote estable y arma/escudo reconocibles a zoom real. | Billboard corregido, oclusión, contacto con suelo, rotación libre de cámara y elevaciones XYZ. |
| **Battle** | Pose de perfil de cuerpo entero; `idle`, `windup`, `contact`, `recovery`, `hurt`. | Arma/manos/asimetrías constantes; poses con continuidad y eventos de impacto independientes del cálculo de combate. |
| **UI** | Miniatura/icono derivados del retrato ya aprobado. | Sin texto generado incrustado y con legibilidad a tamaño real. |

Los tamaños históricos **192×192 retrato pixel art**, `512×512` portrait o cuatro vistas de mapa son **antecedentes**, no obligaciones aquí. Fijar píxeles útiles, márgenes, escala, direcciones y punto de contacto **después** de pruebas en Godot a resoluciones PC/TV y distancias reales.

### Prioridad de dibujo

1. **El retrato no se reduce directamente para hacer el sprite de mapa**: diseñar abstracción/simplificación desde la misma identidad.
2. La cámara libre implica probar el **billboard corregido** antes de exigir vistas `up/down/left/right`; la necesidad de variantes angulares es un resultado del prototipo, no un presupuesto automático.
3. El combatiente lateral necesita equipo sin deriva geométrica; evaluar **rig 2D/cutout con piezas y solapes dibujados** frente a frames adicionales, sin fijar herramienta/plug-in.
4. Un mismo diseño puede requerir **simplificación artística distinta por formato** manteniendo colores, insignias, silueta y personalidad.

## 4. Contrato de fuentes, trazabilidad y export

**Estructura propuesta, no creada/implementada en el juego por esta ficha:**

```text
art_source/characters/pc001_vanguard_lancer/
  character_definition.json         # futuro manifiesto del master aprobado
  references/                       # master aprobado + guías originales
  generation/                       # prompts, versiones, candidatos, descartes y receipts
  portrait/                          # neutral, expresiones, exports
  map/                               # idle, movimiento, anchors, exports
  battle/                            # perfil, poses, partes, rig y exports
  reports/                           # QA y costes
game/assets/characters/pc001_vanguard_lancer/
  portrait/                          # solo derivados aprobados
  map/
  battle/
```

- Un master aceptado pasa a ser **fuente de verdad versionada**, jamás se reemplaza silenciosamente.
- Guardar con cada candidato: ID, fecha, referencia de entrada/hash, modelo y versión si están disponibles, prompt/edición, permisos/licencia comercial verificados, coste e incidencias.
- Rechazados y referencias de trabajo **no** se importan al directorio runtime.
- PNG RGBA con transparencia limpia, pivote/foot anchor y metadata necesarios para Godot **solo cuando se apruebe un export**.
- Las carpetas anteriores son **candidatas para cuando empiece la implementación**; no constituyen una adopción anticipada de n8n, OpenRouter, fal.ai, ComfyUI, un rig propietario o un proveedor.

## 5. Quality Gates: no avanzar por inercia

| Gate | Qué debe aprobarse | Causa típica de rechazo |
| --- | --- | --- |
| **C0 — Identidad** | **Una ilustración maestra aceptada por el autor**; equipo y asimetrías documentados; vistas complementarias sin deriva. | Otra cara, trenza diferente, escudo/lanzas intercambiados, detalle inviable para animar. |
| **C1 — Portrait** | Neutral + dos expresiones editadas sin cambiar personaje/encuadre. | Cambian rostro, ojos, equipo, paleta o proporciones. |
| **C2 — Map** | Silueta mini-anime legible, apoyo al suelo, idle/move, pruebas con cámara libre y mapa XYZ real. | Cartel flotante, arma cambiada, oclusión falsa, pivote inestable. |
| **C3 — Battle** | Perfil corporal completo y 5 poses coherentes (`idle/windup/contact/recovery/hurt`). | Arma espejada, brazos imposibles, huecos de piezas, cambio de proporciones. |
| **C4 — Runtime** | Importación en Godot, tamaño de pantalla real, alpha y anchors correctos. | Fondos contaminados, blur, recortes, pérdida de lectura o colisiones visuales. |
| **C5 — Animación** | Ataque simple y recepción de daño con eventos/contacto; loop estable; lógica de daño externa al VFX. | Frames incoherentes, timings dependientes de FPS, parpadeo/deriva. |
| **C6 — Presupuesto/legal** | Trazabilidad, costes dentro de presupuesto **explícitamente autorizado** y licencias revisadas. | Coste no medido, derechos dudosos o automatización que reintenta sin límite. |

**Criterio general de éxito:** PC-001 se ve como **la misma persona** en las tres representaciones y funciona en una escena real de Godot con una animación elemental. Aun así, **solo un segundo personaje con el mismo contrato** permitirá evaluar repetibilidad del pipeline a escala.

## 6. Secuencia del primer experimento

1. **E0 — C0 sin gastos obligatorios:** evaluar las referencias antiguas solo como propuestas; generar/dibujar hasta **un candidato principal de concept master**, decidir simplificaciones, manos y emblema; someterlo a aprobación humana.
2. **E1 — Identidad en vistas:** comprobar cara, armadura y equipo con una vista adicional guiada. Si deriva, detenerse y ajustar canon/control, no generar diez variantes a ciegas.
3. **E2 — Retrato:** neutral primero y `angry`/`hurt` después, preferentemente edición localizada.
4. **E3 — Unidad mapa:** concepto mini-anime de tamaño jugable, idle y un movimiento mínimo; testear cámara libre y billboard/altura en Godot.
5. **E4 — Actor lateral:** perfil completo y las 5 poses necesarias para ataque + daño; probar cutout/rig y eventos de impacto.
6. **E5 — Repetibilidad:** otro personaje de silueta diferente sobre el mismo contrato, sin asumir que el rig de lancera sea universal.

**Stop condition:** si fallan identidad, asimetrías, legibilidad o edición temporal, revisar técnica o simplificar diseño antes de aumentar volumen. No generar lote masivo de expresiones/animaciones para rescatar un master defectuoso.

## 7. Prompt maestro candidato para E0 (NO ejecutado)

Texto operativo en inglés para probar generación de la **primera ilustración maestra**. No sustituye la necesidad de referencias de imagen y controles de pose:

> Full-body original anime fantasy character design, adult athletic female frontline lancer, calm confident expression, softly oval face with subtle freckles, medium-sized blue-green eyes, ash-blonde braided hair with clear distinct silhouette. Functional medium steel-blue and dark navy armor with restrained aged brass accents, matte grey fur collar, brown leather straps, muted burgundy cape fastened on her anatomical left shoulder. A single elegant leaf-blade spear held in her anatomical right hand and one dark blue round shield with a simple original aged-brass geometric emblem held on her anatomical left arm. Heroic, capable and grounded, Scandinavian-inspired accents within a culturally varied fantasy world, not stereotypically Viking. Clean polished 2D anime illustration, restrained cel shading, consistent top-left studio key light, readable whole-body silhouette, feet fully visible, balanced anatomy, practical medium detailing designed for future cutout animation, plain neutral background, no lettering, no interface, no other characters, no action effects. This is a reference design sheet candidate, not a production sprite.

**Revisar/evitar:** inversión izquierda/derecha, dos lanzas/escudos, hombreras o símbolos distintos en cada vista, anatomía defectuosa, capa tapando silueta, microdetalle excesivo, pelo inconsistente, diseño copiado de franquicias, pixel art, hiperrealismo, texturas fotográficas, texto generado. **Un prompt no garantiza estas condiciones**: solo evaluación visual y revisión humana.

## 8. Estado de aprobación

- **Aprobado como dirección general del videojuego:** ART-001…ART-019.
- **Documentado como experimento de I+D:** `pc001_vanguard_lancer`, sus características y contratos de prueba.
- **Pendiente de aprobación:** primera imagen maestra, paleta exacta, complejidad final del escudo y capa, adaptación de anatomía a mapa/duelo, números de resolución, rig y herramienta concreta.
- **No realizado:** imagen maestra final, importación a Godot, animation rig, sprites jugables, gastos/API, QA superados.
