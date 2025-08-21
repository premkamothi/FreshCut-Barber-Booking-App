class ShopProfileDetails {
  final String ownerUid;
  final String? shopName;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final String? about;

  // Working hours
  final String? monFriStart;
  final String? monFriEnd;
  final String? satSunStart;
  final String? satSunEnd;

  // Contacts
  final String? primaryContactNumber;
  final List<String>? additionalContactNumbers;

  // Services
  final List<Map<String, dynamic>>? services;

  ShopProfileDetails({
    required this.ownerUid,
    this.shopName,
    this.address,
    this.phoneNumber,
    this.website,
    this.about,
    this.monFriStart,
    this.monFriEnd,
    this.satSunStart,
    this.satSunEnd,
    this.primaryContactNumber,
    this.additionalContactNumbers,
    this.services,
  });

  factory ShopProfileDetails.fromMap(String id, Map<String, dynamic> data) {
    return ShopProfileDetails(
      ownerUid: data['ownerUid'] ?? "",
      shopName: data['shopName'],
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      website: data['websiteLink'],
      about: data['aboutShop'],
      monFriStart: data['monFriStart'],
      monFriEnd: data['monFriEnd'],
      satSunStart: data['satSunStart'],
      satSunEnd: data['satSunEnd'],

      // Services list
      services: (data['Services'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),

      // Contacts
      primaryContactNumber: data['primaryContactNumber']?.toString(),
      additionalContactNumbers: (data['additionalContactNumbers'] as List<dynamic>?)
          ?.map((e) => e.toString()) // ✅ ensures it's always List<String>
          .toList(),
    );
  }
}
