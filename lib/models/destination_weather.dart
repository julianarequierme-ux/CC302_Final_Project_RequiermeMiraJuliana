class DestinationWeather {
  final double temperatureC;
  final double feelsLikeC;
  final int humidityPercent;
  final double windSpeedKph;
  final int weatherCode;
  final DateTime observedAt;

  const DestinationWeather({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidityPercent,
    required this.windSpeedKph,
    required this.weatherCode,
    required this.observedAt,
  });

  String get condition => switch (weatherCode) {
        0 => 'Clear sky',
        1 => 'Mainly clear',
        2 => 'Partly cloudy',
        3 => 'Overcast',
        45 || 48 => 'Foggy',
        51 || 53 || 55 => 'Light drizzle',
        56 || 57 => 'Freezing drizzle',
        61 || 63 || 65 => 'Rain',
        66 || 67 => 'Freezing rain',
        71 || 73 || 75 || 77 => 'Snow',
        80 || 81 || 82 => 'Rain showers',
        85 || 86 => 'Snow showers',
        95 => 'Thunderstorm',
        96 || 99 => 'Thunderstorm with hail',
        _ => 'Current conditions',
      };

  factory DestinationWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException(
          'Weather response has no current conditions.');
    }

    double number(String key) {
      final value = current[key];
      if (value is num) return value.toDouble();
      throw FormatException('Weather response is missing $key.');
    }

    final humidity = number('relative_humidity_2m');
    if (humidity < 0 || humidity > 100) {
      throw const FormatException(
          'Weather humidity is outside the valid range.');
    }

    final weatherCode = number('weather_code');
    final observedAt = current['time'];
    if (observedAt is! String) {
      throw const FormatException(
          'Weather response is missing its observation time.');
    }

    return DestinationWeather(
      temperatureC: number('temperature_2m'),
      feelsLikeC: number('apparent_temperature'),
      humidityPercent: humidity.round(),
      windSpeedKph: number('wind_speed_10m'),
      weatherCode: weatherCode.round(),
      observedAt: DateTime.parse(observedAt),
    );
  }
}
