import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<String> getCurrentLocationAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'Location permission denied';
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5)
        );
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return 'Location not available';
      }

      String address = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      try {
        final geoUrl = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');
        final geoResponse = await http.get(geoUrl, headers: {
          'User-Agent': 'PegasosFieldApp/2.0'
        }).timeout(const Duration(seconds: 5));

        if (geoResponse.statusCode == 200) {
          final data = jsonDecode(geoResponse.body);
          final a = data['address'];
          if (a != null) {
            final parts = [
              a['road'],
              a['suburb'] ?? a['neighbourhood'],
              a['city'] ?? a['town'] ?? a['village'],
              a['state']
            ].where((e) => e != null).toList();
            if (parts.isNotEmpty) address = parts.join(', ');
          }
        }
      } catch (_) {
        // Fallback to coordinates
      }

      return address;
    } catch (e) {
      return 'Location not available';
    }
  }
}
