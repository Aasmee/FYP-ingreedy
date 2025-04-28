import 'package:flutter/material.dart';
import 'package:ingreedy_app/models/recipe_model.dart';
import 'package:ingreedy_app/screens/Recipe/recipe_details.dart';
import 'package:ingreedy_app/services/recipe_service.dart';

class ScanResultsPage extends StatefulWidget {
  final String extractedText;

  const ScanResultsPage({super.key, required this.extractedText});

  @override
  State<ScanResultsPage> createState() => _ScanResultsPageState();
}

class _ScanResultsPageState extends State<ScanResultsPage> {
  late Future<List<Recipe>> _matchedRecipesFuture;

  @override
  void initState() {
    super.initState();
    _matchedRecipesFuture = _findMatchingRecipes(widget.extractedText);
  }

  Future<List<Recipe>> _findMatchingRecipes(String text) async {
    // Split the text into individual words or phrases
    final keywords =
        text
            .split(RegExp(r'[,.\s\n]+'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    // Create a map to track match scores
    final Map<int, int> recipeScores = {};
    final Map<int, Recipe> recipeMap =
        {}; // Store recipe objects by ID to avoid duplicate fetches

    // Process each keyword
    for (final keyword in keywords) {
      // Search for recipes matching this keyword
      try {
        final matchingRecipesByName = await RecipeService.searchRecipes(
          keyword,
        );
        // final matchingRecipesByIngredient =
        //     await RecipeService.searchRecipesByIngredient(keyword);

        // Increment score for each matching recipe
        for (final recipe in [
          ...matchingRecipesByName,
          //...matchingRecipesByIngredient,
        ]) {
          recipeScores[recipe.id] = (recipeScores[recipe.id] ?? 0) + 1;
        }
      } catch (e) {
        print('Error searching for "$keyword": $e');
      }
    }

    // If no matches found, return empty list
    if (recipeScores.isEmpty) {
      return [];
    }

    // Convert to list and sort by score
    final List<Recipe> allMatchedRecipes = recipeMap.values.toList();
    allMatchedRecipes.sort(
      (a, b) => (recipeScores[b.id] ?? 0).compareTo(recipeScores[a.id] ?? 0),
    );

    return allMatchedRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Scan Results'),
      ),
      body: Column(
        children: [
          // Show the scanned text
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Text:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.extractedText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Show matched recipes
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _matchedRecipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No matching recipes found',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                final recipes = snapshot.data!;
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            recipe.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, error, _) => Container(
                                  width: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                        title: Text(
                          recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          recipe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      RecipeDetailsPage(recipeId: recipe.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
