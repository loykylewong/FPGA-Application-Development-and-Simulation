Method `RenamePorts2AmbaConventions()` in gen_verilog.scala implemented the following method.

### AXI4-Stream

Requirements:

1. Use `IrrevocableIO`;
2. Name the instance of `IrrevocalbeIO` as:

   * `s**_axis**` or `m**_axis**`,
   * `s**_**_axis**_**` or `m**_**_axis**_**`,

   In which:

   * `**` can be any length (including 0) of alphabet character or digit,
   * `_**` can be repeated any times.

Replace:

```
([sm][^\W_]*(_[^\W_]+)*_axis[^\W_]*(_[^\W_]+)*)_(t?(valid|ready)|[^\W_]+_t?(last|data|user|id|keep|strb))\b
```

To:

```
$1_t$5$6
```

### AXI4 (and AXI4-Lite)

Requirements:

1. Use `Axi4IO` with 5 channels named as "aw", "w","b","ar","r";
2. Name the instance of `Axi4IO` as:

   * `s**_axi**` or `m**_axi**`,
   * `s**_**_axi**_**` or `m**_**_axi**_**`,

   In which:

   * 1st character after "axi" can NOT be 's',
   * `**` can be any length (including 0) of alphabet character or digit,
   * `_**` can be repeated any times.

Replace:

```
([sm][^\W_]*(_[^\W_]+)*_(axi|axi[^\W_s][^\W_]*)(_[^\W_]+)*)_(aw|w|b|ar|r)(_[^\W_]+)?_t?(ready|valid|addr|prot|data|strb|resp|id|len|size|burst|lock|cache|qos|region|user)\b
```

To:

```
$1_$5$7
```
