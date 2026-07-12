# ModDef Devices

The blessed device registry: curated, versioned ModDef profiles that ship as the
default registry for `moddef search`. This is the high-bar library. Every
profile here:

1. lints clean (`moddef lint` reports 0 errors),
2. is derived from a vendor-confirmed register map or a published SunSpec model
   (each profile's header links the source), and
3. carries a source attribution.

`status: vendor-confirmed` in [`registry.yaml`](./registry.yaml) means the
register map matches the vendor's documentation. None of these have been
verified against physical hardware yet; profiles that get hardware-tested will
be marked accordingly.

## Layout

```
<category>/<vendor>-<model>/<vendor>-<model>.moddef.yaml
registry.yaml   # the index moddef search reads
```

Categories: `solar-inverter`, `battery-storage`, `ev-charger`, `hvac`,
`energy-meter`.

## What's here

This first set is deliberately small. The eight profiles were picked so that
between them they exercise every encoding pattern in the spec, which is what
shakes out bugs in the stdlib and the codec before the registry grows.

| Device | Category | Why it's here |
|---|---|---|
| Fronius Symo/Primo GEN24 Plus | solar-inverter | SunSpec-native: model-chain discovery, `model_relative_offset`, register-referenced scale factors (`scale_ref` POW10), `na_values` sentinels, Common-model strings |
| Growatt SPH | solar-inverter | Proprietary Modbus: input + holding registers, static scaling, multi-word U32, status enums, charge/discharge and import/export direction |
| Victron Venus OS GX | battery-storage | BESS via a gateway: Modbus TCP, `default_unit_id`, signed registers, an overlay block for the directional views of a signed register |
| ABB Terra AC Wallbox | ev-charger | Write side: a R/W current setpoint and the watchdog timeout register with constraints, a COMMAND start/stop, a charging-state enum |
| Daikin Altherma 3 | hvac | Heat pump behind a Modbus gateway: signed temperature scaling, mode/status enums, status bit fields, a R/W setpoint |
| Eastron SDM630 | energy-meter | IEEE-754 floats in input registers, per-phase measurands |
| Carlo Gavazzi EM24-DIN | energy-meter | Integer registers with little-endian **word order** (the word-swap case), integer scaling |
| ABB B23 | energy-meter | The wide one: U32/U64 energy, signed power, sentinels, an ASCII string field, multi-flag status registers, a date/time register |

## Encoding-pattern coverage

| Pattern | Exercised by |
|---|---|
| SunSpec discovery + `model_relative_offset` | Fronius GEN24 |
| Register-referenced scale (`scale_ref`, POW10) | Fronius GEN24 |
| Unavailable/sentinel values (`na_values`) | Fronius GEN24, ABB B23 |
| IEEE-754 float storage | Eastron SDM630 |
| Static rational scaling | Growatt, Gavazzi, Daikin, Victron, ABB B23 |
| Word order BIG (multi-word U32/U64) | Fronius, Growatt, ABB B23 |
| Word order LITTLE (word swap) | Carlo Gavazzi EM24 |
| U64 / S32 / wide integers | ABB B23 |
| `STRING_ASCII` with `string_encoding` | Fronius, ABB B23 |
| Reusable enums (`enum_ref`) | Fronius, Growatt, Victron, ABB Terra, Daikin, ABB B23 |
| Bit fields / `flags` | Daikin, ABB B23 |
| `DATETIME` | ABB B23 |
| Write semantics + `COMMAND` | ABB Terra; R/W setpoints in Growatt, Daikin |
| Measurand qualifiers (phase/direction/aggregation/location/accumulation) | across the set |
| Modbus TCP + `default_unit_id` + overlay block | Victron Venus OS |

Patterns these profiles don't reach yet (`COIL`/`DISCRETE_INPUT`, composed
mantissa/exponent, `selector_ref`, repeating arrays with a stride, `BCD`,
`U24/U48`) are covered by the golden fixtures and codec tests in the `moddef`
repo, and will land here when a real device needs them.

## Validating

Profiles import `moddef:stdlib:measurands:1.0.0`, so the linter needs to find a
checked-out stdlib. Point it there with `MODDEF_PACKAGE_ROOTS`:

```sh
# from a moddef checkout next to this repo
MODDEF_PACKAGE_ROOTS=../moddef/stdlib moddef lint solar-inverter/fronius-gen24/fronius-gen24.moddef.yaml

# or lint everything
./validate.sh
```

CI ([`.github/workflows/ci.yml`](./.github/workflows/ci.yml)) builds `moddef`
from the sibling repo and lints every profile on each push.

## Contributing

A profile is accepted into this registry only if it lints clean, cites its
source in the header, and adds something the existing set doesn't already cover
(a new device family, or an encoding pattern not yet represented). Open the
larger field of candidate devices against `moddef lint` first; promote here once
the source is confirmed.

## License

Device profiles in this registry are dedicated to the public domain under
[CC0-1.0](LICENSE), so you can embed them without attribution obligations. See
[NOTICE](NOTICE) for SunSpec-derived content and [CONTRIBUTING.md](CONTRIBUTING.md)
for the sign-off requirement.
