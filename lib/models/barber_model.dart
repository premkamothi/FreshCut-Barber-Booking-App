import 'package:flutter/material.dart';

class BarberModel {
  final String name;
  final String address;
  final String imageUrl;
  final double distanceKm;
  final double rating;
  bool isLiked;

  BarberModel({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.distanceKm,
    required this.rating,
    this.isLiked = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BarberModel &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              address == other.address;

  @override
  int get hashCode => name.hashCode ^ address.hashCode;
}