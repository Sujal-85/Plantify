import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/preference_service.dart';
import '../../../core/theme/app_colors.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';

class CropSelectionScreen extends StatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  State<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  final List<String> _allCrops = [
    'Apple', 'Banana', 'Cabbage', 'Canola', 'Capsicum & Chili', 'Carrot', 'Cashew', 'Cauliflower', 'Cherry', 'Chickpea & Gram', 'Citrus', 'Coffee', 'Cotton', 'Cucumber', 'Currant', 'Ginger', 'Grape', 'Guava', 'Maize', 'Mango', 'Melon', 'Millet', 'Okra', 'Olive', 'Onion', 'Ornamental', 'Papaya', 'Peas', 'Peach', 'Peanut', 'Pear', 'Pigeon Pea & Red Gram', 'Pistachio', 'Pomegranate', 'Potato', 'Pumpkin', 'Rice', 'Rose', 'Sorghum', 'Soybean', 'Strawberry', 'Sugar Beet', 'Sugarcane', 'Tobacco', 'Tomato', 'Turmeric', 'Wheat', 'Zucchini'
  ];

  List<String> _selectedCrops = [];

  @override
  void initState() {
    super.initState();
    final prefs = Provider.of<PreferenceService>(context, listen: false);
    _selectedCrops = List.from(prefs.selectedCrops);
  }

  void _toggleCrop(String crop) {
    setState(() {
      if (_selectedCrops.contains(crop)) {
        _selectedCrops.remove(crop);
      } else {
        if (_selectedCrops.length < 8) {
          _selectedCrops.add(crop);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.maxCropsError)),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectCropsTitle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectCropsMessage,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  '${_selectedCrops.length}/8',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          if (_selectedCrops.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _selectedCrops.length,
                itemBuilder: (context, index) {
                  final crop = _selectedCrops[index];
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipOval(
                                child: _buildCropImage(crop, size: 50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              crop,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _toggleCrop(crop),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0056D2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: _allCrops.length,
              itemBuilder: (context, index) {
                final crop = _allCrops[index];
                final isSelected = _selectedCrops.contains(crop);

                return InkWell(
                  onTap: () => _toggleCrop(crop),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: ClipOval(
                            child: _buildCropImage(crop, size: 60),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        crop,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = Provider.of<PreferenceService>(context, listen: false);
                  await prefs.setSelectedCrops(_selectedCrops);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropImage(String crop, {double size = 40}) {
    // Generate valid filename from crop name
    final filename = crop.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and');
    final assetPath = 'assets/images/crops/$filename.png';

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to initial or generic icon if image doesn't exist yet
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey[200],
          child: Text(
            crop.characters.first.toUpperCase(),
            style: TextStyle(color: Colors.grey[600], fontSize: size * 0.4),
          ),
        );
      },
    );
  }
}
