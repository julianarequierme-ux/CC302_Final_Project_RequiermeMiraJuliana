import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skyseabooking/models/destination.dart';
import 'package:skyseabooking/services/destination_weather_service.dart';

Destination _cebu() => const Destination(
      name: 'Cebu',
      imageUrl: '',
    );

void main() {
  test('requests live weather and parses the API response', () async {
    Uri? requestedUri;
    final service = DestinationWeatherService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          jsonEncode({
            'current': {
              'temperature_2m': 29.4,
              'apparent_temperature': 33.1,
              'relative_humidity_2m': 78,
              'wind_speed_10m': 12.2,
              'weather_code': 61,
              'time': '2026-10-16T09:00',
            },
          }),
          200,
        );
      }),
    );

    final weather = await service.getCurrentWeather(_cebu());

    expect(requestedUri?.host, 'api.open-meteo.com');
    expect(requestedUri?.queryParameters['latitude'], '10.3157');
    expect(weather.temperatureC, 29.4);
    expect(weather.condition, 'Rain');
    expect(weather.humidityPercent, 78);
    service.dispose();
  });

  test('reports API errors to the caller', () async {
    final service = DestinationWeatherService(
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );

    await expectLater(
      service.getCurrentWeather(_cebu()),
      throwsA(isA<DestinationWeatherException>()),
    );
    service.dispose();
  });

  test('rejects malformed weather values instead of displaying fake data',
      () async {
    final service = DestinationWeatherService(
      client: MockClient((_) async => http.Response('{"current":{}}', 200)),
    );

    await expectLater(
      service.getCurrentWeather(_cebu()),
      throwsA(isA<DestinationWeatherException>()),
    );
    service.dispose();
  });
}
