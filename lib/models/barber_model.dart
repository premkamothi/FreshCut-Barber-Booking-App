import 'package:flutter/material.dart';

class BarberModel {
  final String placeId;
  final String name;
  final String address;
  final String imageUrl;
  final double distanceKm;
  final double rating;
  final double lat;
  final double lng;
  bool isLiked;
  final bool openNow;

  BarberModel({
    required this.placeId,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.distanceKm,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.openNow,
    this.isLiked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'distanceKm': distanceKm,
      'rating': rating,
      'lat': lat,
      'lng': lng,
      'openNow': openNow,
    };
  }

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