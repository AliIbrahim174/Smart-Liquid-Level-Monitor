import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:liquid_monitor/services/esp_http_client.dart';

class TrackingClient extends MockClient {
  TrackingClient(super.handler);
  bool closed = false;

  @override
  void close() {
    closed = true;
    super.close();
  }
}

void main() {
  final rooms = Uri.parse('http://192.168.4.1/rooms');
  final status = Uri.parse('http://192.168.4.1/status');

  test('simultaneous room polls share a request; other endpoints wait',
      () async {
    final response = Completer<http.Response>();
    final started = Completer<void>();
    final requests = <Uri>[];
    final transport = EspHttpClient(
        clientFactory: () => MockClient((request) {
              requests.add(request.url);
              if (request.url == rooms) {
                started.complete();
                return response.future;
              }
              return Future.value(http.Response('{"level":70}', 200));
            }));

    final first = transport.get(rooms);
    final duplicate = transport.get(rooms);
    final next = transport.get(status);
    await started.future;
    expect(requests, [rooms]);
    response.complete(http.Response('[]', 200));
    expect(await duplicate, same(await first));
    await next;
    expect(requests, [rooms, status]);

    // A completed read is not cached: later polls must get fresh data.
    await transport.get(status);
    expect(requests, [rooms, status, status]);
  });

  test('timeout closes the socket and releases the queue for recovery',
      () async {
    final stalled = Completer<http.Response>();
    final clients = <TrackingClient>[];
    final transport = EspHttpClient(
      timeout: const Duration(milliseconds: 20),
      clientFactory: () {
        final first = clients.isEmpty;
        final client = TrackingClient((_) =>
            first ? stalled.future : Future.value(http.Response('[]', 200)));
        clients.add(client);
        return client;
      },
    );

    await expectLater(transport.get(rooms), throwsA(isA<TimeoutException>()));
    expect(clients.first.closed, isTrue);
    expect((await transport.get(rooms)).statusCode, 200);
    expect(clients.last.closed, isTrue);
    // A late completion from the old socket cannot replace the new response.
    stalled.complete(http.Response('late response', 200));
  });

  test('configuration and status requests are also serialized', () async {
    final saved = Completer<http.Response>();
    final started = Completer<void>();
    final methods = <String>[];
    final transport = EspHttpClient(
        clientFactory: () => MockClient((request) {
              methods.add(request.method);
              if (request.method == 'POST') {
                expect(request.bodyFields['liquid'], 'Saline');
                started.complete();
                return saved.future;
              }
              return Future.value(http.Response('{}', 200));
            }));
    final config = transport.post(Uri.parse('http://192.168.4.1/config'),
        body: {'liquid': 'Saline'});
    final read = transport.get(status);
    await started.future;
    expect(methods, ['POST']);
    saved.complete(http.Response('{"success":true}', 200));
    await config;
    await read;
    expect(methods, ['POST', 'GET']);
  });
}
