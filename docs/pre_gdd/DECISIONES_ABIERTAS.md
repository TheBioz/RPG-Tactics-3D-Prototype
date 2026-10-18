# Registro de visión, decisiones y cuestiones abiertas

**Inicio:** 2026-10-18. El objetivo es no confundir deseos de producto con alcance confirmado de V1.

| ID | Estado | Tema / constatación | Qué falta decidir |
| --- | --- | --- | --- |
| PRE-001 | VISIÓN EXPRESA | RPG táctico de cuadrícula que fusiona héroes tipo FE con control territorial tipo AW y variedad táctica/estado tipo FFT/BG3. | Reglas originales y límites de complejidad. |
| PRE-002 | PREFERENCIA CON PRUEBA | Escenarios 3D isométricos con arte 2D anime, elevación, zoom/rotación. | Calidad en el prototipo artístico; sprite 2D vs 3D cel shading en mapa. |
| PRE-003 | VISIÓN EXPRESA | PC/consolas, no Android. | Plataformas prioritarias, hardware mínimo y presupuesto de rendimiento. |
| PRE-004 | VISIÓN EXPRESA | Campaña individual + refriegas de 1–4 jugadores competitivas o cooperativas. | Online/local, sincronización, reglas de alianzas y fase de lanzamiento. |
| PRE-005 | VISIÓN FUTURA | Modo separado de supervivencia/mazmorra/roguelike co-op o en solitario con equipo. | Proceduralidad, persistencia, expediciones y fase de desarrollo. |
| PRE-006 | PREFERENCIA FUERTE | Rondas completas con una activación ordinaria por unidad y ventanas proporcionales entre ejércitos desiguales. | Algoritmo exacto, múltiples jugadores, refuerzos, neutros, cierre de ronda. |
| PRE-007 | POR DECIDIR | La velocidad debe importar a nivel de turno además del combate. | Prioridad, orden, cuotas, desempates, efecto sobre balance. |
| PRE-008 | VISIÓN EXPRESA | Danza/Galeforce u otras habilidades podrán excepcionar activaciones. | Restricciones, costes, recursividad y sincronización. |
| PRE-009 | VISIÓN EXPRESA | Unidades genéricas y únicas, mezclables, reclutamiento in-battle; ambas pueden subir nivel y promocionar. | Identidad visual genérica, economía, límites y reglas de promoción. |
| PRE-010 | PREFERENCIA / SISTEMA OPCIONAL | Propiedades, captura, recursos, loot de neutral IA, crafting/equipamiento dentro de refriegas. | Diseño económico y grado de presencia por modo/mapa. |
| PRE-011 | VISIÓN EXPRESA | Niveles con growths probabilísticos + pequeño pool de puntos manuales; enemigos usan asignación IA. | Cantidades, timings, clases, interfaz y balance. |
| PRE-012 | VISIÓN EXPRESA | Skills poco frecuentes, armas con rango de maestría, espada/lanza/hacha triángulo, arco neutral; magia negra/luz/elemental y utilidades/AOE. | Fórmulas, catálogo elemental, estados y progresión. |
| PRE-013 | VISIÓN EXPRESA | Derrota con heridas graves y descenso del countdown únicamente en batallas no desplegadas. Permadeath opcional con advertencia narrativa. | Acumulación, severidad, recuperación, modo de juego. |
| PRE-014 | VISIÓN EXPRESA | Combate anime 2D lateral con zoom/transición **opcional**, y animación básica de mapa siempre. | Pipeline de animación, control, coste, tiempo de presentación. |
| PRE-015 | VISIÓN EXPRESA | Mapas X/Y/Z, altura, muros/casillas impasables, voladores, minimapa, optimización grandes mapas. | Modelo de altura, caminos, 3D geometry, LoS, selección y LOD. |
| PRE-016 | VISIÓN EXPRESA | Campaña como novela visual con decisiones en objetivos y neutrales, consecuencias y rutas. | Estructura de estados/capítulos; cantidad de finales (≈3 preferido). |
| PRE-017 | VISIÓN EXPRESA | Evitar minijuegos/tareas de hub fuera de batallas. | Ritmo entre capítulos, gestión de equipo sin tedio. |
| PRE-018 | PREFERENCIA FUERTE | Game-first, Maker-ready: desarrollar el RPG antes del Maker público. | Reutilización de código anterior y alcance mínimo de tooling interno. |
| PRE-019 | VISIÓN EXPRESA | IA para toda producción de arte, música y audiovisual, presupuesto bajo y sin depender de artistas externos. | Modelos, herramientas, costes, limpieza, derechos y coherencia. |
| PRE-020 | VISIÓN EXPRESA | Post-Ragnarök con raíz nórdica pero muchas culturas y conflictos humanos reales. | Historia mundial, geografía y cosmología. |
| PRE-021 | PROPUESTA NARRATIVA | Cuatro amigos ya unidos + Askr, protagonista-líder no elegido. | Personajes definitivos, motivaciones, rol de Askr y canon. |
| PRE-022 | CONTEXTO PREVIO | Gjallarhorn, Yggdrasil, Embla, Bifröst, Níðhöggr, Tronos, Segundo Ragnarök. | Reconstrucción/confirmación del canon. |
| PRE-023 | POR DECIDIR | Todos los modos comparten sistemas de unidades, combate, efectos y datos. | Políticas por modo y arquitectura de turnos multiplayer. |
| PRE-024 | POR DECIDIR | GDD, roadmap, V1 y fecha de lanzamiento. | Redactar tras visión artística/audio y revisar juntos. |

| ART-001 | DIRECCIÓN APROBADA PRE-GDD | Sprite de mapa **mini-anime táctico** (proporción intermedia). | Dimensión en pantalla, escala por zoom y QA en cámara libre. |
| ART-002 | DIRECCIÓN APROBADA PRE-GDD | Anime **luminoso/heroico** de base, con variaciones **sobrias/melancólicas** según cultura y escena. | Paleta, style bible, referencias canónicas. |
| ART-003 | DIRECCIÓN APROBADA PRE-GDD | Armaduras de **detalle medio**, bonitas y legibles. | Límites de detalle por distancia y técnica de animación. |
| ART-004 | DIRECCIÓN APROBADA PRE-GDD | Genéricos **modulares** por clase/facción; héroes con identidad propia. | Modularidad técnica y coste de variantes. |
| ART-005 | DIRECCIÓN APROBADA PRE-GDD | Combate lateral **vistoso**, con golpes y momentos memorables. | Animación, frames/rig, VFX y timing. |
| ART-006 | DIRECCIÓN APROBADA PRE-GDD | **Billboard corregido** de unidades anime 2D, con **cámara libre**. | Algoritmo, pivote de pies, facings, sombras, oclusión y validación en Godot. |
| ART-007 | VISIÓN EXPRESA (capturada) | Mundo 3D poligonal ilustrado/no pixel art tipo FFT; música escandinava no exclusivamente vikinga, leitmotivs y variantes **normal/attack**. | Style bible, producción musical por IA y transiciones fluidas. |

| ART-008 | DIRECCIÓN APROBADA PRE-GDD | **3D mínimo:** geometría del mapa táctico, XYZ, cámara isométrica libre; personajes y fondos prioritariamente 2D ilustrados. | Optimización y qué elementos del terreno necesitan volumen real. |
| ART-009 | DIRECCIÓN APROBADA PRE-GDD | **Combate lateral 2D con personajes completos**, encuadre estable estilo Fire Emblem, no cinemática continua. | Rig, poses, transiciones y timing de ataque/crítico. |
| ART-010 | PREFERENCIA ELEGIDA | **Fondos pintados 2D con parallax suave** (opción B). | Capas, fondos reutilizables, coste y grado de movimiento. |
| ART-011 | DIRECCIÓN APROBADA PRE-GDD | **Magia/VFX vistosos pero limpios** (opción B); priorizar lectura y no tapar personajes. | Librería de efectos, intensidad, implementación y QA. |

| ART-012 | DIRECCIÓN APROBADA PRE-GDD | **Interfaz limpia y legible con detalles artísticos singulares** que expresen identidad sin ensuciar el HUD táctico. | Motivos, layout, tipografía, iconografía, PC/consola y accesibilidad. |

| ART-013 | DIRECCIÓN APROBADA PRE-GDD | Retratos de busto anime inspirados en Fire Emblem para las conversaciones, no personajes de medio cuerpo como formato habitual. | Expresiones, fondos, composición y animación por definir. |

| ART-014 | DIRECCIÓN APROBADA PRE-GDD | Sistema **híbrido de diálogos**: fondos ilustrados 2D para escenas narrativas y conversaciones sobre el mapa 3D durante batallas, con retratos de busto. | Criterios de cambio, cámara, animación y transiciones. |

## Registro de cambios

- **2026-10-18 — Escenas de diálogo híbridas:** confirmada la opción C como ART-014, combinando fondos 2D ilustrados con diálogos sobre el mapa 3D.
- **2026-10-18 — Retratos para diálogos:** ART-013. El usuario confirma retratos de busto al estilo Fire Emblem. Quedan abiertas las expresiones, los fondos y la disposición exacta.
- **2026-10-18 — Dirección de interfaz:** ART-012. El autor elige una UI limpia, complementada por toques artísticos distintivos, sin fijar todavía su motivo visual, tipografía o distribución. Véase [DIRECCION_ARTISTICA_AUDIOVISUAL.md](DIRECCION_ARTISTICA_AUDIOVISUAL.md).
- **2026-10-18 — Combate lateral, parallax y VFX:** ART-008 a ART-011. 3D mínimo para el mapa, combate 2D con cuerpos completos, fondos 2D en capas con parallax suave y efectos vistosos pero limpios; sin fijar aún implementación ni tiempos. Véase [DIRECCION_ARTISTICA_AUDIOVISUAL.md](DIRECCION_ARTISTICA_AUDIOVISUAL.md).
- **2026-10-18 — Cierre de elecciones de personaje:** aprobadas las seis opciones de dirección visual (ART-001 a ART-006), con cámara libre + billboard corregido. Se han detallado también entorno y música (ART-007). Véase [DIRECCION_ARTISTICA_AUDIOVISUAL.md](DIRECCION_ARTISTICA_AUDIOVISUAL.md). No implica que el prototipo haya superado las pruebas.
- **2026-10-18 — Captura inicial:** tras explicaciones de mecánicas, prioridad Game-first, propuesta de iniciativa híbrida y texto de campaña. Sin implementar sistemas ni aprobar fórmulas; siguiente sesión: dirección artística y audiovisual.

### Regla futura

Para cerrar un asunto, crear nueva fila de cambio con fecha, decisión, justificación, coste/impacto y enlace al GDD o experimento; no sobrescribir silenciosamente la visión histórica.

### Repositorio y privacidad

Este repositorio se verificó como **público** el 2026-10-18. La documentación puede incluir detalles inéditos de ambientación e historia; antes de incorporar spoilers sensibles o propiedad intelectual no publicable, reconsiderar visibilidad. Nunca almacenar API keys.
