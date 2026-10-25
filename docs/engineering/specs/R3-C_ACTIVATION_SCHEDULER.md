# R3-C — Scheduler proporcional SWRR para el PoC

**Estado:** reglas aprobadas expresamente por el autor para el PoC inicial el **2026-10-24**. Implementación en curso; no es aprobación de merge ni cierre de R3.
**Alcance:** exactamente dos bandos, permisos ordinarios y rondas deterministas.
**Antecedentes:** análisis R3-A y corrección/propuesta R3-B; esta especificación sustituye sus alternativas A/B por SWRR aprobado.

## 1. Fórmula

Al inicio de cada ronda, cada bando `i` recibe un peso entero `Wᵢ`, igual al número de unidades elegibles en el roster congelado de esa ronda. Los créditos iniciales son cero. Los pesos no cambian durante la ronda.

Antes de cada permiso, un bando participa si conserva al menos una unidad viva, elegible y sin activación ordinaria consumida. Para cada participante:

```text
acumulado[i] = crédito[i] + W[i]
T = suma de W[i] para los bandos participantes
ganador = bando con mayor acumulado
si hay empate: ganador = prioridad_de_desempate
crédito_siguiente[i] = acumulado[i]
crédito_siguiente[ganador] -= T
```

Los créditos de bandos no participantes no se incrementan ni se reducen. Si solo queda un bando, `T` es su peso: sumar y restar ese peso deja su crédito sin cambio. Si no participa ninguno, el resultado es `ROUND_COMPLETE`, sin permiso.

La prioridad solo resuelve igualdad de créditos. Se conserva en estado y alterna entre rondas válidas; **no fuerza** qué bando obtiene el primer permiso. Toda aritmética es entera y las entradas/límites se validan antes de calcular.

## 2. Permisos y ventanas

El scheduler devuelve un permiso de un único uso lógico para un bando. La ventana de control es el bloque de permisos consecutivos concedidos al mismo bando. El permiso siguiente se recalcula tras confirmar cada activación; no se reservan slots futuros. La selección de unidad corresponde al jugador o a una futura IA, y ambas deben pasar por la misma validación de aplicación.

Una consulta es pura y repetible: no consume activación ni cambia créditos. El permiso identifica ronda y revisión de estado; cualquier transición posterior vuelve obsoletos los permisos anteriores.

## 3. Roster y consumo ordinario

- El roster de ronda queda fijado al iniciarla; los refuerzos se incorporan en la siguiente.
- Cada unidad viva y elegible tiene como máximo una activación ordinaria consumida por ronda.
- Una baja anterior a actuar elimina esa elegibilidad, sin registrar activación. Una baja posterior conserva el registro ya consumido.
- Las bajas son transiciones lógicas validadas; no implican HP ni reglas de daño.
- Consultas, cancelaciones antes de confirmar y órdenes inválidas, duplicadas, obsoletas o de bando incorrecto no mutan el estado ni los créditos.
- La activación confirmada registra consumo, actualiza créditos y revisión de forma atómica.

## 4. Prioridad, límites y cierre

- Dos bandos identificados de forma estable; IDs de unidad únicos y asociados a uno de esos bandos.
- Desempates: prioridad persistida y alternada en cada nueva ronda válida. Sin hora, FPS, orden de nodos ni aleatoriedad implícita.
- Ronda completa cuando ningún bando conserva activaciones ordinarias elegibles pendientes. `ROUND_COMPLETE` no significa victoria ni derrota.
- Iniciar una nueva ronda es una orden explícita. Restaura activaciones ordinarias de supervivientes según el roster aplicable, pone créditos a cero y alterna prioridad. Los IDs de permiso incluyen ronda y revisión para impedir su reutilización.
- PoC inicial: máximo defensivo de 100 000 unidades por bando; protege sumas y créditos frente a entradas malformadas, no es un límite de diseño de juego.

## 5. Exclusiones y asuntos posteriores

Velocidad no participa en el reparto entre bandos de esta versión y conserva posible relevancia futura. Acciones extraordinarias no se implementan ni se exponen como permisos ilimitados. Incapacitación temporal, refuerzos durante una ronda, tres/cuatro bandos, alianzas, neutralidad, red, desconexión y reglas de combate quedan fuera. El scheduler no decide condiciones de victoria/derrota ni si movimiento sin ataque consume una activación.

## 6. Calendarios de referencia

Con créditos iniciales cero, prioridades A/B y pesos fijos:

| Ejército | Prioridad A | Prioridad B |
|---|---|---|
| 1:1 | `AB` | `BA` |
| 4:4 | `ABABABAB` | `BABABABA` |
| 12:4 | `AABAAABAAABAAABA` | `ABAAABAAABAAABAA` |
| 7:4 | `ABAABABAABA` | `ABAABABAABA` |
| 5:3 | `ABAABABA` | `ABABAABA` |
| 12:7 | `ABAABABAABAABABAABA` | `ABAABABAABAABABAABA` |
| 1:8 | `BBBBABBBB` | `BBBBABBBB` |
| 0:5 / 5:0 | `BBBBB` / `AAAAA` | `BBBBB` / `AAAAA` |
| 0:0 | Sin permiso; cierre inmediato | Sin permiso; cierre inmediato |

Los calendarios son permisos de bando, no selección de unidades. Los casos de una unidad, bajas y continuación deben mantener las mismas reglas de revisión/permiso.

## 7. Límite de confianza de checkpoints y deuda futura

El checkpoint local v2 incluye `round_start_revision`. Valida coherencia estructural: ledger de unidades, roster/pesos, créditos SWRR, prioridad, ronda y revisión. Dentro de la ronda actual exige que `revision - round_start_revision` coincida con activaciones ordinarias consumidas más bajas del roster actual; un estado inicial sin transiciones requiere unidades vivas/no consumidas y crédito cero. Los créditos deben sumar cero, y también ser cero cuando todas las unidades del roster siguen vivas y pendientes.

Esa validación **no autentica procedencia ni demuestra la historia completa**. Un checkpoint manipulado que siga siendo estructuralmente coherente puede restaurarse; el formato C2 no promete resistencia a manipulación arbitraria.

No añadir criptografía, networking ni event sourcing en R3-C. Si el formato de checkpoint crece o se convierte en guardado persistente, considerar separar su codec/validador de `BattleState` y definir entonces un contrato de autenticidad/versionado apropiado.
