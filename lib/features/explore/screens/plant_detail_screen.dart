import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PlantInfoScreen extends StatefulWidget {
  const PlantInfoScreen({super.key});

  @override
  State<PlantInfoScreen> createState() => _PlantInfoScreenState();
}

class _PlantInfoScreenState extends State<PlantInfoScreen> {
  bool _isBookmarked = false;
  bool _isAddedToMyPlants = false;

  @override
  Widget build(BuildContext context) {
    final plant = ModalRoute.of(context)?.settings.arguments as Map<String, String>? ?? {
      'name': 'Prayer Plant',
      'scientificName': 'Goeppertia orbifolia',
      'category': 'Foliage Plants',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Plant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline,
              color: _isBookmarked ? AppColors.primary : Colors.black,
            ),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              if (_isBookmarked) {
                _showToast(context, 'Added to Bookmarks!');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.eco, color: AppColors.primary, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant['name']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMetaRow('Genus', 'Calathea'),
                  const SizedBox(height: 8),
                  _buildMetaRow('Scientific Name', plant['scientificName']!),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Photo Gallery',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) => Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.image, color: Colors.black12, size: 40),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description_outlined, color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The Prayer Plant is known for its striking foliage, which features deep green leaves with prominent white veins. It earns its name from the way its leaves fold together at night, resembling hands pressed in prayer. This plant is a popular choice for indoor gardens due to its unique appearance and relatively easy care requirements.',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() => _isAddedToMyPlants = !_isAddedToMyPlants);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAddedToMyPlants ? Colors.white : AppColors.primary,
            foregroundColor: _isAddedToMyPlants ? AppColors.primary : Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: _isAddedToMyPlants ? const BorderSide(color: AppColors.primary) : BorderSide.none,
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isAddedToMyPlants) const Icon(Icons.check, size: 20),
              if (_isAddedToMyPlants) const SizedBox(width: 8),
              Text(
                _isAddedToMyPlants ? 'Added to My Plants' : 'Add to My Plants',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontSize: 15),
          ),
        ),
        const Text(':  ', style: TextStyle(fontSize: 15)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(message, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 24,
          right: 24,
        ),
      ),
    );
  }
}
