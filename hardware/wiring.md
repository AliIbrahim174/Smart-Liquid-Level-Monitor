# Hardware Wiring

## C43 Sensor

| Sensor | NodeMCU V3 |
|-|-|
| VCC | 3V3 |
| GND | GND |
| Signal | A0 |

## LCD 16x2 Parallel

| LCD Pin | Function | NodeMCU |
|-|-|-|
| 1 | VSS | GND |
| 2 | VDD | VIN / 5V |
| 3 | Contrast | GND (temporary) |
| 4 | RS | D1 |
| 5 | RW | GND |
| 6 | Enable | D2 |
| 11 | D4 | D5 |
| 12 | D5 | D6 |
| 13 | D6 | D7 |
| 14 | D7 | D0 |
| 15 | LED+ | VIN / 5V |
| 16 | LED- | GND |

No buzzer or LEDs are used in this version.
