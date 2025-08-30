class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? parentId;
  final List<Category>? subcategories;
  final int coursesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.parentId,
    this.subcategories,
    this.coursesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      parentId: json['parent_id'] as String?,
      subcategories: json['subcategories'] != null
          ? List<Category>.from(
              (json['subcategories'] as List).map((subcat) => Category.fromJson(subcat)))
          : null,
      coursesCount: json['courses_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'parent_id': parentId,
      'subcategories': subcategories?.map((subcat) => subcat.toJson()).toList(),
      'courses_count': coursesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? parentId,
    List<Category>? subcategories,
    int? coursesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      subcategories: subcategories ?? this.subcategories,
      coursesCount: coursesCount ?? this.coursesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasSubcategories => subcategories != null && subcategories!.isNotEmpty;

  bool get isSubcategory => parentId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, coursesCount: $coursesCount)';
  }
}

