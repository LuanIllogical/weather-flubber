import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/weather_service.dart';
import '../services/storage_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isSearching = false;
  List<CitySuggestion> _suggestions = [];
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _favoriteCities = [];

  Future<void>? _debounce;

  static const List<Map<String, String>> _popularCities = [
    {'name': 'São Paulo', 'country': 'BR', 'state': 'São Paulo'},
    {'name': 'Rio de Janeiro', 'country': 'BR', 'state': 'Rio de Janeiro'},
    {'name': 'Brasília', 'country': 'BR', 'state': 'Distrito Federal'},
    {'name': 'Salvador', 'country': 'BR', 'state': 'Bahia'},
    {'name': 'Fortaleza', 'country': 'BR', 'state': 'Ceará'},
    {'name': 'Belo Horizonte', 'country': 'BR', 'state': 'Minas Gerais'},
    {'name': 'Curitiba', 'country': 'BR', 'state': 'Paraná'},
    {'name': 'Manaus', 'country': 'BR', 'state': 'Amazonas'},
    {'name': 'Recife', 'country': 'BR', 'state': 'Pernambuco'},
    {'name': 'Porto Alegre', 'country': 'BR', 'state': 'Rio Grande do Sul'},
    {'name': 'Londres', 'country': 'GB', 'state': 'Inglaterra'},
    {'name': 'Nova York', 'country': 'US', 'state': 'Nova York'},
    {'name': 'Tóquio', 'country': 'JP', 'state': 'Tóquio'},
    {'name': 'Paris', 'country': 'FR', 'state': 'Île-de-France'},
    {'name': 'Sydney', 'country': 'AU', 'state': 'Nova Gales do Sul'},
  ];

  @override
  void initState() {
    super.initState();

    _loadFavorites();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _storageService.getFavoriteCities();

    if (mounted) {
      setState(() {
        _favoriteCities = favorites;
      });
    }
  }

  Future<void> _searchSuggestions(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      setState(() => _isSearching = true);

      try {
        final suggestions = await _fetchCitySuggestions(query);
        if (mounted) {
          setState(() {
            _suggestions = suggestions;
            _isSearching = false;
          });

          print('Sugestões encontradas: ${suggestions.length}');
          for (var s in suggestions) {
            print('- ${s.name}, ${s.country}');
          }
        }
      } catch (e) {
        print('Erro na busca: $e');
        if (mounted) {
          setState(() {
            _isSearching = false;
            _suggestions = [];
          });
        }
      }
    });
  }

  Future<List<CitySuggestion>> _fetchCitySuggestions(String query) async {
    const String apiKey = 'cf9efc493d8bcbd101231c722c6b97c8';
    const String baseUrl = 'https://api.openweathermap.org/geo/1.0/direct';

    try {
      final uri = Uri.parse(
          '$baseUrl?q=${Uri.encodeComponent(query)}&limit=5&appid=$apiKey');
      print('Buscando: $uri');

      final response = await http.get(uri);
      print('Status: ${response.statusCode}');
      print('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return [];
        }

        final seen = <String>{};
        final uniqueCities = data.where((item) {
          final key = '${item['name']}-${item['country']}';
          if (seen.contains(key)) return false;
          seen.add(key);
          return true;
        }).toList();

        return uniqueCities.map((item) {
          return CitySuggestion(
            name: item['name'] ?? '',
            country: item['country'] ?? '',
            state: item['state'] ?? '',
            latitude: (item['lat'] ?? 0).toDouble(),
            longitude: (item['lon'] ?? 0).toDouble(),
          );
        }).toList();
      } else if (response.statusCode == 401) {
        print('ERRO: API Key inválida!');
        return [];
      }
      return [];
    } catch (e) {
      print('Erro na requisição: $e');
      return [];
    }
  }

  Future<void> _selectCity(String cityName) async {
    setState(() => _isLoading = true);

    try {
      await _weatherService.getWeatherByCity(cityName);

      if (!_recentSearches.contains(cityName)) {
        _recentSearches.insert(0, cityName);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }

      if (mounted) {
        Navigator.pop(context, cityName);
      }
    } catch (e) {
      print('Erro ao buscar cidade: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar cidade: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchCity() async {
    final cityName = _searchController.text.trim();
    if (cityName.isEmpty) return;
    await _selectCity(cityName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Cidade'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Digite o nome da cidade...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSearching)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _suggestions = [];
                              });
                            },
                          ),
                        ],
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {});
                _searchSuggestions(value);
              },
              onSubmitted: (_) => _searchCity(),
              textInputAction: TextInputAction.search,
            ),
          ),
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      if (_isSearching) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Buscando cidades...'),
            ],
          ),
        );
      }

      if (_suggestions.isEmpty) {
        return ListView(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma cidade encontrada',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pressione Enter para buscar "$query"',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: Text('Buscar "$query"'),
                    onPressed: _searchCity,
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _suggestions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sugestões (${_suggestions.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            );
          }
          return _buildSuggestionTile(_suggestions[index - 1]);
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Buscas Recentes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ..._recentSearches.map((city) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(city),
                onTap: () => _selectCity(city),
              )),
          const Divider(),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _favoriteCities.isNotEmpty
                ? 'Cidades Favoritas'
                : 'Cidades Populares',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _favoriteCities.isNotEmpty
                  ? Colors.red.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ),
        if (_favoriteCities.isNotEmpty)
          ..._favoriteCities.map((city) => ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(city['cityName'] ?? ''),
                subtitle: Text(city['country'] ?? ''),
                onTap: () => _selectCity(city['cityName']),
              ))
        else
          ..._popularCities.map((city) => ListTile(
                leading: const Icon(Icons.location_city),
                title: Text(city['name']!),
                subtitle: Text('${city['state']}, ${city['country']}'),
                onTap: () => _selectCity(city['name']!),
              )),
      ],
    );
  }

  Widget _buildSuggestionTile(CitySuggestion city) {
    final key = '${city.name}-${city.country}';

    return ListTile(
      leading: const Icon(Icons.location_city),
      title: Text(city.name),
      subtitle: Text('${city.state}, ${city.country}'),
      onTap: () => _selectCity(city.name),
    );
  }
}

class CitySuggestion {
  final String name;
  final String country;
  final String state;
  final double latitude;
  final double longitude;

  CitySuggestion({
    required this.name,
    required this.country,
    required this.state,
    required this.latitude,
    required this.longitude,
  });
}
