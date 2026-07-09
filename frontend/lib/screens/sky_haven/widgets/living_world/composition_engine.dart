import 'asset_registry.dart';

class ComposedObject {
  final String id;
  final SkyObjectDefinition def;
  final double x;
  final double y;
  final int seed;

  ComposedObject({
    required this.id,
    required this.def,
    required this.x,
    required this.y,
    required this.seed,
  });
}

class CompositionEngine {
  static List<ComposedObject> compose(List<dynamic> rawObjects, int maxObjects) {
    if (rawObjects.isEmpty) return [];

    final mapped = rawObjects.map((obj) {
      final name = obj['type'] ?? obj['name'] ?? 'unknown';
      final def = AssetRegistry.get(name);
      return {
        'data': obj,
        'def': def,
        'priority': def.previewPriority,
      };
    }).toList();

    mapped.sort((a, b) => (b['priority'] as int).compareTo(a['priority'] as int));
    final topItems = mapped.take(maxObjects).toList();

    return topItems.map((item) {
      final obj = item['data'] as Map;
      final def = item['def'] as SkyObjectDefinition;
      final seed = obj['id']?.hashCode ?? obj.hashCode;
      
      final px = (obj['position_x'] ?? 0.0) * 40 + 150;
      final py = (obj['position_y'] ?? 0.0) * 20 + 80;

      return ComposedObject(
        id: obj['id']?.toString() ?? 'sys_$seed',
        def: def,
        x: px,
        y: py,
        seed: seed,
      );
    }).toList();
  }
}
