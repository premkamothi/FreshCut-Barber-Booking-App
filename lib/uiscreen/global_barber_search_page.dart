import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GlobalBarberSearchPage extends StatefulWidget {
  const GlobalBarberSearchPage({super.key});

  @override
  State<GlobalBarberSearchPage> createState() => _GlobalBarberSearchPageState();
}

class _GlobalBarberSearchPageState extends State<GlobalBarberSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final String apiKey = "AIzaSyA5xVaMFV6c5rM4BCq1uVzUmXD_MxGwEZY"; // Replace with your key
  bool isLoading = false;
  List<dynamic> _results = [];

  Future<void> searchBarberShops(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      _results.clear();
    });

    final encodedQuery = Uri.encodeComponent("barber $query India");
    final url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&type=hair_care&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'OK') {
        setState(() {
          _results = data['results'];
        });
      } else {
        setState(() {
          _results = [];
        });
      }
    } catch (e) {
      setState(() {
        _results = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: searchBarberShops,
                  decoration: const InputDecoration(
                    hintText: "Search shop name or shop + city...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () => searchBarberShops(_searchController.text),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
          ? const Center(child: Text("No shops found."))
          : ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final shop = _results[index];
          final name = shop['name'] ?? 'No Name';
          final address = shop['formatted_address'] ?? 'No Address';
          final rating = shop['rating']?.toString() ?? 'N/A';
          final openNow = shop['opening_hours'] != null
              ? shop['opening_hours']['open_now'] == true
              : null;

          final imageUrl = shop['photos'] != null
              ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${shop['photos'][0]['photo_reference']}&key=$apiKey"
              : "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png";

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(rating),
                      const SizedBox(width: 10),
                      if (openNow != null)
                        Text(
                          openNow ? "Open Now" : "Closed",
                          style: TextStyle(
                            color: openNow
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                // TODO: Navigate to details page
              },
            ),
          );
        },
      ),
    );
  }
}
