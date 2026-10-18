# Visión del juego (pre-GDD)

**Fuente principal:** descripción del autor, 2026-10-18.  
**Estado:** visión expresada; alcance de versiones y detalles concretos aún por definir.

## Fantasía de producto

RPG táctico de fantasía por turnos, sobre **cuadrícula**, que aspire a recuperar la claridad, crecimiento de unidades, triángulo de armas y campaña con personajes de Fire Emblem, junto a la conquista de territorio, propiedades y tropas de Advance Wars; introducir más variedad de magia, efectos tácticos, rutas y decisiones, con referencias de profundidad como Final Fantasy Tactics y el combate táctico de Baldur's Gate 3 / D&D.

La intención no es crear un clon ni adoptar obligatoriamente todas las reglas de esos juegos: diseñar una obra propia capaz de alternar desde escaramuzas pequeñas hasta guerras de castillo y batallas con muchas unidades.

## Plataformas y formato

- **PC y consolas** como objetivos. Android/móvil **queda fuera** de esta nueva visión.
- **Mundo táctico de geometría 3D mínima para XYZ, elevación y cámara isométrica libre**, con personajes y arte predominantemente 2D anime ilustrado (ART-006/008). Viabilidad en prototipo aún por validar.
- Unidades en casillas con coordenadas X, Y, Z y elevación; orientación y oclusión deben resultar coherentes al girar cámara.
- **Combate lateral 2D anime con personajes completos estilo Fire Emblem**, fondos 2D con parallax suave y VFX vistosos/legibles; representación opcional/desactivable, sustituyendo por animaciones básicas sobre el mapa (ART-009/010/011).
- Mapas pequeños, medianos y grandes con la misma lógica subyacente; minimapa y medidas de visibilidad/rendimiento (culling, streaming o representaciones simplificadas) conforme a pruebas reales.

## Modos de juego planteados

1. **Campaña individual:** capítulos, **retratos de busto tipo Fire Emblem** y presentación híbrida (fondos ilustrados 2D en escenas narrativas; diálogo sobre mapa 3D durante batallas), decisiones, despliegue, progreso, consecuencias e historia (ART-013/014).
2. **Refriega 1–4 jugadores:** mapas PvP, PvE o cooperativos según configuración; equipos de unidades únicas, genéricas o mixtos, edificios de captura/reclutamiento y eventualmente economía dentro de la batalla.
3. **Supervivencia/expedición cooperativa (modo separado):** 1–4 jugadores o uno solo controlando su equipo, crear unidad/grupo, explorar una mazmorra estilo aventura D&D/roguelike y sobrevivir el mayor tiempo posible. Visión aspiracional, no alcance cerrado para V1.

La infraestructura de juego cooperativo/competitivo para jugadores humanos debe evaluarse desde arquitectura, pero **online/local, turnos en red y orden de implementación están pendientes**.

## Filosofía de campaña

- RPG táctico narrativo con tono de novela visual: diálogos, mundo, relaciones y **decisiones que alteran capítulos, sucesos, objetivos y consecuencias**.
- Evitar minijuegos obligatorios/actividades de hub fuera de las batallas del estilo de los Fire Emblem modernos. Priorizar narrativa → despliegue → combate táctico → consecuencias.
- Unos **tres finales como máximo** es una preferencia aproximada, no compromiso definitivo.
- Sin permadeath narrativo por defecto; sistema de heridas graves y rotación de tropa. Permadeath opcional con advertencia de incoherencias de diálogo, por definir.
- Fantasía **post-Ragnarök**, con raíz nórdica y pluralidad de pueblos/culturas no necesariamente vikingos. El apocalipsis no explica todas las tramas personales/políticas.

## Game-first, Maker-ready

- La intención actual es **desarrollar primero un buen juego**; el Maker será una característica posterior/opcional y potencialmente una plataforma de campañas propias.
- **Arquitectura preparada para Maker:** mapas, unidades, clases, armas, propiedades, eventos y reglas suficientemente data-driven para que después puedan editarse; no codificar cada capítulo como excepción irrepetible.
- La herramienta de creación de mapas es el caso de uso fundamental para refriegas, incluso si la UI pública se lanza más tarde.
- Posibilidad futura de crear visual y mecánicamente unidades, mapas, misiones e incluso campañas; todavía no fijar su profundidad ni fecha.

## Producción independiente con IA

- Objetivo: **crear todos los assets visuales, música y material audiovisual con herramientas IA** en la medida necesaria, sin depender de artistas externos por el bajo presupuesto disponible.
- Debe existir identidad visual y sonora coherente, pipeline repetible, edición/revisión humana, trazabilidad de referencias y verificación de **licencias de uso comercial**.
- Se ha mencionado previamente un presupuesto disponible de **250 € para exploración de IA/artes visuales**, no un presupuesto de producción total ni una compra realizada. No asignar gasto sin acuerdo.
- Evitar confundir arte generado con assets técnicos listos para Godot; rig, loops, UV, export 3D, transparencia, animación y timing requieren validación.
- El test central del prototipo 3D será **si la dirección artística funciona** en zoom, rotación de cámara, mapa grande/pequeño y escenarios con elevaciones, no solamente si el motor dibuja unos cubos.

## Acuerdos audiovisuales adicionales

- **Interfaz limpia con toques artísticos propios** (ART-012).
- **Banda sonora orquestal con identidad escandinava**, predominantemente instrumental y con coros cuando proceda; leitmotivs y versiones normal/attack (ART-015/016).
- **Doblaje parcial en inglés** y **textos, menús y subtítulos en español e inglés** (ART-017/018/019).
- Ver [síntesis consolidada](ESTADO_CONSOLIDADO_2026-10-18.md) para todas las elecciones y cuestiones abiertas.

## Lo que esta visión NO decide todavía

Nombre comercial final, estructura exacta de rondas/iniciativa, tamaño máximo real del ejército, sistema de altura, reglas de economía, recursos, alcance de lanzamiento, stack artístico definitivo, herramientas online, cronograma, precio o si la primera versión ya incluirá Maker.
