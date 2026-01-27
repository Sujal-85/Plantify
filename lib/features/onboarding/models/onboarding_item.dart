class OnboardingItem {
  final String title;
  final String description;
  final String? imagePath;
  // We can add icon data if we don't have images yet
  final Object? icon;

  OnboardingItem({
    required this.title,
    required this.description,
    this.imagePath,
    this.icon,
  });
}
