# Appearance Contract

```json
{
  "top": { "status": "known", "type": "패딩", "color": "blue", "brand": "FILA" },
  "bottom": { "status": "known", "type": "트레이닝복", "color": "gray" },
  "hat": { "status": "none" },
  "shoes": { "status": "unknown" },
  "glasses": { "status": "unknown" },
  "items": [{ "type": "지팡이", "color": "brown" }]
}
```

`known` means the user explicitly stated the information. `none` means the user explicitly said the item is absent. `unknown` means unmentioned, unknown, or ambiguous.

Only `top`, `bottom`, `hat`, and `shoes` may be recolored, and only when `status === "known"` and `color` exists. `glasses` and `items` are MVP text only.
