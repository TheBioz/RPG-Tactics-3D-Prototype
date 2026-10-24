# Roadmap — RPG-Tactics-3D-Prototype

**Versión:** 0.2 (propuesta documental) · **Original:** 2026-10-18 · **Actualización:** 2026-10-22 · **Estado:** BORRADOR OPERATIVO. Decisión ISO/TOPDOWN manual acordada; el resto de prioridades y parámetros abiertos no pasan a aprobado automáticamente.  
**Documento de diseño:** [GDD v0.1](GDD.md). **Visión original:** [pre-GDD](pre_gdd/README.md).  
**Propósito:** convertir una visión amplia en entregables verificables de desarrollo **solo-dev**, priorizando un **Proof of Concept jugable**, sin confundir aspiraciones futuras con compromisos de V1 o fechas de lanzamiento.

> **Regla de avance:** se pasa de una fase a la siguiente por **criterios de aceptación**, no por cantidad de imágenes, líneas de código ni tiempo transcurrido. Una prueba fallida se documenta y corrige; no se transforma en éxito por renombrarla.

## 0. Situación real al crear este roadmap

### Documentación existente

- Pre-GDD consolidado: visión de producto, sistema de iniciativas, modes, narrativa exploratoria, **ART-001…ART-019** audiovisuales, Character Master de PC-001.
- **GDD v0.1** creado ahora; propuestas/abiertos claramente marcados.
- Experimento PC-001: diseño base anime de lancera con **botas de combate planas**, intentos de perfil lateral que generaron collages/pixel art y **se rechazaron**; prueba de recorte RGB→RGBA con aceptación solo técnica del formato.
- Hay documentos de **rig proxy articulado v0.1** y **Power Thrust v0.2** para Godot 4, y paquetes de conversación citados como adjuntos, **pero los informes expresan que no se ejecutaron/validaron dentro de Godot**. El feedback del autor pide estocada con carga corporal y salida explosiva.
- Herramienta de repositorio `tools/art/validate_actor_png.py` para validar propiedades mecánicas de PNG (no estilo/identidad/animación).

### Lo que NO está demostrado

- No consta **juego integrado** ni un circuito táctico jugable funcionando en este repositorio.
- No consta avatar anime lateral final con rig funcional ni aprobación de C3–C5.
- No consta verificación de cámara XYZ con billboard corregido en Godot.
- No consta prueba del scheduler proporcional como código, guardado, IA táctica ni editor.
- **La existencia de archivos de diseño y proxies no equivale a completar ninguno de estos hitos.**
- No se ha aprobado presupuesto general, equipo adicional ni cronograma. La antigua referencia de 250 € fue para exploración de IA, no caja disponible garantizada.

## 1. Principios de producción

1. **Una hipótesis principal por prototipo.** Evitar construir campaña, Maker, online y fábrica IA antes de validar la interacción táctica y la estética.
2. **La estética es requisito, no decoración opcional:** el PoC técnico puede usar placeholders, pero el **PoC artístico completo** debe pasar la prueba de personajes 2D en mundo XYZ/cámara libre y duelo 2D.
3. **Datos primero, editor después:** mapas/unidades/clases/armas/escenas configurables con datos, sin interfaz Maker pública durante las fases tempranas.
4. **Solo-dev y reutilización:** cada asset nuevo demuestra una capacidad de producción repetible; un héroe espectacular sin método para hacer el segundo no desbloquea producción masiva.
5. **Gameplay autoritativo:** reglas de turnos/daño nunca dependen del arte, FPS, sonido o animaciones.
6. **Separar conformidad legal y técnica:** registros de coste, licencias, referencias, QA, versiones y fuente/exports.
7. **Medir antes de escalar:** sin tamaños de ejército, FPS, precio, número de capítulos o calendario inventados.

### Tablero de prioridades

- **P0 — Bloqueo de PoC:** indispensable para demostrar combate táctico, scheduler y presentación visual básica real.
- **P1 — Vertical slice:** una misión con contenido, narrativa, progreso y acabado suficiente para juzgar producto.
- **P2 — Alpha y campaña:** expansión de clases, enemigos, mapas, balance y herramientas internas.
- **P3 — Lanzamiento y sistemas avanzados:** multijugador completo, Maker público, roguelike; se planifican solo tras decisiones de alcance.

## 2. Vista de fases y gates

| Fase | Prioridad | Resultado esperado | Estado al 2026-10-18 | Gate de salida |
| --- | --- | --- | --- | --- |
| **R0 — Baseline y alcance** | P0 | GDD/roadmap versionados, stack y pruebas mínimas definidos | **Documentación inicial creada; revisión pendiente** | Decisiones bloqueantes anotadas, repositorio reproducible |
| **R1 — Art Tech PC-001** | P0 | Un personaje 2D reconocible, perfil, piezas/poses, prueba Godot; mapa mini-anime | **Investigación y rig proxy no validado; C3 falla** | C0/C3/C4/C5 de prueba superados, coste registrado |
| **R2 — Mapa 3D táctico XYZ** | P0 | Cuadrícula/cámara ISO↔TOPDOWN manual/altura, selección, trayectoria y billboard | **GridModel, GridView y CameraController integrados (PR #3–#5); 916 tests, no juego táctico completo** | Ruta de movimiento legal y vistas coherentes con la cuadrícula |
| **R3 — Reglas y scheduler** | P0 | Estado de ronda, activaciones proporcionales y tests | **Definición de visión, sin algoritmo validado** | Tests automatizados 1:1, 12:4, 7:4, bajas y excepciones |
| **R4 — Combate táctico + IA** | P0 | Movimiento, daño, ataque/defensa, victoria, IA básica | **Sin implementación integrada verificada** | Batalla completa, estados deterministas reproducibles |
| **R5 — PoC jugable integrado** | P0 | Una escaramuza funcional con UI, mapa/actores 2D, feedback y audio básico | **Pendiente** | Checklist de PoC cumplida, errores reproducibles |
| **R6 — Vertical slice narrativa** | P1 | Una misión con diálogos 2D/mapa, decisiones y progreso | **Pendiente** | Flujo de inicio a consecuencias persistidas |
| **R7 — Producción alpha / contenido** | P2 | Repetición de assets, clases/biomas/capítulos, herramientas internas, balance | **Pendiente** | Contenido con QA, límites y métricas comprobados |
| **R8 — Beta / publicación** | P2/P3 | QA, UX mando, ES/EN, optimización, empaquetado/comercialización | **Pendiente** | Criterios de lanzamiento por definir y aprobar |

**Las fases pueden solaparse en pequeñas pruebas** (R1/R2), pero el salto a producción masiva requiere gates de ambas. **El PoC no equivale a V1 ni a juego comercial.**

## 3. R0 — Fundamentos y marco de prueba

**Objetivo:** que el código/arte futuro crezca con estructura auditable.

### Backlog R0

- [ ] **R0-01** Revisar/aprobar o modificar GDD v0.1 y ROADMAP v0.1: identificar las **propuestas** que el autor quiere convertir en alcance efectivo del PoC.
- [ ] **R0-02** Definir estructura real del proyecto Godot 4 (versión concreta, carpetas, .gitignore, licencia, builds reproducibles, launcher). **No portear todo RPG-Tactics-Maker.**
- [ ] **R0-03** Crear escena `Main/DevLauncher` o equivalente para ejecutar pruebas pequeñas con un clic, mensajes de error y log de versiones.
- [ ] **R0-04** Crear convención de datos/IDs y mínimos de tests automatizados o ejecutables headless para reglas, sin atar lógica al render.
- [ ] **R0-05** Establecer el registro de decisiones de diseño: `propuesto` / `aprobado` / `probado` / `descartado`, fechas, responsables y link a evidencias.
- [ ] **R0-06** Revisar licencias y procedencia del primer lote de assets antes de cualquier distribución pública.
- [ ] **R0-07** Formalizar una política de **revisión de cada PR, revisión intermedia de ramas largas y auditoría arquitectónica periódica** al cerrar cada milestone o tras dos PRs de código; registrar dependencias, deuda, estado autoritativo, regresiones y riesgos en `docs/engineering/audits/`. Preparar CI headless tras verificar/pinear versión Godot. Ver [Workflow](engineering/WORKFLOW.md) y [plantilla de auditoría](engineering/ARCHITECTURE_AUDIT_TEMPLATE.md).

### Gate R0

- Entorno Godot del proyecto reproducible en equipo del autor, escena vacía que abre sin errores, y documentación/criterios de prueba enlazados.
- Se identifica cualquier diferencia entre código existente y GDD sin atribuir automáticamente funcionalidades al nuevo repositorio.

## 4. R1 — Demostrar el pipeline artístico de un personaje

**Riesgo crítico:** conseguir consistencia entre concept → retrato → mapa → duelo lateral, no solo crear una ilustración atractiva. Véase [Character Master PC-001](pre_gdd/personajes/PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md) y [Power Thrust v0.2](pre_gdd/personajes/PC-001_POWER_THRUST_v0.2.md).

### R1-A — Fijar dirección sin re-generar infinitamente

- [ ] **R1-01** Identificar **una referencia exacta** de PC-001 simplificada (rostro, trenza, escudo, armadura, capa); respetar **botas planas**, mano derecha con lanza, izquierda con escudo y broche izquierdo. Guardar hash/metadatos, comprobar procedencia.
- [ ] **R1-02** Acordar nivel de detalle realmente animable (simplificar armadura de grebas/brazos y capa en vez de producir infinitas hojas de concepto).
- [ ] **R1-03** Producir una guía de **perfil estrictamente lateral**, mirando a la derecha, **un único personaje**, cuerpo/arma/pies completos; evitar collages, pseudo-spritesheets y pixel art.
- [ ] **R1-04** Repetir generación con **imagen de identidad + pose controlada / edición**, o interveniendo manualmente; **detener** tras fallos repetidos y cambiar de técnica/proveedor, no continuar con prompts libres.

### R1-B — Cutout, rig y movimiento

- [ ] **R1-05** Extraer o crear PNG con alpha real y márgenes limpios; usar `tools/art/validate_actor_png.py` **sin confundir PASS de formato con arte aprobado**.
- [ ] **R1-06** Separar piezas reales (torso, cabeza, brazos, manos, muslos, piernas, capa/trenza, lanza/escudo), reconstruir zonas ocultas y fijar pivotes; comparar rig/cutout contra frames adicionales.
- [ ] **R1-07** Ejecutar **de verdad en Godot 4** el rig proxy v0.1 y Power Thrust v0.2, registrar errores, video y feedback. Las descripciones previas NO son prueba runtime.
- [ ] **R1-08** Sustituir proxy por al menos un **actor 2D ilustrado real** en un ataque `idle → windup → contacto → recovery → idle` y reacción `hurt`.
- [ ] **R1-09** Aplicar feedback de potencia del autor: flexión/carga visible, pausa, estocada **explosiva**, hit-stop breve y recuperación; evento `attack_contact` una sola vez.
- [ ] **R1-10** Dibujar un actor mini-anime de mapa desde el mismo canon, idle + desplazamiento mínimo; validar primer billboard en escena XYZ rotatoria.
- [ ] **R1-11** Retrato busto neutral y al menos una expresión derivada sin deriva facial; ampliar a `angry/hurt` si el método funciona.
- [ ] **R1-12** Registrar tiempo humano, intentos, costes, licencias, fallos de asimetría y facilidad de reproducir el proceso en un **segundo personaje**.

### Gate R1 — Se puede abandonar la fase solo si...

- [ ] C0: imagen maestra identificable y aprobada; no se aceptan manos invertidas/tacones.
- [ ] C3: **un actor real 2D de perfil** conservando cara, ropa, arma y silueta; no collage/pixel art.
- [ ] C4: textura/rig o frames funcionan en un proyecto **Godot ejecutado**; alpha, pies, escala y pivotes comprobados.
- [ ] C5: ataque + hurt visualmente legibles y estables, sin deriva temporal; acción no calcula daño.
- [ ] C2: unidad mini-anime y billboard con cámara real al menos en prueba específica.
- [ ] C6: coste y derechos revisados, fuentes y runtime separados.

**Salida alternativa si falla arte:** continuar temporalmente con PoC **mecánico** usando placeholder claramente etiquetado, pero **no** afirmar PoC artístico y **no** encargar docenas de animaciones. Registrar decisión go/no-go explícita.

## 5. R2 — Mundo táctico XYZ, selección, altura y cámara ISO/TOPDOWN

**Actualización de decisión (2026-10-22):** el autor acordó **dos modos explícitos ISO y TOPDOWN con conmutación manual**, en lugar de ISO_FULL / ISO_HYBRID / TOPDOWN por pitch con histéresis. Véase [ADR-0001 actualizado](engineering/adr/ADR-0001-pitch-presentation.md). **Es una decisión de producto, no un reporte de funcionalidades implementadas**. Pendientes límite ISO definitivo, UX de controles, tokens/props cenitales y autorización separada para programarlo.

**Baseline integrado en `main`:** PR #7 / R2-05A está fusionada mediante `5f7b9f39a7ac7d563e58d726cde0bec6252883a0` (incluye `GridModel`, `GridView` y `CameraController`). **PR #8 Draft, aún no fusionada**, implementa en su rama R2-05B: pathfinding/costes, validación de órdenes, preview, confirmación TAB y movimiento visual por casillas; runner local/CI en ese HEAD: **1310 checks**. Estas capacidades visuales/tácticas de PR #8 no se atribuyen al `main` integrado. La cámara actual sigue con yaw 45°/pitch 50°/zoom 17, Q/E, R/F y rueda, pitch 25–78°; **todavía no implementa** arrastre MMB ni conmutación manual ISO/TOPDOWN. La limitación visual del billboard fixed-Y a pitch 78° sigue pendiente.

### Backlog R2

- [ ] **R2-01** Definir `GridCoordinate`, casilla lógica y altura; validar correspondencia entre world space, celda seleccionada y trayectoria. *Parcial:* GridModel/conversiones y trayectorias legales con coste ya implementados en la rama de PR #8 (no fusionada); otros contratos del hito siguen pendientes.
- [ ] **R2-02** Renderizar escenario pequeño con 2–3 niveles de elevación y obstáculos, ilustraciones provisionales. *Baseline visual implementado y probado; gate integrado de R2 pendiente.*
- [ ] **R2-03** Cámara ortográfica ISO rotatoria, zoom, enfoque/centrado y ayuda de altura; extender con TOPDOWN manual en trabajo separado. *Parcial:* CameraController extraído; foco fijo y sin conmutación de modo.
- [ ] **R2-04** Picking casilla/unidad con ratón y control compatible con mando, resaltados en el mundo. *Parcial:* picking de collider real y selección de celda probados; unidad/mando pendientes.
- [x] **R2-05** Movimiento táctico con vecinos ortogonales, costes provisionales de terreno/altura y ocupación, Dijkstra determinista, resultado tipado, evaluación de orden, preview y confirmación por TAB. El coordinador confirma `actor_coordinate` una vez al aceptar; la presentación recorre los pasos usando tiempo visual independiente del coste. Presupuesto provisional **4 por orden**, reiniciado en cada orden; no hay turnos ni límite de órdenes. **Implementado en PR #8 Draft, aún no integrado en `main`**; 1310 checks y CI limpia en el HEAD revisado. Los props ilustrados siguen siendo decorativos/no bloqueantes.
- [ ] **R2-06** Pivote de pies, sombra y oclusiones frente a muros/rocas/escaleras; probar yaw completo y **rango ISO aprobado**. *Deuda visual R2-05B: al cambiar de superficie la sombra salta entre niveles (aprox. 0,58 unidades); se acepta solo como limitación provisional del proxy, no como resuelto. Requiere QA y decisión de presentación futura.*
- [ ] **R2-07** HUD de selección, altura, rangos y minimapa si aporta legibilidad. *HUD básico de selección ya existe; rango/minimapa pendientes.*
- [ ] **R2-08** Medir rendimiento en escenario pequeño y carga de unidades, registrando hardware, versión y frame time.
- [ ] **R2-09** **Presentación manual ISO ↔ TOPDOWN:** mantener ilustración vertical legible en ISO y una presentación cenital independiente del actor/props en TOPDOWN, con fallback temporal. **No implementar** ISO_HYBRID, umbrales automáticos ni histéresis. Compartir mismo estado lógico y picking, medir QA visual antes de aprobar assets. Ver [ADR-0001](engineering/adr/ADR-0001-pitch-presentation.md).
- [ ] **R2-10 (controles; propuesto para PR propio)** Conservar Q/E (yaw) y rueda (zoom); añadir soporte de botón central pulsado y arrastre de cámara. Probar horizontal→yaw y vertical→pitch ISO. Conmutación manual por botón visible y tecla candidata T. WASD/pan, sensibilidad y mando por confirmar, no aprobados como valores finales.

### Próximos checkpoints propuestos — orden aún por aprobar

1. Formalizar ADR-0001 y este roadmap (solo documentación).
2. Separar cambios de controles MMB y conmutación de modo de la extracción B2-B ya fusionada; decidir alcance mínimo y pruebas antes de programar.
3. **Histórico (2026-10-22):** la propuesta de priorizar R2-05 frente al pulido de TOPDOWN se ejecutó como PR #8 Draft; no constituye autorización automática de ningún hito posterior. Próximos checkpoints requieren decisión explícita del autor.
4. Probar y fijar el máximo ISO a partir de muestras 50°/55°/60°; diseñar presentación cenital de actor y objetos altos sin falsear el gate artístico.

### Gate R2

Una unidad visible se selecciona y mueve mediante ruta legal con coste, restricciones de terreno/altura y estado determinista; conserva pies y sombra al cambiar altura. **R2-05 está implementado en la rama de PR #8**, no se afirma aún integrado en `main`. QA C3 observó una transferencia discontinua de sombra entre niveles (aprox. 0,58 unidades), registrada como deuda provisional; a pitch 78° el billboard fixed-Y pierde legibilidad (**QA FAIL conocido**, no corregido). La cámara debe girar/zoomear dentro del rango ISO que se apruebe y alternar ISO ↔ TOPDOWN con presentación legible, una vez diseñado y autorizado. **El gate global R2 permanece PENDING**: el PoC mecánico no supone gate artístico aprobado.

## 6. R3 — Scheduler híbrido y reglas de ronda

- [ ] **R3-01** Formalizar invariantes y reglas abiertas: elegibilidad, inicio de ronda, ventanas, bando inicial, desempates, tratamiento de Velocidad, bajas/refuerzos.
- [ ] **R3-02** Implementar `BattleState` y registro de unidades/acciones ordinarias consumidas, separados de cámara y UI.
- [ ] **R3-03** Prototipar y comparar al menos **dos políticas** para proporciones no enteras (p. ej., turnos ponderados / déficit acumulado), documentando injusticias y facilidad de uso. **No aceptar un algoritmo solo por el caso 12:4.**
- [ ] **R3-04** Acordar con el autor la política elegida, incluyendo casos límite; plasmar fórmula exacta y ejemplos trazables en una especificación posterior.
- [ ] **R3-05** Crear suite automática para 1:1, 4:4, 12:4, 7:4, 5:3 y variaciones de unidades elegibles; verificar que cada una actúa ordinariamente una vez.
- [ ] **R3-06** Añadir eventos de baja, unidades adicionales, bloqueo/desbloqueo de estado y excepción danza/acción extra sin loops.
- [ ] **R3-07** Visualizar ventana/bando/unidades pendientes con UI legible; sin inventar todavía online/código de red.

### Gate R3

**100 %** de la suite de invariantes definida pasa en ejecución; sin bandos hambrientos, rondas que no acaban ni activaciones ordinarias duplicadas. El autor ha revisado el comportamiento de reparto, sobre todo 7:4 y 12:4. El atributo Velocidad mantiene decisión explícita de rol o estado abierto sin enmascarar el conflicto.

## 7. R4 — Combate, estado, objetivos e IA mínima

- [ ] **R4-01** Definir `UnitInstance`, HP, equipo/arma, clase y stats mínimos para un ataque físico y una magia simple.
- [ ] **R4-02** Resolver daño/acierto y estado de forma reproducible; separar RNG y la presentación; log de `ActionResult`.
- [ ] **R4-03** Implementar vista previa de movimiento/ataque, selección de blanco, comando validado, consumo de activación y derrota/retirada de unidad.
- [ ] **R4-04** Introducir 1–2 tipos de terreno con coste/bonus, un ataque cuerpo a cuerpo y un ataque con alcance/efecto diferente.
- [ ] **R4-05** Implementar condiciones de victoria/derrota, restart y partida de prueba completa.
- [ ] **R4-06** IA básica legal y repetible capaz de elegir acciones y avanzar hacia objetivo; sin comportamiento imposible por sesgo al jugador.
- [ ] **R4-07** Iniciar test de captura de propiedad **si** no bloquea PoC; economía/reclutamiento ampliados pueden esperar a la vertical slice.

### Gate R4

Un enfrentamiento termina con un resultado reproducible sin intervención manual de consola: atacar, fallar/acertar, aplicar daño, morir/retirarse, finalizar ronda y evaluar condición de victoria. La vista lateral no altera el estado.

## 8. R5 — Integrar y cerrar el Proof of Concept

### Entregable

**Una build PC local**, iniciable por desarrollador, que permita jugar al menos una escaramuza completa contra IA: mapa táctico 3D con alturas, cámara ISO rotatoria y TOPDOWN seleccionable, actor(es) 2D, movimiento/ataque, scheduler proporcional, resultado de combate, UI legible y victoria/derrota.

### Tareas de integración

- [ ] **R5-01** Crear un nivel-test único intencionadamente pequeño (candidato **aprox. 10×10 a 16×16 casillas**, a ajustar sin convertirse en estándar de mapas).
- [ ] **R5-02** Integrar scheduler, turnos humanos/IA, reglas de ataque, estados, objetivos y HUD en una sola escena.
- [ ] **R5-03** Añadir modo de combate sobre mapa y, **si Gate R1 superado**, un duelo lateral 2D con dos personajes completos, fondo ilustrado de parallax suave, impacto sincronizado y retorno.
- [ ] **R5-04** Probar activar/desactivar animaciones sin alterar HP, RNG o victoria.
- [ ] **R5-05** Registrar fallos de alturas/oclusiones al orbitar y al desplazar por bordes del mapa.
- [ ] **R5-06** Test de scheduler 12:4 y 7:4 mediante simulaciones aunque la partida visual tenga menos unidades.
- [ ] **R5-07** Ejecutar controles básicos en teclado/ratón y evaluar mando; identificar acciones sin foco accesible.
- [ ] **R5-08** Guardar captura/video de partida, resumen QA y build reproducible con hash/versión.

### Criterios de aceptación PoC

| Criterio | Mínimo necesario |
| --- | --- |
| Juego completo | Se puede empezar → jugar contra IA → ganar/perder → reiniciar sin editar manualmente código durante una partida. |
| Movimiento | Reglas de cuadrícula/obstáculo y al menos un caso de altura verificables en mundo 3D. |
| Cámara / arte | Cámara rota/zoomea y actor 2D no rompe pies/posición. **PoC artístico exige actor ilustrado, no solo proxy.** |
| Iniciativa | Suite proporcional y rondas correctas; movimientos del UI corresponden al motor. |
| Combate | Ataque con resultado estable, daño, muerte/retirada y una diferencia táctica visible entre ataques o terrenos. |
| Presentación | Acción en mapa; duelo lateral 2D funcional **cuando el gate artístico esté aprobado**. |
| Estabilidad | Sin crash/bloqueo de flujo en la secuencia probada; defectos conocidos documentados. |
| Calidad | Registro de fallos con prioridad, vídeo/evidencia y decisión sobre cambios. |

**Tres posibles resultados, que nunca deben confundirse:**

1. **PoC técnico aprobado, arte pendiente:** reglas/cámara/IA funcionan con placeholders; falta probar la visión completa.
2. **PoC artístico parcial:** aspecto bueno pero no se consigue animación/rig o estabilidad; no lanzar producción.
3. **PoC integral aprobado:** experiencia jugable y pipeline artístico mínimo pasan sus respectivos gates.

**No incluir por obligación:** narrativa extensa, diez biomas, crafting, multiplayer en red, 4 jugadores, música dinámica acabada, Maker, cientos de tropas o localización completa.

## 9. R6 — Vertical slice (demostración del producto real)

Una vez el PoC demuestre motor + arte:

- [ ] **R6-01** Diseñar **microcapítulo no necesariamente canónico** con situación inicial, diálogos, despliegue, misión, decisión y consecuencia posterior.
- [ ] **R6-02** Ilustración de fondo narrativo 2D, **retratos busto** y diálogo sobre mapa 3D durante la misión; pipeline reproducible.
- [ ] **R6-03** Dar significado táctico a objetivo secundario, unidad neutral o propiedad capturable; persistir una **bandera** que modifica un diálogo o condición de misión posterior.
- [ ] **R6-04** Añadir ejemplo pequeño de crecimiento/maestría, promoción o estado de herida y descanso (escoger demostración sostenible), con interfaz apropiada.
- [ ] **R6-05** Ampliar a **segundo personaje** real para comprobar repetibilidad de canon → retrato/mapa/battle y medir coste por asset.
- [ ] **R6-06** Introducir VFX legibles, audio, música de combate normal/attack en prototipo sincronizado; no declarar que dos pistas IA diferentes encajan sin prueba.
- [ ] **R6-07** Textos y UI **ES/EN** de todo el fragmento; voces parciales en inglés si disponibles/licenciadas.
- [ ] **R6-08** Guardado/carga del estado relevante y UI accesible con mando para validar consola como intención.
- [ ] **R6-09** Probar con usuarios: comprensión de altura, activación, selección, daño, ritmo de animaciones y objetivos.

### Gate R6

Persona ajena al desarrollo puede completar una misión breve, comprender controles/objetivos, experimentar una consecuencia real, reconocer a los mismos personajes entre las representaciones y dar feedback reproducible. Presupuesto y esfuerzo de generar el segundo actor registrados.

## 10. R7 — Alpha de campaña y sistemas de producto

**Solo después de revisar alcance comercial:**

- Construir bible narrativa, canon de mundo, reparto definitivo, capítulos y guion; escalada humana → política → cósmica sin invocar dioses para todo.
- Clases/armas/magia/skills: catálogo, fórmulas, progresión/level-ups/promociones y balance; más estados, alturas y voladores.
- Campaña persistente: roster, heridas/descanso, inventario, despliegue, misiones alternativas y consecuencias que convergen.
- Herramientas internas **data-driven** de mapas/eventos/unidades; no confundir con el Maker público.
- Generación de biomas, fondos, portraits, genéricos modulares, rigs y efectos **después de medir repetibilidad**.
- Refriegas y propiedades como reglas de escenario; economía/crafteo neutral AI solo tras diseño/balance de prototipo.
- IA capaz de controlar ejércitos más grandes, defender propiedades, evitar bloqueos y usar hechizos, objetivos y recursos.
- Rendimiento y escalabilidad; determinar tamaños máximos con profiling, no extrapolar de un mapa 10×10.

**Gate de entrada R7:** alcance específico de V1 consensuado y recursos reales medidos. **No** lanzar automáticamente un enorme backlog de contenido por haber pasado una única misión.

## 11. R8 — Beta, localización, consola y lanzamiento (plan preliminar)

- QA funcional/regresión de rondas, guardado, IA, mapa y arte; pruebas de rendimiento de hardware objetivo.
- Corrección de accesibilidad, contraste, subtítulos, remapeo y mando/TV.
- Traducción + revisión de **español/inglés**, glosario consistente, layouts tolerantes a textos largos.
- Mezcla de OST dinámica, SFX, voces parciales inglés; separar buses de audio.
- Auditoría de derechos: imágenes, voces sintéticas, música, iconos, código externo, tipografías, licencias y marcas.
- Decidir publicación PC, consolas, tiendas, precio, clasificación, promoción, telemetría, guardado cloud, achievements y soporte; **todo ello pendiente**.
- Plan de pruebas externas, trailer/capturas solo con assets aprobados, proceso de bugs y definición de «release candidate».

**No se fija fecha de lanzamiento**, ni plataforma de consola concreta ni precio. Su estimación se basa en volumen validado de contenido y esfuerzo real del solo-dev, no en expectativas.

## 12. Rutas futuras separadas (no ruta crítica del primer PoC)

### Maker público

- Herramienta de mapas / propiedades / activadores; guardado/compartición de escenarios y potencial editor de campañas.
- Requiere formato data-driven estable, UX robusta, validadores y seguridad de import de contenido.
- **No empezar por editor público**: herramientas internas bastan al principio.

### Multiplayer 1–4

- Reglas de alianzas, neutral IA, turnos humanos y desconexión; definir online, local/hot-seat y sincronización.
- Si es en red, comandos deterministas/validación autoritativa y pruebas de lag/abandono. Arquitectura preparada; **no implementar netcode hasta completar reglas del simulador**.

### Supervivencia cooperativa / roguelike

- Grupo persistente, creación de unidad/expedición, generación de mazmorras y progresión/supervivencia.
- Modo separado con coste de diseño muy alto, **no parte de la ruta mínima a GDD/PoC/V1 salvo nueva decisión del autor**.

## 13. Pruebas y Quality Gates transversales

### Gameplay y scheduler

- Invariante una activación ordinaria por unidad y ronda; ninguna elegible queda sin actuar.
- Registrar secuencias 12:4, 7:4 y otros casos fraccionarios.
- Resolución de ataque independiente de imagen, FPS y música; casos reproducibles por seed/registro.
- Validar clic/picking de casilla con elevación y pathfinding sin atravesar obstáculos.

### Arte y presentación

- Personaje reconocido entre portrait, mapa, duelo; asimetrías coherentes y **calzado plano funcional**.
- Cámara ISO de inclinación limitada: contacto de pies, sombra, oclusión y yaw de prueba; TOPDOWN con presentación cenital específica y picking del mismo modelo, sin sustituirlo por billboards verticales aplastados.
- Animación: carga/ataque/contacto/reacción, **no** slideshow de un cuerpo rígido vendido como rig funcional.
- PNG: transparencia real, márgenes y pivotes, formato correcto, visual inspection; hash y costo/licencia.

### Rendimiento y experiencia

- Guardar datos reproducibles de hardware/escena/fps/frame time/memoria y nº de unidades activas para comparar.
- Testear combinaciones de escala de interfaz/zoom, lectura de cursor y apoyo de mando.
- Versionar informes de pruebas e incidencias; no esconder fallos detrás de capturas promocionales.

## 14. Riesgos, trade-offs y condiciones de parada

| Riesgo prioritario | Impacto | Medida y criterio de parada |
| --- | --- | --- |
| **R-ART-01: personaje 2D no animable** | Muy alto; la promesa visual depende de ello. | Pasar por C0–C5. Si falla método guiado tras iteraciones acotadas, cambiar técnica o hacer draw-over/rig manual; no lote de assets. |
| **R-ART-02: billboards ISO y vista TOPDOWN** | Alto; arma/pies pierden lectura si el ISO se inclina demasiado (observado a 78°). | Probar límite ISO legible y representación cenital independiente; yaw, alturas y oclusiones antes de escalar clases. |
| **R-GAME-01: scheduler desigual** | Muy alto; núcleo original del juego. | Tests de equidad y no duplicación antes de IA avanzada o red. |
| **R-TECH-01: 3D/2D + input Godot** | Alto; prototipo puede lucir bien en foto y fallar jugando. | Escena controlada real en Godot, vídeo y QA rotatorio. |
| **R-SCOPE-01: un solo desarrollador** | Crítico para plazo/calidad. | Congelar PoC y diferir Maker, online, survival y economía profunda. |
| **R-IA-01: derechos y coste** | Alto para comercialización. | Aprobación de proveedores/licencias y techo de reintentos antes de gasto. |
| **R-CONTENT-01: narrativa ramificada** | Alto para contenido. | Vertical slice con una variable persistente, rutas convergentes y coste medido. |

## 15. Criterio de priorización del backlog

Antes de iniciar cualquier ticket responder:

1. ¿Demuestra uno de nuestros **tres riesgos dominantes** —arte, cámara XYZ o turnos—?
2. ¿Es requisito directo de la batalla PoC o de la micro-misión vertical?
3. ¿Su salida es **verificable dentro de Godot / test automático**?
4. ¿Existe una solución provisional más barata sin hipotecar los datos futuros?
5. ¿Cuántos intentos/candidatos y coste máximo permitiría el autor?

**Si las respuestas son negativas, no está en P0.**

### Ruta crítica propuesta

`R0 (ambiente) → [R1 (actor/animación) en paralelo controlado con R2 (mapa/cámara)] → R3 (scheduler) → R4 (combate/IA) → R5 (PoC integral) → R6 (vertical slice) → decisión alcance V1 → R7/R8.`

**Nota de planificación:** el scheduler se puede prototipar antes del arte y en paralelo a cámara; la ruta anterior expresa dependencias de integración, no obliga a esperar para escribir tests puros.

## 16. Próximas cinco acciones concretas

| Orden | Acción | Entregable observable | Por qué ahora |
| --- | --- | --- | --- |
| **1** | Revisar GDD/roadmap, marcar «propuestas» que deben decidirse antes de programar | Lista pequeña de bloqueantes priorizados | Evita asumir fórmulas o fecha. |
| **2** | Abrir/ejecutar **Godot Power Thrust v0.2** y comprobar la estocada contra el vídeo anterior | Captura/video + feedback técnico, no solo documentación | Hay un proxy y feedback concreto ya creados. |
| **3** | Obtener **una imagen lateral aislada, no pixel**, de PC-001 con botas planas y lados anatómicos correctos | Un PNG de referencia revisado (C3-A), sin paneles | El actual bloqueo de arte es material, no textual. |
| **4** | Crear primer mapa XYZ con cámara libre y billboard placeholder/real | Escena Godot reproducible con 2–3 alturas | Comprueba que la dirección visual realmente funciona. |
| **5** | Prototipar scheduler proporcional determinista 12:4 + 7:4 | Suite de tests y simulación de ventanas | Demuestra el sistema diferencial del juego. |

**Resultado deseado al completar estas acciones:** sabemos si las tres columnas del juego (arte 2D, mundo XYZ y turnos híbridos) son viables antes de invertir en campaña de larga duración.

## 17. Registro de estados y cambios

- **2026-10-18:** **ROADMAP v0.1 creado por solicitud del autor**. No se declaran cerradas las decisiones futuras ni realizados los hitos. Las pruebas artísticas previas PC-001 se arrastran como evidencia experimental y riesgos, no como gates aprobados.
- **2026-10-22:** **Propuesta v0.2 (registro histórico):** actualizar el estado de R2 tras PR #3–#5 y documentar la decisión del autor de **dos modos ISO/TOPDOWN manuales**, sin modo híbrido ni conmutación automática. La prioridad de adelantar R2-05 se autorizó posteriormente y su implementación está en PR #8 Draft (aún no fusionada). Este registro histórico no autoriza R2-06, R2-09 ni R3. La implementación de modos/controles sigue pendiente de autorización propia.
- Toda modificación de requisitos después de esta versión debe indicar fecha, motivo, impacto de alcance y relación con el GDD.
- **Fuente central de la visión:** [pre-GDD](pre_gdd/README.md). **Especificación de diseño actual:** [GDD](GDD.md).

**Éxito a corto plazo:** no «tener muchos sistemas», sino **poder jugar una batalla corta en Godot y mostrar un personaje 2D coherente bajo cámara libre, con turnos proporcionales correctos y ataque de lectura convincente**.
