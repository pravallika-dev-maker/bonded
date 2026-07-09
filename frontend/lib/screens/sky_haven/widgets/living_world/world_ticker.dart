import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class WorldTicker extends StatefulWidget {
  final Widget child;
  
  const WorldTicker({super.key, required this.child});

  @override
  State<WorldTicker> createState() => _WorldTickerState();

  static double of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_WorldTimeProvider>();
    return provider?.time ?? 0.0;
  }
}

class _WorldTickerState extends State<WorldTicker> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _WorldTimeProvider(
      time: _time,
      child: widget.child,
    );
  }
}

class _WorldTimeProvider extends InheritedWidget {
  final double time;

  const _WorldTimeProvider({
    required this.time,
    required super.child,
  });

  @override
  bool updateShouldNotify(_WorldTimeProvider oldWidget) {
    return time != oldWidget.time;
  }
}
