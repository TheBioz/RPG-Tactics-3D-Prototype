# Dirección artística y audiovisual — tema para continuar

**Estado:** dirección de personajes **aprobada como objetivo visual pre-GDD el 2026-10-18**; aspectos técnicos y coherencia visual aún pendientes de prototipo. No es todavía una biblia de arte final ni una prueba de viabilidad.

## Requisitos actualmente expresados

- **Entorno táctico 3D** con proyección isométrica y alturas reales; cuadrícula reconocible pero mundo creíble al rotar y cambiar de zoom.
- **Gráficos/actores 2D anime** sobre el escenario 3D como dirección inicial deseada; comparativa con personajes 3D estilizados solo como experimento artístico y técnico.
- **Presentación de combate lateral 2D anime** con transición/zoom opcional y acciones básicas en mapa cuando esté desactivada.
- **Variedad cultural y fantasía general**: ambientación post-Ragnarök con raíz nórdica, no todo de estética vikinga.
- **PC y consolas**: diseño visual, controles, legibilidad y rendimiento para estos dispositivos, no Android.
- Arte, animaciones, VFX, UI, retratos, música y sonido mediante producción asistida por IA tanto como sea viable; todas las salidas requieren control de calidad y revisión de licencias de uso comercial.
- **El arte que funciona dentro del juego es el motivo central del experimento 3D**. Una imagen atractiva aislada no basta.

## Aprobaciones explícitas del autor — personajes (2026-10-18)

El autor ha confirmado los seis puntos propuestos en conversación. **Estos criterios son decisiones de dirección visual**, no pruebas superadas de producción:

| Decisión | Elección aprobada | Interpretación |
| --- | --- | --- |
| ART-001 — Proporción en mapa | **B. Mini-anime táctico** | Silueta clara, cabeza algo más grande, armas reconocibles; evitar chibi exagerado y proporción hiperrealista a tamaño de mapa. |
| ART-002 — Tono visual | **C, con base A. Anime luminoso/heroico con matices regionales** | Base colorida, atractiva y evocadora; regiones, culturas y arcos dramáticos pueden tener tono más sobrio o melancólico. |
| ART-003 — Armaduras | **B. Detalle medio** | Materiales bonitos y formas características, sin ornamentación que destruya lectura o multiplique el coste de animación. |
| ART-004 — Tropas genéricas | **B. Modulares por clase y facción** | Variaciones de cascos, cabello, accesorios y color sin regenerar una identidad completa por recluta. Héroes únicos conservan diseño, rostro y distintivos individuales. |
| ART-005 — Combate lateral | **B. Vistoso con momentos memorables** | Buen timing, anticipación, golpe, recuperación, VFX y críticos especiales; no perseguir nivel de animación de juego de lucha para cada acción. |
| ART-006 — Unidad mapa | **B. Billboard corregido** | Personajes anime 2D fundamentalmente orientados a la cámara, con correcciones artísticas/técnicas para mantener apoyo, silueta y credibilidad al orbitar/rotar la vista. |

### Alcance exacto del billboard corregido

**Visión del autor:** cámara libre en un escenario 3D, con personajes **dibujados 2D** que se orientan hacia ella; correcciones suficientes para no parecer carteles rígidos. Esto **sustituye la anterior propuesta experimental de limitar obligatoriamente la cámara a cuatro cuadrantes de 90°**. La libertad concreta de pitch, yaw, límites y acercamiento sigue por decidir y verificar en Godot.

**Posibles técnicas a comparar, NO aprobadas todavía:**

- Orientación del plano alrededor del eje vertical, sin obligar a que el personaje se incline al elevar la cámara.
- Pivote de pies correcto, sombra de contacto independiente y pequeña compensación de escala según perspectiva/zoom.
- Variaciones discretas de pose o de vista para ángulos críticos y/o animaciones, manteniendo coherencia de identidad y equipamiento.
- Distinción entre **facing lógico en mundo**, **orientación aparente hacia cámara** y dirección de animaciones/ataque; evitar que una lanza o escudo cambie de mano al girar.
- Pruebas de oclusión frente a muros, árboles, pendientes, escaleras y alturas.

La cantidad de vistas del sprite, las reglas de corrección y si puede convivir con cámara completamente libre son una **decisión técnica pendiente de validación artística**. No se exigirá un turno completo del personaje en cada ángulo antes de estudiar si un único sprite y pequeños ajustes son suficientes.

## Contexto artístico y musical ya expresado por el autor

### Escenarios

- **Inspiración Final Fantasy Tactics:** geometría 3D simplificada/poligonal, materiales y texturas ilustradas de gran calidad; alturas reales en cuadrícula, cámara libre, mapas pequeños y grandes.
- Paisajes coloridos, bonitos, evocativos y de fantasía con diversidad regional/cultural. Raíz escandinava/nórdica, no ambiente exclusivamente vikingo.
- **No pixel art** como objetivo de este proyecto: ilustración anime / pintura estilizada con legibilidad táctica.
- Prototipo obligatorio: materiales, sprites y props deben mantenerse coherentes al girar cámara, acercar/alejar y cambiar tamaño de escenario.

### Identidad sonora y música

- Banda sonora **táctica, melódica y narrativa**, con **leitmotivs** reconocibles para personajes, momentos dramáticos y conflictos.
- Música evoluciona de escala aventurera/contenida hacia pasajes **más épicos** conforme avanza la historia.
- Para batalla, cada tema/identidad principal contempla **versión de mapa normal** y **versión attack más intensa** al activar la presentación lateral del combate, inspirada funcionalmente en Fire Emblem moderno.
- Color escandinavo en instrumentación, motivos y atmósfera, **sin caer en una OST íntegramente vikinga**. Permitir lenguaje musical propio de las distintas culturas del mundo.
- El modo de sincronizar o transicionar música (capas, crossfade, cortes musicalizados, compás, BPM compartido) está **por diseñar y validar**. No afirmar que se generan parejas de pistas compatibles sin trabajo musical/técnico.
- Música, efectos, VFX y voces —si hubiera— se plantean con producción IA y edición humana bajo límites de coste, licencia y originalidad.

## Contrato visual por representación — objetivo

- **Retrato/dialogo:** anime expresivo y de alto detalle con identidad inequívoca.
- **Mapa:** mini-anime táctico legible, billboard corregido sobre mundo 3D y sombra/pivote de contacto.
- **Combate lateral:** anime 2D más detallado, vistoso pero reproducible, ataques y especiales memorables.
- **Héroes únicos:** rasgos y paleta reconocibles entre mapa, retrato y combate.
- **Genéricos:** familias modulares por clase y facción; variación sostenible compatible con animación y equipo.

**Siguiente etapa de la conversación:** afinar interfaz/HUD y retratos/diálogos, y más adelante detalles de VFX, música y producción, para completar la biblia audiovisual antes del GDD y roadmap.

## Decisiones confirmadas: uso limitado de 3D, combate lateral y VFX (2026-10-18)

El autor ha concretado las siguientes decisiones después de seleccionar el estilo de personajes. Se registran como **dirección audiovisual aprobada para el diseño**, no como sistema implementado:

- **ART-008 — 3D mínimo y funcional.** Usar geometría y espacio 3D principalmente por la **cuadrícula isométrica, elevación XYZ y cámara libre**. Priorizar arte dibujado 2D para personajes, fondos, retratos y combate. Evitar modelos 3D de personajes y escenarios complejos salvo donde sean imprescindibles para el mapa.
- **ART-009 — Combate lateral 2D de cuerpo entero.** Referencia de puesta en escena: Fire Emblem, con ambos personajes completos visibles, vista lateral, posiciones legibles, cámara mayormente estable, movimientos cortos, impactos y regreso a poses claras. Animaciones críticas/skills pueden ser más impactantes sin imponer un formato de cinemática continua. El combate lateral sigue siendo opcional y puede sustituirse por animación en mapa.
- **ART-010 — Fondos laterales pintados en 2D con parallax suave (elección B, formulada como preferencia).** Capas lejanas, plano medio y suelo/primer plano, desplazamiento limitado para dar profundidad. No reutilizar como requisito el escenario 3D del mapa para el fondo de duelo. Fondos reutilizables asociados a bioma/localización. Partículas o animación ambiental más compleja no son requisito de base.
- **ART-011 — Efectos y magia vistosos pero limpios (elección B).** Los VFX de impactos, críticos, curación, buffs/debuffs y estados, así como magias de fuego, hielo, viento, trueno, luz y magia negra, deben resultar expresivos y atractivos **sin ocultar a los personajes ni perjudicar la lectura táctica**. Destellos, sacudidas, partículas y capas son herramientas posibles; nivel exacto de espectáculo por habilidad pendiente de pruebas. No asumir duraciones ni sistemas de partículas concretos.

### Consecuencias prácticas para el prototipo y el pipeline IA

1. La prioridad es verificar un **mapa 3D ligero con terreno/texturas ilustradas y sprites 2D con billboard corregido** bajo cámara libre; no producir un ejército de modelos humanos 3D como plan principal.
2. Producir una escena lateral 2D con **dos personajes completos**, fondo 2D pintado multicapa y VFX legibles. El sistema de combate calcula el resultado antes de su representación.
3. Reservar gestos y golpes más elaborados para críticos y skills, conservando un ciclo base de ataque reutilizable para genéricos.
4. Evaluar material generado por IA por coherencia entre frames, transparencia, siluetas, licencias y tiempo de corrección; el parallax exige capas limpias, no basta un único JPG plano.
5. Pendiente: contenido exacto y sistema de VFX, música sincronizada, rig/frames, interfaz y estilo de retratos. Ninguna de estas decisiones establece producción validada o coste final.

## Dirección UI/HUD — decisión del autor (2026-10-18)

**ART-012 — Dirección aprobada como visión pre-GDD:** interfaz **predominantemente limpia, clara y funcional**, con **algunos detalles artísticos característicos** que aporten una identidad reconocible al juego. No quiere una UI recargada ni una interfaz tan genérica que parezca una plantilla sin personalidad.

**Principio rector:** la ornamentación comunica el mundo, pero **nunca debe competir con la información táctica**.

### Implicaciones prácticas propuestas (no estilo final aprobado)

- **Mapa táctico:** HUD discreto, jerarquía clara para fase/ventana de activación, unidad seleccionada, alcance/movimiento, terreno y altura, objetivos, propiedades, recursos cuando correspondan, minimapa y estado de equipos; información contextual en vez de paneles permanentes excesivos.
- **Combate lateral:** mostrar HP, ataques, previsiones/resultados y otros datos imprescindibles sin ocultar sprites completos ni VFX. Mantener nitidez en pantallas de PC/TV.
- **Menús, fichas y diálogos:** mayor margen para identidad gráfica: divisores, pequeños grabados, símbolos, marcos finos, transiciones suaves y motivos asociados al lore/culturas.
- **Posibles firmas visuales a explorar, NO aprobadas:** trazos inspirados en ramas de Yggdrasil, nudos geométricos, runas reinterpretadas con diseño original y destellos/paleta evocadores del Bifröst. Evitar convertir todo en estética vikinga; adaptar variantes discretas a las culturas del mundo.
- **UX:** foco y selección inequívocos con mando, ratón y teclado; contrastes suficientes, escalado para pantallas grandes y pequeñas, y distinguir facciones mediante iconos/formas además del color.
- **Pipeline IA:** permitir generación de motivos ornamentales/fondos/UI ilustrados, pero construir texto, iconografía mecánica, botones y paneles con elementos escalables/consistentes; no usar texto dibujado por modelos generativos como UI funcional.

### No decidido todavía

Paleta exacta, tipografías, iconografía, marco/nudo/runa concreto, densidad de HUD, posición de minimapa, layout para 4 jugadores, presentación del orden de activación, diagramas de rangos/altura, estilo de ventanas de diálogo, menú principal, escalas/resoluciones y guía de interacción. Validar con una **captura funcional de batalla de mapa pequeño y grande** antes de fijar la biblia UI.

## ART-013 — Retratos narrativos (elección confirmada 2026-10-18)

El autor elige **retratos anime de busto al estilo Fire Emblem** para conversaciones, en vez de ilustraciones habituales de medio cuerpo estilo novela visual. Se priorizan expresiones legibles, identidad facial consistente y diálogo ágil.

**Propuestas técnicas pendientes de validación:** retrato maestro por personaje y expresiones con identidad controlada mediante IA; varias emociones a partir de referencias aprobadas; cajas de texto limpias con pequeños motivos artísticos. Los retratos deben representar al mismo personaje que los sprites mini-anime del mapa y las animaciones completas del combate lateral.

**No decidido:** cantidad de expresiones, fondos de diálogo ilustrados o mapa 3D como fondo, posicionamiento exacto de retratos, animación de boca/ojos, doblaje, dimensiones y transiciones.

## Agenda sugerida, NO elecciones predeterminadas

1. Estilo global: anime 2D ilustrado, línea, paleta, saturación, sombreado y referencias visuales.
2. Mundo: arquitectura, culturas/biomas, terrain materials, relieve, clima, ciclo día/noche y consistencia al rotar.
3. Unidades en el mapa: resolución, proporción, cuatro/ocho vistas, billboard controlado, facings y animación.
4. Combate lateral: grado de detalle, cutout vs animación dibujada, ritmo de ataques y magia/VFX.
5. Retratos, diálogos y cinemáticas: estilo e integración con render 3D.
6. UI/UX PC/consola, legibilidad en mapas grandes, minimapa, ayudas de altura.
7. Identidad sonora: música ambiental, batalla, facciones, instrumentos, voces, SFX, nivel de orquestación y consistencia.
8. Pipeline IA: generación con referencias canónicas, máscaras, modelado texturizado, música, métricas, costes y licencias.
9. Quality gate: pequeña escena 3D con varias rotaciones, mapa grande y pequeño, retrato y actor anime; comparar 2D vs 3D solo si es necesario.

**Decisiones ART-001 a ART-013 registradas como visión pre-GDD**; técnica de billboard corregido, parallax y VFX aún por validar. Continuar con retratos/diálogos, detalles UI y pipeline audiovisual antes del GDD/roadmap.
