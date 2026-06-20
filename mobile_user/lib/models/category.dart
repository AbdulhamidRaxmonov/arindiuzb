class WasteCategory {
  final String key;
  final String label;
  final bool active;

  WasteCategory({required this.key, required this.label, required this.active});

  factory WasteCategory.fromJson(Map<String, dynamic> json) => WasteCategory(
        key: json['key'] as String,
        label: json['label'] as String,
        active: json['active'] == true,
      );
}
