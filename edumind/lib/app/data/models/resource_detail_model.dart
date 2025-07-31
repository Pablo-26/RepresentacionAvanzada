class ResourceDetail {
  final String propertyUri;
  final String propertyLabel;
  final String value;
  final String valueLabel;

  ResourceDetail({
    required this.propertyUri,
    required this.propertyLabel,
    required this.value,
    required this.valueLabel,
  });

  factory ResourceDetail.fromJson(Map<String, dynamic> json) {
    final propiedadUri = json['propiedad']?['value'] ?? '';
    final propiedadLabel = json['propiedadLabel']?['value'] ?? '';

    final valorRaw = json['valor']?['value'] ?? '';
    final valorLabel = json['valorLabel']?['value'] ?? '';

    return ResourceDetail(
      propertyUri: propiedadUri,
      propertyLabel: propiedadLabel.isNotEmpty
          ? propiedadLabel
          : propiedadUri.split('/').last, // fallback
      value: valorRaw,
      valueLabel: valorLabel.isNotEmpty ? valorLabel : valorRaw,
    );
  }
}
