import 'package:flutter/material.dart';
import '../utils/weather.dart';
import '../theme.dart';

// WeatherCard: shows Kigali weather with loading, error and data states
class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Weather? weather;
  bool loading = true;
  String? error;

  // initState: load the weather when the card first appears
  @override
  void initState() {
    super.initState();
    load();
  }

  // load: fetch weather and update loading/error/weather
  Future<void> load() async {
    try {
      final result = await fetchWeather();
      setState(() {
        weather = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Could not load the weather. Check your internet connection.';
      });
    }
  }

  // retry: clear error and try loading again
  void retry() {
    setState(() {
      loading = true;
      error = null;
    });
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: cardBox(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kigali today',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kInk,
            ),
          ),
          const SizedBox(height: 10),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(error!, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                FilledButton(onPressed: retry, child: const Text('Retry')),
              ],
            )
          else if (weather != null)
            Row(
              children: [
                Icon(iconFor(weather!.code), size: 40, color: kTeal),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather!.temperature.round()}°C',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: kInk,
                        ),
                      ),
                      Text(
                        describe(weather!.code),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Humidity ${weather!.humidity}%',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'Wind ${weather!.wind.toStringAsFixed(1)} km/h',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'Updated at ${weather!.time.substring(11, 16)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// iconFor: pick an icon for a weather code
IconData iconFor(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code == 1 || code == 2) return Icons.wb_cloudy;
  if (code == 3) return Icons.cloud;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 51 && code <= 57) return Icons.grain;
  if (code >= 61 && code <= 67) return Icons.umbrella;
  if (code >= 80 && code <= 82) return Icons.water_drop;
  if (code >= 95) return Icons.thunderstorm;
  return Icons.help_outline;
}
