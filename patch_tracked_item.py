import re

with open("lib/data/models/tracked_item_model.dart", "r") as f:
    content = f.read()

# Add toJson and fromJson
json_methods = r'''
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type.name,
      'sizeBytes': sizeBytes,
      'mimeType': mimeType,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
      'temporarySince': temporarySince?.toIso8601String(),
      'binnedAt': binnedAt?.toIso8601String(),
      'systemTrashPath': systemTrashPath,
      'isFlagged': isFlagged,
      'thumbnailPath': thumbnailPath,
    };
  }

  factory TrackedItemModel.fromJson(Map<String, dynamic> json) {
    return TrackedItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      path: json['path'] as String,
      type: ItemType.values.firstWhere((e) => e.name == json['type']),
      sizeBytes: json['sizeBytes'] as int,
      mimeType: json['mimeType'] as String?,
      category: ItemCategory.values.firstWhere((e) => e.name == json['category']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
      temporarySince: json['temporarySince'] != null ? DateTime.parse(json['temporarySince'] as String) : null,
      binnedAt: json['binnedAt'] != null ? DateTime.parse(json['binnedAt'] as String) : null,
      systemTrashPath: json['systemTrashPath'] as String?,
      isFlagged: json['isFlagged'] as bool,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }
'''

content = content.replace("  /// Creates a copy of this model with the given fields replaced with the new values.", json_methods + "\n  /// Creates a copy of this model with the given fields replaced with the new values.")

with open("lib/data/models/tracked_item_model.dart", "w") as f:
    f.write(content)
