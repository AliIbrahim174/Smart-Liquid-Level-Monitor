# ESP Wi-Fi and interrupted readings

The ESP creates a local Wi-Fi network named `LiquidMonitor`, password
`liquid123`, with its HTTP API at `http://192.168.4.1`. This network does not
provide internet access.

## Apply the connection fixes

1. Compile and upload `esp8266/LiquidMonitorESP8266/LiquidMonitorESP8266.ino`
   using the NodeMCU 1.0 (ESP-12E Module) board and ESP8266 Arduino core.
2. Rebuild and install the Flutter app. Both the firmware and app need updating.
3. Join `LiquidMonitor` on the phone. Accept the phone's option to stay connected
   if it reports that the network has no internet.
4. Open `http://192.168.4.1/status` in the phone browser. It should return JSON.
5. Open Live Bottle and check that readings continue updating. Brief request
   failures show an orange delayed-reading indicator; three consecutive failed
   polls show Offline. Polling continues automatically, and successful reads
   restore Online. Older values remain visible with an explicit stale label.

## What changed

- App requests share a queue within each Dart isolate; simultaneous GETs to the
  same endpoint share a response. This reduces pressure on the ESP's synchronous
  HTTP server. Workmanager and the native Android service run separately.
- Screen and foreground monitoring polls cannot overlap themselves. Requests
  time out after five seconds, and their HTTP clients are closed, allowing
  recovery instead of accumulating waiting sockets.
- ESP HTTP processing runs continuously. Sensor averaging uses timed samples
  instead of blocking delays, and serial commands no longer wait for a newline.
- Wi-Fi runs explicitly in AP mode at `192.168.4.1` with sleep disabled.
- `/status` returns the bottle and sensor fields expected by the app. Text is
  JSON-escaped so quotes in liquid names cannot cause parsing failures.
- Android release builds have internet permission, with plain HTTP allowed for
  the ESP address only.

## If interruptions continue

- If the phone leaves the Wi-Fi network, select its stay-connected option and
  temporarily disable mobile data or automatic switching to mobile data to
  determine whether network selection is responsible.
- If Wi-Fi stays joined, check the phone browser's `/status` endpoint during an
  interruption. If the browser also fails, investigate the ESP, power supply,
  signal, or routing. If it works, investigate the app and collect its logs.
- Watch the ESP Serial Monitor at **115200 baud**. `Wi-Fi clients: 0` means
  no phone is currently associated. Repeated `LiquidMonitor boot` messages mean
  the ESP is restarting; the reset reason is printed immediately afterward.
- Test near the ESP with a stable USB power supply and cable.

The app cannot recover measurements that were never received during a true
network outage. Background Workmanager checks are periodic and do not provide
continuous live monitoring when the app is suspended.

## Automated checks

From `flutter_app`, run `flutter analyze` and `flutter test`. Regression tests
cover request serialization and coalescing, socket cleanup after timeout,
non-overlapping screen polling, stale-reading labels, and reconnection.

For an Arduino CLI build with the ESP8266 core and LiquidCrystal installed:

```text
arduino-cli compile --fqbn esp8266:esp8266:nodemcuv2 esp8266/LiquidMonitorESP8266
```

References: [ESP8266 soft-AP documentation](https://arduino-esp8266.readthedocs.io/en/stable/esp8266wifi/soft-access-point-class.html),
[Android network state documentation](https://developer.android.com/develop/connectivity/network-ops/reading-network-state),
[Dart timeout documentation](https://api.dart.dev/dart-async/Future/timeout.html).

Validation for this change: Flutter analysis and all six tests passed. The sketch
compiled with ESP8266 core 3.1.2 for `nodemcuv2` and LiquidCrystal 1.0.7. Android
dependency downloads initially delayed the build; after they completed, an
incremental ARM64 debug build succeeded in 14.7 seconds. Phone/ESP connection
stability still needs a physical-device test.

## Android installation fails after the APK builds

On the connected SM S938B, Flutter's streamed ADB install failed without a useful
error message. Installing the same APK with `--no-streaming` succeeded and
preserved existing app data. From `flutter_app`, with this SDK location:

```powershell
& 'C:\Android\sdk\platform-tools\adb.exe' install --no-streaming -r -t '.\build\app\outputs\flutter-apk\app-debug.apk'
& 'C:\Android\sdk\platform-tools\adb.exe' shell am start -n com.example.liquid_monitor/.MainActivity
flutter attach
```

`flutter attach` connects debugging and hot reload to the already running app.
To update the APK after code changes, build with `flutter build apk --debug`
before installing again. This works around the observed streamed-transfer
failure; it does not establish its underlying cause.

The background Workmanager dispatcher also requires `@pragma('vm:entry-point')`
because Android invokes it through native code. Without the annotation, device
logs report that the background Dart entry point cannot be resolved.
