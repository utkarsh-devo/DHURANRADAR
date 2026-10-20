class FieldReport {
  final String id;
  final String workerId;
  final String workerRole;
  final String? villageName;
  final double latitude;
  final double longitude;
  final String reportType;
  final String reportLabelEn;
  final String reportLabelHi;
  final String? notes;
  final DateTime createdAt;
  final String verificationStatus;
  final bool eligibleForRelay;

  FieldReport({
    required this.id,
    required this.workerId,
    required this.workerRole,
    this.villageName,
    required this.latitude,
    required this.longitude,
    required this.reportType,
    required this.reportLabelEn,
    required this.reportLabelHi,
    this.notes,
    required this.createdAt,
    required this.verificationStatus,
    required this.eligibleForRelay,
  });

  factory FieldReport.fromJson(Map<String, dynamic> json) {
    return FieldReport(
      id: json['id'] as String? ?? '',
      workerId: json['worker_id'] as String? ?? '',
      workerRole: json['worker_role'] as String? ?? 'ASHA',
      villageName: json['village_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      reportType: json['report_type'] as String? ?? '',
      reportLabelEn: json['report_label_en'] as String? ?? '',
      reportLabelHi: json['report_label_hi'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      verificationStatus: json['verification_status'] as String? ?? 'Unverified',
      eligibleForRelay: json['eligible_for_relay'] as bool? ?? false,
    );
  }
}

class DownwindRelayAlert {
  final bool active;
  final String? sourceReportId;
  final String? reportType;
  final String? upwindVillage;
  final double? distanceKm;
  final String message;
  final String messageHi;
  final String statusLabel;
  final String warningNote;

  DownwindRelayAlert({
    required this.active,
    this.sourceReportId,
    this.reportType,
    this.upwindVillage,
    this.distanceKm,
    required this.message,
    required this.messageHi,
    required this.statusLabel,
    required this.warningNote,
  });

  factory DownwindRelayAlert.fromJson(Map<String, dynamic> json) {
    return DownwindRelayAlert(
      active: json['active'] as bool? ?? false,
      sourceReportId: json['source_report_id'] as String?,
      reportType: json['report_type'] as String?,
      upwindVillage: json['upwind_village'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      message: json['message'] as String? ?? 'No active relay alerts.',
      messageHi: json['message_hi'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? 'Unverified',
      warningNote: json['warning_note'] as String? ?? 'Always "Unverified" (a heads up, not an alarm).',
    );
  }
}
