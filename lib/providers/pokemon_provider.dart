import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/database_service.dart';
import '../services/pokemon_api_service.dart';

class PokemonProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final PokemonApiService _apiService = PokemonApiService();

  List<Pokemon> _pokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _showOnlyFavorites = false;

  List<Pokemon> get pokemons => _filteredPokemons;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get showOnlyFavorites => _showOnlyFavorites;

  Future<void> loadPokemons() async {
    _isLoading = true;
    notifyListeners();

    _pokemons = await _dbService.getAllPokemons();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<Pokemon?> searchPokemonInApi(String nameOrId) async {
    return await _apiService.getPokemon(nameOrId);
  }

  Future<List<Map<String, dynamic>>> searchPokemonList(String query) async {
    return await _apiService.searchPokemonList(query);
  }

  Future<bool> addPokemon(Pokemon pokemon) async {
    try {
      final isAlreadyCaptured = _pokemons.any((p) => p.apiId == pokemon.apiId);
      if (isAlreadyCaptured) {
        return false; // Pokémon já foi capturado
      }
      await _dbService.insertPokemon(pokemon);
      _pokemons.add(pokemon);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      print('Erro ao adicionar Pokémon: $e');
      return false;
    }
  }

  Future<void> toggleFavorite(Pokemon pokemon) async {
    pokemon.isFavorite = !pokemon.isFavorite;
    await _dbService.updatePokemon(pokemon);
    _applyFilters();
    notifyListeners();
  }

  Future<void> removePokemon(Pokemon pokemon) async {
    await _dbService.deletePokemon(pokemon.apiId);
    _pokemons.removeWhere((p) => p.apiId == pokemon.apiId);
    _applyFilters();
    notifyListeners();
  }

  void searchInCollection(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showOnlyFavorites = !_showOnlyFavorites;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _showOnlyFavorites = false;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredPokemons = _pokemons.where((pokemon) {
      bool matchesSearch = _searchQuery.isEmpty ||
          pokemon.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesFavorites = !_showOnlyFavorites || pokemon.isFavorite;
      return matchesSearch && matchesFavorites;
    }).toList();
  }

  bool isPokemonCaptured(int apiId) {
    return _pokemons.any((p) => p.apiId == apiId);
  }
}