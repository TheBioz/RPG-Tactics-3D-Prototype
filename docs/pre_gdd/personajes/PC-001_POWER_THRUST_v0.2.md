# PC-001 — Power Thrust: revisión de animación articulada v0.2

**Fecha:** 2026-10-18  
**Estado:** **prototipo de animación mecánica preparado, NO ejecutado ni validado en el editor Godot en esta sesión**. No es arte final ni un rig 2D comercial.  
**Motivo de la revisión:** feedback directo del autor tras un vídeo de aproximadamente 8,9 s del rig v0.1: «al lanzazo le falta potencia, el windup debe ser más extenso, su cuerpo debe prepararse [...] y luego de golpe, BAM! lanzazo, incluso más rápido de lo normal».

## Diagnóstico del rig v0.1 (vídeo aportado por autor)

- Anticipación anterior: solo **0,29 s**, con transición demasiado uniforme.
- Liberación anterior: aproximadamente **0,22 s** entre preparación y contacto.
- El cuerpo no mostraba suficiente flexión de rodillas, transferencia de peso hacia atrás ni impulso corporal concatenado.
- El arma rotaba y se extendía, pero la preparación física y el cambio brusco de velocidad apenas se distinguían. El gesto parecía «mover lanza» y no «estocada con todo el cuerpo».

## Principio aprobado como feedback de animación

**Carga legible y extensa → tensión breve → acción explosiva muy rápida → impacto breve → inercia y recuperación.** Aplicarlo primero al ataque de lanza; el mismo principio puede inspirar animaciones de otras clases sin volverlas idénticas.

## Timing de ensayo v0.2 (valores de prueba, no estándar definitivo)

| Beat | Tramo de timeline | Qué debe percibirse |
| --- | --- | --- |
| Anticipación / windup | 0.08–0.66 s | Peso en pierna trasera, centro de masas baja, rodillas flexionadas, escudo de protección, lanza retrasada y nivelada |
| Pausa cargada | 0.66–0.76 s | Unos 100 ms de tensión máxima |
| **Estocada explosiva** | **0.76–0.86 s** | **100 ms**: pie delantero avanza, cadera impulsa el torso, hombro y brazo aceleran, punta viaja veloz |
| Contacto | 0.86–0.89 s + 55 ms de hit-stop | Señal `attack_contact` emitida una vez; freeze de contacto corto, destello puntual |
| Follow-through/recoil | 0.89–1.09 s | Continúa ligeramente el movimiento, sin quedar rígida |
| Recuperación | 1.09–1.69 s | Controla equilibrio, recoge lanza, vuelve a guardia |
| Settle | 1.69–1.78 s | Retorno al idle |

Duración total visual aproximada: 1,84 s con hit-stop. Las duraciones podrán reajustarse según vídeos del editor y escala real del duelo.

## Prototipo preparado

Paquete de conversación: **`PC001_Rig_PowerThrust_v0.2.zip`**. Incluye `project.godot`, `RigTest.tscn`, `RigTest.gd`, `README.md`, previsualización ilustrativa GIF realizada con un script Python que replica de forma aproximada las ecuaciones de pose, y una comparación visual de seis momentos clave. **Los binarios y el GDScript completo están en el paquete adjunto al chat y no se han subido automáticamente a GitHub.**

El rig usa geometría vectorial provisional: **pierna trasera plantada**, pie delantero que avanza solo durante el burst, centro de gravedad retrasado durante la carga, hombro y brazo de lanza acelerados, brazo del escudo en guardia, capa y trenza con retraso visual. Mantiene los eventos de contacto **separados del cálculo de HP**.

**Controles:** Espacio/Enter = ataque; H = herida; R = reposo; **S = cámara lenta al 35 %**; T = mostrar/esconder muñeco objetivo; Q = texto técnico.

**Limitación:** la generación de previews con Python no equivale a ejecución en Godot; no se ha medido rendimiento ni comprobado el resultado en el ejecutable. El ZIP sí se comprobó como archivo comprimido válido, pero el editor requiere prueba en el equipo del autor. Si hay errores GDScript, corregir antes de evaluar movimiento.

## QA específico de potencia

- ¿Se lee **carga previa a la acción**, con cadera y torso moviéndose hacia atrás/abajo y flexión real del apoyo?
- ¿El acelerón de la lanza destaca por contraste frente al windup, sin transición blanda que diluya el golpe?
- ¿El pie trasero permanece estable, con paso de la pierna delantera únicamente en la salida del ataque?
- ¿Lanza y mano derecha anatómica se mantienen unidas? ¿Escudo sigue en la izquierda anatómica?
- ¿Hay **contacto** y recuperación claros, pero no un efecto gigante que tape al personaje?
- ¿El evento de contacto se dispara una vez y sigue independiente de los cálculos del combate?
- ¿El ataque se percibe convincente a velocidad normal, **no solo en cámara lenta**?
- ¿A tamaños de personaje realistas, la estocada de lanza mantiene silueta y legibilidad?

## Siguiente hito

**Probar v0.2 en Godot y comparar vídeo v0.1 vs v0.2**, afinando cadera, flexión de rodillas, lunge, dirección de punta y efecto del impacto antes de introducir ilustración. **La dirección artística sigue siendo anime 2D ilustrado NO pixel.** Este rig procedural es un placeholder válido mientras desarrollamos sprites, sin elevarlo a un asset jugable definitivo.

Relacionado: [prototipo anterior v0.1](PC-001_RIG_PROXY_EXPERIMENT_v0.1.md), [Character Master](PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md).
