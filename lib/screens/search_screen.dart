import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokemon_provider.dart';
import '../models/pokemon.dart';
import 'pokemon_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Pokemon? _foundPokemon;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Pokémon'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite o nome ou ID do Pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _searchPokemon,
                ),
              ),
              onSubmitted: (_) => _searchPokemon(),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              )
            else if (_foundPokemon != null)
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (_foundPokemon!.sprite.isNotEmpty)
                          Image.network(
                            _foundPokemon!.sprite,
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          _foundPokemon!.capitalizedName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('ID: ${_foundPokemon!.apiId}'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _foundPokemon!.types.map((type) {
                            return Chip(
                              label: Text(type.toUpperCase()),
                              backgroundColor: Pokemon.getTypeColor(type).withOpacity(0.7),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PokemonDetailScreen(pokemon: _foundPokemon!),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info),
                              label: const Text('Detalhes'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _addToCollection,
                              icon: const Icon(Icons.add),
                              label: const Text('Capturar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchPokemon() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _foundPokemon = null;
    });

    try {
      final pokemon = await context.read<PokemonProvider>().searchPokemonInApi(_searchController.text.trim());
      
      setState(() {
        _isLoading = false;
        if (pokemon != null) {
          _foundPokemon = pokemon;
        } else {
          _errorMessage = 'Pokémon não encontrado!';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao buscar Pokémon. Verifique sua conexão.';
      });
    }
  }

  Future<void> _addToCollection() async {
    if (_foundPokemon == null) return;

    final success = await context.read<PokemonProvider>().addPokemon(_foundPokemon!);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? '${_foundPokemon!.capitalizedName} capturado com sucesso!'
                : '${_foundPokemon!.capitalizedName} já está na sua coleção!',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );

      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}