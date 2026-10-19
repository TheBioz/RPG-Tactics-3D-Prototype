# Arquitectura de referencia: juego táctico Godot 4

**Propuesta de implementación para R0/R2**, derivada del GDD §15 y roadmap R0–R5. No significa que ya existan estos módulos.

## Dependencias hacia el núcleo

- **Datos de contenido** (definiciones de mapas, unidades, terreno, escenas y reglas): versionados, validados al cargar y separados del estado de una partida.
- **Dominio**: estado lógico y reglas deterministas, sin dependencias a Node, SceneTree, Sprite3D o UI. Modelos de celdas, comandos, scheduler, movimiento, combate y resultados (cada uno solo cuando su hito lo necesite).
- **Aplicación**: casos de uso que reciben comandos de humano o IA, revalidan contra estado actual, ejecutan una única transición y publican un resultado. Punto de mutación único por acción.
- **Adaptadores Godot**: cámara, presenter de actores/props, UI, input, import/export y audio. Consumen resultados, no duplican reglas.
- **Escenas**: ensamblaje. Ningún script de UI actúa como fuente de verdad de HP, cuotas de acción o nivel de una casilla.

Dirección de dependencia: adaptadores → aplicación → dominio. El dominio no importa adaptadores.

### Convención espacial

En Godot 3D: X/Z = plano de casillas; Y = elevación. Modelo lógico explícito tile_x, tile_z, height_level; transformar a Vector3 solo en adaptador. No derivar transitabilidad ni estado del mundo a partir de texturas, Sprite3D ni posiciones interpoladas.

### Contratos de integridad

- Rechazar comandos duplicados/obsoletos, posiciones fuera de límites, alturas inválidas, referencias ausentes, targets fuera de alcance, unidades sin acción, acciones del bando contrario y estados negativos.
- No hay mutación parcial si una validación falla. Error tipado/controlado.
- Semillas registradas, simulado reproducible. Animaciones opcionales y cámara no influyen RNG, HP, alcance ni turnos.
- El contenido de Maker futuro es **no confiable**: validación de esquema, ID, tipo, tamaño, referencias, datos no finitos y rutas; nunca ejecutar código de mods dentro de la lógica de importación.
- Desacoplar estado lógico del render para que una selección en topdown no cambie ocupación/facing real. No exponer entidades invisibles por un token de topdown.
- Evitar múltiples singletons con estado global, dependencias circulares, funciones demasiado grandes y lógica copiada entre escenas.
- No crear un framework genérico prematuro; extraer interfaces ante límites claros y necesidades comprobadas.

### Estructura prevista (crecer por necesidad)

game/domain, game/application, game/adapters/godot, game/content, game/scenes, game/tests. Para el PoC previo usar experiments/iso_art_gate. Actualmente esta jerarquía **es una propuesta**, no código ya instalado.

### Auditoría continuada de la arquitectura

No basta con que una escena compile: tras cada milestone (o cada dos PRs de código dentro de uno), contrastar el grafo de dependencias real con este contrato. Revisar quién escribe el estado lógico, qué servicios comparten datos duplicados, acoplamientos por rutas de nodos, señales con mutaciones indirectas, tipos/errores, configuración centralizada y tests de regresión. Versionar resultados en `docs/engineering/audits/` usando [la plantilla](ARCHITECTURE_AUDIT_TEMPLATE.md). Priorizar refactors acotados por impacto; no añadir capas innecesarias para satisfacer un diagrama.

Proyecto único: `project.godot` en la raíz actual `C:\Dev\RPG-Tactics-3D-Prototype`. El experimento isométrico existente es una escena del mismo proyecto; no introducir otro `project.godot` en subcarpetas. La ubicación definitiva de scripts/escenas sigue sujeta a la revisión de baseline PR A.

### Pruebas y cambios

Tests puros sobre lógica y selección de presentación; smoke headless de escenas Godot; revisión visual de yaw/pitch/zoom/altura. Bug → test de regresión. Cambios de contrato requieren revisión/ADR, y refactors grandes no se mezclan con feats de gameplay sin necesidad. Optimizar solo tras perf medido.
