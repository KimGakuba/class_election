import 'package:flutter_test/flutter_test.dart';
import 'package:class_election/utils/weather.dart';

void main() {
  test('Weather.fromJson reads the current object fields', () {
    Weather w = Weather.fromJson({
      'temperature_2m': 24.9,
      'relative_humidity_2m': 52,
      'wind_speed_10m': 11.7,
      'weather_code': 3,
      'time': '2026-10-27T12:30',
    });

    expect(w.temperature, 24.9);
    expect(w.humidity, 52);
    expect(w.wind, 11.7);
    expect(w.code, 3);
    expect(w.time, '2026-10-27T12:30');
  });

  test('Weather.fromJson handles a whole number temperature', () {
    Weather w = Weather.fromJson({
      'temperature_2m': 25,
      'relative_humidity_2m': 52,
      'wind_speed_10m': 11.7,
      'weather_code': 0,
      'time': '2026-10-27T12:30',
    });

    expect(w.temperature, 25.0);
  });

  test('describe returns the right sky words', () {
    expect(describe(0), 'Clear sky');
    expect(describe(3), 'Cloudy');
    expect(describe(61), 'Rain');
    expect(describe(95), 'Thunderstorm');
    expect(describe(999), 'Unknown');
  });
}
