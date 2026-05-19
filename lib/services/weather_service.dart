// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = 'cf9efc493d8bcbd101231c722c6b97c8';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Busca clima atual por nome da cidade
  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=pt_br'),
      );

      if (response.statusCode == 200) {
        final weatherData = json.decode(response.body);

        // Buscar previsão de 5 dias
        final forecastData = await _getForecastByCoordinates(
          weatherData['coord']['lat'],
          weatherData['coord']['lon'],
        );

        return WeatherModel.fromJson(weatherData, forecast: forecastData);
      } else if (response.statusCode == 404) {
        throw Exception('Cidade não encontrada');
      } else {
        throw Exception('Erro ao buscar dados do clima');
      }
    } catch (e) {
      throw Exception('Falha na conexão: ${e.toString()}');
    }
  }

  /// Busca clima atual por coordenadas
  Future<WeatherModel> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=pt_br'),
      );

      if (response.statusCode == 200) {
        final weatherData = json.decode(response.body);

        // Buscar previsão de 5 dias
        final forecastData = await _getForecastByCoordinates(lat, lon);

        return WeatherModel.fromJson(weatherData, forecast: forecastData);
      } else {
        throw Exception('Erro ao buscar dados do clima');
      }
    } catch (e) {
      throw Exception('Falha na conexão: ${e.toString()}');
    }
  }

  /// Busca previsão de 5 dias a cada 3 horas
  Future<List<Forecast>> _getForecastByCoordinates(
      double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=pt_br'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];

        // Agrupar previsões por dia e pegar a do meio-dia
        Map<String, Forecast> dailyForecasts = {};

        for (var item in forecastList) {
          final forecast = Forecast.fromJson(item);
          final dayKey =
              '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';

          // Pegar previsão mais próxima do meio-dia ou a primeira disponível
          if (!dailyForecasts.containsKey(dayKey) ||
              (forecast.dateTime.hour >= 12 && forecast.dateTime.hour < 15)) {
            dailyForecasts[dayKey] = forecast;
          }
        }

        return dailyForecasts.values.take(5).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtém localização atual do dispositivo
  Future<Position?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização permanentemente negada');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Erro ao obter localização: ${e.toString()}');
    }
  }

  /// Converte coordenadas em nome da cidade
  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ??
            place.subAdministrativeArea ??
            'Localização atual';
      }
      return 'Localização atual';
    } catch (e) {
      return 'Localização atual';
    }
  }
}
