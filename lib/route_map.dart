import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

import 'package:smart_delivery/flexible_polyline.dart';
import 'package:smart_delivery/latlngz.dart';

// void main() {
//   runApp(MyApp());
// }

class MyApp11 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('HERE Map Example')),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _getRoute(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              print(snapshot.data);
              var route =
                  snapshot.data!['routes'][0]['sections'][0]['polyline'];
              var startMarker = snapshot.data!['routes'][0]['sections'][0]
                  ['departure']['place']['location'];
              var endMarker = snapshot.data!['routes'][0]['sections'][0]
                  ['arrival']['place']['location'];
              // print(startMarker[0] + "  " + endMarker[0]);

              return FlutterMap(
                options: MapOptions(
                  center: LatLng(startMarker['lat'] as double,
                      startMarker['lng'] as double),
                  zoom: 5.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // subdomains: ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: decode_with_polyline(route).map((e) {
                          print(e.lng.toString() + " " + e.lat.toString());
                          return LatLng(e.lat, e.lng);
                        }).toList(),
                        color: Colors.blue,
                        strokeWidth: 3.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(startMarker['lat'], startMarker['lng']),
                        child: Icon(Icons.location_on, color: Colors.green),
                      ),
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(endMarker['lat'], endMarker['lng']),
                        child: Icon(Icons.location_on, color: Colors.red),
                      ),
                    ],
                  )
                ],
                // layers: [
                //   TileLayerOptions(
                //     urlTemplate:
                //         'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                //     subdomains: ['a', 'b', 'c'],
                //   ),
                //   PolylineLayerOptions(
                //     polylines: [
                //       Polyline(
                //         points: decodePolyline(route),
                //         color: Colors.blue,
                //         strokeWidth: 3.0,
                //       ),
                //     ],
                //   ),
                //   MarkerLayerOptions(
                //     markers: [
                //       Marker(
                //         width: 40.0,
                //         height: 40.0,
                //         point: LatLng(startMarker[0], startMarker[1]),
                //         builder: (ctx) =>
                //             Icon(Icons.location_on, color: Colors.green),
                //       ),
                //       Marker(
                //         width: 40.0,
                //         height: 40.0,
                //         point: LatLng(endMarker[0], endMarker[1]),
                //         builder: (ctx) =>
                //             Icon(Icons.location_on, color: Colors.red),
                //       ),
                //     ],
                //   ),
                // ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getRoute() async {
    final apiKey = 'd_ag3Uo2tkXDKu4yXHAHMX5L-YsiYlhswXAYd6M6fUo';
    final url = Uri.parse(
        'https://router.hereapi.com/v8/routes?transportMode=car&origin=12.788984785298272,80.22124499381923&destination=12.859312691685638,80.2266953129383&return=polyline&app_id=lGbbK0FdH3y7Qu4ZaZIU&apiKey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load route: ${response.statusCode}');
    }
  }

  List<LatLng> decodePolyline(String polyline) {
    if (polyline == null || polyline.isEmpty) {
      return [];
    }

    List<LatLng> decoded = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
4.1611307

      if (latitude >= -90 &&
          latitude <= 90 &&
          longitude >= -180 &&
          longitude <= 180) {
        decoded.add(LatLng(latitude, longitude));
      } else {
        print('Invalid latitude/longitude: $latitude, $longitude');
      }
    }

    return decoded;
  }

  List<LatLngZ> decode_with_polyline(String encoded) {
    List<LatLngZ> decoded = FlexiblePolyline.decode("BFoz5xJ67i1B1B7PzIhaxL7Y");
    print(decoded);
    return decoded;
  }

  List<PointLatLng> decodeEncodedPolyline(String encoded) {
    List<PointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      PointLatLng p =
          new PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  /// Note instead of using the class,
  /// you can use Google LatLng() by importing it from their library.

  // List<LatLng> decodePolyline(String polyline) {
  //   List<LatLng> decoded = [];
  //   var index = 0;
  //   var lat = 0;
  //   var lng = 0;

  //   while (index < polyline.length) {
  //     var b;
  //     var shift = 0;
  //     var result = 0;
  //     do {
  //       b = polyline.codeUnitAt(index++) - 63;
  //       result |= (b & 0x1F) << shift;
  //       shift += 5;
  //     } while (b >= 0x20);
  //     var dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
  //     lat += dlat;

  //     shift = 0;
  //     result = 0;
  //     do {
  //       b = polyline.codeUnitAt(index++) - 63;
  //       result |= (b & 0x1F) << shift;
  //       shift += 5;
  //     } while (b >= 0x20);
  //     var dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
  //     lng += dlng;

  //     var latitude = lat / 1E5;
  //     var longitude = lng / 1E5;
  //     if (latitude >= -90 &&
  //         latitude <= 90 &&
  //         longitude >= -180 &&
  //         longitude <= 180) {
  //       decoded.add(LatLng(latitude, longitude));
  //     }
  //   }

  //   return decoded;
  // }
}

// class PointLatLng {
//   /// Creates a geographical location specified in degrees [latitude] and
//   /// [longitude].
//   ///
//   const PointLatLng(double latitude, double longitude)
//       : assert(latitude != null),
//         assert(longitude != null),
//         this.latitude = latitude,
//         this.longitude = longitude;

//   /// The latitude in degrees.
//   final double latitude;

//   /// The longitude in degrees
//   final double longitude;

//   @override
//   String toString() {
//     return "lat: $latitude / longitude: $longitude";
//   }
// }
