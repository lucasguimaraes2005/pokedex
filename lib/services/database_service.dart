import 'package:hive/hive.dart';
import '../models/pokemon.dart';

class DatabaseService {
  static const String boxName = 'pokemons';
  static Future<Box> get _box async => await Hive.openBox(boxName);

  Future<void> insertPokemon(Pokemon pokemon) async {
    final box = await _box;
    pokemon.localId = DateTime.now().millisecondsSinceEpoch;
    await box.put(pokemon.apiId, pokemon.toMap());
  }

  Future<List<Pokemon>> getAllPokemons() async {
    final box = await _box;
    return box.values
        .map((e) => Pokemon.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Pokemon>> getFavoritePokemons() async {
    final box = await _box;
    return box.values
        .map((e) => Pokemon.fromMap(Map<String, dynamic>.from(e)))
        .where((p) => p.isFavorite)
        .toList();
  }

  Future<List<Pokemon>> searchPokemons(String query) async {
    final box = await _box;
    return box.values
        .map((e) => Pokemon.fromMap(Map<String, dynamic>.from(e)))
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> deletePokemon(int apiId) async {
    final box = await _box;
    await box.delete(apiId);
  }

  Future<void> updatePokemon(Pokemon pokemon) async {
    final box = await _box;
    await box.put(pokemon.apiId, pokemon.toMap());
  }
}