import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/destination.dart';
import '../models/destination_weather.dart';

class DestinationWeatherException implements Exception {
  final String message;

  const DestinationWeatherException(this.message);

  @override
  String toString() => message;
}

/// Reads live current conditions from Open-Meteo; no API key is required.
class DestinationWeatherService {
  DestinationWeatherService({http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  static const _coordinates = <String, (double, double)>{
    'cebu': (10.3157, 123.8854),
    'boracay': (11.9674, 121.9248),
    'palawan': (9.8349, 118.7384),
    'bohol': (9.8500, 124.1435),
    'siargao': (9.8482, 126.0458),
    'siquijor': (9.1999, 123.5952),
    'baguio': (16.4023, 120.5960),
    'davao': (7.1907, 125.4553),
    'batanes': (20.4487, 121.9702),
    'camiguin': (9.1732, 124.7292),
  };

  Future<DestinationWeather> getCurrentWeather(Destination destination) async {
    final location = _coordinates[destination.name.toLowerCase()];
    if (location == null) {
      throw DestinationWeatherException(
        'Live weather is not available for ${destination.name} yet.',
      );
    }

    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.$1.toString(),
      'longitude': location.$2.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
      'timezone': 'Asia/Manila',
    });

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 12),
          );
      if (response.statusCode != 200) {
        throw DestinationWeatherException(
          'Weather service returned status ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Weather response is not a JSON object.');
      }
      return DestinationWeather.fromJson(decoded);
    } on DestinationWeatherException {
      rethrow;
    } on FormatException catch (error) {
      throw DestinationWeatherException(
        'Could not read live weather data: ${error.message}',
      );
    } on Exception catch (error) {
      throw DestinationWeatherException(
        'Could not load live weather. Check your internet connection. ($error)',
      );
    }
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
