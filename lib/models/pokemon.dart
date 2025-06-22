import 'package:flutter/material.dart';

class Pokemon {
  int? localId;
  int apiId;
  String name;
  String sprite;
  List<String> types;
  Map<String, int> stats;
  bool isFavorite;
  DateTime capturedAt;

  Pokemon({
    this.localId,
    required this.apiId,
    required this.name,
    required this.sprite,
    required this.types,
    required this.stats,
    this.isFavorite = false,
    required this.capturedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'localId': localId,
      'apiId': apiId,
      'name': name,
      'sprite': sprite,
      'types': types.join(','),
      'stats': _statsToString(),
      'isFavorite': isFavorite ? 1 : 0,
      'capturedAt': capturedAt.millisecondsSinceEpoch,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      localId: map['localId'],
      apiId: map['apiId'],
      name: map['name'],
      sprite: map['sprite'],
      types: map['types'].split(','),
      stats: _statsFromString(map['stats']),
      isFavorite: map['isFavorite'] == 1,
      capturedAt: DateTime.fromMillisecondsSinceEpoch(map['capturedAt']),
    );
  }

  String _statsToString() {
    return stats.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  static Map<String, int> _statsFromString(String statsStr) {
    Map<String, int> result = {};
    for (String stat in statsStr.split(',')) {
      List<String> parts = stat.split(':');
      result[parts[0]] = int.parse(parts[1]);
    }
    return result;
  }

  String get capitalizedName {
    return name[0].toUpperCase() + name.substring(1);
  }

  Color get primaryTypeColor {
    return getTypeColor(types.first);
  }

  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire': return Colors.red;
      case 'water': return Colors.blue;
      case 'grass': return Colors.green;
      case 'electric': return Colors.yellow;
      case 'psychic': return Colors.pink;
      case 'ice': return Colors.cyan;
      case 'dragon': return Colors.indigo;
      case 'fairy': return Colors.pinkAccent;
      case 'fighting': return Colors.brown;
      case 'poison': return Colors.purple;
      case 'ground': return Colors.orange;
      case 'flying': return Colors.lightBlue;
      case 'bug': return Colors.lightGreen;
      case 'rock': return Colors.grey;
      case 'ghost': return Colors.deepPurple;
      case 'steel': return Colors.blueGrey;
      case 'dark': return Colors.black87;
      case 'normal': return Colors.grey[400]!;
      default: return Colors.grey;
    }
  }
}
