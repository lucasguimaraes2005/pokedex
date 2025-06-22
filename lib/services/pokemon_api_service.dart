import 'package:dio/dio.dart';
import '../models/pokemon.dart';

class PokemonApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<Pokemon?> getPokemon(String nameOrId) async {
    try {
      final response = await _dio.get('$baseUrl/pokemon/${nameOrId.toLowerCase()}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        List<String> types = [];
        for (var type in data['types']) {
          types.add(type['type']['name']);
        }

        Map<String, int> stats = {};
        for (var stat in data['stats']) {
          stats[stat['stat']['name']] = stat['base_stat'];
        }

        return Pokemon(
          apiId: data['id'],
          name: data['name'],
          sprite: data['sprites']['front_default'] ?? '',
          types: types,
          stats: stats,
          capturedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erro ao buscar Pokémon: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchPokemonList(String query) async {
    try {
      final response = await _dio.get('$baseUrl/pokemon?limit=1000');
      
      if (response.statusCode == 200) {
        final List results = response.data['results'];
        return results
            .where((pokemon) => pokemon['name'].toString().toLowerCase().contains(query.toLowerCase()))
            .take(20)
            .map<Map<String, dynamic>>((pokemon) => {
              'name': pokemon['name'],
              'url': pokemon['url'],
            })
            .toList();
      }
    } catch (e) {
      print('Erro ao buscar lista de Pokémon: $e');
    }
    return [];
  }
}
