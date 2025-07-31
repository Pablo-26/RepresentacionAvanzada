class ResourceModel {
  final String uri;
  final String label;

  ResourceModel({required this.uri, required this.label});

  factory ResourceModel.fromJson(
      Map<String, dynamic> json, String variableName) {
    final uri = json[variableName]?['value'] ?? '';
    final label = json['label']?['value'] ??
        json['${variableName}Label']?['value'] ??
        uri.split('/').last.replaceAll('_', ' ');

    return ResourceModel(uri: uri, label: label);
  }
}
