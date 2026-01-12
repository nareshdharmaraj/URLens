/// Download option model
class DownloadOption {
  final String qualityLabel;
  final String extension;
  final int? fileSizeApprox;
  final String downloadUrl;

  DownloadOption({
    required this.qualityLabel,
    required this.extension,
    this.fileSizeApprox,
    required this.downloadUrl,
  });

  factory DownloadOption.fromJson(Map<String, dynamic> json) {
    return DownloadOption(
      qualityLabel: json['quality_label'] as String,
      extension: json['extension'] as String,
      fileSizeApprox: json['file_size_approx'] as int?,
      downloadUrl: json['download_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quality_label': qualityLabel,
      'extension': extension,
      'file_size_approx': fileSizeApprox,
      'download_url': downloadUrl,
    };
  }
}
