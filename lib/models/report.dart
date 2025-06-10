class Report {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final DateTime createdAt;
  final ReportStatus status;
  final String reporterName;
  final String? reporterEmail;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    required this.createdAt,
    this.status = ReportStatus.pending,
    required this.reporterName,
    this.reporterEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'status': status.index,
      'reporterName': reporterName,
      'reporterEmail': reporterEmail,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: ReportCategory.values[json['category']],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      status: ReportStatus.values[json['status']],
      reporterName: json['reporterName'],
      reporterEmail: json['reporterEmail'],
    );
  }
}

enum ReportCategory {
  ragweed,
  waterPollution,
  airPollution,
  illegalDumping,
  noisePollution,
  other,
}

enum ReportStatus {
  pending,
  investigating,
  resolved,
  rejected,
}

extension ReportCategoryExtension on ReportCategory {
  String get displayName {
    switch (this) {
      case ReportCategory.ragweed:
        return 'Ragweed Outbreak';
      case ReportCategory.waterPollution:
        return 'Water Pollution';
      case ReportCategory.airPollution:
        return 'Air Pollution';
      case ReportCategory.illegalDumping:
        return 'Illegal Dumping';
      case ReportCategory.noisePollution:
        return 'Noise Pollution';
      case ReportCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ReportCategory.ragweed:
        return '🌿';
      case ReportCategory.waterPollution:
        return '💧';
      case ReportCategory.airPollution:
        return '🏭';
      case ReportCategory.illegalDumping:
        return '🗑️';
      case ReportCategory.noisePollution:
        return '🔊';
      case ReportCategory.other:
        return '⚠️';
    }
  }
}

extension ReportStatusExtension on ReportStatus {
  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.investigating:
        return 'Under Investigation';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }
} 