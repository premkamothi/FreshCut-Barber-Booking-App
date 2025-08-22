import 'package:flutter/material.dart';
import '../models/mearge_barber_model.dart';

class BookingProvider extends ChangeNotifier {
  MergedBarber? _barber;
  List<Map<String, dynamic>> _selectedServices = [];
  DateTime? _selectedDate;
  String? _selectedSlot;
  int _totalPrice = 0;

  // Getters
  MergedBarber? get barber => _barber;
  List<Map<String, dynamic>> get selectedServices => _selectedServices;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedSlot => _selectedSlot;
  int get totalPrice => _totalPrice;

  // Setters
  void setBarber(MergedBarber barber) {
    _barber = barber;
    notifyListeners();
  }

  void setSelectedServices(List<Map<String, dynamic>> services) {
    _selectedServices = services;
    _calculateTotalPrice();
    notifyListeners();
  }

  void setDateTime(DateTime date, String slot) {
    _selectedDate = date;
    _selectedSlot = slot;
    notifyListeners();
  }

  void _calculateTotalPrice() {
    _totalPrice = _selectedServices.fold(0, (sum, service) => sum + (service['price'] as int));
  }

  // Check if booking is complete
  bool get isBookingComplete =>
      _barber != null &&
          _selectedServices.isNotEmpty &&
          _selectedDate != null &&
          _selectedSlot != null;

  // Clear all data
  void clearBooking() {
    _barber = null;
    _selectedServices = [];
    _selectedDate = null;
    _selectedSlot = null;
    _totalPrice = 0;
    notifyListeners();
  }

  // Get booking data for Firebase
  Map<String, dynamic> getBookingData(String userId) {
    return {
      "userId": userId,
      "placeId": _barber!.placeId,
      "shopName": _barber!.name,
      "shopAddress": _barber!.address,
      "services": _selectedServices,
      "totalPrice": _totalPrice,
      "date": _selectedDate!.toIso8601String().split('T')[0], // YYYY-MM-DD format
      "slot": _selectedSlot,
      "createdAt": DateTime.now().toIso8601String(),
    };
  }
}