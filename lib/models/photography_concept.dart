import 'package:flutter/material.dart'; // 需要 IconData

// --- Data Model ---
class PhotographyConcept {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Parameter> parameters; // Parameters adjustable for this concept
  final List<String> imageAssets; // 新增的圖片資源路徑列表

  const PhotographyConcept({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.parameters,
    this.imageAssets = const [], // 初始化為空列表
  });
}

class Parameter {
  final String name;
  final double initialValue;
  final double minValue;
  final double maxValue;
  final int divisions; // For Slider

  const Parameter({
    required this.name,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.divisions = 100, // Default divisions
  });
}