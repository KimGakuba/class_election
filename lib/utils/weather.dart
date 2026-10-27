import 'dart:convert';
import 'package:http/http.dart' as http;

// Weather: holds current weather data from Open-Meteo
class Weather {
  double temperature; // temperature_2m
  int humidity; // relative_humidity_2m
  double wind; // wind_speed_10m
  int code; // weather_code
  String time; // time

  Weather({
    required this.temperature,
    required this.humidity,
    required this.wind,
    required this.code,
    required this.time,
  });

  // fromJson: build Weather from "current" object
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: ((json['temperature_2m'] as num?) ?? 0).toDouble(),
      humidity: ((json['relative_humidity_2m'] as num?) ?? 0).toInt(),
      wind: ((json['wind_speed_10m'] as num?) ?? 0).toDouble(),
      code: ((json['weather_code'] as num?) ?? 0).toInt(),
      time: json['time'] as String? ?? '',
    );
  }
}

// describe: return sky description for weather code
String describe(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1 || code == 2) return 'Partly cloudy';
  if (code == 3) return 'Cloudy';
  if (code == 45 || code == 48) return 'Fog';
  if (code >= 51 && code <= 57) return 'Drizzle';
  if (code >= 61 && code <= 67) return 'Rain';
  if (code >= 80 && code <= 82) return 'Rain showers';
  if (code >= 95 && code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

// fetchWeather: get today's Kigali weather from Open-Meteo
Future<Weather> fetchWeather() async {
  final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=-1.9441&longitude=30.0619&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=Africa%2FKigali');
  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw Exception('Failed to load weather');
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final current = data['current'] as Map<String, dynamic>;
  return Weather.fromJson(current);
}
