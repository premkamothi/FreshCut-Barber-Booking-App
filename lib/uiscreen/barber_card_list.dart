import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/barber_model.dart';
import '../providers/liked_shops_provider.dart';
import '../shop_profile/shop_profile.dart';

class BarberCardList extends StatefulWidget {
  final List<BarberModel> barbers;

  const BarberCardList({super.key, required this.barbers});

  @override
  State<BarberCardList> createState() => _BarberCardListState();
}

class _BarberCardListState extends State<BarberCardList> {
  Set<String> registeredShops = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRegisteredShops();
  }

  Future<void> _loadRegisteredShops() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('RegisteredShops').get();
    setState(() {
      registeredShops = snapshot.docs.map((doc) => doc.id).toSet();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final likedProvider = context.watch<LikedShopsProvider>();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        itemCount: widget.barbers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final barber = widget.barbers[index];
          final isLiked = likedProvider.isLiked(barber);
          final isRegistered = registeredShops.contains(barber.placeId);

          return SizedBox(
            width: 180,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopProfile(barberData: barber),
                  ),
                );
              },
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image with Like Icon
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              barber.imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image_not_supported,
                                        size: 60, color: Colors.grey),
                                  ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLiked
                                  ? const Color(0xFFF31E1E)
                                  : Colors.grey[600],
                            ),
                            onPressed: () {
                              likedProvider.toggleLike(barber);
                            },
                          ),
                        ),
                      ],
                    ),

                    // Barber Info
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barber.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            barber.address,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                '${barber.distanceKm.toStringAsFixed(2)} km',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.star,
                                  size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                barber.rating.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                        thickness: 1, indent: 16, endIndent: 16, height: 1),

                    // Book Now / Not Registered
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Center(
                        child: isRegistered
                            ? TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ShopProfile(barberData: barber),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        )
                            : const Text(
                          "Not Registered",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
