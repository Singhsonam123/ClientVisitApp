import 'package:flutter/material.dart';

class AgendaCategory {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  AgendaCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class AgendaItem {
  final String title;
  final String startTime;
  final String endTime;
  final String description;
  final String? speaker;
  final String? venue;
  final AgendaCategory category;
  final String dayLabel;
  final bool isHighlight;

  AgendaItem({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.speaker,
    this.venue,
    required this.category,
    required this.dayLabel,
    this.isHighlight = false,
  });

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      title: json['title'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      description: json['description'] as String,
      speaker: json['speaker'] as String?,
      venue: json['venue'] as String?,
      category: json['category'] as AgendaCategory,
      dayLabel: json['dayLabel'] as String,
      isHighlight: json['isHighlight'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'speaker': speaker,
      'venue': venue,
      'category': category,
      'dayLabel': dayLabel,
      'isHighlight': isHighlight,
    };
  }
}

/// A city-explore venue shown on the Weekend tab.
class WeekendVenue {
  final String name;
  final String description;
  final String imageUrl;
  final String emoji;
  final String dayLabel; // 'Saturday, 8 Aug' or 'Sunday, 9 Aug'
  final Color accentColor;

  const WeekendVenue({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.emoji,
    required this.dayLabel,
    required this.accentColor,
  });
}

// Category definitions
class AgendaCategoryType {
  static final meeting = AgendaCategory(
    label: 'Meeting',
    icon: Icons.people_outline_rounded,
    color: const Color(0xFF6366F1),
    bgColor: const Color(0xFF6366F1).withOpacity(0.1),
  );

  static final activity = AgendaCategory(
    label: 'Activity',
    icon: Icons.directions_walk_rounded,
    color: const Color(0xFF10B981),
    bgColor: const Color(0xFF10B981).withOpacity(0.1),
  );

  static final meal = AgendaCategory(
    label: 'Meal',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFF59E0B),
    bgColor: const Color(0xFFF59E0B).withOpacity(0.1),
  );

  static final transport = AgendaCategory(
    label: 'Transport',
    icon: Icons.directions_car_rounded,
    color: const Color(0xFF3B82F6),
    bgColor: const Color(0xFF3B82F6).withOpacity(0.1),
  );

  static final social = AgendaCategory(
    label: 'Social',
    icon: Icons.celebration_rounded,
    color: const Color(0xFFEC4899),
    bgColor: const Color(0xFFEC4899).withOpacity(0.1),
  );
}

// Agenda Data
class AgendaData {
  /// Chronological day tabs. Day 4 (Sat 8 Aug) and Day 5 (Sun 9 Aug) are merged
  /// as "Weekend". Work days resume at Day 5 label from Monday 10 Aug.
  static final List<String> days = [
    'Day 1 (5 Aug)',
    'Day 2 (6 Aug)',
    'Day 3 (7 Aug)',
    'Weekend (8-9 Aug)',
    'Day 5 (10 Aug)',
    'Day 6 (11 Aug)',
    'Day 7 (12 Aug)',
    'Day 8 (13 Aug)',
  ];

  /// Weekend city-explore venues for Saturday 8 Aug and Sunday 9 Aug.
  static const List<WeekendVenue> weekendVenues = [
    // ── Saturday, 8 Aug ──────────────────────────────────────────────────
    WeekendVenue(
      name: 'Charminar',
      description:
          'The iconic 16th-century mosque and monument of Hyderabad. '
          'A UNESCO-listed heritage site surrounded by the bustling old city.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Charminar.JPG/400px-Charminar.JPG',
      emoji: '🕌',
      dayLabel: 'Saturday, 8 Aug',
      accentColor: Color(0xFFE67E22),
    ),
    WeekendVenue(
      name: 'Chowmahalla Palace',
      description:
          'The Nizam\'s stunning palace complex with four grand halls, '
          'a vintage car collection and manicured courtyards.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Chowmahalla_palace_hyderabad.jpg/400px-Chowmahalla_palace_hyderabad.jpg',
      emoji: '🏯',
      dayLabel: 'Saturday, 8 Aug',
      accentColor: Color(0xFF8E44AD),
    ),
    WeekendVenue(
      name: 'Salar Jung Museum',
      description:
          'One of India\'s largest museums, housing a world-renowned '
          'collection of art, manuscripts, paintings and antiques.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Salar_Jung_Museum_Hyderabad.jpg/400px-Salar_Jung_Museum_Hyderabad.jpg',
      emoji: '🏛️',
      dayLabel: 'Saturday, 8 Aug',
      accentColor: Color(0xFF2980B9),
    ),
    WeekendVenue(
      name: 'Laad Bazaar & Pearl Shopping',
      description:
          'Hyderabad\'s famous bangle market near Charminar. '
          'Shop for colourful lac bangles and lustrous Hyderabadi pearls.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Laad_Bazaar.jpg/400px-Laad_Bazaar.jpg',
      emoji: '💎',
      dayLabel: 'Saturday, 8 Aug',
      accentColor: Color(0xFFE91E63),
    ),

    // ── Sunday, 9 Aug ────────────────────────────────────────────────────
    WeekendVenue(
      name: 'Jagannath Temple',
      description:
          'A serene and beautifully adorned temple dedicated to Lord Jagannath, '
          'located in the Film Nagar area of Hyderabad.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Jagannath_Temple_Hyderabad.jpg/400px-Jagannath_Temple_Hyderabad.jpg',
      emoji: '🛕',
      dayLabel: 'Sunday, 9 Aug',
      accentColor: Color(0xFFF39C12),
    ),
    WeekendVenue(
      name: 'In-Orbit Mall',
      description:
          'A premium shopping destination with top national and international '
          'brands, a food court, multiplex cinema and entertainment zone.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Inorbit_mall_hyderabad.jpg/400px-Inorbit_mall_hyderabad.jpg',
      emoji: '🛍️',
      dayLabel: 'Sunday, 9 Aug',
      accentColor: Color(0xFF27AE60),
    ),
    WeekendVenue(
      name: 'Hussain Sagar & Necklace Road',
      description:
          'Hyderabad\'s iconic heart-shaped lake featuring the giant '
          'monolithic Buddha statue. Visit at night for a spectacular view '
          'of city lights along Necklace Road.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Hussain_sagar.jpg/400px-Hussain_sagar.jpg',
      emoji: '🌅',
      dayLabel: 'Sunday, 9 Aug',
      accentColor: Color(0xFF1ABC9C),
    ),
    WeekendVenue(
      name: 'Birla Mandir',
      description:
          'A stunning white marble temple dedicated to Lord Venkateswara, '
          'perched on a rocky hillock with panoramic views of the city '
          'and Hussain Sagar lake.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Birla_Mandir_Hyderabad.jpg/400px-Birla_Mandir_Hyderabad.jpg',
      emoji: '⛪',
      dayLabel: 'Sunday, 9 Aug',
      accentColor: Color(0xFFFF5722),
    ),
  ];

  static final List<AgendaItem> items = [
    // Day 1 - 5 Aug 2026 (Wednesday)
    AgendaItem(
      title: 'Pick-up from the Hotel',
      startTime: '10:00 AM',
      endTime: '10:00 AM',
      description: 'Hotel pickup for the event',
      speaker: 'Kiran D',
      category: AgendaCategoryType.transport,
      dayLabel: 'Day 1',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Meet & Greet',
      startTime: '10:30 AM',
      endTime: '11:00 AM',
      description: 'Welcome and introductions with the team',
      speaker: 'Team',
      category: AgendaCategoryType.social,
      dayLabel: 'Day 1',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Floor walk',
      startTime: '11:00 AM',
      endTime: '11:30 AM',
      description: 'Office tour and facility walkthrough',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 1',
    ),
    AgendaItem(
      title: 'Meeting with Leadership',
      startTime: '11:30 AM',
      endTime: '12:30 PM',
      description: 'Strategic discussion with leadership team',
      speaker: 'Divya, Kasi, Kiran, Bhaskar',
      venue: 'Boardroom - H6 5th floor',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 1',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Joining with team Members',
      startTime: '12:30 PM',
      endTime: '1:00 PM',
      description: 'Informal interaction with team members',
      category: AgendaCategoryType.social,
      dayLabel: 'Day 1',
    ),
    AgendaItem(
      title: 'Lunch',
      startTime: '1:00 PM',
      endTime: '2:00 PM',
      description: 'Lunch break',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 1',
    ),
    AgendaItem(
      title: 'Meeting with all Backend lead',
      startTime: '2:00 PM',
      endTime: '3:00 PM',
      description: 'Backend team discussion and updates',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 1',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '3:00 PM',
      endTime: '5:00 PM',
      description: 'Collaborative work session with team',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 1',
    ),

    // Day 2 - 6 Aug 2026 (Thursday)
    AgendaItem(
      title: 'Pick-up from the Hotel',
      startTime: '9:15 AM',
      endTime: '9:15 AM',
      description: 'Hotel pickup for the day',
      speaker: 'Kiran',
      category: AgendaCategoryType.transport,
      dayLabel: 'Day 2',
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '10:00 AM',
      endTime: '1:00 PM',
      description: 'Extended work session with team',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 2',
    ),
    AgendaItem(
      title: 'Lunch',
      startTime: '1:00 PM',
      endTime: '2:00 PM',
      description: 'Lunch break',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 2',
    ),
    AgendaItem(
      title: 'Meeting with AIDE (QE)',
      startTime: '2:00 PM',
      endTime: '3:00 PM',
      description: 'Quality Assurance team meeting',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 2',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '3:00 PM',
      endTime: '5:00 PM',
      description: 'Continued collaboration with team',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 2',
    ),
    AgendaItem(
      title: 'Dinner with Leadership',
      startTime: '6:00 PM',
      endTime: '8:00 PM',
      description: 'Dinner with leadership team',
      venue: 'Olive Bistro',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 2',
      isHighlight: true,
    ),

    // Day 3 - 7 Aug 2026 (Friday)
    AgendaItem(
      title: 'Pick-up from the Hotel',
      startTime: '9:15 AM',
      endTime: '9:15 AM',
      description: 'Hotel pickup for the day',
      speaker: 'Kiran',
      category: AgendaCategoryType.transport,
      dayLabel: 'Day 3',
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      description: 'Team collaboration session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 3',
    ),
    AgendaItem(
      title: 'Meeting with AIDE (Mobile Apps)',
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      description: 'Mobile applications team meeting',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 3',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Lunch: (Potluck) + Traditional Wear',
      startTime: '1:00 PM',
      endTime: '3:00 PM',
      description: 'Potluck lunch with traditional wear celebration',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 3',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '3:00 PM',
      endTime: '5:00 PM',
      description: 'Final work session of the day',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 3',
    ),

    // Day 5 - 10 Aug 2026 (Monday) — resumes after Weekend
    AgendaItem(
      title: 'Pick-up from the Hotel',
      startTime: '9:15 AM',
      endTime: '9:15 AM',
      description: 'Hotel pickup for the day',
      speaker: 'Kiran',
      category: AgendaCategoryType.transport,
      dayLabel: 'Day 5',
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      description: 'Team collaboration session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 5',
    ),
    AgendaItem(
      title: 'Discussion on innovations',
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      description: 'Innovation discussion and brainstorming',
      speaker: 'Kiran Dandeboina, Subhash, Kasi, Viswanath Morva, Sai Divya, Gummadi, Bhaskar Reddy Thamma',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 5',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Lunch',
      startTime: '1:00 PM',
      endTime: '2:00 PM',
      description: 'Lunch break',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 5',
    ),
    AgendaItem(
      title: 'KT Session on creation',
      startTime: '2:00 PM',
      endTime: '3:00 PM',
      description: 'Knowledge transfer session on creation process',
      speaker: 'Satish Chilaka, Krishna Nalam, Sujana Pandidi',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 5',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '3:00 PM',
      endTime: '5:00 PM',
      description: 'Final work session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 5',
    ),
    AgendaItem(
      title: 'Jewel Of Nizam (Dinner)',
      startTime: '6:00 PM',
      endTime: '8:00 PM',
      description: 'Dinner with leadership team',
      speaker: 'Leadership',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 5',
      isHighlight: true,
    ),

    // Day 6 - 11 Aug 2026 (Tuesday)
    AgendaItem(
      title: 'Pick-up from the Hotel',
      startTime: '9:15 AM',
      endTime: '9:15 AM',
      description: 'Hotel pickup for the day',
      speaker: 'Kiran',
      category: AgendaCategoryType.transport,
      dayLabel: 'Day 6',
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      description: 'Team collaboration session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 6',
    ),
    AgendaItem(
      title: 'KT Session With Catalogue team',
      startTime: '11:00 AM',
      endTime: '12:00 PM',
      description: 'Knowledge transfer session',
      speaker: 'Sanjith Gujje',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 6',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      description: 'Team collaboration session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 6',
    ),
    AgendaItem(
      title: 'Lunch',
      startTime: '1:00 PM',
      endTime: '2:00 PM',
      description: 'Lunch break',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 6',
    ),
    AgendaItem(
      title: 'KT Session with CNC team',
      startTime: '2:00 PM',
      endTime: '3:00 PM',
      description: 'Knowledge transfer session',
      speaker: 'Janardhan Gurram, Rohit Gudesa',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 6',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '3:00 PM',
      endTime: '4:00 PM',
      description: 'Team collaboration session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 6',
    ),
    AgendaItem(
      title: 'Shilparamam + Nilofer Café',
      startTime: '4:00 PM',
      endTime: '7:00 PM',
      description: 'Evening outing',
      category: AgendaCategoryType.social,
      dayLabel: 'Day 6',
      isHighlight: true,
    ),

    // Day 7 - 12 Aug 2026 (Wednesday)
    AgendaItem(
      title: 'Pick-up from the Hotel',
      startTime: '9:15 AM',
      endTime: '9:15 AM',
      description: 'Hotel pickup for the day',
      speaker: 'Kiran',
      category: AgendaCategoryType.transport,
      dayLabel: 'Day 7',
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '10:00 AM',
      endTime: '1:00 PM',
      description: 'Extended work session with team',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 7',
    ),
    AgendaItem(
      title: 'Lunch',
      startTime: '1:00 PM',
      endTime: '2:00 PM',
      description: 'Lunch break',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 7',
    ),
    AgendaItem(
      title: 'Townhall',
      startTime: '3:00 PM',
      endTime: '5:00 PM',
      description: 'Company townhall meeting',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 7',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Dinner with leadership - Brewery',
      startTime: '6:00 PM',
      endTime: '8:00 PM',
      description: 'Dinner at Babylon Kitchen & Bar',
      speaker: 'Parveen, Kasi, Kiran, Bhaskar',
      venue: 'Babylon Kitchen & Bar',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 7',
      isHighlight: true,
    ),

    // Day 8 - 13 Aug 2026 (Thursday)
    AgendaItem(
      title: 'Pick-up from the Hotel',
      startTime: '9:15 AM',
      endTime: '9:15 AM',
      description: 'Hotel pickup for the day',
      speaker: 'Kiran',
      category: AgendaCategoryType.transport,
      dayLabel: 'Day 8',
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      description: 'Team collaboration session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 8',
    ),
    AgendaItem(
      title: 'KT Session With Projects & rendering team',
      startTime: '11:00 AM',
      endTime: '12:00 PM',
      description: 'Knowledge transfer session',
      speaker: 'Santosh Mendagujjula, Tariq Jalal',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 8',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      description: 'Team collaboration session',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 8',
    ),
    AgendaItem(
      title: 'Lunch',
      startTime: '1:00 PM',
      endTime: '2:00 PM',
      description: 'Lunch break',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 8',
    ),
    AgendaItem(
      title: 'KT Session with Photos team',
      startTime: '2:00 PM',
      endTime: '3:00 PM',
      description: 'Knowledge transfer session',
      speaker: 'Manasa Gudapati',
      category: AgendaCategoryType.meeting,
      dayLabel: 'Day 8',
      isHighlight: true,
    ),
    AgendaItem(
      title: 'Working with team Members',
      startTime: '3:00 PM',
      endTime: '5:00 PM',
      description: 'Final work session of the day',
      category: AgendaCategoryType.activity,
      dayLabel: 'Day 8',
    ),
    AgendaItem(
      title: 'Team Dinner',
      startTime: '5:00 PM',
      endTime: '8:00 PM',
      description: 'Farewell dinner with the team',
      category: AgendaCategoryType.meal,
      dayLabel: 'Day 8',
      isHighlight: true,
    ),
  ];

  static List<AgendaItem> itemsForDay(String day) {
    // Tab labels include a date suffix, e.g. "Day 1 (5 Aug)" — strip it
    // before comparing against item.dayLabel which is just "Day 1".
    final dayKey = day.contains(' (') ? day.split(' (').first : day;
    return items.where((item) => item.dayLabel == dayKey).toList();
  }
}

// Agenda days constants (updated numbering)
class AgendaDays {
  AgendaDays._();
  static const String day1 = '2.0 Agenda – 5th Aug 2026 (Wednesday)';
  static const String day2 = '3.0 Agenda – 6th Aug 2026 (Thursday)';
  static const String day3 = '4.0 Agenda – 7th Aug 2026 (Friday)';
  // Day 4 (Sat) + Day 5 (Sun) = Weekend explore — no work agenda
  static const String day5 = '5.0 Agenda – 10th Aug 2026 (Monday)';
  static const String day6 = '6.0 Agenda – 11th Aug 2026 (Tuesday)';
  static const String day7 = '7.0 Agenda – 12th Aug 2026 (Wednesday)';
  static const String day8 = '8.0 Agenda – 13th Aug 2026 (Thursday)';
}