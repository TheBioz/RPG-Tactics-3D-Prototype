# PC-001 — Del concepto a un personaje animado (siguiente gate)

**Fecha:** 2026-10-18 · **Estado:** plan de experimento / NO implementado · **ID:** `pc001_vanguard_lancer` · **Canon narrativo:** no.

## Decisión práctica

Tras varios conceptos ilustrados, **detener nuevas rondas de simplificación estética de la hoja**. El diseño es suficientemente claro para **comenzar las pruebas técnicas**, aunque una hoja compuesta RGB aún no sirve para jugar. El autor aceptó la identidad general y pidió eliminar los tacones; la última versión mantiene botas de combate planas, un equipo más simple y una silueta legible. Registrar esta hoja como **referencia provisional del experimento**. No afirmar `C0_APPROVED` ni `C4/C5` superados hasta inspección/confirmación del asset maestro exacto y ejecución en Godot.

Archivo fuente inspeccionado localmente en la sesión: `hoja_de_personaje_caballera_lancera.png`. Datos: PNG RGB 1122×1402, 1 816 449 bytes. SHA-256: `eeeffa30e8bf51a4c7df590dab76ea576c30cc66a78e0a4c32f3bef82e7d4d10`. El archivo binario **no está incorporado a GitHub**, porque esta integración permite escribir documentos de texto, no subir ese PNG. Existe un paquete ZIP preparado para el desarrollador con el archivo de referencia + manifest de trazabilidad; el usuario puede colocarlo manualmente en la carpeta `art_source/` de su clon local tras revisión de derechos.

## Riesgo real que prueba el próximo experimento

**Consistencia temporal de la animación 2D y reutilización de assets**, no belleza de una imagen aislada. La capa y la trenza son particularmente problemáticas al moverse; la lanza y el escudo revelan cambios de mano, reflejos falsos y errores de oclusión.

## Prioridad 1: prototipo lateral de cuerpo completo

1. **Referencia limpia de perfil lateral**, cuerpo entero, sin elementos de otras vistas ni fondo; mano anatómica derecha con lanza, izquierda con escudo, escudo y capa con continuidad lógica. Esta nueva imagen debe derivarse de la referencia C0, no inventarse desde texto solo.
2. **Probar separación por piezas** para cutout/rig 2D: cabeza, torso, brazos, antebrazos, manos, escudo, arma y empuñadura, muslos/piernas, capa (2–3 masas), trenza. Guardar capas editables cuando sea posible. No prometer que la IA puede descomponer limpiamente una imagen sin retoque.
3. **Un único ciclo de ataque** y reacción: `idle → anticipación/windup → thrust/contact → recovery → idle`, más `hurt`. Prototipo mínimo; no generar todavía todos los críticos/skills.
4. **Importar a una escena independiente de Godot** (sin sustituir runtime de juego) con un fondo ilustrado provisional en 2D. Registrar datos objetivos: duración, estabilidad del rostro/equipo, pivotes, foot sliding y export.
5. **Gate de aceptación:** se reconoce la misma unidad en todas las poses; lanza/escudo en lado anatómico correcto; animación sin mutaciones de armadura/capa; al menos un ataque y daño legibles; eventos de ataque sincronizados pero resultado de HP calculado por lógica separada. Medir iteraciones, limpieza humana y coste.

## Prioridad 2: prueba de unidad de mapa

Después de tener una identidad de perfil manejable, producir un **actor mini-anime 2D aislado** con alpha, pivote de pies explícito y un primer idle/move. Probar en escenario XYZ de Godot: billboard corregido, zoom cercano y lejano, 4 rotaciones y alturas, sombras y oclusión. **No** heredar automáticamente cuatro direcciones del pipeline pixel art anterior.

## Prioridad 3: retrato y expresiones

Recortar una versión de busto **como referencia de identidad**, pero generar `neutral` aislado con composición constante y luego `angry/hurt` mediante edición localizada. No aceptar nueva identidad por cambiar solo de expresión.

## Orden de salida que debe respetarse

- Referencia y derechos/ID de generación → perfil lateral aislado → separación de piezas o pose-to-pose → **ataque jugable mínimo en Godot** → actor mini-anime y billboard → retrato expresivo → segundo personaje de control.
- No convertir imágenes bonitas en aprobación de pipeline; no comprar lotes ni iniciar generación masiva.
- Los valores de resolución, software (rig), frames/timing y coste definitivo se decidirán a partir de la prueba, no como suposición.

**Documentos relacionados:** [Character Master v0.1](PC-001_VANGUARD_LANCER_CHARACTER_MASTER_v0.1.md) y [Revisión C0 candidata 01](PC-001_C0_REVISION_CANDIDATO_01.md).

## Actualización — prueba realizada el 2026-10-18

Se han intentado tres generaciones de vista lateral, **rechazadas** por producir láminas y pixel art en lugar del actor anime 2D aislado solicitado. Ver [reporte con hashes y nuevo método](PC-001_SIDE_VIEW_TEST_RESULT_2026-10-18.md). No considerar el gate C3 aprobado.
