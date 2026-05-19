class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime dateTime;
  final List<Forecast> forecast;
  final int pressure;
  final int visibility;
  final double? latitude;
  final double? longitude;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.dateTime,
    required this.forecast,
    required this.pressure,
    required this.visibility,
    this.latitude,
    this.longitude,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json,
      {List<Forecast>? forecast}) {
    return WeatherModel(
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']?['country'] ?? '',
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']?['feels_like'] ?? 0).toDouble(),
      tempMin: (json['main']?['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']?['temp_max'] ?? 0).toDouble(),
      humidity: json['main']?['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      description: json['weather']?[0]?['description'] ?? '',
      icon: json['weather']?[0]?['icon'] ?? '01d',
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? 0) * 1000,
        isUtc: true,
      ),
      forecast: forecast ?? [],
      pressure: json['main']?['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      latitude: json['coord']?['lat'],
      longitude: json['coord']?['lon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get weatherIcon {
    switch (icon) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
        return '⛅';
      case '02n':
        return '☁️';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '🌨️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}

class Forecast {
  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  Forecast({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? 0) * 1000,
        isUtc: true,
      ),
      temperature: (json['main']?['temp'] ?? 0).toDouble(),
      tempMin: (json['main']?['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']?['temp_max'] ?? 0).toDouble(),
      description: json['weather']?[0]?['description'] ?? '',
      icon: json['weather']?[0]?['icon'] ?? '01d',
      humidity: json['main']?['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
    );
  }

  String get weatherIcon {
    switch (icon) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
        return '⛅';
      case '02n':
        return '☁️';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '🌨️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}
