// lib/models/recipe.dart
class Recipe {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  bool isBookmarked;
  List<Ingredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isBookmarked = false,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['recipeId'] ?? json['id'] ?? 0,
      name: json['recipeName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl:
          json['image_url'] ??
          json['imageUrl'] ??
          'https://via.placeholder.com/150',
      isBookmarked: json['isBookmarked'] ?? false,
      ingredients:
          (json['ingredients'] as List?)
              ?.map((ing) => Ingredient.fromJson(ing))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipeId': id,
      'recipeName': name,
      'description': description,
      'image_url': imageUrl,
      'isBookmarked': isBookmarked,
    };
  }
}

class Ingredient {
  final int id;
  final int recipeId;
  final String name;
  final String quantity;
  final String unit;

  Ingredient({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['ingredientId'] ?? json['id'] ?? 0,
      recipeId: json['recipeId'] ?? 0,
      name: json['ingredientName'] ?? '',
      quantity: json['quantity']?.toString() ?? '0',
      unit: json['unit'] ?? '',
    );
  }
}

class Step {
  final int id;
  final int recipeId;
  final int number;
  final String description;

  Step({
    required this.id,
    required this.recipeId,
    required this.number,
    required this.description,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      id: json['stepId'] ?? json['id'] ?? 0,
      recipeId: json['recipeId'] ?? 0,
      number: json['stepNumber'] ?? json['number'] ?? 0,
      description: json['stepDescription'] ?? json['description'] ?? '',
    );
  }
}

class RecipeDetails {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Step> steps;

  // Add getters to access Recipe properties directly from RecipeDetails
  int get id => recipe.id;
  String get name => recipe.name;
  String get description => recipe.description;
  String get imageUrl => recipe.imageUrl;
  bool get isBookmarked => recipe.isBookmarked;
  set isBookmarked(bool value) => recipe.isBookmarked = value;

  RecipeDetails({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    // Handle potential null values in the lists
    final ingredientsList = json['ingredients'] as List? ?? [];
    final stepsList = json['steps'] as List? ?? [];

    return RecipeDetails(
      recipe: Recipe.fromJson(json['recipe']),
      ingredients: ingredientsList.map((i) => Ingredient.fromJson(i)).toList(),
      steps: stepsList.map((s) => Step.fromJson(s)).toList(),
    );
  }
}
