# Corrección Godot 4 — Billboard FIXED_Y

**Fecha:** 2026-10-19
**Rama:** `poc/isometric-2d-art-gate`
**Estado:** error de compilación localizado y parcheado en el paquete v0.2; aún pendiente de ejecución visual en el editor del autor.

## Error comunicado

```text
res://scripts/isometric_art_test.gd:156
Cannot find member "BILLBOARD_FIXED_Y" in base "SpriteBase3D".
```

## Causa

La propiedad `Sprite3D.billboard` acepta `BaseMaterial3D.BillboardMode` en Godot 4.2+. La clase `SpriteBase3D` no expone la constante `BILLBOARD_FIXED_Y` usada originalmente.

## Cambio mínimo

```gdscript
# Incorrecto:
s.billboard = SpriteBase3D.BILLBOARD_FIXED_Y

# Correcto:
s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
```

Este modo restringe el billboard al eje vertical para que el sprite siga el yaw de la cámara sin tumbarse al cambiar pitch.

## Artefactos y validación

- Nuevo archivo completo: `RTM_Isometric_Art_PoC_v0_2_billboard_fix.zip`, adjunto al chat.
- Archivo cambiado: `scripts/isometric_art_test.gd` (línea 156).
- No modifica materiales, geometría, selección, cámara ni arte.
- ZIP verificado: 17 archivos y entradas sin corrupción; script escaneado y confirmado sin la referencia incorrecta.
- **No ha podido ejecutarse Godot en este entorno.** La ejecución real y los posibles errores adicionales deberán confirmarse en el editor del usuario.
- SHA-256 del ZIP v0.2: `ceae2cdb6ba602662efd5df534eee34f34fc7b06f1288020809c547bcd73a902`.

[Documentación oficial SpriteBase3D Godot 4.2](https://docs.godotengine.org/en/4.2/classes/class_spritebase3d.html) · [Enum BaseMaterial3D](https://docs.godotengine.org/en/4.2/classes/class_basematerial3d.html)

No dar por superado el gate del arte por arreglar un error de compilación; siguen faltando pruebas visuales del sprite bajo cámara libre y alturas XYZ.
