import 'dart:io'; // Necessário para detectar a plataforma (Platform.isLinux)
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as open_map; // Salvo como open_map para não confundir
import 'package:latlong2/latlong.dart' as latlng;
import '../models/visit.dart';

class MapPage extends StatefulWidget {
  final List<Visit> visits;

  const MapPage({super.key, required this.visits});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Está em Natal pra seguir o padrão do design feito por Bianca no Figma
  final _initialLat = -5.79448;
  final _initialLng = -35.211;

  @override
  Widget build(BuildContext context) {
    // se for Linux, Windows ou macOS usa OpenStreetMap
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return _buildOpenStreetMap();
    } 
    // se for Android ou iOS usa Google Maps (Nativo)
    else {
      return _buildGoogleMap();
    }
  }
    // --- VERSÃO GOOGLE MAPS ---
  Widget _buildGoogleMap() {
    Set<Marker> markers = {};
    for (var visit in widget.visits) {
      if (visit.latitude != 0 && visit.longitude != 0) {
        markers.add(Marker(
          markerId: MarkerId(visit.id.toString()),
          position: LatLng(visit.latitude, visit.longitude),
          infoWindow: InfoWindow(title: visit.placeName, snippet: visit.date),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Mapa')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_initialLat, _initialLng),
          zoom: 13,
        ),
        markers: markers,
      ),
    );
  }

  // --- VERSÃO OPENSTREETMAP ---
  Widget _buildOpenStreetMap() {
    List<open_map.Marker> markers = [];
    for (var visit in widget.visits) {
      if (visit.latitude != 0 && visit.longitude != 0) {
        markers.add(
          open_map.Marker(
            point: latlng.LatLng(visit.latitude, visit.longitude),
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Mapa')),
      body: open_map.FlutterMap(
        options: open_map.MapOptions(
          initialCenter: latlng.LatLng(_initialLat, _initialLng),
          initialZoom: 13.0,
        ),
        children: [
          open_map.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.maply_app',
          ),
          open_map.MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}