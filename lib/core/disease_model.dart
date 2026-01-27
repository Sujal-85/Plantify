class Disease {
  final String name;
  final String description;
  final String severity;
  final String imageUrl;
  final List<TreatmentStep> treatmentSteps;
  
  // New Fields for Redesign
  final String pathogenType; // e.g. "Fungus", "Bacteria"
  final String organicControl;
  final String chemicalControl;

  Disease({
    required this.name,
    required this.description,
    required this.severity,
    required this.imageUrl,
    required this.treatmentSteps,
    this.pathogenType = 'Fungus', // Default
    this.organicControl = 'No biological control is available for this disease.',
    this.chemicalControl = 'No regulated chemical products are currently approved.',
  });
}

class TreatmentStep {
  final String title;
  final String description;

  TreatmentStep({required this.title, required this.description});
}
