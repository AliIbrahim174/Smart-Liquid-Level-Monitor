# ESP8266 Simulation Commands

## Purpose

The prototype uses one real ESP8266 + C43 sensor and simulated rooms for demonstration.

## Serial Monitor Commands

Send commands at 115200 baud:

```
N1
L1
C1
```

Meaning:

- N = Normal
- L = Low
- C = Critical
- Number = Room number

Examples:

```
C2
```

Room 2 becomes:

```
Status: CRITICAL
Level: 5%
Mode: SIMULATION
```

```
N3
```

Room 3 becomes:

```
Status: NORMAL
Level: 80%
Mode: SIMULATION
```

## Demo scenario

Room 1:
- Real C43 sensor
- Live level measurement

Room 2 and Room 3:
- Software controlled scenarios
- Used for hospital monitoring demonstration
