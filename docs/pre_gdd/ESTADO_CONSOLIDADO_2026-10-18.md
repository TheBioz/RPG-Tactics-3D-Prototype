# Síntesis consolidada del pre-GDD — 18 de octubre de 2026

**Estado:** registro de la visión del autor y de sus elecciones **ART-001…ART-019**. No equivale a GDD aprobado, PoC validado, alcance de V1 comprometido, pipeline IA elegido ni código implementado.

Para detalles técnicos: [visión](VISION_DEL_JUEGO.md), [mecánicas](MECANICAS_Y_MODOS.md), [narrativa](NARRATIVA_Y_PERSONAJES.md), [arte y audio](DIRECCION_ARTISTICA_AUDIOVISUAL.md), [decisiones y pendientes](DECISIONES_ABIERTAS.md).

## Visión general declarada (PRE-001…PRE-024)

- RPG táctico por cuadrícula: Fire Emblem (héroes, clases, historia), Advance Wars (territorio, propiedades, ejércitos), FFT/BG3/D&D (variedad táctica), **con diseño propio**.
- **PC y consolas; no móvil/Android**. **Game-first, Maker-ready**: construir juego y datos reutilizables antes de ofrecer una herramienta de creación pública.
- **Campaña individual** narrativa con decisiones y consecuencias de misión; **refriegas 1–4 jugadores** PvP/PvE/co-op con tropas únicas/genéricas; **supervivencia/mazmorra cooperativa** como modo aspiracional no comprometido para V1.
- **Activación híbrida por bandas proporcionales al tamaño de los ejércitos**: cada unidad elegible actúa normalmente una vez por ronda; cierre cuando los bandos han agotado sus unidades; 12 vs 4 ejemplifica 3:1. Velocidad, cuotas fraccionarias, jugadores múltiples, refuerzos, IA neutral y habilidades extra aún sin algoritmo cerrado.
- **Combate/RPG:** triángulo espada-lanza-hacha, arco neutral, maestría de armas, magia elemental/luz/oscuridad, pocas skills singulares; growths probabilísticos más puntos asignables por nivel, también para genéricos y enemigos IA; promociones y captura/reclutamiento durante partidas.
- **Heridas sin permadeath por defecto**; el contador de descanso avanza solo en batallas **no desplegadas**. Permadeath alternativo avisando de incompatibilidades narrativas. Terrenos, elevaciones XYZ, voladores, obstáculos, captura, recursos/economía de refriegas y minimapa.
- **Narrativa:** post-Ragnarök multicultural; conflictos humanos y políticos sin intervención divina obligatoria; cuatro aventureros amigos y Askr/Jeigan como **reparto exploratorio**, no guion canónico. Gjallarhorn, Yggdrasil, Bifröst, Hel, Níðhöggr y otros elementos son **contexto por reconfirmar**. Finales aprox. tres como preferencia.
- **IA como apoyo de producción** visual, sonora y audiovisual bajo presupuesto reducido, con edición humana y derechos comerciales revisados. Ningún proveedor, modelo, coste ni técnica final aprobados.

## Dirección artística y audiovisual confirmada

| ID | Elección explícita del autor |
| --- | --- |
| ART-001 | Personajes del mapa con proporciones **mini-anime táctico**. |
| ART-002 | Estética anime **lumínica/heroica**, matices regionales más sobrios o melancólicos. |
| ART-003 | Armaduras de **detalle medio**. |
| ART-004 | **Genéricos modulares por clase/facción**; héroes de diseño único. |
| ART-005 | Batallas laterales vistosas con críticos y habilidades memorables. |
| ART-006 | Sprites 2D en mapa con **billboard corregido** y cámara libre. |
| ART-007 | Geometría 3D simplificada/texturas ilustradas, **no pixel art**; música con leitmotivs y versiones **normal/attack**. |
| ART-008 | **Usar el mínimo 3D posible**, solo principalmente para entorno táctico isométrico, cámara y XYZ; prioridad al 2D ilustrado. |
| ART-009 | **Combate lateral con personajes completos estilo Fire Emblem**; cámara estable, acciones legibles; animaciones opcionales. |
| ART-010 | **Fondos de duelo ilustrados 2D con parallax suave** (B), no fondos 3D completos. |
| ART-011 | **Magia/VFX vistosos pero limpios** (B), siempre legibles. |
| ART-012 | **Interfaz limpia con algún toque artístico propio**; sin saturar el HUD. |
| ART-013 | **Retratos de busto estilo Fire Emblem**. |
| ART-014 | **Diálogos híbridos (C):** fondo ilustrado 2D en escenas narrativas, retratos sobre mapa 3D en combate. |
| ART-015 | **Orquestal con identidad escandinava (C)**, no solo folk vikingo, leitmotivs y variaciones culturales. |
| ART-016 | **A+B según el momento:** instrumental o coros épicos/etéreos; sin coros obligatorios. |
| ART-017 | **Doblaje parcial (B):** reacciones y frases cortas de combate, diálogos escritos. |
| ART-018 | **Inglés** para el doblaje parcial. |
| ART-019 | **Español e inglés** iniciales en textos, interfaz, menús y subtítulos. |

La música de combate apunta a **versión normal en el mapa y versión attack en duelo lateral**; sincronización/capas aún por validar. El audio de voces es **en inglés**, no equivale a que los diálogos tengan que escribirse solo en inglés. No se ha aprobado doblaje completo ni canciones con letras.

## Abierto para diseño y pruebas

- **Lore y campaña:** personajes definitivos, canon, estructura de misiones, decisiones, culturas, finales.
- **Sistemas:** reglas exactas de turnos, velocidad, estados, terreno/altura, economía, balance, multiplayer/IA.
- **Tecnología/art:** sprites y animación, oclusiones del billboard con cámara libre, calidad del mapa XYZ, clases/genéricos modulares, fondos parallax, VFX e identidad de UI.
- **Audio/loc:** composición IA reproducible, versiones normal/attack que transicionen bien, mezcla, SFX, voces por personaje, acentos, regionalismos y QA bilingüe.
- **Producción:** nombre final, PoC, alcance de V1, roadmap, costes/herramientas/proveedores, derechos específicos, multiplayer online/local y Maker público.

**Siguiente bloque acordado como conversación, no decisión de implementación:** definir un pipeline IA para **personajes**: diseño maestro → retrato de busto → unidad mini-anime sobre mapa → actor de cuerpo entero para combate lateral, **mismo personaje reconocible**. Animación, coste, consistencia y exportabilidad como pruebas obligatorias antes de producir en masa.

## Experimento de personajes documentado (PC-001)

Se ha preparado la ficha **[PC-001 Vanguard Lancer — Character Master v0.1](personajes/PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md)** como **propuesta no canónica** de ensayo de la metodología heredada de RTM AI Art Factory. Todavía **no hay imagen maestra aprobada, asset jugable ni pipeline validado**. El siguiente hito es la revisión visual E0/C0.

## Documentos posteriores a esta fotografía de pre-GDD

Ya existen [GDD v0.1](../GDD.md) y [Roadmap v0.1](../ROADMAP.md) redactados después de esta síntesis. Este documento conserva la fotografía histórica del pre-GDD; para la planificación operativa usar los borradores nuevos, aún pendientes de revisión.

## Regla de interpretación

**Dirección elegida ≠ factibilidad demostrada ≠ entrega prometida para V1.** Las propuestas técnicas o ejemplos del asistente, aun documentados, no se vuelven decisiones por aparecer aquí.
