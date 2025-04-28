// lib/services/recipe_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ingreedy_app/models/recipe_model.dart';
import '../constants.dart';

class RecipeService {
  // Fetch all recipes (basic info only)
  static Future<List<Recipe>> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/recipes'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> recipesData = data['recipes'];
          return recipesData.map((recipe) => Recipe.fromJson(recipe)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load recipes');
        }
      } else {
        throw Exception(
          'Failed to load recipes. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes: $e');
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  // Search recipes (basic info only)
  static Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/recipes/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> recipesData = data['recipes'];

          return recipesData.map((recipeJson) {
            final recipe = Recipe.fromJson(recipeJson);

            return recipe;
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to search recipes');
        }
      } else {
        throw Exception(
          'Failed to search recipes. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching recipes: $e');
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  // Fetch recipe details (ingredients + steps)
  static Future<RecipeDetails> fetchRecipeDetails(
    int recipeId, {
    String? userId,
  }) async {
    try {
      final url = '${ApiConfig.baseUrl}/api/recipes/$recipeId';
      if (kDebugMode) {
        print('Requesting URL: $url');
      }

      final response = await http.get(Uri.parse(url));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // Make sure recipe ID is an integer
          if (data['recipe']['recipeId'] == null) {
            throw Exception('Recipe ID is null in response');
          }

          // Create recipe details object
          final recipeDetails = RecipeDetails.fromJson(data);

          // If userId is provided, check if recipe is bookmarked
          if (userId != null) {
            await checkIfBookmarked(userId, recipeId)
                .then((isBookmarked) {
                  recipeDetails.isBookmarked = isBookmarked;
                })
                .catchError((e) {
                  // If checking fails, default to false
                  if (kDebugMode) {
                    print('Error checking bookmark status: $e');
                  }
                });
          }

          return recipeDetails;
        } else {
          throw Exception(data['message'] ?? 'Failed to load recipe details');
        }
      } else {
        throw Exception(
          'Failed to load recipe details. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipe details: $e');
      }
      throw Exception(
        'Network error: Unable to connect to server. Details: $e',
      );
    }
  }

  // Check if a recipe is bookmarked by a user
  static Future<bool> checkIfBookmarked(String userId, int recipeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/users/$userId/bookmarks/check/$recipeId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['isBookmarked'] ?? false;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking bookmark status: $e');
      }
      return false;
    }
  }

  // Get all bookmarked recipes for a user
  static Future<List<Recipe>> fetchBookmarkedRecipes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/bookmarks'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final List<dynamic> recipesData = data['bookmarkedRecipes'];
          return recipesData.map((recipe) => Recipe.fromJson(recipe)).toList();
        } else {
          throw Exception(
            data['message'] ?? 'Failed to load bookmarked recipes',
          );
        }
      } else {
        throw Exception(
          'Failed to load bookmarked recipes. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching bookmarked recipes: $e');
      }
      throw Exception('Network error: Unable to connect to server');
    }
  }

  // Toggle bookmark status - add or remove bookmark based on current status
  static Future<bool> toggleBookmark(
    String userId,
    RecipeDetails recipeDetails,
  ) async {
    try {
      if (recipeDetails.isBookmarked) {
        // If currently bookmarked, remove it
        await removeBookmark(userId, recipeDetails.id);
        return false; // Return new status (not bookmarked)
      } else {
        // If not bookmarked, add it
        await addBookmark(userId, recipeDetails);
        return true; // Return new status (bookmarked)
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling bookmark: $e');
      }
      // Re-throw to allow UI to handle the error
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  // Add a recipe to bookmarks
  static Future<void> addBookmark(
    String userId,
    RecipeDetails recipeDetails,
  ) async {
    try {
      final bookmarkData = {
        'recipeName': recipeDetails.name,
        'recipeImage': recipeDetails.imageUrl,
        'savedAt': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/bookmarks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'recipeId': recipeDetails.id,
          'bookmarkData': bookmarkData,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to add bookmark');
        }
      } else {
        throw Exception(
          'Failed to add bookmark. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding bookmark: $e');
      }
      throw Exception('Failed to add bookmark: $e');
    }
  }

  // Remove a recipe from bookmarks
  static Future<void> removeBookmark(String userId, int recipeId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/users/$userId/bookmarks/recipe/$recipeId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['success']) {
          throw Exception(data['message'] ?? 'Failed to remove bookmark');
        }
      } else {
        throw Exception(
          'Failed to remove bookmark. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing bookmark: $e');
      }
      throw Exception('Failed to remove bookmark: $e');
    }
  }
}
