# Gate isométrico 2D + 3D — experimento v0.1

**Fecha:** 2026-10-18  
**Rama:** `poc/isometric-2d-art-gate`  
**Estado:** **prototipo Godot creado como paquete descargable de la conversación; todavía SIN ejecutar en Godot ni integrado aquí como código fuente**. Este documento conserva el contrato y los resultados del experimento, sin fingir que los assets/escena están ya versionados en el repositorio.

## Por qué retomamos este experimento

Después de ensayar PC-001 y su ataque articulado, el autor señaló una desviación de prioridades. Se decide **congelar el refinamiento de ataque** y comprobar primero la dirección visual fundamental del juego:

- cuadrícula de mapa pequeña o grande en mundo 3D XYZ, con alturas;
- cámara isométrica libre en yaw, pitch limitado y zoom;
- geometría 3D utilizada con moderación y arte 2D ilustrado por encima;
- personajes y vegetación 2D en billboard corregido para que no parezcan carteles giratorios;
- selección de casillas y contacto de los sprites con terreno irregular;
- un actor PC-001 de referencia, de forma explícita **provisional**, no una unidad/rig canon listo para el juego.

## Paquete de ensayo local

El paquete preparado en conversación se llama **`RTM_Isometric_Art_PoC_v0_1.zip`**. Se entrega mediante enlace al archivo del chat. Contiene un proyecto Godot 4 independiente en la carpeta `RTM_Isometric_Art_PoC_v0_1/`, con:

- `project.godot`
- `scenes/IsometricArtTest.tscn`
- `scripts/isometric_art_test.gd` — escenario 12×12, tres niveles de altura, materiales y props 2D, raycast de casillas y cámara.
- `art/ground_*.svg`, `art/tree_*.svg` y otras ilustraciones **vectoriales provisionales**, no pintura IA final.
- `art/pc001_map_proxy.svg` — pequeño proxy 2D **NO canon**.
- `art/pc001_reference_character.png` — copia redimensionada de la ilustración de PC-001 para comparar en pantalla (solo ZIP); **no** sprite mini-anime validado.
- `docs/ART_QA_CHECKLIST.md` — matriz de pruebas visuales.
- `README.md` — instrucciones para abrirlo en Godot.

**Este repositorio no almacena todavía el ZIP ni sus SVG/PNG/código por la limitación de transferencia binaria entre los artefactos locales y la integración de GitHub**. Para versionarlos, extraer el ZIP en `C:\Dev\RPG-Tactics-3D-Prototype\experiments\iso-art-gate-v0.1\` y hacer commit desde el clon local a esta rama tras las pruebas. No extraer dentro de `game/assets` como si fueran definitivos.

## Protocolo de validación

1. Importar escena Godot 4.2+ y confirmar que abre sin errores ni texturas perdidas.
2. Probar rotación **Q/E** en 360°, pitch **R/F** (25°–78°), zoom con rueda.
3. Probar clic para seleccionar casilla, mirar altura XYZ, **Tab** mover actor a casilla seleccionada (agua no transitable).
4. **G** alterna la cuadrícula, **B** muestra solo geometría sin sprites, **V** compara proxy SVG frente a ilustración anterior (solo paquete ZIP completo).
5. Grabar capturas/video a yaw 45°, 135°, 225°, 315°; pitch 30°, 50°, 70°; zoom cerca/lejos. Inspeccionar pivotes, sombra de contacto, oclusión, efecto «cartel», facing lógico y calidad artística.
6. **No declarar aprobado** si el mapa es demasiado esquemático o el arte aún necesita pintura definitiva. Validar después con un actor mini-anime 2D y props ilustrados de calidad objetivo.

## Gates y riesgos

- **TÉCNICO:** se han validado únicamente estructura del ZIP, 11 recursos SVG (renderizados fuera de Godot), rutas `preload`, PNG transparente y presencia de funciones de cámara y selección. **Godot no está instalado en este entorno; no se ha ejecutado**.
- **ARTÍSTICO:** los SVG son proxies vectoriales, no el anime pintado definitivo; este test no prueba la consistencia o calidad de generaciones con IA.
- **BILLBOARD:** se usa `Sprite3D.BILLBOARD_FIXED_Y`, un primer ajuste de orientación vertical, pero aún sin facings de mundo, correction atlas, mejores sombras, pruebas exhaustivas de oclusión y occlusion-of-bodies.
- **RUNTIME:** cajas/colisiones por casilla, no chunks/LOD/MultiMesh; no es una solución escalable de rendimiento.
- **NARRATIVA / COMBATE LATERAL:** fuera de alcance. Prototipos de ataque PC-001 quedan archivados.

**Criterio de decisión:** si la presentación con sprites 2D corregidos resulta convincente al girar/zoom/altura, seguir con un **asset mini-anime de calidad real** y el pipeline IA. Si falla, corregir camera/facing/sprite presentation antes de dedicar recursos al Maker o a animaciones espectaculares.
