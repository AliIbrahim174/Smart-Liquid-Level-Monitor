# Smart Liquid Level Monitor

IoT liquid monitoring prototype using:

- NodeMCU V3 (ESP8266)
- C43 water level sensor
- 16x2 parallel LCD
- Flutter mobile application

## System

```
C43 Sensor -> ESP8266 -> WiFi -> Flutter App
                 |
                 -> LCD
```

## Current Features

- Sensor calibration for bottle liquid levels
- LCD percentage display
- ESP8266 WiFi Access Point
- HTTP JSON API
- Mobile app communication
- QR based container configuration (planned)

## Calibration

| Level | ADC |
|---|---:|
| 0% | 14 |
| 25% | 540 |
| 50% | 586 |
| 75% | 605 |
| 100% | 630 |

## API

GET:
```
/status
```

POST:
```
/config
```

## Hardware

See `hardware/` for wiring information.
