import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../models/report.dart';
import 'database_service.dart';

class ReportProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Report> _reports = [];
  bool _isLoading = false;
  
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  
  List<Report> get pendingReports => 
      _reports.where((report) => report.status == ReportStatus.pending).toList();
  
  List<Report> get resolvedReports => 
      _reports.where((report) => report.status == ReportStatus.resolved).toList();

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _reports = await _databaseService.getAllReports();
    } catch (e) {
      debugPrint('Error loading reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReport(Report report) async {
    try {
      await _databaseService.insertReport(report);
      _reports.add(report);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding report: $e');
      rethrow;
    }
  }

  Future<void> updateReport(Report report) async {
    try {
      await _databaseService.updateReport(report);
      final index = _reports.indexWhere((r) => r.id == report.id);
      if (index != -1) {
        _reports[index] = report;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating report: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _databaseService.deleteReport(reportId);
      _reports.removeWhere((report) => report.id == reportId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting report: $e');
      rethrow;
    }
  }

  List<Report> getReportsByCategory(ReportCategory category) {
    return _reports.where((report) => report.category == category).toList();
  }

  List<Report> getReportsNearLocation(double latitude, double longitude, double radiusInKm) {
    return _reports.where((report) {
      double distance = _calculateDistance(
        latitude, longitude, 
        report.latitude, report.longitude
      );
      return distance <= radiusInKm * 1000; // Convert km to meters
    }).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth radius in meters
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  int getReportCountByCategory(ReportCategory category) {
    return _reports.where((report) => report.category == category).length;
  }

  int get totalReports => _reports.length;
} 