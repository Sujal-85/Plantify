
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/database_service.dart';

class PlantDetailsScreen extends StatefulWidget {
  final String label;
  final String imagePath;
  final bool isHealthy;

  const PlantDetailsScreen({
    super.key,
    required this.label,
    required this.imagePath,
    required this.isHealthy,
  });

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  List<Map<String, dynamic>> _treatments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbService = context.read<DatabaseService>();
    final treatments = await dbService.getTreatments(widget.label);
    
    if (mounted) {
      setState(() {
        _treatments = treatments;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.label, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,  
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)]
                )
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Description
                  const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.isHealthy 
                    ? "${widget.label} plants are generally vigorous. Keep monitoring for any changes."
                    : "${widget.label} is identified on your plant. Follow the recommended treatments below to restore its health.",
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Treatment (if not healthy and not loading)
                  if (!widget.isHealthy) ...[
                    const Text("Recommended Treatment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_treatments.isEmpty)
                      const Text("No specific treatments found in local database. Consult an expert or try identifying again with AI.", 
                        style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic))
                    else
                      ..._treatments.asMap().entries.map((entry) {
                        return _buildTreatmentCard(entry.value['type'], entry.value['instruction']);
                      }).toList(),
                    const SizedBox(height: 24),
                  ],

                  // Care Tips
                  const Text("Prevention & Care", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCareItem(Icons.water_drop, "Watering", "Water at the base, avoid wetting leaves."),
                  _buildCareItem(Icons.wb_sunny, "Sunlight", "Ensure adequate sunlight exposure per plant species."),
                  _buildCareItem(Icons.content_cut, "Pruning", "Regularly remove dead or yellowing leaves."),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(String type, String instruction) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'chemical':
        icon = Icons.science_outlined;
        color = Colors.blue;
        break;
      case 'organic':
        icon = Icons.eco_outlined;
        color = Colors.green;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(type.toUpperCase(), 
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 8),
          Text(instruction, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCareItem(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
