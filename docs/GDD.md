# Game Design Document — RPG-Tactics-3D-Prototype

**Versión:** 0.1 · **Fecha:** 2026-10-18 · **Estado:** BORRADOR DE TRABAJO PARA REVISIÓN DEL AUTOR.  
**Autoría del concepto:** creador del proyecto. **Documento de diseño:** síntesis estructurada de la conversación y de `docs/pre_gdd/`; no supone aprobación automática de reglas aún abiertas.  
**Relacionado:** [Roadmap](ROADMAP.md) · [Síntesis pre-GDD](pre_gdd/ESTADO_CONSOLIDADO_2026-10-18.md) · [Registro de decisiones](pre_gdd/DECISIONES_ABIERTAS.md) · [Art Factory PC-001](pre_gdd/personajes/PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md).

> **Convención de certeza:** **CONFIRMADO** = intención expresa o elección del autor; **DISEÑO PROPUESTO** = decisión sugerida por este GDD, pendiente de validar; **ABIERTO** = no acordado; **ASPIRACIONAL** = visión futura sin promesa de V1; **GATE** = condición observable para aceptar un entregable. Los valores de ejemplo NO son especificación final.

## 1. Resumen ejecutivo

RPG táctico de fantasía **por turnos y cuadrícula**, centrado en batallas de unidades únicas y tropas genéricas, decisiones estratégicas, progresión de clases y una campaña narrativa de inspiración post-Ragnarök. Fusiona como **referentes**, sin copiar sus sistemas: legibilidad y personajes de Fire Emblem, captura/territorio de Advance Wars y diversidad táctica de Final Fantasy Tactics / D&D / Baldur's Gate 3.

La principal diferenciación sistémica es un **planificador de activaciones proporcional al número de unidades elegibles de cada ejército**, en lugar de turnos de ejército completos sin intercalado. La diferenciación visual es una **cuadrícula en 3D funcional con XYZ y cámara isométrica libre**, poblada por **personajes anime dibujados en 2D** y presentada opcionalmente con duelos laterales 2D de cuerpo entero.

**Estrategia de desarrollo CONFIRMADA:** **game-first, Maker-ready**. El juego debe justificar su existencia por sí mismo; la edición pública de contenido es evolución posterior. Prioridad PC; consolas como meta de producto. **Android/móvil excluido**.

## 2. Pilares de experiencia

1. **Decisiones tácticas con consecuencias:** posicionamiento, terreno, altura, objetivos y activaciones importan más que el espectáculo gratuito.
2. **Escaramuza y ejército dentro del mismo sistema:** desde grupos pequeños de héroes hasta enfrentamientos con tropas reclutables, propiedades y asedios.
3. **Personajes que crecen y se recuerdan:** clases, porcentajes de crecimiento, puntos ajustables, maestría, promociones y heridas que fomentan la rotación.
4. **Historia que reacciona a lo jugado:** elecciones y objetivos de misión que cambian consecuencias, rutas y personajes; evitar minijuegos de hub obligatorios.
5. **Anime 2D ilustrado con 3D mínimo:** la belleza depende del diseño dibujado; el 3D se usa porque permite cámaras, terreno y elevaciones tácticas.
6. **Arquitectura extensible, producción austera:** datos reutilizables y calidad comprobable con herramientas IA, sin asumir que una imagen generada equivale a un asset animable.

**No objetivos para el PoC:** campaña completa, multijugador en red, batallas masivas definitivas, Maker público, supervivencia roguelike, lanzamiento comercial o asset factory automatizada de extremo a extremo.

## 3. Público, plataformas y sesión de juego

- **Público objetivo (DISEÑO PROPUESTO):** aficionados a JRPG tácticos, Fire Emblem, Advance Wars y combates estratégicos de fantasía; jugadores que valoran tanto historia como refriegas configurables.
- **Plataformas CONFIRMADAS como visión:** PC y consolas; no Android. Primera plataforma de producción **propuesta**: PC, con ratón/teclado y navegación para mando desde arquitectura/UI.
- **Ciclo del jugador en campaña:** escena de diálogo → preparación/despliegue → misión táctica → resultados, recompensas, heridas y progreso → decisión/consecuencia → siguiente capítulo.
- **Ciclo en refriega:** configurar bando/reglas/mapa → despliegue → activaciones, objetivos/captura y reclutamiento según reglas → victoria/derrota → resumen.
- **Duración de sesión, dificultad, límites de unidades y hardware mínimo: ABIERTO.**

## 4. Modos de juego y relación con el lanzamiento

| Modo | Experiencia prevista | Estatus | Alcance propuesto de primera validación |
| --- | --- | --- | --- |
| **Campaña** | Un jugador, elenco con relaciones, narrativa ramificada, progreso entre misiones, heridas y decisiones. | CONFIRMADO, núcleo de producto | Una misión vertical breve con introducción y consecuencia. |
| **Refriegas** | 1–4 participantes humanos, competitivo/co-op/PvE según escenario, tropas únicas/genéricas, propiedades y reclutamiento. | CONFIRMADO como visión; online/local abierto | Simulación táctica con dos bandos; 1 humano + IA; sin red. |
| **Expedición/supervivencia** | 1–4 jugadores, mazmorra, supervivencia/roguelike y posible creación de grupo. | ASPIRACIONAL | Sin implementación en PoC; evaluar tras base comercial. |
| **Maker** | Crear mapas, unidades/eventos y eventualmente campañas. | ASPIRACIONAL posterior; arquitectura compatible desde el inicio | Datos externos editables para pruebas, **sin editor público**. |

**Decisión no tomada:** qué modos incluir en V1 comercial. Este GDD recomienda una campaña sólida antes de multiplicar modos. Una refriega local básica podría adelantarse si comparte el núcleo y tiene bajo coste, pero **no es compromiso aprobado**. Online exige proyecto de red independiente.

## 5. Terreno, cuadrícula y cámara

### 5.1 Modelo de mundo

- Casillas **cuadradas** con coordenadas lógicas `(x, y, z)` o superficie más altura; geometría 3D mínima para representar desniveles, escaleras, obstáculos y arquitectura legibles. **Convención exacta de ejes del motor: ABIERTO.**
- Topología/tipo de celda (pradera, bosque, camino, roca, agua, fortificación...) define transitabilidad, coste por movilidad, buffs/debuffs, cobertura/defensa y reglas de propiedad cuando proceda.
- Unidades voladoras pueden ignorar barreras o costes que impiden a terrestres, dentro de límites por diseñar.
- Posibles muros, casillas ocupadas, puentes y desniveles; definición precisa de alturas, escalada, alcance, saltos y línea de visión **ABIERTO**.
- No usar la forma de una textura como dato táctico: la lógica de casilla debe existir separada del render.

### 5.2 Cámara, control y rendimiento

- **Cámara libre rotatoria** de orientación isométrica/táctica, zoom legible, selección de casillas y unidades, ayudas de elevación, rutas y rangos.
- **Billboard corregido** para sprites 2D: mantener pies/grounding, coherencia de mano/arma/escudo y oclusión frente a muros, sombras y objetos, con rotación/zoom reales.
- **Nueva observación del PoC (2026-10-19):** al inclinar la cámara hacia cenital, los sprites verticales y props altos pierden coherencia. **DISEÑO PROPUESTO, aún no validado:** modos visuales por pitch (isométrico, híbrido, cenital táctico) con transición e histéresis, sin modificar reglas ni posición de las unidades. Véase [ADR-0001](engineering/adr/ADR-0001-pitch-presentation.md); parámetros y arte de cada modo siguen abiertos.
- Minimap y ayudas visuales especialmente para escenarios grandes.
- Estrategias futuras como frustum culling, LOD, chunks y streaming se seleccionarán por perfilado real, sin fingir tamaños máximos o FPS objetivo ya medidos.

**GATE del PoC:** una escena con varias alturas, obstáculos y cámara rotatoria donde selección, rango, pies y silueta sigan siendo coherentes en distintos ángulos y zooms.

## 6. Núcleo de turnos: iniciativa híbrida

### 6.1 Invariantes de visión (CONFIRMADOS)

1. Cada unidad elegible tiene normalmente **una activación ordinaria por ronda**.
2. La ronda **solo acaba cuando todos los ejércitos han agotado** las activaciones ordinarias elegibles de sus unidades.
3. El sistema reparte **ventanas de activación proporcionales** al número de unidades activables por ejército, permitiendo ejércitos desiguales.
4. Ejemplo ilustrativo: **12 contra 4** podría alternar ventanas **3:1** hasta completar la ronda.
5. Habilidades excepcionales como danza o efectos de acción extra **pueden romper** la regla de una acción ordinaria, sin permitir loops infinitos.
6. La **Velocidad** debe importar en el juego y quizá en el orden, pero **no se ha definido** cómo influye en la agenda.

### 6.2 Contrato de implementación recomendado (DISEÑO PROPUESTO)

- Mantener `eligible_units`, `ordinary_activations_remaining` y registro de activaciones por unidad/bando; distinguir acciones excepcionales de la cuota ordinaria.
- Un **scheduler puro y determinista** recibe estado y devuelve `acting_side` y tamaño/autorización de ventana; no debe depender de la UI.
- Cuando las proporciones no sean enteras (p. ej. 7:4, 5:3, 12:7), repartir oportunidades sin bloqueos o sesgo sistemático. **Algoritmo concreto pendiente de diseño y pruebas automatizadas**; no elegir hoy una fórmula de cuota/redondeo.
- En cada ventana, un humano o la IA decide qué unidades elegibles activar. Gastar una activación la marca como utilizada; una unidad no repite activación ordinaria por error.
- Registrar órdenes y estado resultante para depuración, guardado, deshacer solo si se aprueba, y futura sincronización.
- Separar muerte/reclutamiento/refuerzos a mitad de ronda y bandos neutrales como **casos límite que se prueban antes de soportar cuatro jugadores**.

### 6.3 Pruebas mínimas obligatorias

| Prueba | Resultado requerido |
| --- | --- |
| 1 contra 1, 4 contra 4 | Todas las unidades elegibles obtienen su activación ordinaria; cierre correcto. |
| 12 contra 4 | Reparto proporcional razonable y ronda completa sin duplicados. |
| 7 contra 4, 5 contra 3 | Sin inanición de bando, doble acción ordinaria ni bloqueo; equidad verificable. |
| Baja y reclutamiento en mitad de ronda | Regla documentada y estado coherente; el tratamiento exacto aún por decidir. |
| Danza/acción extra | Nunca activa un bucle infinito ni permite romper límites de forma imprevista. |
| Bandos 3–4 y neutral IA | **Posterior a PoC**, con casos de alianza y desconexión a definir. |

**ABIERTO:** prioridad de banda inicial, velocidad, desempates, creación de unidades, invocaciones, aliados, neutralidad, empate de batalla, pauses, red y reconexión. El roadmap incluye un hito de cierre de estas reglas.

## 7. Movimiento y resolución de combate

### 7.1 Flujo táctico (DISEÑO PROPUESTO)

1. Elegir unidad elegible → visualizar casillas alcanzables y costes.
2. Planificar movimiento con alturas/ocupación/terreno → confirmar destino.
3. Elegir una acción válida: atacar, usar magia/skill, objeto, interacción/captura u otra acción contextual.
4. Mostrar vista previa de alcance, objetivo y probabilidades **cuando la regla exista**.
5. Resolver el resultado con lógica central (estadísticas, RNG registrado si aplica, estado y efectos).
6. Emitir un resultado de acción independiente de la animación, actualizar objetivo/recursos y consumir activación conforme a reglas aprobadas.

**Movimiento y acción en una activación, costes y cancelaciones** son detalles todavía abiertos; la secuencia anterior guía el prototipo sin elevarla a regla final.

### 7.2 Armas y magia

- **Triángulo:** espada, lanza y hacha con relación de ventajas **por definir numéricamente y en sentido**. **Arco neutral** respecto al triángulo.
- **Maestría** por familia de armas: condiciona equipamiento/progresión; rangos/restricciones definitivas **ABIERTO**.
- Estadísticas influyen en daño, precisión, esquiva, doble ataque, defensa, crítico y movimiento según fórmulas futuras. **No dar valores sin test de balance.**
- **Magias:** fuego, viento, hielo, trueno, luz y oscuridad; daño, alcance, áreas (AOE), estados, apoyo y utilidades. Costes, círculos de vulnerabilidad y resistencias **ABIERTO**.
- **Skills:** pocas por clase/personaje, fuertes y con identidad. Nombres de franquicias citados por analogía **no** implican adopción literal.

### 7.3 Resultado autoritativo y vistas

- El sistema táctico produce `ActionResult` / `StrikeResult` (acierto, fallo, crítico, daño/efectos, derrota, etc.).
- Presentación **A: mapa**, animación sencilla siempre disponible; **B: duelo lateral 2D opcional**, personajes completos, fondo ilustrado con parallax suave y VFX vistosos pero limpios.
- La cámara del duelo es contenida; golpes normales rápidos y críticos/skills destacados. El jugador puede acelerar/omitir combates visuales sin cambiar el resultado.
- **Evento de contacto visual** sincronizado con el resultado calculado previamente; la animación no inventa HP ni RNG.
- Música batalla `normal` en tablero y `attack` durante duelo, transiciones musicales por validar.

## 8. Unidades, clases y crecimiento

- **Únicas:** rostro/diseño, historia y progresión propias.
- **Genéricas:** producción modular por clase/facción; pueden combatir, subir de nivel, promocionar y ser reclutadas en batalla. Su muerte no requiere consecuencias narrativas de protagonista.
- **Enemigos IA:** usan mismas reglas de nivel y promoción; asignación automática de puntos cuando corresponda.
- **Level-up:** crecimiento estadístico probabilístico por atributos + **pequeño fondo manual distribuible**; magnitudes, puntos por nivel, caps, frecuencia, RNG y guardado **ABIERTO**.
- **Promoción:** clases/objetos/materiales, incluso para enemigos; reglas de timing e inventario **ABIERTO**.
- **Inventario/equipo:** compatibilidad con rango de arma, persistencia e ítems/recursos según modo; UX para ejército grande sin tedio.
- **Balance recomendado:** las estadísticas dominan; skills personales excepcionales no deben sustituir el valor del posicionamiento.

## 9. Derrota, heridas y permadeath

**CONFIRMADO:** por defecto HP=0 retira la unidad del combate sin muerte narrativa. Aplica una **herida temporal persistente** con penalización. Su contador de recuperación solo avanza cuando la unidad **NO se despliega** en batallas posteriores; volver a desplegarla herida no acelera la recuperación.

**Permadeath opcional:** advertir antes de activarlo que algunas unidades fallecidas pueden seguir apareciendo en diálogos, porque la campaña no se bifurca para todas las muertes.

**ABIERTO:** severidad y acumulación, número de batallas de descanso, asistencia/magia, herida de genéricas, derrotas obligatorias y diferencias entre campaña/refriega. PoC puede simular el estado sin necesidad de un roster extenso.

## 10. Captura, refuerzos y economía de refriegas

- Propiedades capturables, edificios de reclutamiento y territorios disputados.
- Genéricas reclutables en batalla; posibilidad excepcional de únicos según escenario.
- **Economía interna opcional por modo/mapa:** ingresos, materiales, loot, campamentos neutros con IA, compra/crafteo y equipamiento durante partida.
- **DISEÑO PROPUESTO:** todo configurable por reglas de escenario: `enable_capture`, `enable_recruitment`, `enable_resources`, `enable_crafting`; no obligar a cada batalla de campaña a tener microeconomía.
- **ABIERTO:** ingresos, captura parcial, costes, límites de población, economía anti-snowball, crafting y control territorial multijugador.

**PoC recomendado:** validar **una propiedad capturable y un reclutamiento opcional** solo después de combate/scheduler estable; si comprometen la prueba visual/táctica, moverlos a la vertical slice y documentar el recorte.

## 11. IA táctica y dificultad

- La IA utiliza el mismo motor de acciones y las mismas restricciones de turnos, casillas y recursos que un humano.
- **Propuesta de IA PoC:** heurística reproducible que evalúe ataques válidos, distancias, seguridad básica y objetivo de misión; suficiente para ejercer scheduler y combate.
- **Posterior:** roles, defensa de propiedad, elección de objetivos, magia, retirada, economía, neutralidad y dificultad escalable.
- No prometer una IA óptima o cuatro participantes online a partir de una simple demo 4v4.

## 12. Campaña, mundo, estructura y personajes

### 12.1 Tono y enfoque

Fantasía **post-Ragnarök** con raíces escandinavas y regiones culturalmente variadas, no todos visualmente vikingos. La narrativa debe comenzar con conflictos comprensibles y concretos y escalar hacia amenazas mayores; los problemas sociales/políticos conservan causalidad humana real.

**CONFIRMADO como dirección:** personajes y vínculos previos, capítulos con decisiones que afectan objetivos y consecuencias, sin actividades/hub obligatorios. **Preferencia:** pocas rutas principales y aprox. tres finales como techo orientativo, no número final.

### 12.2 Reparto de trabajo narrativo (PROPUESTA NO CANONIZADA)

| Rol | Motor personal exploratorio | Riesgo de canon |
| --- | --- | --- |
| Líder humano/carismático | Busca bestia peligrosa ligada al pasado; después elige seguir ayudando a sus amigos. | No confirmado nombre, clase ni vínculo con Fenrir. |
| Exploradora de ruinas | Busca persona desaparecida y reliquia; descubre secretos del Bifröst. | Identidad y relación sin concretar. |
| Sanador/exorcista | Busca descanso para alma cercana y descubre la dimensión de Hel. | Motivación y cosmología por validar. |
| Cuarta amistad, conflicto civil | Deudas, injusticia territorial, persecución o poder económico; presenta política sin dios oculto. | Trama/rol no elegidos. |
| Askr / veterano tipo Jeigan | Se incorpora después; veterano poderoso con vínculo posible al pasado. | Papel Einherjar/identidad no canonizados. |

**Cosmología en investigación narrativa:** Gjallarhorn, Yggdrasil, Níðhöggr, Midgard, Bifröst roto, Embla, Hel, Fenrir, Jörmungandr, Loki y Segundo Ragnarök. No escribir como canon aprobado ninguna cadena causal o destino de los protagonistas hasta validarla.

### 12.3 Máquina narrativa recomendada

- `CampaignState` conserva banderas, variables de capítulo y consecuencias de misiones; los capítulos consumen estado y ofrecen objetivos/escenas diferentes.
- Escenas de diálogo con **retratos de busto anime**; **fondos ilustrados 2D** en escenas narrativas y **diálogo sobre mapa 3D** durante misiones.
- Consecuencias demostrables de ayudar/no ayudar a una unidad neutral, cambiar ruta, conservar propiedad o completar objetivo secundario.
- Las rutas pueden converger sin anular elecciones: cambios persistentes en aliados, eventos, recursos y diálogos.

**Primera prueba narrativa propuesta:** escena introductoria breve, decisión táctica con bandera persistida, resumen y línea/objetivo posterior diferente. No exige canonizar la campaña completa.

## 13. Dirección artística y audiovisual — acuerdos ART-001…ART-019

**ART-001–004:** mapa mini-anime táctico, tono luminoso/heroico con matices regionales melancólicos, armaduras de detalle medio, héroes únicos y genéricos modulares por clase/facción.

**ART-005–011:** duelos 2D completos estilo Fire Emblem, cámara relativamente estable, ataques/skills vistosos; billboard corregido para actores de mapa; **3D mínimo** por alturas/XYZ/cámara; **no pixel art**; fondos de duelo 2D ilustrados en capas con **parallax suave**; VFX expresivos pero legibles.

**ART-012–014:** HUD limpia y funcional con una marca gráfica original discreta (motivos concretos **NO** seleccionados); retratos anime de busto; fondos de escena narrativa 2D y conversaciones en mapa durante combate.

**ART-015–019:** banda sonora **orquestal/melódica con color escandinavo** y culturas diferenciadas; leitmotivs, instrumental o coros épicos/etéreos **según escena**, temas de combate normal/attack; **doblaje parcial en inglés**, no diálogo íntegro doblado; **textos, UI y subtítulos español/inglés** desde la versión inicial prevista.

**Accesibilidad/UX recomendadas:** navegación con mando, contraste, tamaño de texto escalable, controles remapeables cuando resulte factible, color + símbolos para facciones, omitir/velocizar animaciones, controles de volumen separados (voces, SFX, música). No afirmar QA de accesibilidad realizado.

## 14. Pipeline IA, Golden Character y riesgo artístico

- **Character master único e inmutable tras aprobación:** rostro, pelo, armadura, accesorios, paleta, asimetrías y física del equipo.
- **Representaciones distintas pero coherentes:** retrato busto, actor mapa mini-anime con pivote/pies, actor 2D lateral completo y animable.
- **Fuentes vs runtime:** `art_source/` para referencias, candidatos, parámetros, máscaras, metadatos, pruebas; `game/assets/` solo assets aprobados con transparencia, pivotes y formatos adecuados.
- **Gates C0–C6:** identidad, retrato, mapa, battle actor, integración Godot, animación y coste/legal.
- **PC-001 Vanguard Lancer:** piloto **no canónico**; se eligió mantener dirección visual (trenza rubio ceniza, armadura azul acero, capa granate, lanza derecha, escudo izquierdo) y **eliminar tacones**: botas de combate planas. Se han intentado diseños simplificados y perfiles. **No es asset final.**
- **Estado real según experimentos de 2026-10-18:** varios intentos de crear perfil aislado fallaron y produjeron collages/pixel art; un recorte RGBA pasó controles mecánicos pero **no artísticos**; se creó un **rig proxy procedural Godot 4** y una v0.2 de estocada de potencia preparada y descrita, **no ejecutada/validada en Godot** según los informes. No existe una prueba cerrada de actor 2D ilustrado animado en runtime.
- **Feedback de animación confirmado:** carga corporal más prolongada → pausa de tensión → **estocada explosiva** → hit-stop breve → recuperación, con transferencia de peso. Los tiempos anotados en la prueba PC-001 son temporales, no estándar global.
- **Control de coste:** no asumir presupuesto de producción; la cifra histórica de 250 € era exploratoria, no partida de gasto autorizada. Licencias y trazabilidad de cada herramienta/proveedor **antes de publicar**. No copiar código de pipelines de terceros sin revisar licencia.
- **Stop rule:** si la identidad, los lados del equipo o los frames derivan, detener generación masiva y cambiar método (guías, edición controlada, draw-over y piezas) en lugar de reiterar prompts sin control.

## 15. Arquitectura técnica recomendada (no implementación existente)

**Motor candidato:** Godot 4 por el historial del proyecto y los ensayos de proxy; **versión/build/estructura definitivas por verificar**. El repo nuevo aún no demuestra un juego integrado.

Separar:
1. **Datos de autoría:** `MapData`, `TileData`, `UnitData`, `ClassData`, `WeaponData`, `AbilityData`, `StatusData`, `ScenarioRules`, `DialogueEvent`.
2. **Estado y dominio:** `BattleState`, `CampaignState`, `UnitInstance`, `Roster`, `Inventory`, `PropertyState`, `ActivationLedger`.
3. **Servicios deterministas:** `MovementRules`, `Pathfinding`, `RangeAndLoS`, `CombatResolver`, `ActivationScheduler`, `VictoryEvaluator`, `ProgressionResolver`.
4. **Controladores IA/humano:** producen **comandos validados** sin saltarse el motor de reglas.
5. **Presentación:** mundo visual 3D y sprites 2D, HUD, minimapa, diálogo, duelo lateral 2D, VFX/audio/locale. Solo consumen estados y resultados.
6. **Persistencia:** guardado/carga, versión de esquema y migración a futuro, recursos localizados por clave y datos de contenido para Maker eventual.

**Reglas arquitectónicas:** no duplicar lógica de daño en animaciones; no codificar misiones como escenas imposibles de parametrizar; pruebas unitarias para turnos y estados; reproducir casos deterministas con seeds; no diseñar netcode completo antes de estabilizar el simulador.

## 16. Propuesta de alcance verificable: PoC y vertical slice

### 16.1 Proof of Concept — propuesta mínima

**Una batalla jugable sencilla en Godot**, sin venderla como demo pública. Contenido sugerido ajustable:

- **Mapa único pequeño** con varias alturas, dos o más terrenos y obstáculo real; rotación/zoom de cámara libre.
- **Actores anime 2D** o placeholder explícito si el gate artístico aún bloquea; al menos **un actor ilustrado real** es condición para validar el **PoC artístico completo**.
- Movimiento y selección de casillas, un ataque físico y un efecto mágico/estado simple, HP, derrota y condición de victoria.
- **Scheduler híbrido implementado y probado** en múltiples proporciones (incluyendo 12:4 y 7:4 en tests de simulación; la batalla de muestra puede ser más pequeña).
- **Un bando humano y otro de IA** con comportamiento mínimo.
- Visualización del ataque **sobre mapa**; duelo lateral de cuerpo entero con fondo 2D y evento de contacto si supera el gate de assets/animación.
- Menú/HUD provisional pero legible, control de cámara y registros de prueba; **no** red, Maker público, gran campaña ni cientos de unidades.
- **Resultados reproducibles y test automatizado** para scheduler, combate, casillas y derrota.

**Criterio decisivo:** si funciona el motor táctico pero no el sprite 2D, se habrá demostrado un **PoC técnico parcial**, **no** la visión artística final. Si existe una buena imagen pero no puede animarse/importarse, **no** se ha demostrado el pipeline.

### 16.2 Vertical slice de producto — fase posterior, recomendada

- Una **micro-misión narrativa completa**: retratos busto, escena con fondo 2D, diálogo sobre mapa 3D, condición táctica con decisión y consecuencia persistente.
- Una propiedad/objetivo secundario y/o reclutamiento demostrativo, selección de equipos, crecimiento o estado de herida mínimo.
- Dos o más familias de unidad con arte repetible, una animación normal y una habilidad representativa.
- UI limpia, opción de animaciones on/off, audio provisional y dos idiomas en textos de muestra.
- Dos escenarios de rendimiento: pequeña escaramuza visualmente cuidada y prueba mecánica con ejércitos desiguales.

**Go/no-go:** solo pasar a multiplicar capítulos y plantillas de unidades después de que los tests de arte, combate, scheduler y UX superen criterios medibles.

## 17. Métricas, validación y riesgos principales

| Riesgo | Indicador/gate | Mitigación prevista |
| --- | --- | --- |
| Inconsistencia de arte IA | Personaje no conserva cara/equipo entre formatos y fotogramas. | Master único, edición guiada, simplificación, QA C0–C6, intervención manual. |
| Cámara libre + billboards | Pies flotantes, facings erróneos y oclusiones malas. | Escena de prueba rotatoria con altura, pivote y sombra real. |
| Activaciones injustas | Unidades actúan dos veces, bandos sin turno, rondas bloqueadas. | Scheduler determinista y tests 1:1, 12:4, 7:4, bajas/refuerzos. |
| Scope creep del estudio solo | Múltiples modos/red/art factory retrasan núcleo. | PoC cerrado y gates; multiplayer/Maker/roguelike fuera de la ruta crítica. |
| Render de grandes mapas | FPS/memoria y navegación caen sin métricas. | Profiling progresivo, culling/LOD solo ante evidencia. |
| Economía demasiado compleja | Bloqueo de turnos, bola de nieve, UI sobrecargada. | Reglas opcionales por escenario, empezar con propiedad simple. |
| Historia inabarcable | Ramificaciones multiplican capítulos/diálogos. | Banderas y ramas que convergen; objetivos con consecuencias medibles. |
| Derechos y coste de IA | Assets no publicables o pipeline caro. | Registro de fuente, licencias, coste por asset, límites de reintentos. |

## 18. Decisiones abiertas prioritarias

1. Algoritmo proporcional preciso y relación con Velocidad.
2. Contrato de altura, línea de visión, bloqueos, geometría/casilla y vuelo.
3. Fórmulas de combate/crecimiento/heridas y catálogo mínimo de armas/magia/skills.
4. Calidad y método de sprite billboard con cámara realmente libre.
5. Obtener **actor lateral ilustrado real** de PC-001, con identidad fija, manos correctas, **botas planas**, partes/poses y evaluación en Godot.
6. Qué debe incluir la primera versión comercial, multijugador local/en red y alcance de Maker.
7. Canon narrativo de personajes, cosmología, capítulos y mapa político.
8. Herramientas IA, producción musical dinámica, UI final, hardware y presupuesto.

El registro detallado sigue en [decisiones PRE y ART](pre_gdd/DECISIONES_ABIERTAS.md). **Ningún vacío queda implícitamente aprobado por estar organizado en un GDD.**

## 19. Estado de aprobación del GDD

- **Creado por petición del autor:** 2026-10-18.
- **Estado:** **DRAFT v0.1**, sujeto a revisión de alcance/reglas/canon; estructura de visión confirmada conservada.
- **Implementado y verificado:** **no se declara aquí** un juego jugable. El repositorio contiene documentación y pequeñas herramientas/prototipos experimentales descritos por separado; ver historial y pruebas.
- **Para iniciar desarrollo:** ejecutar el [Roadmap v0.1](ROADMAP.md), medir PoC, actualizar reglas y registrar versiones del GDD conforme a tests reales.

**Fuentes de verdad:** [Visión inicial](pre_gdd/VISION_DEL_JUEGO.md), [Mecánicas](pre_gdd/MECANICAS_Y_MODOS.md), [Narrativa exploratoria](pre_gdd/NARRATIVA_Y_PERSONAJES.md), [Dirección audiovisual ART-001…019](pre_gdd/DIRECCION_ARTISTICA_AUDIOVISUAL.md), [Character Master PC-001](pre_gdd/personajes/PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md) y [prueba de rig Power Thrust](pre_gdd/personajes/PC-001_POWER_THRUST_v0.2.md).
