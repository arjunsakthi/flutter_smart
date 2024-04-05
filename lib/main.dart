import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:smart_delivery/live_location.dart';
import 'package:smart_delivery/rough_work.dart';
import 'package:smart_delivery/route_map.dart';

void main() {
  runApp(MyApp11());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('HERE Map Example')),
        body: FutureBuilder<Uint8List>(
          future: _getMapImageUrl(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.fill,
                      )));
            }
          },
        ),
      ),
    );
  }

  Future<Uint8List> _getMapImageUrl() async {
    final apiKey = 'd_ag3Uo2tkXDKu4yXHAHMX5L-YsiYlhswXAYd6M6fUo';
    final url = Uri.parse('https://image.maps.ls.hereapi.com/mia/1.6/mapview?');
    final queryParams = {
      'apiKey': apiKey,
      'c': '12.8374806,80.2290676', // Berlin coordinates
      'z': '13', // Zoom level
      'w': '500', // Width of the map image
      'h': '500', // Height of the map image
      'f': '1', // Format (1 for PNG)
    };
    final response = await http.get(url.replace(queryParameters: queryParams));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load map image: ${response.statusCode}');
    }
  }
}
