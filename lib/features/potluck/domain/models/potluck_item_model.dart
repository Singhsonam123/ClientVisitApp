import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum FoodCategory {
  salad,
  welcomeSnack,
  welcomeSweet,
  starter,
  bread,
  rice,
  mainCourse,
  accompaniment,
  dessert,
  finish,
}

extension FoodCategoryX on FoodCategory {
  String get label {
    switch (this) {
      case FoodCategory.salad:
        return 'Salad';
      case FoodCategory.welcomeSnack:
        return 'Welcome Snack';
      case FoodCategory.welcomeSweet:
        return 'Welcome Sweet';
      case FoodCategory.starter:
        return 'Starter';
      case FoodCategory.bread:
        return 'Bread';
      case FoodCategory.rice:
        return 'Rice';
      case FoodCategory.mainCourse:
        return 'Main Course';
      case FoodCategory.accompaniment:
        return 'Accompaniment';
      case FoodCategory.dessert:
        return 'Dessert';
      case FoodCategory.finish:
        return 'Finish';
    }
  }

  IconData get icon {
    switch (this) {
      case FoodCategory.salad:
        return Icons.eco_rounded;
      case FoodCategory.welcomeSnack:
        return Icons.fastfood_rounded;
      case FoodCategory.welcomeSweet:
        return Icons.star_rounded;
      case FoodCategory.starter:
        return Icons.restaurant_rounded;
      case FoodCategory.bread:
        return Icons.grain_rounded;
      case FoodCategory.rice:
        return Icons.rice_bowl_rounded;
      case FoodCategory.mainCourse:
        return Icons.set_meal_rounded;
      case FoodCategory.accompaniment:
        return Icons.add_circle_outline_rounded;
      case FoodCategory.dessert:
        return Icons.cake_rounded;
      case FoodCategory.finish:
        return Icons.flag_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FoodCategory.salad:
        return const Color(0xFF33691E);
      case FoodCategory.welcomeSnack:
        return const Color(0xFFE65100);
      case FoodCategory.welcomeSweet:
        return const Color(0xFFFF8F00);
      case FoodCategory.starter:
        return const Color(0xFFC62828);
      case FoodCategory.bread:
        return const Color(0xFF5D4037);
      case FoodCategory.rice:
        return const Color(0xFF558B2F);
      case FoodCategory.mainCourse:
        return const Color(0xFFBF360C);
      case FoodCategory.accompaniment:
        return const Color(0xFF546E7A);
      case FoodCategory.dessert:
        return const Color(0xFFAD1457);
      case FoodCategory.finish:
        return const Color(0xFF6A1B9A);
    }
  }

  Color get bgColor {
    switch (this) {
      case FoodCategory.salad:
        return const Color(0xFFF9FBE7);
      case FoodCategory.welcomeSnack:
        return const Color(0xFFFBE9E7);
      case FoodCategory.welcomeSweet:
        return const Color(0xFFFFF8E1);
      case FoodCategory.starter:
        return const Color(0xFFFFEBEE);
      case FoodCategory.bread:
        return const Color(0xFFEFEBE9);
      case FoodCategory.rice:
        return const Color(0xFFF1F8E9);
      case FoodCategory.mainCourse:
        return const Color(0xFFFBE9E7);
      case FoodCategory.accompaniment:
        return const Color(0xFFECEFF1);
      case FoodCategory.dessert:
        return const Color(0xFFFCE4EC);
      case FoodCategory.finish:
        return const Color(0xFFF3E5F5);
    }
  }
}

class PotluckItem extends Equatable {
  final String id;
  final String dishName;
  final String bringBy;
  final String department;
  final FoodCategory category;
  final String description;
  final String origin;
  final String flavourProfile;
  final String? imagePath;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final String servings;
  final List<String> allergens;

  const PotluckItem({
    required this.id,
    required this.dishName,
    required this.bringBy,
    required this.department,
    required this.category,
    required this.description,
    this.origin = '',
    this.flavourProfile = '',
    this.imagePath,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.servings,
    this.allergens = const [],
  });

  @override
  List<Object?> get props => [id, dishName, bringBy];
}

/// Static potluck menu data.
class PotluckData {
  static const List<PotluckItem> items = [
    // ── Salad ──────────────────────────────────────────────────────────────
    PotluckItem(
      id: 'p1',
      dishName: 'Mixed Veg Salad',
      bringBy: 'Prajna',
      department: 'Salad',
      category: FoodCategory.salad,
      origin: 'Beetroot, Carrot, Cucumber & Onion',
      flavourProfile: 'Healthy, Colorful, Delicious',
      description: 'Healthy, Colorful, Delicious',
      imagePath: 'assets/images/Mixed Veg Salad.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '4 Kg',
    ),

    // ── Welcome Snack ───────────────────────────────────────────────────────
    PotluckItem(
      id: 'p2',
      dishName: 'Garelu (Medu Vada)',
      bringBy: 'Sayyed Sameer',
      department: 'Welcome Snack',
      category: FoodCategory.welcomeSnack,
      origin: 'Telugu States',
      flavourProfile: 'Crispy, Peppery, Soft',
      description: 'Traditional urad dal fritters fried until golden and crisp.',
      imagePath: 'assets/images/Garelu.png',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '60 Nos',
    ),
    PotluckItem(
      id: 'p3',
      dishName: 'Tomato Chutney (Dip)',
      bringBy: 'Divya',
      department: 'Welcome Snack',
      category: FoodCategory.welcomeSnack,
      origin: 'South India',
      flavourProfile: 'Tangy, Spicy, Garlic',
      description: 'Fresh tomato-onion chutney tempered with mustard and curry leaves.',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '1 L',
    ),

    // ── Welcome Sweet ───────────────────────────────────────────────────────
    PotluckItem(
      id: 'p4',
      dishName: 'Palathalikalu',
      bringBy: 'Kiran',
      department: 'Welcome Sweet',
      category: FoodCategory.welcomeSweet,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Milky, Jaggery, Cardamom',
      description: 'Rice-flour dumplings simmered in jaggery-flavoured milk.',
      imagePath: 'assets/images/Palathalikalu.png',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '60 Nos',
    ),
    PotluckItem(
      id: 'p5',
      dishName: 'Poornalu (Poornam Boorelu)',
      bringBy: '\u2013',
      department: 'Welcome Sweet',
      category: FoodCategory.welcomeSweet,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Sweet, Jaggery, Cardamom',
      description: 'Chana dal and coconut-jaggery filling coated with lentil batter and deep-fried golden.',
      imagePath: 'assets/images/Poornam Boorelu.png',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '\u2013',
    ),

    // ── Starter ─────────────────────────────────────────────────────────────
    PotluckItem(
      id: 'p6',
      dishName: 'Crispy Corn',
      bringBy: 'Shravan',
      department: 'Starter',
      category: FoodCategory.starter,
      origin: 'Indo-Chinese',
      flavourProfile: 'Sweet, Crispy, Mild Spice',
      description: 'Fried corn kernels tossed in chilli-garlic seasoning.',
      imagePath: 'assets/images/Crispy-Corn-.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: false,
      servings: '3 Kg',
    ),
    PotluckItem(
      id: 'p7',
      dishName: 'Chilli Mushroom',
      bringBy: 'Shravan',
      department: 'Starter',
      category: FoodCategory.starter,
      origin: 'Indo-Chinese',
      flavourProfile: 'Spicy, Umami, Garlicky',
      description: 'Mushrooms wok-tossed in chilli-soy glaze.',
      imagePath: 'assets/images/Chilli-mushroom.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: false,
      servings: '3 Kg',
    ),
    PotluckItem(
      id: 'p8',
      dishName: 'Hara Bhara Kebab',
      bringBy: 'Kiran',
      department: 'Starter',
      category: FoodCategory.starter,
      origin: 'North India',
      flavourProfile: 'Herby, Earthy, Mild Spice',
      description: 'Spinach, peas and potato patties grilled to perfection.',
      imagePath: 'assets/images/Hara Bhara Kebab.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: false,
      servings: '60 Nos',
    ),
    PotluckItem(
      id: 'p9',
      dishName: 'Paneer Tikka',
      bringBy: 'Srikanth J',
      department: 'Starter',
      category: FoodCategory.starter,
      origin: 'Punjab',
      flavourProfile: 'Smoky, Tangy, Spicy',
      description: 'Marinated paneer cubes charred in tandoor style.',
      imagePath: 'assets/images/Paneer Tikka.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '60 Pieces',
    ),

    // ── Bread ───────────────────────────────────────────────────────────────
    PotluckItem(
      id: 'p10',
      dishName: 'Butter Naan',
      bringBy: 'Bhaskar T',
      department: 'Bread',
      category: FoodCategory.bread,
      origin: 'Punjab',
      flavourProfile: 'Buttery, Soft',
      description: 'Tandoor-baked naan finished with melted butter.',
      imagePath: 'assets/images/Butter Naan.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '30 Half pieces',
    ),
    PotluckItem(
      id: 'p11',
      dishName: 'Rumali Roti',
      bringBy: 'Shravan',
      department: 'Bread',
      category: FoodCategory.bread,
      origin: 'Hyderabad / Awadh',
      flavourProfile: 'Thin, Soft, Light',
      description: 'Handkerchief-thin roti traditionally cooked on an inverted tawa.',
      imagePath: 'assets/images/Rumali Roti.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '30 Nos',
    ),

    // ── Rice ────────────────────────────────────────────────────────────────
    PotluckItem(
      id: 'p12',
      dishName: 'Pulihora',
      bringBy: 'Bhaskar P',
      department: 'Rice',
      category: FoodCategory.rice,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Tangy, Tamarind',
      description: 'Traditional festival rice with tamarind seasoning.',
      imagePath: 'assets/images/Pulihora.avif',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '1 Kg',
    ),
    PotluckItem(
      id: 'p13',
      dishName: 'Veg Biryani',
      bringBy: 'Aruna Kumari',
      department: 'Rice',
      category: FoodCategory.rice,
      origin: 'Hyderabad',
      flavourProfile: 'Fragrant, Layered',
      description: 'Rice with vegetables and aromatic spices.',
      imagePath: 'assets/images/Veg Biryani.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: true,
      servings: '2.5 Kg',
    ),
    PotluckItem(
      id: 'p14',
      dishName: 'Bagara Rice',
      bringBy: 'Rama / Spandana',
      department: 'Rice',
      category: FoodCategory.rice,
      origin: 'Telangana',
      flavourProfile: 'Aromatic, Mild Spice',
      description: 'Rice flavoured with whole spices and herbs.',
      imagePath: 'assets/images/Bagara-Rice.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '2.5 Kg',
    ),
    PotluckItem(
      id: 'p15',
      dishName: 'Steamed Rice',
      bringBy: 'Padmaja',
      department: 'Rice',
      category: FoodCategory.rice,
      origin: 'Pan India',
      flavourProfile: 'Neutral, Fluffy',
      description: 'Freshly steamed rice served with curries and dal.',
      imagePath: 'assets/images/Steamed Rice.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '3 Kg',
    ),
    PotluckItem(
      id: 'p16',
      dishName: 'Curd Rice',
      bringBy: 'Vikas',
      department: 'Rice',
      category: FoodCategory.rice,
      origin: 'South India',
      flavourProfile: 'Cool, Mild',
      description: 'Tempered yogurt rice for a soothing finish.',
      imagePath: 'assets/images/Curd Rice.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: true,
      servings: '2 Kg',
    ),

    // ── Main Course ─────────────────────────────────────────────────────────
    PotluckItem(
      id: 'p17',
      dishName: 'Paneer Butter Masala',
      bringBy: 'Aruna Kumari',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Punjab',
      flavourProfile: 'Rich, Creamy, Mild Spice',
      description: 'Paneer cubes in buttery tomato-cashew gravy.',
      imagePath: 'assets/images/Paneer-butter-masala.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: true,
      servings: '2 Kg',
    ),
    PotluckItem(
      id: 'p18',
      dishName: 'Malai Kofta',
      bringBy: 'Udaya',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Mughlai',
      flavourProfile: 'Creamy, Mildly Sweet',
      description: 'Paneer-potato dumplings in a luxurious cashew gravy.',
      imagePath: 'assets/images/Malai Kofta.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '5 Litres',
    ),
    PotluckItem(
      id: 'p19',
      dishName: 'Gutti Vankaya Fry',
      bringBy: 'Ram Prasad',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Spicy, Nutty, Earthy',
      description: 'Stuffed baby brinjals shallow-fried with Andhra masala.',
      imagePath: 'assets/images/Gutti Vankaya.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '3 Kg',
    ),
    PotluckItem(
      id: 'p20',
      dishName: 'Beerakaya Senagapappu',
      bringBy: 'Naidu',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Mild, Nutty',
      description: 'Ridge gourd cooked with chana dal and spices.',
      imagePath: 'assets/images/Beerakaya Senagapappu.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '3 Kg',
    ),
    PotluckItem(
      id: 'p21',
      dishName: 'Tomato Pappu',
      bringBy: 'Lakshmi Narayana',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Tangy, Comforting',
      description: 'Toor dal cooked with tomatoes and finished with an aromatic tadka.',
      imagePath: 'assets/images/Tomato Pappu.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '1.5 Litres',
    ),
    PotluckItem(
      id: 'p22',
      dishName: 'Sambar',
      bringBy: 'Bhargavi',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Tamil Nadu',
      flavourProfile: 'Tangy, Lentil Rich',
      description: 'Traditional vegetable and lentil stew.',
      imagePath: 'assets/images/Sambar.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '1.5 Litres',
    ),
    PotluckItem(
      id: 'p23',
      dishName: 'Pachi Pulusu',
      bringBy: 'Kiran',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Tangy, Refreshing',
      description: 'Raw tamarind broth seasoned with onions and green chillies.',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '1.5 Litres',
    ),
    PotluckItem(
      id: 'p24',
      dishName: 'Ulavacharu with Cream',
      bringBy: 'Rajesh Ganta',
      department: 'Main Course',
      category: FoodCategory.mainCourse,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Earthy, Rich',
      description: 'Slow-cooked horse gram soup finished with fresh cream.',
      imagePath: 'assets/images/Ulavacharu with Cream.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: true,
      servings: '1.5 Litres',
    ),

    // ── Accompaniment ───────────────────────────────────────────────────────
    PotluckItem(
      id: 'p25',
      dishName: 'Appadam',
      bringBy: 'Uma Shankar',
      department: 'Accompaniment',
      category: FoodCategory.accompaniment,
      origin: 'South India',
      flavourProfile: 'Crispy, Salty',
      description: 'Thin roasted or fried lentil wafers.',
      imagePath: 'assets/images/Appadam.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '60 Nos',
    ),
    PotluckItem(
      id: 'p26',
      dishName: 'Avakaya Pickle',
      bringBy: 'Charishma',
      department: 'Accompaniment',
      category: FoodCategory.accompaniment,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Spicy, Sour',
      description: 'Signature Andhra mango pickle.',
      imagePath: 'assets/images/Avakaya Pickle.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '250 g',
    ),
    PotluckItem(
      id: 'p27',
      dishName: 'Dosakaya Pachadi',
      bringBy: 'Divya',
      department: 'Accompaniment',
      category: FoodCategory.accompaniment,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Tangy, Fresh',
      description: 'Yellow cucumber chutney with coconut and spices.',
      imagePath: 'assets/images/Dosakaya Pachadi.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '\u2013',
    ),
    PotluckItem(
      id: 'p28',
      dishName: 'Ghee',
      bringBy: 'Rakesh Rai',
      department: 'Accompaniment',
      category: FoodCategory.accompaniment,
      origin: 'Indian Subcontinent',
      flavourProfile: 'Rich, Aromatic',
      description: 'Clarified butter served with rice and dal.',
      imagePath: 'assets/images/Ghee.avif',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: true,
      servings: '500 g',
    ),
    PotluckItem(
      id: 'p29',
      dishName: 'Vadiyalu',
      bringBy: 'Uma Shankar',
      department: 'Accompaniment',
      category: FoodCategory.accompaniment,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Crunchy, Savoury',
      description: 'Crunchy fritters fried fresh.',
      imagePath: 'assets/images/Vadiyalu.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '60 Nos',
    ),
    PotluckItem(
      id: 'p30',
      dishName: 'Dosakaya Pachadi',
      bringBy: '\u2013',
      department: 'Accompaniment',
      category: FoodCategory.accompaniment,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Refreshing, Tangy',
      description: 'Traditional Andhra-style chutney made with yellow cucumber.',
      imagePath: 'assets/images/Dosakaya Pachadi.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '\u2013',
    ),
    PotluckItem(
      id: 'p31',
      dishName: 'Majjinga Mirapakayalu',
      bringBy: 'Harish',
      department: 'Accompaniment',
      category: FoodCategory.accompaniment,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Tangy, Spicy',
      description: 'Curd-marinated sun-dried chillies fried crisp.',
      imagePath: 'assets/images/Majjinga Mirapakayalu.webp',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: true,
      servings: '60 Nos',
    ),

    // ── Dessert ─────────────────────────────────────────────────────────────
    PotluckItem(
      id: 'p32',
      dishName: 'Fruit Custard',
      bringBy: 'Divya',
      department: 'Dessert',
      category: FoodCategory.dessert,
      origin: 'Anglo-Indian',
      flavourProfile: 'Creamy, Chilled',
      description: 'Seasonal fruits folded into vanilla custard.',
      imagePath: 'assets/images/Fruit Custard.webp',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: true,
      servings: '5 Litres',
    ),
    PotluckItem(
      id: 'p33',
      dishName: 'Gulab Jamun',
      bringBy: 'Srinivas Varada',
      department: 'Dessert',
      category: FoodCategory.dessert,
      origin: 'Mughlai',
      flavourProfile: 'Syrupy, Cardamom',
      description: 'Soft milk-solid dumplings soaked in sugar syrup.',
      imagePath: 'assets/images/Gulab Jamun.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '60 Nos',
    ),
    PotluckItem(
      id: 'p34',
      dishName: 'Sheer Khurma',
      bringBy: 'Sravani',
      department: 'Dessert',
      category: FoodCategory.dessert,
      origin: 'Hyderabad',
      flavourProfile: 'Milky, Nutty',
      description: 'Traditional vermicelli dessert with dates and nuts.',
      imagePath: 'assets/images/Sheer Khurma.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '4 Litres',
    ),

    // ── Finish ──────────────────────────────────────────────────────────────
    PotluckItem(
      id: 'p35',
      dishName: 'Banana',
      bringBy: 'Venkatesh',
      department: 'Finish',
      category: FoodCategory.finish,
      origin: 'Traditional',
      flavourProfile: 'Sweet, Cooling',
      description: 'Natural palate cleanser and digestive aid.',
      imagePath: 'assets/images/Banana.jpg',
      isVegetarian: true,
      isVegan: true,
      isGlutenFree: true,
      servings: '40 Nos',
    ),
    PotluckItem(
      id: 'p36',
      dishName: 'Sweet Killi',
      bringBy: 'Uday / Sajal',
      department: 'Finish',
      category: FoodCategory.finish,
      origin: 'Andhra Pradesh',
      flavourProfile: 'Sweet, Crunchy',
      description: 'Traditional after-meal Andhra confection.',
      imagePath: 'assets/images/Sweet Killi.jpg',
      isVegetarian: true,
      isVegan: false,
      isGlutenFree: false,
      servings: '60 Nos',
    ),
  ];

  static List<FoodCategory> get categories =>
      FoodCategory.values.where((c) => items.any((i) => i.category == c)).toList();

  static List<PotluckItem> itemsByCategory(FoodCategory? category) =>
      category == null ? items : items.where((i) => i.category == category).toList();
}