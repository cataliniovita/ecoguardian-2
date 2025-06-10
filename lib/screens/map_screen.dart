import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/report_provider.dart';
import '../services/location_service.dart';
import '../models/report.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final LocationService _locationService = LocationService();
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(44.4268, 26.1025), // Bucharest coordinates
    zoom: 12,
  );

  Set<Marker> _markers = {};
  ReportCategory? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Comentat pentru a nu se muta automat la locația utilizatorului
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _loadUserLocation();
    // });
  }

  Future<void> _loadUserLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && _controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  void _updateMarkers(List<Report> reports) {
    setState(() {
      _markers = reports.map((report) {
        return Marker(
          markerId: MarkerId(report.id),
          position: LatLng(report.latitude, report.longitude),
          icon: _getMarkerIcon(report.category),
          infoWindow: InfoWindow(
            title: report.title,
            snippet: report.category.displayName,
            onTap: () => _showReportDetails(report),
          ),
        );
      }).toSet();
    });
  }

  BitmapDescriptor _getMarkerIcon(ReportCategory category) {
    // For now, using default markers with different colors
    switch (category) {
      case ReportCategory.ragweed:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case ReportCategory.waterPollution:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case ReportCategory.airPollution:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case ReportCategory.illegalDumping:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case ReportCategory.noisePollution:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case ReportCategory.other:
        return BitmapDescriptor.defaultMarker;
    }
  }

  void _showReportDetails(Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      report.category.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            report.category.displayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(report.description),
                const SizedBox(height: 16),
                if (report.imagePath != null) ...[
                  Text(
                    'Photo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      report.imagePath!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text('Reported by ${report.reporterName}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text('Status: ${report.status.displayName}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ReportCategory?>(
              title: const Text('All Categories'),
              value: null,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value;
                });
                Navigator.of(context).pop();
              },
            ),
            ...ReportCategory.values.map((category) {
              return RadioListTile<ReportCategory?>(
                title: Row(
                  children: [
                    Text(category.icon),
                    const SizedBox(width: 8),
                    Text(category.displayName),
                  ],
                ),
                value: category,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environmental Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadUserLocation,
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          List<Report> filteredReports = _selectedFilter != null
              ? reportProvider.getReportsByCategory(_selectedFilter!)
              : reportProvider.reports;

          // Update markers when reports change
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateMarkers(filteredReports);
          });

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  _loadUserLocation();
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
              ),
              if (_selectedFilter != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Text(_selectedFilter!.icon),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Showing: ${_selectedFilter!.displayName}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedFilter = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
} 