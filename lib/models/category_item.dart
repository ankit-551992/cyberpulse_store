import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int iconCodePoint;
  final String? iconFontFamily;
  final List<int> gradientColors; // stored as 0xAARRGGBB hex
  final bool featured;
  final bool isActive;
  final DateTime createdAt;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.gradientColors = const [0xFF00F0FF, 0xFF7000FF],
    this.featured = false,
    this.isActive = true,
    required this.createdAt,
  });

  static IconData resolveIcon(int codePoint) {
    switch (codePoint) {
      case 0xe37a: return Icons.laptop_chromebook_rounded;
      case 0xe2f2: return Icons.headphones_rounded;
      case 0xe35f: return Icons.keyboard_rounded;
      case 0xe3e3: return Icons.monitor_rounded;
      case 0xe3cc: return Icons.memory_rounded;
      case 0xe6e1: return Icons.watch_rounded;
      case 0xe6bd: return Icons.videogame_asset_rounded;
      case 0xe6df: return Icons.wifi_rounded;
      case 0xe56c: return Icons.security_rounded;
      case 0xe4b2: return Icons.phone_android_rounded;
      case 0xe5cb: return Icons.smart_toy_rounded;
      case 0xe11e: return Icons.cable_rounded;
      case 0xe135: return Icons.camera_alt_rounded;
      case 0xe602: return Icons.storage_rounded;
      case 0xe5e7: return Icons.speaker_rounded;
      case 0xe5ee: return Icons.speed_rounded;
      case 0xe0e7: return Icons.bolt_rounded;
      case 0xe0a6: return Icons.auto_awesome_rounded;
      case 0xe53c: return Icons.rocket_launch_rounded;
      case 0xe179: return Icons.cloud_queue_rounded;
      case 0xe1d6: return Icons.devices_other_rounded;
      case 0xe148: return Icons.category_rounded;
    }
    // Static fallback
    return Icons.category_rounded;
  }

  IconData get iconData => resolveIcon(iconCodePoint);

  List<Color> get colors => gradientColors.map((c) => Color(c)).toList();

  CategoryItem copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    int? iconCodePoint,
    String? iconFontFamily,
    List<int>? gradientColors,
    bool? featured,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      gradientColors: gradientColors ?? this.gradientColors,
      featured: featured ?? this.featured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'iconCodePoint': iconCodePoint,
    'iconFontFamily': iconFontFamily,
    'gradientColors': gradientColors,
    'featured': featured,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String? ?? '',
    iconCodePoint: json['iconCodePoint'] as int? ?? Icons.category_rounded.codePoint,
    iconFontFamily: json['iconFontFamily'] as String?,
    gradientColors: (json['gradientColors'] as List<dynamic>?)?.map((e) => e as int).toList() ??
        const [0xFF00F0FF, 0xFF7000FF],
    featured: json['featured'] as bool? ?? false,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}
