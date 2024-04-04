// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong/latlong.dart';
// import 'package:provider/provider.dart';

// class MapView extends StatelessWidget {
//   final LatLng start;
//   final LatLng end;

//   const MapView({Key? key, required this.start, required this.end})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<RouteService>(
//       builder: (context, routeService, child) {
//         return FlutterMap(
//           options: MapOptions(
//             center: start,
//             zoom: 12,
//           ),
//           layers: [
//             TileLayerOptions(
//               urlTemplate:
//                   "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//               subdomains: ['a', 'b', 'c'],
//             ),
//             PolylineLayerOptions(

  