import 'dart:async';
import 'package:http/http.dart' as http;

/// The ESP's synchronous server handles one request at a time. Share this
/// transport between screens and monitoring, and close timed-out sockets.
class EspHttpClient {
  static final shared = EspHttpClient();

  EspHttpClient({
    http.Client Function()? clientFactory,
    this.timeout = const Duration(seconds: 5),
  }) : _clientFactory = clientFactory ?? http.Client.new;

  final http.Client Function() _clientFactory;
  final Duration timeout;
  Future<void> _pending = Future<void>.value();
  final Map<Uri, Future<http.Response>> _reads = {};

  Future<http.Response> get(Uri uri) {
    return _reads.putIfAbsent(uri, () {
      return _enqueue((client) => client.get(uri)).whenComplete(() {
        _reads.remove(uri);
      });
    });
  }

  Future<http.Response> post(Uri uri, {required Map<String, String> body}) {
    return _enqueue((client) => client.post(uri, body: body));
  }

  Future<http.Response> _enqueue(
    Future<http.Response> Function(http.Client) request,
  ) {
    final result = _pending.then((_) async {
      final client = _clientFactory();
      try {
        return await request(client).timeout(timeout);
      } finally {
        // Future.timeout alone does not cancel the underlying HTTP request.
        client.close();
      }
    });
    // A failed request must not prevent the next poll from recovering.
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }
}
