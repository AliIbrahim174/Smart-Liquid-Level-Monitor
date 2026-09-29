# C43 Sensor Calibration

Calibration was performed using the actual bottle prototype.

| Water Height | ADC Value |
|-|-:|
| Empty | 14 |
| 25% | 540 |
| 50% | 586 |
| 75% | 605 |
| 100% | 630 |

The sensor response is nonlinear, therefore the ESP8266 software uses piecewise interpolation instead of a single linear map.
