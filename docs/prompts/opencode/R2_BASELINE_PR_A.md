# OpenCode — PR A: versionar y verificar baseline Godot R2

**ESTADO: PREPARADO, NO ACTIVADO.** Este prompt se entregará al agente **después de que el autor revise, apruebe y fusione la PR #1 de gobernanza**, y autorice explícitamente comenzar **PR A**. La mera existencia del documento en GitHub no autoriza implementación ni merge. El diagnóstico previo [ya se completó](R2_CAMERA_PRESENTATION.md); no repetirlo.

## Contexto y límites

- Directorio **único y exclusivo**: `C:\Dev\RPG-Tactics-3D-Prototype`. No generar fuentes, ZIPs ni proyectos externos a esta raíz.
- **Un solo proyecto Godot**, conservando `project.godot` en la raíz del repositorio. El baseline local ya tiene `scenes/IsometricArtTest.tscn`, `scripts/isometric_art_test.gd`, `art/`, `docs/ART_QA_CHECKLIST.md`, un `README.md` modificado y `.godot/` sin seguimiento.
- El baseline local es **provisional**; el ZIP externo de referencia no se encontró. No atribuir igualdad de hash ni procedencia completa sin pruebas. No borrar materiales locales no aprobados.
- OpenCode detectó `config/features = ["4.7", "GL Compatibility"]`, pero **no verificó un ejecutable Godot**. No asumir Godot 4.2 ni cambiar características del proyecto; hallar binario y reportar versión, o marcar pruebas de ejecución como PENDING.
- Leer `AGENTS.md`, GDD, Roadmap R0/R2, `docs/engineering/ARCHITECTURE.md`, `docs/engineering/WORKFLOW.md`, `docs/engineering/REVIEW_CHECKLIST.md` y ADR-0001 antes de editar.

## Gate de activación

**Antes de escribir código, comprobar:**
1. PR #1 ya fusionada en `main`, y existe aprobación **explícita** del autor para comenzar PR A. Si no, parar y pedir instrucciones.
2. `git status --short`, `git diff -- README.md`, `git branch --show-current`, `git rev-parse --show-toplevel`, `git remote -v` y archivos sin seguimiento. Mostrar plan de preservación de datos y ramas antes de operaciones que puedan alterar el árbol.
3. Si el árbol local sigue sucio, **no** ejecutar `git reset --hard`, `git clean`, `git stash -u`, merges/checkout/switch que puedan pisar archivos, ni comandos equivalentes. No descartar el README editado, PNG de PC-001 ni cache del autor. Si un cambio de rama no es seguro, **detenerse** y solicitar mecanismo de preservación dentro de la misma raíz, sin sobrescribir nada.
4. **No duplicar `project.godot`**. Proponer staging selectivo en el proyecto raíz y conservar las rutas originales del PoC mientras no exista necesidad demostrada de reorganizar.

## Entrega técnica exclusivamente de PR A

1. Añadir un `.gitignore` Godot 4 apropiado que ignore `.godot/` y archivos generados, **sin borrar cachés existentes**. Mantener recursos fuente `*.svg`, `*.gd`, `*.tscn`, `*.godot` raíz, `*.import` y `*.uid` pertinentes versionables; comprobar el diff staged. No ignorar `*.import` o `*.uid` globalmente.
2. Versionar `project.godot` raíz, escena `scenes/IsometricArtTest.tscn`, script `scripts/isometric_art_test.gd`, fuentes SVG, importación relevante y `docs/ART_QA_CHECKLIST.md`. No copiar todo con `git add .`; usar `git add` selectivo y mostrar `git diff --cached --stat` y nombres.
3. Revisar `README.md` local **contra el README ya revisado de main** para conservar íntegros ambos contenidos y resolver diferencias de forma explícita. No aceptar sobrescrituras silenciosas.
4. `art/pc001_reference_character.png`: **no subir** hasta poder documentar procedencia/derechos; usar fallback visual verificable si falta sin modificar ni borrar el archivo local.
5. Compilar/importar con la versión real encontrada del ejecutable Godot; ejecutar smoke/headless y prueba manual del proyecto cuando sea posible. Guardar versión/comandos/salidas y capturas; si no hay binario o editor, no fingir PASS.
6. Registrar la procedencia provisional del baseline, esquema de archivos incorporados, límites del PoC y bugs conocidos. La PR A **no refactoriza** cámaras, presenters o cuadrícula; únicamente preserva y hace reproducible el estado inicial y corrige errores de importación realmente reproducidos, preferiblemente en commit aislado.
7. Añadir al menos una verificación reproducible del arranque/importación disponible en el entorno y checklist de regresión visual del baseline.

## Exclusiones

**No implementar** ISO_FULL/ISO_HYBRID/TOPDOWN, histéresis, refactor del monolito, combate, scheduler, IA táctica, Maker ni un segundo proyecto Godot. La lógica de pitch pertenece a **PR B futura**, tras revisión de PR A.

## Quality Gate de PR A

- Archivo `project.godot` único, rutas `res://` válidas, ninguna pérdida de fuentes/datos locales.
- Repositorio reproducible; `.godot/` sin seguimiento por Git, sin borrarlo físicamente.
- Assets locales opcionales y licencias registrados; no subir PNG sin revisión.
- Se aporta versión real de Godot y resultados de ejecución; de no ser posible, gate `PENDING` y bloqueo de merge de código salvo excepción documentada y aprobada por el autor.
- Diff real, pruebas y evidencia en **PR A a main**; review intermedio según umbrales de AGENTS; cero BLOCKER/MAJOR para el merge.
- **No hacer merge automático**. Esperar revisión y autorización explícita del autor.

## Informe del agente

Indicar rama y PR, `git status` previo/posterior, rutas y archivos cambiados, cómo preservó los archivos existentes, pruebas realizadas (versión, comandos, resultados reales), fallos o bloqueos y gate `PASS / FAIL / PENDING`. Pausar antes de PR B.
