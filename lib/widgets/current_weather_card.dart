import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class CurrentWeatherCard extends StatefulWidget {
  final WeatherModel weather;
  final VoidCallback? onRefresh;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const CurrentWeatherCard({
    Key? key,
    required this.weather,
    this.onRefresh,
    this.isFavorite = false,
    this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade400,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Cabeçalho
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.weather.cityName}, ${widget.weather.country}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(widget.weather.dateTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.onRefresh,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.weather.weatherIcon,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      '${widget.weather.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.weather.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTempInfo('Mín', '${widget.weather.tempMin.round()}°',
                    Colors.blue.shade200),
                const SizedBox(width: 30),
                _buildTempInfo('Máx', '${widget.weather.tempMax.round()}°',
                    Colors.red.shade200),
                const SizedBox(width: 30),
                _buildTempInfo(
                    'Sensação',
                    '${widget.weather.feelsLike.round()}°',
                    Colors.orange.shade200),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAdditionalInfo(
                    Icons.water_drop, 'Umidade', '${widget.weather.humidity}%'),
                _buildAdditionalInfo(Icons.air, 'Vento',
                    '${widget.weather.windSpeed.toStringAsFixed(1)} m/s'),
                _buildAdditionalInfo(Icons.compress, 'Pressão',
                    '${widget.weather.pressure} hPa'),
                _buildAdditionalInfo(Icons.visibility, 'Visibilidade',
                    '${(widget.weather.visibility / 1000).toStringAsFixed(1)} km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildAdditionalInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Hoje, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
