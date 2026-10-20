class AdvisoryModel {
  final String status;
  final String title;
  final String summary;
  final String? summaryHi;
  final String? issuedDate;
  final String sourceName;
  final String? sourceUrl;
  final bool isVerified;
  final String notice;
  final String disclaimer;

  AdvisoryModel({
    required this.status,
    required this.title,
    required this.summary,
    this.summaryHi,
    this.issuedDate,
    required this.sourceName,
    this.sourceUrl,
    required this.isVerified,
    required this.notice,
    required this.disclaimer,
  });

  factory AdvisoryModel.fromJson(Map<String, dynamic> json) {
    return AdvisoryModel(
      status: json['status'] as String? ?? 'VERIFIED',
      title: json['title'] as String? ?? 'Health Advisory',
      summary: json['summary'] as String? ?? '',
      summaryHi: json['summary_hi'] as String?,
      issuedDate: json['issued_date'] as String?,
      sourceName: json['source_name'] as String? ?? 'Official Source',
      sourceUrl: json['source_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
      notice: json['notice'] as String? ?? 'Official source and dated',
      disclaimer: json['disclaimer'] as String? ?? 'Health guidance comes only from official advisories.',
    );
  }
}
