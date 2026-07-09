import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'asset_registry.dart';
import 'composition_engine.dart';
import 'world_ticker.dart';

class LayerRenderer extends StatelessWidget {
  final RenderLayer layer;
  final List<ComposedObject> objects;
  final int islandSeed;

  const LayerRenderer({
    super.key,
    required this.layer,
    required this.objects,
    required this.islandSeed,
  });

  @override
  Widget build(BuildContext context) {
    final time = WorldTicker.of(context);
    final layerObjects = objects.where((o) => o.def.layer == layer).toList();

    return Stack(
      clipBehavior: Clip.none,
      children: layerObjects.map((obj) {
        return _SpriteRenderer(object: obj, time: time);
      }).toList(),
    );
  }
}

class _SpriteRenderer extends StatelessWidget {
  final ComposedObject object;
  final double time;

  const _SpriteRenderer({required this.object, required this.time});

  @override
  Widget build(BuildContext context) {
    final anim = object.def.animation;
    final tOffset = anim?.getTranslation(time, object.seed) ?? Offset.zero;
    final rAngle = anim?.getRotation(time, object.seed) ?? 0.0;
    final scale = anim?.getScale(time, object.seed) ?? 1.0;
    final opacity = anim?.getOpacity(time, object.seed) ?? 1.0;

    Widget child = Image.asset(
      'assets/sky_haven/${object.def.assetName}',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );

    if (opacity < 1.0) {
      child = Opacity(opacity: opacity, child: child);
    }

    // Blend mode trick: The AI generated images have #EAF8FF backgrounds.
    // If our sky is #EAF8FF, setting BlendMode.darken on them removes the background
    // against the slightly lighter clouds (or we just rely on matching bg color).
    child = ColorFiltered(
      colorFilter: const ColorFilter.mode(Color(0xFFEAF8FF), BlendMode.darken),
      child: child,
    );

    return Positioned(
      left: object.x + tOffset.dx - 50,
      bottom: object.y + tOffset.dy,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.identity()
          ..scale(scale)
          ..rotateZ(rAngle),
        child: SizedBox(width: 100, height: 100, child: child),
      ),
    );
  }
}

class IslandBaseLayer extends StatelessWidget {
  final int seed;
  const IslandBaseLayer({super.key, required this.seed});

  @override
  Widget build(BuildContext context) {
    final time = WorldTicker.of(context);
    final bobY = math.sin(time * (2 * math.pi / 15) + seed) * 6;
    final rotZ = math.cos(time * (2 * math.pi / 15) + seed) * 0.008;

    return Positioned(
      bottom: -40 + bobY,
      left: -20,
      right: -20,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateZ(rotZ),
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(Color(0xFFEAF8FF), BlendMode.darken),
          child: Image.asset('assets/sky_haven/island_base.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
