# Inventario de mecánicas y modos — pre-GDD

**Fuente:** descripción de mecánicas del autor el 2026-10-18 y primer párrafo del texto pegado conservado literalmente en fuentes.  
**Regla:** capturar toda la visión, sin inventar fórmulas ni imponer prioridades de V1.

## 1. Núcleo de batalla

- **Turnos por casillas cuadradas**; desplazamiento, ataque, defensa, rangos, terreno y objetivos.
- **Velocidad y características propias** diferencian unidades. Estadísticas, tipo de movimiento, crítico, defensa, fuerza y alcance importan más que una proliferación de skills.
- **Skills escasas y definitorias** de clases y personales, con ejemplos de inspiración Fire Emblem como Aether, Astra, Luna; evitar asumir que nombres o comportamientos existentes se adoptan literalmente.
- **Triángulo de armas:** espada > hacha > lanza > espada (orden concreto y bonificaciones por especificar). **Arco neutral** al triángulo y categoría propia.
- **Competencia/nivel de arma:** progresión por categoría que permite o impide equipar ciertas armas.
- **Magia:** elemental (fuego, viento, hielo y trueno), negra y luz; no solo daño: AOE, estados, control, buffs/debuffs, efectos y utilidades, combinaciones por diseñar.
- **Terrenos:** costes distintos por tipo de movimiento, bonificaciones y penalizaciones, muros/barreras y casillas infranqueables; unidades voladoras pueden franquear ciertos obstáculos.
- **Altura real:** mundo con ejes X/Y/Z, elevación, desniveles y restricciones ligadas a movimiento, alcance y quizá habilidades. Diseño exacto pendiente.
- **Combate visual:** transición/zoom a escenas de combate laterales anime 2D opcional/desactivable; siempre existe presentación básica en el mapa. Resultado táctico debe ser autoridad independiente de la representación.

## 2. Turnos / activaciones (visión híbrida)

El autor propone abandonar fases completas de ejército y explorar un **modelo de activaciones por ventanas proporcionales al tamaño de cada ejército**, manteniendo la sensación de fases entre jugadores/bandos.

- Cada unidad tiene, como norma, **una activación ordinaria por ronda**. Una vez usada no puede actuar de nuevo hasta la siguiente ronda.
- La **ronda termina cuando todas las tropas elegibles de todos los ejércitos han agotado sus activaciones ordinarias**, aunque los ejércitos tengan tamaños diferentes.
- El planificador distribuye ventanas de una o más unidades por bando **en proporción a su cantidad de unidades** para que todos puedan terminar la ronda; no imponer fórmula entera perfecta para ratios como 7:4.
- Puede haber activaciones adicionales o restauración de acción mediante skills especiales (conceptos como danza / Galeforce). Definir su impacto en cierre de ronda y equidad; las activaciones extraordinarias no deben generar bucles infinitos.
- La **velocidad de las unidades** podría intervenir en orden/prioridad y debe ser un elemento estratégico, pero aún no se ha decidido si interviene en cuota por bando, selección intra-ventana, desempates o acciones extra.
- No especificado: cómo distribuir varios participantes (1–4), alianzas, empates de iniciativa, unidades neutral IA, invocaciones/refuerzos, entradas en mitad de ronda, desconexión o AFK, mecanismos anti-snowball.
- **Ejemplo didáctico NO cerrado:** en un enfrentamiento 12 vs 4, pueden alternarse ventanas de 3 activaciones del ejército grande por 1 del pequeño. Para tamaños no múltiplos se necesita reparto proporcional dinámico.

## 3. Clases, RPG y estadísticas

- **Unidades únicas** con nombre, representación visual propia, narrativa, relaciones y progresión individual.
- **Unidades genéricas** sin obligaciones narrativas; pueden ser reclutadas dentro del mapa incluso cuando el ejército ya incluye héroes únicos. Su pérdida es aceptable; no son simples tokens sin progresión.
- Pueden existir mapas con solo únicas, solo genéricas (especialmente refriegas tipo Advance Wars) o mezclas.
- **Subida de nivel** para **todas las unidades**, incluidas genéricas y enemigos. Crecimientos de estadísticas mediante porcentajes, como Fire Emblem, **más un pequeño pool de puntos distribuibles** por jugador para intervenir en la evolución.
- La IA debe ser capaz de distribuir los puntos manuales para sus unidades. Reglas de asignación y si el proceso ocurre en mitad de la batalla: por diseñar.
- **Promociones de clase** inspiradas en Fire Emblem para únicas, genéricas y enemigos si reúnen requisitos y consiguen objeto/material de promoción; no restringirlas a héroes.
- Skills de arma y clase con acceso controlado; desbloqueos, progresión, equipamiento, inventario y límites todavía por especificar.

## 4. Derrota, heridas, reposo y permadeath

- **Campaña sin permadeath narrativo por defecto.** Cuando HP cae a cero, la unidad abandona esa batalla.
- Se aplica una **herida grave con debuff temporal persistente**, cuyo contador **solo avanza cuando la unidad no se despliega en batallas posteriores**. Usarla herida no ayuda a su recuperación.
- Sistema incentiva rotar compañeros/tropas y gestionar riesgo sin obligar a ramificar cada diálogo para cubrir cualquier muerte.
- **Permadeath opcional** como variante con aviso explícito: unidades muertas pueden seguir presentes en diálogos porque la narrativa no se diseña para esas muertes.
- Pendiente: acumulación/severidad de heridas, mínimo descanso, recuperación mediante objetos/magia, caso de genéricas, derrotas por retirada y persistencia en cada modo.

## 5. Refriegas, captura y economía

- Mapas de tamaño **pequeño, medio y grande**, con múltiples unidades y posibilidad de grandes asedios.
- **Propiedades capturables** y beneficios por control, inspirados en edificios de Advance Wars: puestos de reclutamiento, bonus, ingresos o recursos, según tipo.
- **Reclutamiento en la propia batalla** de tropas genéricas y excepcionalmente unidades únicas cuando un escenario lo permita.
- Posible **microeconomía in-battle**: capturar zonas de recolección, obtener loot de enemigos neutrales IA, conseguir materiales, **crear/comprar/equipar armas durante la batalla**. Incentiva disputas por posición, crecimiento de fuerza y decisiones de riesgo.
- Posibles bandos neutrales IA guardando recursos/loot. El funcionamiento de IA y neutralidad se debe diseñar.
- Pendiente: tipos de recursos, cuotas de producción, límites de población, economía que no provoque estancamientos, tiendas/crafteo, cómo equilibrar ejércitos desiguales y reglas de captura.

## 6. Modos y multiplayer

- **Campaña single-player:** capítulos, decisiones, objetivos alternativos, diálogos; algunas batallas usan reclutamiento y edificios.
- **Refriegas 1–4 jugadores humanos**, competitivas o cooperativas según escenario, con genéricas/únicas/mixtas. Posibilidad de alianzas y neutral IA.
- **Expedición/roguelike de supervivencia** como modo separado: grupo de 1–4 jugadores humanos o 1 jugador con su equipo, crear una unidad, explorar mazmorra cooperativamente, intentar sobrevivir y progresar, inspirado por la exploración D&D; detalles procedurales pendientes.
- Se desea un **sistema común** para movimiento, combate, efectos y unidades, con políticas de modo para reclutamiento, persistencia, economía, objetivos y despliegue.
- Diseño de red, sincronización, online/local, IA, guardado y alcance de primera versión: pendientes; no prometer que estén todos en el primer lanzamiento.

## 7. Campaña y decisiones

- Presentación estilo novela visual/Fire Emblem: escenas de diálogo, quizá escenas en mapas renderizados, elección, entrada al capítulo y desenlaces de misión.
- No incluir minijuegos obligatorios, simuladores de base o tareas ajenas a las batallas.
- Decisiones **sustantivas**: salvar o no a un neutral, escoger un objetivo frente a otro, asegurar una región a costa de perder otra, etc. Consecuencias en capítulos, personajes, mapas y sucesos.
- Ramificaciones que converjan hacia unos **tres finales como máximo** (cifra tentativa), evitando producir incontables campañas incompatibles.
- Relación directa con resultados reales de misión y eventos, no solo menú de elecciones cosméticas.

## 8. Mapa, cámara y rendimiento

- Geometría 3D, cuadrícula lógica, alturas reales y vista táctica isométrica para PC y consolas.
- Deben poder mostrarse muchos actores, assets altos, props que oculten casillas y escaleras/murallas sin perder selección ni lectura.
- Posibilidad de cámara rotatoria/zoom y facings 2D según el cuadrante, a confirmar visualmente.
- **Minimapa** para lectura y navegación en mapas grandes.
- Frustum culling, LOD, chunks o streaming como estrategias candidatas para evitar procesar/renderizar todo lo lejano; probar coste real y no confundir ahorro de dibujo con ahorro de memoria.
- Elevación, vuelos y obstáculos deben tener reglas independientes del modelo gráfico.
