import 'dart:async';

/// Singleton event bus for broadcasting app-wide state changes.
/// Screens subscribe to this to instantly react to partner connect,
/// disconnect, time-travel, or any hero data change — without polling.
enum AppEvent {
  partnerConnected,
  partnerDisconnected,
  timeTravelCompleted,
  separationCreated,
  heroDataChanged,
}

class AppEventBus {
  AppEventBus._internal();
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;

  final _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  void emit(AppEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
