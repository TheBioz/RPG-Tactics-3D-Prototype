# ADR-0001: pitch libre, representación visual adaptable

**Estado: PROPUESTA A VALIDAR en R2, no diseño definitivo.**  
**Observación:** vídeo real 20261019-0724-50.4016436.mp4: con pitch ~78° sprites Sprite3D billboard fixed-Y se ven mal, incluido el personaje y props altos.

## Decisión candidata

Separar CameraController (ángulo) de PitchPresentationResolver (modo, umbrales e histeresis) y Actor/PropPresenter (textura, pivote, sombra y transición). Los presenters no mutan grid/turnos/HP.

- ISO_FULL: sprite 2D vertical ilustrado para cámara isométrica.
- ISO_HYBRID: transición entre vistas con crossfade/variante 2D más compacta; comprimir Y no es solución artística completa.
- TOPDOWN: vista cenital dibujada o token táctico provisional para actor; copa de árbol/props con representación cenital o transparencia controlada.
- Umbrales orientativos: entrar híbrido a 58–60° y cenital a 70–72°; histéresis 3°; volver tras descenso a banda anterior. Convención: 0° horizonte, 90° cenital. **Valores NO aprobados; ajustar con pruebas.**
- Mientras no existan variantes ilustradas, usar proxies etiquetados; no declarar gate artístico superado.

## Alternativas y compensaciones

Un solo billboard es barato pero falla cenital; restringir pitch elimina topdown deseado; comprimir sprite deforma anatomía; variantes por ángulo requieren assets extra y diseño de transición. Probar primero 2 modos y refinar híbrido solo con evidencia.

## Tests de aceptación

Pitch sube/baja por umbrales, oscilaciones de ±2° sin parpadeos; yaw 360°, zoom y alturas. Mismo tile lógico, mismo actor ID, mismo target, no duplicación de sombras ni desaparición indebida. Recursos alternativos faltantes → fallback visible y log, sin crash. No filtraciones de fog-of-war o estado oculto por visual. Confirmación artística del autor con vídeo antes de congelar estándar.
