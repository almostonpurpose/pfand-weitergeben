# Open-data boundary for Berlin return points

The bundled file `PfandWeitergeben/Resources/berlin-return-points.json` is a dated, offline extract from OpenStreetMap. It is deliberately separate from private offer and hand-over data.

## Source and licence

- Source: OpenStreetMap contributors, queried through the public Overpass API
- Snapshot date: 2026-09-07
- Licence: Open Database Licence 1.0 (ODbL)
- Attribution shown in the app: `© OpenStreetMap contributors` with a link to `https://www.openstreetmap.org/copyright`

The snapshot contains 177 points: 92 supermarket/bottle-return entries and 85 glass-recycling entries. It includes every object explicitly tagged `amenity=vending_machine` plus `vending=bottle_return` returned by the query. To keep the native map responsive, supermarket and glass results are deterministically thinned to one representative point per approximately 0.04-degree grid cell; this makes the extract intentionally incomplete.

## Query categories

```overpass
[out:json][timeout:90];
area["ISO3166-2"="DE-BE"][admin_level=4]->.berlin;
(
  nwr["amenity"="vending_machine"]["vending"="bottle_return"](area.berlin);
  nwr["shop"="supermarket"](area.berlin);
  nwr["amenity"="recycling"]["recycling:glass_bottles"="yes"](area.berlin);
);
out center tags;
```

## Claims the UI may and may not make

- An explicit `vending=bottle_return` tag supports calling a point a bottle-return machine, but not claiming that it currently works or accepts every container.
- `shop=supermarket` supports calling a point a supermarket. It does not prove that deposit returns are available there.
- `recycling:glass_bottles=yes` supports calling a point glass-bottle recycling. It is not a deposit-return point.
- The app must not claim completeness, live opening status, machine availability, accepted container types or bin capacity.

A production refresh can replace the JSON behind `ReturnPointProviding`, but must preserve the source URL, licence, snapshot date, evidence tag and these uncertainty boundaries.

## Support-service sources

The optional in-app “Hilfe in Berlin” section was checked on 2026-09-07 against the Berlin Senate pages for Kältehilfe and Fachstellen Soziale Wohnhilfe. It links to the current Kältehilfe guide instead of hard-coding shelter opening times or capacity. Contact details must be rechecked before distribution.
