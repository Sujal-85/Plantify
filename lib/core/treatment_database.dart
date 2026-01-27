import 'disease_model.dart';

// A mock database of disease treatments.
// In a real app, this would be fetched from a server or a local database.

final Map<String, Disease> diseaseDatabase = {
  'leaf_spot': Disease(
    name: 'Leaf Spot',
    description: 'A common fungal or bacterial infection that causes dark spots on leaves.',
    severity: 'High',
    imageUrl: 'https://example.com/leaf_spot.jpg',
    treatmentSteps: [
      TreatmentStep(
        title: 'Isolate the Plant',
        description: 'Move the affected plant away from others to prevent the disease from spreading.',
      ),
      TreatmentStep(
        title: 'Prune Infected Leaves',
        description: 'Use clean, sharp scissors to remove all leaves showing signs of infection. Dispose of them in the trash, not the compost.',
      ),
      TreatmentStep(
        title: 'Apply Fungicide',
        description: 'Use a copper-based fungicide or a neem oil solution. Spray the entire plant, including the undersides of the leaves, every 7-10 days.',
      ),
      TreatmentStep(
        title: 'Improve Air Circulation',
        description: 'Ensure the plant has good airflow around it. This helps leaves dry quickly, making it harder for fungi to grow.',
      ),
      TreatmentStep(
        title: 'Water Carefully',
        description: 'Water the plant at the base, avoiding the leaves. Wet leaves are a breeding ground for fungal diseases.',
      ),
    ],
  ),
  // Add more diseases here
  'powdery_mildew': Disease(
    name: 'Powdery Mildew',
    description: 'A fungal disease that appears as white, powdery spots on leaves and stems.',
    severity: 'Medium',
    imageUrl: 'https://example.com/powdery_mildew.jpg',
    treatmentSteps: [
      TreatmentStep(
        title: 'Wipe or Wash Leaves',
        description: 'Gently wipe off the mildew with a damp cloth or rinse the leaves with water. Do this in the morning so the leaves have time to dry.',
      ),
      TreatmentStep(
        title: 'Apply a DIY Solution',
        description: 'Spray the affected areas with a mixture of 1 tablespoon of baking soda and 1/2 teaspoon of liquid soap in 1 gallon of water.',
      ),
      TreatmentStep(
        title: 'Use a Commercial Fungicide',
        description: 'If the infection is severe, use a commercial fungicide specifically designed for powdery mildew.',
      ),
    ],
  ),
};
