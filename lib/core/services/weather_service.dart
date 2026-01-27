import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String date;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.date,
    required this.cityName,
  });
}

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<WeatherData> fetchWeather() async {
    try {
      final position = await _getCurrentLocation();
      String cityName = "Location Unknown";
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        if (placemarks.isNotEmpty) {
          cityName = placemarks[0].locality ?? placemarks[0].subAdministrativeArea ?? "Unknown";
        }
      } catch (e) {
        print("Error getting city name: $e");
      }

      final url = Uri.parse(
          '$_baseUrl?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current_weather'];
        final temp = current['temperature'] as double;
        final weatherCode = current['weathercode'] as int;

        return WeatherData(
          temperature: temp,
          condition: _getWeatherCondition(weatherCode),
          date: _formatDate(DateTime.now()),
          cityName: cityName,
        );
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Fallback data if location or API fails
      return WeatherData(
        temperature: 24.0,
        condition: 'Sunny',
        date: _formatDate(DateTime.now()),
        cityName: "Delhi",
      );
    }
  }

  String _getWeatherCondition(int code) {
    // Basic mapping of WMO weather codes (https://open-meteo.com/en/docs)
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
