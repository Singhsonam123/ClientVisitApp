class AppSettings {
  final bool enableGallery;
  final bool enableAgenda;
  final bool enablePotluck;
  final bool enableSweets;
  final bool enableNotifications;
  final bool enableAnalytics;
  final bool enableDarkMode;

  AppSettings({
    this.enableGallery = true,
    this.enableAgenda = true,
    this.enablePotluck = true,
    this.enableSweets = true,
    this.enableNotifications = true,
    this.enableAnalytics = true,
    this.enableDarkMode = false,
  });

  AppSettings copyWith({
    bool? enableGallery,
    bool? enableAgenda,
    bool? enablePotluck,
    bool? enableSweets,
    bool? enableNotifications,
    bool? enableAnalytics,
    bool? enableDarkMode,
  }) {
    return AppSettings(
      enableGallery: enableGallery ?? this.enableGallery,
      enableAgenda: enableAgenda ?? this.enableAgenda,
      enablePotluck: enablePotluck ?? this.enablePotluck,
      enableSweets: enableSweets ?? this.enableSweets,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableGallery': enableGallery,
      'enableAgenda': enableAgenda,
      'enablePotluck': enablePotluck,
      'enableSweets': enableSweets,
      'enableNotifications': enableNotifications,
      'enableAnalytics': enableAnalytics,
      'enableDarkMode': enableDarkMode,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      enableGallery: map['enableGallery'] ?? true,
      enableAgenda: map['enableAgenda'] ?? true,
      enablePotluck: map['enablePotluck'] ?? true,
      enableSweets: map['enableSweets'] ?? true,
      enableNotifications: map['enableNotifications'] ?? true,
      enableAnalytics: map['enableAnalytics'] ?? true,
      enableDarkMode: map['enableDarkMode'] ?? false,
    );
  }
}
