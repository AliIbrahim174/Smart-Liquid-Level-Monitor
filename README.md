# Smart Liquid Level Monitor

IoT liquid monitoring prototype using:

- NodeMCU V3 (ESP8266)
- C43 water level sensor
- 16x2 parallel LCD
- Flutter mobile application

## System Architecture

```
C43 Sensor -> ESP8266 -> WiFi -> Flutter App
                 |
                 -> LCD
```

## Implemented Features

- Sensor calibration for liquid levels
- LCD percentage and status display
- ESP8266 WiFi communication
- HTTP JSON API
- Flutter mobile monitoring
- Live bottle monitoring
- Multi-room monitoring
- Real and simulation devices
- Critical and low-level notifications
- Background monitoring service
- Bottle identity and QR foundation
- Volume mismatch detection logic
- Alert history

## Phase 3 Documentation

Complete project documentation is available at:

```
docs/PHASE3_DOCUMENTATION.md
```

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
