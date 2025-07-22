import 'package:flutter/material.dart';
import '../models/barber_model.dart';

class LikedShopsProvider with ChangeNotifier {
  final List<BarberModel> _likedShops = [];

  List<BarberModel> get likedShops => _likedShops;

  void toggleLike(BarberModel shop) {
    final index = _likedShops.indexOf(shop);
    if (index != -1) {
      _likedShops.removeAt(index);
    } else {
      _likedShops.add(shop);
    }
    notifyListeners();
  }

  bool isLiked(BarberModel shop) {
    return _likedShops.contains(shop);
  }
}