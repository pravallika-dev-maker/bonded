import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Models ---

class DreamRoom {
  final String id;
  final String name;
  final String description;
  final bool isUnlocked;
  final int unlockDay;
  final String ambientState;
  final String baseImageUrl;
  final List<String> objects;

  DreamRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.isUnlocked,
    required this.unlockDay,
    required this.ambientState,
    required this.baseImageUrl,
    required this.objects,
  });

  factory DreamRoom.fromJson(Map<String, dynamic> json) {
    return DreamRoom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isUnlocked: json['isUnlocked'],
      unlockDay: json['unlockDay'],
      ambientState: json['ambientState'],
      baseImageUrl: json['baseImageUrl'],
      objects: List<String>.from(json['objects']),
    );
  }
}

class DreamObject {
  final String id;
  final String roomId;
  final String name;
  final IconData icon;
  final String type;
  final String addedBy;
  final String emotionalMeaning;
  final DateTime timestamp;
  final double xPos;
  final double yPos;
  final String? reaction;

  DreamObject({
    required this.id,
    required this.roomId,
    required this.name,
    required this.icon,
    required this.type,
    required this.addedBy,
    required this.emotionalMeaning,
    required this.timestamp,
    required this.xPos,
    required this.yPos,
    this.reaction,
  });

  factory DreamObject.fromJson(Map<String, dynamic> json) {
    IconData iconData = Icons.favorite_border;
    final nameLower = json['name'].toString().toLowerCase();
    if (nameLower.contains('light') || nameLower.contains('lamp')) {
      iconData = Icons.lightbulb_outline;
    } else if (nameLower.contains('couch') || nameLower.contains('chair')) {
      iconData = Icons.weekend;
    } else if (nameLower.contains('plant') || nameLower.contains('monstera')) {
      iconData = Icons.local_florist;
    } else if (nameLower.contains('photo') || nameLower.contains('music')) {
      iconData = Icons.photo_camera_back;
    }

    return DreamObject(
      id: json['id'],
      roomId: json['roomId'],
      name: json['name'],
      icon: iconData,
      type: json['type'],
      addedBy: json['addedBy'],
      emotionalMeaning: json['emotionalMeaning'],
      timestamp: DateTime.parse(json['timestamp']),
      xPos: json['xPos'].toDouble(),
      yPos: json['yPos'].toDouble(),
      reaction: json['reaction'],
    );
  }

  DreamObject copyWith({
    String? id,
    String? roomId,
    String? name,
    IconData? icon,
    String? type,
    String? addedBy,
    String? emotionalMeaning,
    DateTime? timestamp,
    double? xPos,
    double? yPos,
    String? reaction,
  }) {
    return DreamObject(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      addedBy: addedBy ?? this.addedBy,
      emotionalMeaning: emotionalMeaning ?? this.emotionalMeaning,
      timestamp: timestamp ?? this.timestamp,
      xPos: xPos ?? this.xPos,
      yPos: yPos ?? this.yPos,
      reaction: reaction ?? this.reaction,
    );
  }
}

// --- Asynchronous Loop State ---

class DreamHouseState {
  final int day;
  final String turn; // 'me' or 'partner'
  final String step; // 'discover', 'play', 'passed', 'final_reveal'
  final bool hasUnreadUpdate;
  final List<DreamObject> placedObjects;
  final DreamObject? latestDiscoveredObject;
  final bool isFirstTime;
  final DateTime? countdownEnd;

  DreamHouseState({
    required this.day,
    required this.turn,
    required this.step,
    required this.hasUnreadUpdate,
    required this.placedObjects,
    this.latestDiscoveredObject,
    this.isFirstTime = true,
    this.countdownEnd,
  });

  DreamHouseState copyWith({
    int? day,
    String? turn,
    String? step,
    bool? hasUnreadUpdate,
    List<DreamObject>? placedObjects,
    DreamObject? latestDiscoveredObject,
    bool? isFirstTime,
    DateTime? countdownEnd,
  }) {
    return DreamHouseState(
      day: day ?? this.day,
      turn: turn ?? this.turn,
      step: step ?? this.step,
      hasUnreadUpdate: hasUnreadUpdate ?? this.hasUnreadUpdate,
      placedObjects: placedObjects ?? this.placedObjects,
      latestDiscoveredObject: latestDiscoveredObject ?? this.latestDiscoveredObject,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      countdownEnd: countdownEnd ?? this.countdownEnd,
    );
  }
}

// --- Providers ---

final mockRoomsProvider = FutureProvider<List<DreamRoom>>((ref) async {
  final String response = await rootBundle.loadString('assets/mock_data/mock_rooms.json');
  final data = await json.decode(response) as List<dynamic>;
  return data.map((e) => DreamRoom.fromJson(e)).toList();
});

class DreamHouseNotifier extends Notifier<DreamHouseState> {
  @override
  DreamHouseState build() {
    // Initial Day 1 empty state
    return DreamHouseState(
      day: 1,
      turn: 'me',
      step: 'play',
      hasUnreadUpdate: false,
      placedObjects: [],
      isFirstTime: true,
      countdownEnd: null,
    );
  }

  void completeOnboarding() {
    state = state.copyWith(isFirstTime: false);
  }

  static Map<String, dynamic> parseImaginedDescription(String desc) {
    final lower = desc.toLowerCase();
    IconData icon = Icons.auto_awesome;
    String name = 'Imagined Touch';
    String ambience = 'warm_evening';

    if (lower.contains('coffee') || lower.contains('corner') || lower.contains('mug') || lower.contains('cafe')) {
      icon = Icons.coffee;
      name = 'Coffee Corner';
    } else if (lower.contains('light') || lower.contains('lamp') || lower.contains('fairy') || lower.contains('lantern')) {
      icon = Icons.lightbulb_outline;
      name = 'Fairy Lights';
    } else if (lower.contains('plant') || lower.contains('monstera') || lower.contains('eco') || lower.contains('flower') || lower.contains('vine') || lower.contains('ivy')) {
      icon = Icons.local_florist;
      name = 'Green Corner';
    } else if (lower.contains('candle') || lower.contains('fire') || lower.contains('flame')) {
      icon = Icons.local_fire_department;
      name = 'Warm Candles';
    } else if (lower.contains('book') || lower.contains('read') || lower.contains('shelf') || lower.contains('bookshelf') || lower.contains('library')) {
      icon = Icons.menu_book;
      name = 'Reading Corner';
    } else if (lower.contains('vinyl') || lower.contains('player') || lower.contains('music') || lower.contains('song') || lower.contains('album') || lower.contains('record')) {
      icon = Icons.album_outlined;
      name = 'Vinyl Corner';
    } else if (lower.contains('projector') || lower.contains('movie') || lower.contains('screen')) {
      icon = Icons.videocam_outlined;
      name = 'Cozy Projector';
    } else if (lower.contains('rug') || lower.contains('carpet') || lower.contains('mat')) {
      icon = Icons.grid_on_outlined;
      name = 'Cozy Rug';
    } else if (lower.contains('swing') || lower.contains('balcony') || lower.contains('chair') || lower.contains('couch') || lower.contains('sofa')) {
      icon = Icons.chair_alt;
      name = 'Balcony Swing';
    } else if (lower.contains('promise') || lower.contains('wish') || lower.contains('dream')) {
      icon = Icons.star_border;
      name = 'Future Promise';
    } else if (lower.contains('memory') || lower.contains('photo') || lower.contains('frame') || lower.contains('sketch') || lower.contains('playlist')) {
      icon = Icons.favorite_border;
      name = 'Hidden Memory';
    } else if (lower.contains('voice') || lower.contains('fragment') || lower.contains('record') || lower.contains('audio')) {
      icon = Icons.mic_none;
      name = 'Voice Fragment';
    } else if (lower.contains('note') || lower.contains('letter') || lower.contains('thought') || lower.contains('promise')) {
      icon = Icons.sticky_note_2_outlined;
      name = 'Emotional Note';
    }

    if (desc.length > 0 && desc.length < 25) {
      name = desc[0].toUpperCase() + desc.substring(1);
    }

    if (lower.contains('rain') || lower.contains('storm') || lower.contains('drizzle')) {
      ambience = 'rainy_night';
    } else if (lower.contains('night') || lower.contains('moon') || lower.contains('star') || lower.contains('starlight') || lower.contains('dark')) {
      ambience = 'moonlit';
    } else if (lower.contains('sun') || lower.contains('afternoon') || lower.contains('day')) {
      ambience = 'cozy_afternoon';
    } else if (lower.contains('gold') || lower.contains('sunset') || lower.contains('sunrise') || lower.contains('evening')) {
      ambience = 'golden_hour';
    } else if (lower.contains('warm') || lower.contains('cozy') || lower.contains('ambient') || lower.contains('soft')) {
      ambience = 'warm_evening';
    }

    return {
      'name': name,
      'icon': icon,
      'ambience': ambience,
    };
  }

  static String formatEmotionalTimestamp(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return "Added during a quiet morning ✨";
    } else if (hour >= 12 && hour < 17) {
      return "Left in a cozy afternoon ✨";
    } else if (hour >= 17 && hour < 21) {
      return "Added during a peaceful sunset ✨";
    } else {
      return "Left here last night ✨";
    }
  }

  void placeObject(String name, IconData icon, String meaning, String roomId, {double? xPos, double? yPos, String? customAmbience}) {
    // Limit to 100 characters maximum for emotional impact
    final cappedMeaning = meaning.length > 100 ? meaning.substring(0, 100) : meaning;

    final newObj = DreamObject(
      id: 'user_obj_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      name: name,
      icon: icon,
      type: 'user',
      addedBy: 'me',
      emotionalMeaning: cappedMeaning,
      timestamp: DateTime.now(),
      xPos: xPos ?? (0.35 + (0.3 * (state.placedObjects.length % 3) / 2.0)),
      yPos: yPos ?? (0.35 + (0.28 * ((state.placedObjects.length + 1) % 3) / 2.0)),
    );

    if (customAmbience != null) {
      ref.read(ambienceStateProvider.notifier).setAmbience(customAmbience);
    } else {
      final parsed = parseImaginedDescription(name + " " + cappedMeaning);
      ref.read(ambienceStateProvider.notifier).setAmbience(parsed['ambience']);
    }

    // Set lock countdown for 18 hours and 12 minutes
    final countdown = DateTime.now().add(const Duration(hours: 18, minutes: 12));

    state = state.copyWith(
      placedObjects: [...state.placedObjects, newObj],
      step: 'passed',
      turn: 'partner',
      countdownEnd: countdown,
    );
  }

  void addReactionToObject(String objectId, String reaction) {
    state = state.copyWith(
      placedObjects: state.placedObjects.map((obj) {
        if (obj.id == objectId) {
          return obj.copyWith(reaction: reaction);
        }
        return obj;
      }).toList(),
    );
  }

  void simulatePartnerAction() {
    final nextDay = state.day + 1;
    
    // Day 7 is the final walkthrough, so we transition there
    if (nextDay > 7) {
      state = state.copyWith(
        step: 'final_reveal',
        turn: 'me',
        hasUnreadUpdate: false,
      );
      return;
    }

    String pName = 'Balcony Candles';
    IconData pIcon = Icons.local_fire_department;
    String pMeaning = 'To light up our nights when we look at stars.';
    String pRoomId = 'living_room';

    if (nextDay == 2) {
      pName = 'Balcony Candles';
      pIcon = Icons.local_fire_department;
      pMeaning = 'These burn softly just like my thoughts of you.';
      pRoomId = 'living_room';
    } else if (nextDay == 3) {
      pName = 'Music Player';
      pIcon = Icons.music_note;
      pMeaning = 'A small jukebox playing our favorite songs.';
      pRoomId = 'kitchen';
    } else if (nextDay == 4) {
      pName = 'Fairy Lights';
      pIcon = Icons.lightbulb_outline;
      pMeaning = 'For cozy, starry late night chats.';
      pRoomId = 'bedroom';
    } else if (nextDay == 5) {
      pName = 'Monstera Plant';
      pIcon = Icons.local_florist;
      pMeaning = 'Growing slowly, just like our bond.';
      pRoomId = 'hobby_corner';
    } else if (nextDay == 6) {
      pName = 'Dream Polaroid';
      pIcon = Icons.photo_camera_back;
      pMeaning = 'Our first trip together, immortalized.';
      pRoomId = 'future_corner';
    } else if (nextDay == 7) {
      pName = 'Aesthetic Journal';
      pIcon = Icons.book_online;
      pMeaning = 'A record of all our quiet moments.';
      pRoomId = 'final_reveal';
    }

    final newObj = DreamObject(
      id: 'partner_obj_${DateTime.now().millisecondsSinceEpoch}',
      roomId: pRoomId,
      name: pName,
      icon: pIcon,
      type: 'partner',
      addedBy: 'partner',
      emotionalMeaning: pMeaning,
      timestamp: DateTime.now(),
      xPos: 0.45,
      yPos: 0.48,
    );

    state = state.copyWith(
      day: nextDay,
      turn: 'me',
      step: nextDay == 7 ? 'final_reveal' : 'discover',
      hasUnreadUpdate: nextDay < 7,
      latestDiscoveredObject: nextDay < 7 ? newObj : null,
      placedObjects: [...state.placedObjects, newObj],
      countdownEnd: null,
    );
  }

  void acknowledgeDiscovery() {
    state = state.copyWith(
      step: 'play',
      hasUnreadUpdate: false,
      latestDiscoveredObject: null,
    );
  }

  void resetGame() {
    state = DreamHouseState(
      day: 1,
      turn: 'me',
      step: 'play',
      hasUnreadUpdate: false,
      placedObjects: [],
      countdownEnd: null,
    );
  }
}

final dreamHouseStateProvider = NotifierProvider<DreamHouseNotifier, DreamHouseState>(DreamHouseNotifier.new);

// A simple notifier for the current ambient state
class AmbienceStateNotifier extends Notifier<String> {
  @override
  String build() => 'warm_evening';
  void setAmbience(String ambience) => state = ambience;
}
final ambienceStateProvider = NotifierProvider<AmbienceStateNotifier, String>(AmbienceStateNotifier.new);

// A notifier for daily activity unlocks
class ActivityUnlockNotifier extends Notifier<int> {
  @override
  int build() => 1;
  void advance() => state++;
}
final activityUnlockDayProvider = NotifierProvider<ActivityUnlockNotifier, int>(ActivityUnlockNotifier.new);
