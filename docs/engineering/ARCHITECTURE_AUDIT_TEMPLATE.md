# Auditoría arquitectónica — plantilla obligatoria

**Uso:** copiar a `docs/engineering/audits/<fecha>_<milestone>.md` al cerrar cada milestone o cada 2 PRs de código dentro del mismo milestone, lo que ocurra antes. La auditoría tiene que evaluar **código real**, no repetir la arquitectura deseada.

## Datos verificables
- Milestone / alcance auditado:
- Fecha:
- PRs y commits revisados:
- Versión Godot y ejecución comprobada (o PENDING):
- Revisor / evidencia (diff, logs, vídeos):
- Última auditoría anterior:

## 1. Mapa de componentes y dependencias
- Componentes nuevos/cambiados, propósito único de cada uno:
- Dependencias dirigidas y casos de inversión de capas:
- Nodos/autoloads/señales: quién lee/escribe estado, qué listeners causan efectos:
- ¿Surgió un archivo/clase con responsabilidades inconexas o un estado duplicado? Referencia a archivos/líneas:

## 2. Robustez y seguridad
- Único origen de verdad para coordenadas, turnos, órdenes, HP o recursos, según fase:
- Entradas inválidas, duplicados, recursos faltantes, datos externos y cancelaciones:
- Pruebas de RNG/eventos si afectan estado; dependencia accidental de frame rate:
- Explotaciones o bypass de reglas plausibles y contramedidas:
- Regresión: qué estaba funcionando y qué evidencia demuestra que sigue funcionando:

## 3. Calidad comprobable
- Tests automatizados: comandos, resultados y cobertura de caminos negativos:
- Smoke Godot: versión, comando y resultado; capturas/video si visual:
- Rendimiento y uso de memoria (solo si se midieron):
- Gestión de importación, fuentes de arte, licencias y archivos generados:
- Limitaciones de la prueba y no comprobado:

## 4. Hallazgos y decisiones

| ID | Severidad | Archivo/contrato | Evidencia e impacto | Acción mínima | Responsable / hito |
| --- | --- | --- | --- | --- | --- |
| EX-001 | SUGGESTION (ejemplo) | — | — | — | — |

- BLOCKER/MAJOR abiertos, si los hay:
- Refactors que deben separarse en PR posterior:
- Deuda aceptada y motivo (solo MINOR/SUGGESTION salvo excepción explícita del autor):
- ¿Hace falta un ADR nuevo o ajustar uno existente?:

## 5. Gate

- Arquitectura: PASS / FAIL / PENDING
- Tests/regresión: PASS / FAIL / PENDING
- Arte/presentación si aplica: PASS / FAIL / PENDING
- Decisión recomendada: CONTINUAR / PAUSAR Y REFACTORIZAR / NO MERGE
- Aprobación final y enlace PR: **pendiente del autor hasta confirmación**.
