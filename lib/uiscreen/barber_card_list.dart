import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barber_model.dart';
import '../providers/liked_shops_provider.dart';

class BarberCardList extends StatelessWidget {
  final List<BarberModel> barbers;

  const BarberCardList({super.key, required this.barbers});

  @override
  Widget build(BuildContext context) {
    final likedProvider = context.watch<LikedShopsProvider>();

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: barbers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final barber = barbers[index];
          final isLiked = likedProvider.isLiked(barber);

          return SizedBox(
            width: 180,
            child: Card(
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
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 150,
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      // Like Button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          barber.address,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('${barber.distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(barber.rating.toString(), style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 1, indent: 16, endIndent: 16, height: 1),

                  // Book Now Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextButton(
                      onPressed: () {
                        // TODO: Add your booking logic here
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Book Now',
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
          );
        },
      ),
    );
  }
}