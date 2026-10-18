# PC-001 — Evaluación C0 del candidato visual 01

**Fecha:** 2026-10-18  
**Personaje:** `pc001_vanguard_lancer` — piloto no canónico.  
**Estado:** **CANDIDATO VISUAL 01 — REVISIÓN PRELIMINAR**, no `C0_APPROVED`. Falta confirmación del autor y vista de perfil.  
**Contrato:** [Character Master v0.1](PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md).  
**Fuente:** imagen generada en la conversación del 2026-10-18, denominada localmente `hoja_de_personaje_guerrera_de_fantasía.png`. **No se ha incorporado el binario de la imagen a este repositorio**: el enlace persistente a la imagen original queda pendiente de almacenamiento/importación autorizado.

## Identificación técnica de la fuente examinada

- Nombre local: `hoja_de_personaje_guerrera_de_fantasía.png`.
- Dimensiones: **1122 × 1402 px**.
- Formato: **PNG RGB (sin canal alpha/transparencia)**.
- Tamaño de archivo observado: **2 290 973 bytes**.
- SHA-256 del archivo examinado:
  `055f5dea8e57fa2fda1dc3e22be0269b73c2156a1bb4f4b8aa309805bd2ce9b9`.
- Composición: cuerpo entero en vista tres cuartos frontal, retrato de busto ampliado y vista posterior pequeña. **No es turnaround completo ni spritesheet listo para rig**.
- Proveniencia: salida de una generación de imagen iniciada durante la conversación, no imagen renderizada por Godot ni export runtime. Información de modelo/licencia comercial específica **pendiente de confirmar**; no inventar un proveedor, modelo, coste o versión.

## Revisión visual frente al Character Master

| Criterio C0 | Observación | Estado |
| --- | --- | --- |
| Estilo anime 2D / heroico | Silueta, iluminación y proporciones visualmente próximas a la dirección ART-001/002/003. | **Bueno para concepto** |
| Reconocimiento facial | Rostro y paleta de cabello/ojos se repiten razonablemente entre cuerpo entero y busto; pecas visibles en ampliación. | **Bueno; no prueba animación** |
| Equipo y asimetrías | Vista frontal 3/4: **lanza en mano anatómica derecha**, **escudo en izquierda**, broche/capa hacia hombro anatómico izquierdo; vista posterior pequeña aparenta continuidad general. | **Alineado visualmente; verificar en turnaround** |
| Silueta / rol | Lanza alta, escudo circular azul con decoración dorada y capa granate definen clase y personalidad. | **Fuerte** |
| Armadura para producción | Pechera, hombreras, guanteletes, piernas y bordados contienen bastante detalle pequeño; a tamaño de mapa no se reproducirá y en animación multiplicará trabajo. | **Simplificación pendiente** |
| Capa / rig | Gran longitud y múltiples pliegues; cubre parte de silueta y generaría trabajo adicional de cutout/corrección frame a frame. | **Simplificación o estrategia de rig pendiente** |
| Pelo / trenza | Peinado trenzado atractivo; vista trasera muestra trenza larga, sin guía exacta de dónde nace ni cómo cae respecto a la masa recogida del busto. | **Congelar construcción y longitud** |
| Escudo | Motivo geométrico dorado legible como idea, pero su simetría real y geometría exacta no están documentadas en vista plana. | **Fijar símbolo maestro y lado** |
| Referencia de perfil lateral | **No existe perfil completo aislado**; indispensable antes de evaluar actor de combate. | **Falta** |
| Transparencia y exportación | PNG es **RGB con fondo y composición múltiple**; no tiene máscaras, pivotes ni piezas separadas. | **No apto para runtime** |
| Calidad en Godot / 3D XYZ | No se ha probado sobre cuadrícula 3D, variaciones de cámara, tamaño real ni oclusiones. | **No evaluado** |
| Animación / estabilidad | No hay rig, poses temporales ni frames para comprobar continuidad. | **No evaluado** |

## Decisión recomendada (no automática)

**Mantener la identidad estética de este concepto como propuesta preferida y simplificar lo necesario para producción.** No declararlo C0 aprobado hasta que el autor acepte el diseño y se resuelvan las discrepancias/omisiones clave. No pasar directamente a retratos de expresión ni a sprites jugables.

### Ajustes concretos propuestos para la versión 02

1. **Reducir microdetalle** en grebas, brazales, piezas de cintura y filigrana del faldón; conservar las grandes formas y acentos de latón.
2. **Capa con estructura clara:** pliegues principales grandes, borde limpio y un único broche anatómico izquierdo; decidir si longitud actual se mantiene o se acorta para simplificar animación.
3. **Trenza inequívoca:** vista trasera y rostro deben compartir una disposición explicable (corona de trenzas + trenza posterior, o un diseño más simple), con longitud definida y hoja de detalle.
4. **Escudo reproducible:** motivo original del escudo como pequeño dibujo plano definido, sin cambios al girar, reflejar o reducir.
5. **Preparar una única vista maestra frontal 3/4 aislada**, sin el busto y vista posterior dentro del mismo asset, para usarla como referencia. Conservar la hoja compuesta como exploración.
6. **Hacer vista lateral de cuerpo entero** guiada por la candidata aprobable, con arma, escudo, pies y capa completamente visibles. No inventar orientación física distinta.

### Nuevo prompt de refinamiento propuesto (NO ejecutado)

> Using the provided PC-001 candidate image as the primary reference, refine the same ORIGINAL adult female fantasy anime lancer without changing her face, ash-blonde braided hairstyle identity, blue-green eyes, subtle freckles, steel-blue/navy medium armor, grey fur collar, muted burgundy cape, dark blue round shield with its consistent original brass geometric insignia, and leaf-blade spear. Keep the spear in her anatomical RIGHT hand, shield in anatomical LEFT hand, and cape clasp on anatomical LEFT shoulder. Produce one clear full-body studio character reference image, feet and spear tip fully visible, accurate medium-detail armor simplified into animation-friendly large color shapes, fewer tiny engravings, simplified cape folds, and consistent braid structure. Plain neutral backdrop, no text, no UI, no additional characters, no cropped equipment. Polished original 2D anime tactical-fantasy art with readable silhouette, controlled cel shading. Preserve character identity above stylistic novelty.

La IA puede seguir cambiando manos, detalles y rostro pese a estas instrucciones; revisar cada candidato visualmente.

## Decisión pendiente del autor (revisión C0)

- ¿Se conserva la identidad del **candidato 01** (rostro, pelo, paleta, armadura, lanza/escudo) como punto de partida, aplicando solo simplificaciones técnicas? **Pendiente de respuesta.**
- En caso de aprobación: marcar `C0_DESIGN_DIRECTION_ACCEPTED` y crear candidata 02 / master definitivo. **`C0_APPROVED` solo tras validar imagen maestra concreta y asimetrías.**
- Si se pide otro estilo/rostro/equipo, actualizar primero Character Master y producir un nuevo candidato, manteniendo trazabilidad.

**No logrado hasta ahora:** asset maestro aprobado, perfil final, sprites, alpha, rig, animaciones, integración con Godot, repetibilidad, licencias y coste aprobados.
