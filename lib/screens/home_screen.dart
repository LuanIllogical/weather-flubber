// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/loading_indicator.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();

  WeatherModel? _weather;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestLocationAndLoadWeather();
  }

  Future<void> _requestLocationAndLoadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _weatherService.getCurrentPosition();
      if (position != null) {
        await _loadWeatherByCoordinates(position.latitude, position.longitude);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Não foi possível obter sua localização.\nUse a busca para encontrar uma cidade.';
      });
    }
  }

  Future<void> _loadWeatherByCoordinates(double lat, double lon) async {
    try {
      final weather = await _weatherService.getWeatherByCoordinates(lat, lon);
      setState(() {
        _weather = weather;
        _isLoading = false;
        _errorMessage = null;
      });
      _checkIfFavorite();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados do clima: ${e.toString()}';
      });
    }
  }

  Future<void> _loadWeatherByCity(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.getWeatherByCity(cityName);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
      _checkIfFavorite();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao buscar cidade: ${e.toString()}';
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    if (_weather != null) {
      final isFav = await _storageService.isCityFavorite(
        _weather!.cityName,
        _weather!.country,
      );
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_weather == null) return;

    print('Clicou no favorito! Cidade: ${_weather!.cityName}'); // Debug
    print('É favorito atualmente? $_isFavorite'); // Debug

    try {
      if (_isFavorite) {
        await _storageService.removeFavoriteCity(
          _weather!.cityName,
          _weather!.country,
        );
        print('Removido com sucesso!'); // Debug
      } else {
        await _storageService.saveFavoriteCity({
          'cityName': _weather!.cityName,
          'country': _weather!.country,
          'latitude': _weather!.latitude,
          'longitude': _weather!.longitude,
        });
        print('Salvo com sucesso!'); // Debug
      }

      // Atualiza o estado
      setState(() {
        _isFavorite = !_isFavorite;
      });

      // Feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? '${_weather!.cityName} adicionada aos favoritos! ❤️'
                  : '${_weather!.cityName} removida dos favoritos',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: _isFavorite ? Colors.green : Colors.grey.shade700,
          ),
        );
      }
    } catch (e) {
      print('ERRO ao favoritar: $e'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshWeather() async {
    if (_weather != null &&
        _weather!.latitude != null &&
        _weather!.longitude != null) {
      await _loadWeatherByCoordinates(
          _weather!.latitude!, _weather!.longitude!);
    } else {
      await _requestLocationAndLoadWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão do Tempo'),
        actions: [
          if (_weather != null)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: _toggleFavorite,
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
              if (result != null && result is String) {
                _loadWeatherByCity(result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
              if (result != null && result is String) {
                _loadWeatherByCity(result);
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Carregando dados do clima...');
    }

    if (_errorMessage != null && _weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Buscar Cidade'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                  if (result != null && result is String) {
                    _loadWeatherByCity(result);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    if (_weather == null) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    return RefreshIndicator(
      onRefresh: _refreshWeather,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CurrentWeatherCard(
              weather: _weather!,
              onRefresh: _refreshWeather,
            ),
            const SizedBox(height: 16),
            if (_weather!.forecast.isNotEmpty)
              ForecastCard(forecasts: _weather!.forecast),
          ],
        ),
      ),
    );
  }
}
