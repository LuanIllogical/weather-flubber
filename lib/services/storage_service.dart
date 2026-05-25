import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorite_cities';

  Future<void> saveFavoriteCity(Map<String, dynamic> cityData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteCities();

      bool exists = favorites.any((city) =>
          city['cityName'] == cityData['cityName'] &&
          city['country'] == cityData['country']);

      if (!exists) {
        favorites.add(cityData);
        await prefs.setString(_favoritesKey, json.encode(favorites));
        print('Cidade salva nos favoritos: ${cityData['cityName']}');
      } else {
        print('Cidade já existe nos favoritos');
      }
    } catch (e) {
      print('Erro ao salvar favorito: $e');
    }
  }

  Future<void> removeFavoriteCity(String cityName, String country) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavoriteCities();

      favorites.removeWhere(
          (city) => city['cityName'] == cityName && city['country'] == country);

      await prefs.setString(_favoritesKey, json.encode(favorites));
      print('Cidade removida dos favoritos: $cityName');
    } catch (e) {
      print('Erro ao remover favorito: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavoriteCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }

      return [];
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
      return [];
    }
  }

  Future<bool> isCityFavorite(String cityName, String country) async {
    try {
      final favorites = await getFavoriteCities();
      final isFav = favorites.any((city) =>
          city['cityName']?.toString().toLowerCase() ==
              cityName.toLowerCase() &&
          city['country']?.toString().toLowerCase() == country.toLowerCase());
      print('Verificando favorito - $cityName: $isFav');
      return isFav;
    } catch (e) {
      print('Erro ao verificar favorito: $e');
      return false;
    }
  }
}
