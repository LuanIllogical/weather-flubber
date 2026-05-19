// lib/widgets/forecast_card.dart
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final List<Forecast> forecasts;

  const ForecastCard({
    Key? key,
    required this.forecasts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Previsão para os Próximos Dias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: forecasts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final forecast = forecasts[index];
                return _buildForecastItem(forecast);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(Forecast forecast) {
    String dayName = _getDayName(forecast.dateTime);
    bool isToday = DateTime.now().day == forecast.dateTime.day;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Dia da semana
          Expanded(
            flex: 2,
            child: Text(
              isToday ? 'Hoje' : dayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),

          // Ícone do clima
          Expanded(
            flex: 1,
            child: Text(
              forecast.weatherIcon,
              style: const TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
            ),
          ),

          // Temperaturas
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${forecast.tempMin.round()}°',
                  style: TextStyle(
                    color: Colors.blue.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade300,
                        Colors.orange.shade300,
                        Colors.red.shade300,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${forecast.tempMax.round()}°',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Descrição
          Expanded(
            flex: 2,
            child: Text(
              forecast.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return days[date.weekday - 1];
  }
}
