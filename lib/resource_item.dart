
class ResourceItem {
  ResourceItem({
    required this.resourceId,
    required this.resourceText,
    this.resourceInfo = "",
  });

  String resourceId;
  String resourceText;
  String resourceInfo;

  factory ResourceItem.fromJson(Map<String, dynamic> json) => ResourceItem(
    resourceId: json["resource_id"],
    resourceText: json["resource_text"],
    resourceInfo: json["resource_info"],
  );

  Map<String, dynamic> toJson() => {
    "resource_id": resourceId,
    "resource_text": resourceText,
    "resource_info": resourceInfo,
  };
}