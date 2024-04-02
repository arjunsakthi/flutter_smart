import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoutePage extends StatefulWidget {
  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final String apiKey = 'd_ag3Uo2tkXDKu4yXHAHMX5L-YsiYlhswXAYd6M6fUo';
  final String start = '52.5308,13.3847'; // Berlin latitude, longitude
  final String end = '52.5200,13.4050'; // Berlin latitude, longitude

  Future<List<List<double>>> getRouteCoordinates() async {
    final url =
        Uri.parse('https://route.ls.hereapi.com/routing/7.2/calculateroute.json'
            '?apiKey=$apiKey'
            '&waypoint0=$start'
            '&waypoint1=$end'
            '&mode=fastest;car'
            '&representation=navigation');

    final response = await http.get(url);
    final data = jsonDecode(response.body);
    print(data);
    final shapePoints = data['response']['route'][0]['leg'][0]['shape'];
    final coordinates = shapePoints.split(';').map((point) {
      final parts = point.split(',');
      return [double.parse(parts[0]), double.parse(parts[1])];
    }).toList();

    return coordinates;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Route Coordinates'),
        ),
        body: FutureBuilder<List<List<double>>>(
          future: getRouteCoordinates(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final coordinates = snapshot.data!;
              return ListView.builder(
                itemCount: coordinates.length,
                itemBuilder: (context, index) {
                  final coordinate = coordinates[index];
                  return ListTile(
                    title: Text(
                        'Latitude: ${coordinate[0]}, Longitude: ${coordinate[1]}'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: RoutePage()));
}
