# Checklist de code review (obligatorio)

## Alcance y arquitectura
- [ ] El PR coincide con el milestone/contrato del roadmap y GDD.
- [ ] Responsabilidades cohesivas, sin scripts que aglutinan reglas+UI+render+cámara; no singleton multipropósito ni dependencias circulares.
- [ ] Dominio puro y validación central; UI/AI/render no cambian estado por su cuenta.
- [ ] Contratos e interfaces mínimos, tipados, claros. Refactor separado de cambios funcionales cuando sea posible.

## Integridad, bugs y exploits
- [ ] Verificación central de bando, activación, límites, ocupación, coste, alcance, objetivo, fase y permisos si aplica.
- [ ] Comandos duplicados, obsoletos, cancelados o inválidos no mutan parcialmente estado.
- [ ] Datos externos malformados, IDs repetidos, números fuera de rango/no finitos y recursos faltantes manejados.
- [ ] RNG/damage/XP independiente de frames, hit-stop, visualización y sonido.
- [ ] No hay scripts o secrets ejecutables en contenido no confiable ni assets IA de licencia dudosa.

## Tests y evidencias
- [ ] Versión Godot, comandos de smoke/headless, salida real.
- [ ] Camino feliz + bordes + pruebas negativas + regresión de bugs.
- [ ] Cámara: pitch/tokens/sombras/selección no rompen alturas, zoom, yaw ni occlusión.
- [ ] PR incluye pruebas visuales (vídeo o capturas) cuando cambia representación.
- [ ] Docs y deuda técnica actualizadas, estado PASS/FAIL/PENDING honesto.
- [ ] Review intermedio hecho si rama larga; comentarios mayores resueltos.

BLOCKER y MAJOR impiden merge. Después de cambios para resolverlos, revisar el nuevo diff y ejecutar tests de nuevo. Aprobación final del usuario, no del agente.
