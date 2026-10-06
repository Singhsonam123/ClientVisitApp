import 'package:equatable/equatable.dart';

class SweetModel extends Equatable {
  final String id;
  final String name;
  final String origin;
  final String description;
  final String ingredients;
  final String funFact;
  final String emoji;
  final String qrData;
  final bool isVegetarian;
  final List<String> allergens;
  final String calories;

  const SweetModel({
    required this.id,
    required this.name,
    required this.origin,
    required this.description,
    required this.ingredients,
    required this.funFact,
    required this.emoji,
    required this.qrData,
    required this.isVegetarian,
    required this.allergens,
    required this.calories,
  });

  @override
  List<Object?> get props => [id, name];
}

class SweetsData {
  static const List<SweetModel> sweets = [
    SweetModel(
      id: 's1',
      name: 'Moti Chur Laddu',
      origin: 'North India (Rajasthan & Uttar Pradesh)',
      emoji: '🟠',
      description:
          'Soft, melt-in-the-mouth spheres made from microscopic, deep-fried drops of chickpea flour (besan) that are soaked in fragrant sugar syrup and rolled together.',
      ingredients:
          'Besan (chickpea flour), sugar syrup, ghee, cardamom, saffron, pistachios',
      funFact:
          'The name is highly poetic. In Hindi, Moti means "pearl" and Chur means "crushed." You are essentially eating "crushed pearls of sweetness."',
      qrData: 'shutterfly://sweets/s1',
      isVegetarian: true,
      allergens: ['Chickpea', 'Nuts'],
      calories: '~160 kcal per piece',
    ),
    SweetModel(
      id: 's2',
      name: 'Kaju Katli',
      origin: 'Evolved in 16th-century Royal Kitchens, post-Goa',
      emoji: '💎',
      description:
          'A minimalist, premium Indian fudge made almost entirely of finely ground cashew nuts and sugar syrup. Unlike most Indian sweets, it traditionally contains no milk or ghee, making it a naturally vegan delicacy.',
      ingredients:
          'Cashew nuts, sugar, water, edible silver vark (optional)',
      funFact:
          'Its signature diamond shape (katli means "slice") was historically chosen by royal chefs to symbolize clarity and prosperity. The edible silver foil (vark) on top was traditionally believed to ward off negativity.',
      qrData: 'shutterfly://sweets/s2',
      isVegetarian: true,
      allergens: ['Tree Nuts'],
      calories: '~180 kcal per piece',
    ),
    SweetModel(
      id: 's3',
      name: 'Gujhiya',
      origin: 'North India (Rajasthan, UP & Bihar)',
      emoji: '🥮',
      description:
          'A crisp, flaky pastry half-moon, deeply fried and stuffed with a rich mixture of sweetened khoya (reduced milk solids), coconut, and chopped nuts.',
      ingredients:
          'Maida (all-purpose flour), khoya, desiccated coconut, sugar, chopped nuts, ghee',
      funFact:
          'Gujhiyas are essentially the Indian cousin of Middle Eastern Baklava. In the historic royal Rajput courts, these sweets were considered so luxurious that they were sometimes wrapped entirely in pure edible gold foil.',
      qrData: 'shutterfly://sweets/s3',
      isVegetarian: true,
      allergens: ['Dairy', 'Gluten', 'Nuts'],
      calories: '~200 kcal per piece',
    ),
    SweetModel(
      id: 's4',
      name: 'Mini Samosa',
      origin: 'Middle East (arrived in India 13th–14th century)',
      emoji: '🔺',
      description:
          'A savory, deep-fried triangular pastry pocket. These mini versions are stuffed with a spiced, dry mixture of lentils (dal) and dry fruits, allowing them to stay exceptionally crisp for days.',
      ingredients:
          'Maida (all-purpose flour), lentils (dal), dry fruits, spices, oil',
      funFact:
          'The iconic triangular shape was deliberately modeled after the Pyramids of Central Asia and Egypt. The original 10th-century recipes were entirely meat-based; the vegetarian lentil and potato fillings are purely Indian innovations.',
      qrData: 'shutterfly://sweets/s4',
      isVegetarian: true,
      allergens: ['Gluten'],
      calories: '~80 kcal per piece',
    ),
    SweetModel(
      id: 's5',
      name: 'Murkul (Murukku)',
      origin: 'Tamil Nadu, South India',
      emoji: '🌀',
      description:
          'A highly addictive, crunchy savory snack made from a dough of rice flour and urad dal (black gram). The dough is pressed through a mold into hot oil to form its distinct coiled shape.',
      ingredients:
          'Rice flour, urad dal (black gram), sesame seeds, cumin, butter, salt, oil',
      funFact:
          'The word Murukku literally translates to "twisted" in Tamil. In traditional South Indian households, frying the first batch of Murukku officially signals the start of a major festival or celebration.',
      qrData: 'shutterfly://sweets/s5',
      isVegetarian: true,
      allergens: ['Lentils'],
      calories: '~120 kcal per serving',
    ),
    SweetModel(
      id: 's6',
      name: 'Appalu',
      origin: 'Andhra Pradesh & Telangana, South India',
      emoji: '🫓',
      description:
          'Traditional, flat, deep-fried sweet discs made from rice flour and jaggery (unrefined cane sugar). Crisp and caramelized on the outside, but slightly soft and chewy on the inside.',
      ingredients:
          'Rice flour, jaggery, sesame seeds, coconut, cardamom, oil',
      funFact:
          'Appalu are considered incredibly pure and are one of the most prominent items made as prasadam (sacred food offering to deities) in South Indian temples, especially during harvest festivals like Makara Sankranti.',
      qrData: 'shutterfly://sweets/s6',
      isVegetarian: true,
      allergens: [],
      calories: '~150 kcal per piece',
    ),
  ];

  static SweetModel? findById(String id) {
    try {
      return sweets.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static SweetModel? findByQrData(String qrData) {
    try {
      return sweets.firstWhere((s) => s.qrData == qrData);
    } catch (_) {
      return null;
    }
  }
}