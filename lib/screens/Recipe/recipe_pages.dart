import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingreedy_app/models/recipe_model.dart';
import 'package:ingreedy_app/screens/Recipe/recipe_details.dart';
import 'package:ingreedy_app/screens/Recipe/scan_result.dart';
import 'package:ingreedy_app/services/recipe_service.dart';
import 'package:ingreedy_app/widgets/scan_icon.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  late Future<List<Recipe>> _recipesFuture;
  final TextEditingController _searchController = TextEditingController();
  File? _image;
  // final Set<int> _bookmarkedRecipes = {}; // Stores bookmarked recipe IDs
  List<Recipe> _filteredRecipes = []; // Stores search results
  List<String> _searchSuggestions =
      []; // Stores search suggestions for dropdown
  // bool _isLoadingBookmarks = false;
  final Set<int> _bookmarkedRecipes = {}; // Track bookmarked recipes

  Future<void> _pickAndProcessImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await _processImage(_image!);
    }
  }

  Future<void> _processImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    textRecognizer.close();

    final extractedText =
        recognizedText.text.isNotEmpty ? recognizedText.text : "No text found.";

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultsPage(extractedText: extractedText),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _recipesFuture = RecipeService.fetchRecipes();
    _loadSearchSuggestions();
  }

  // Load search suggestions based on recipe names
  Future<void> _loadSearchSuggestions() async {
    final recipes = await _recipesFuture;
    if (mounted) {
      setState(() {
        _searchSuggestions = recipes.map((recipe) => recipe.name).toList();
      });
    }
  }

  void _updateSearchSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
      });
      return;
    }

    _recipesFuture.then((recipes) {
      final suggestions =
          recipes
              .where(
                (recipe) =>
                    recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                    recipe.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .map((recipe) => recipe.name)
              .toList();

      if (mounted) {
        setState(() {
          _searchSuggestions = suggestions;
        });
      }
    });
  }

  void _searchRecipes(String query) async {
    final allRecipes = await _recipesFuture;
    final results =
        allRecipes
            .where(
              (recipe) =>
                  recipe.name.toLowerCase().contains(query.toLowerCase()) ||
                  recipe.description.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
    if (mounted) {
      setState(() {
        _filteredRecipes = results;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Recipes'),
        actions: [
          IconButton(
            onPressed: () async {
              await _pickAndProcessImage();
            },
            icon: ScanFrameIcon(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                _updateSearchSuggestions(textEditingValue.text);
                return _searchSuggestions.where(
                  (suggestion) => suggestion.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (String selection) {
                _searchController.text = selection;
                _searchRecipes(selection);
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // Use this controller to update search results when typing
                textEditingController.addListener(() {
                  _searchRecipes(textEditingController.text);
                });

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color.fromRGBO(238, 238, 238, 1),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          textEditingController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  textEditingController.clear();
                                  _searchRecipes('');
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Color.fromRGBO(238, 238, 238, 1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(238, 238, 238, 1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(238, 238, 238, 1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                      _searchRecipes(value);
                    },
                  ),
                );
              },
              optionsViewBuilder: (
                BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 16,
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option),
                              leading: const Icon(Icons.food_bank),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lightbulb),
                label: const Text("Surprise Me!"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _recipesFuture = RecipeService.fetchRecipes();
                });
                await _loadSearchSuggestions();
              },
              child: FutureBuilder<List<Recipe>>(
                future: _recipesFuture,
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
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _recipesFuture = RecipeService.fetchRecipes();
                              });
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recipes found',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }

                  final recipes =
                      _searchController.text.isNotEmpty
                          ? _filteredRecipes
                          : snapshot.data!;
                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.2),
                              blurRadius: 3,
                              spreadRadius: 1,
                              offset: Offset(-1, 1),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
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
                          trailing: IconButton(
                            icon: Icon(
                              _bookmarkedRecipes.contains(recipe.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color:
                                  _bookmarkedRecipes.contains(recipe.id)
                                      ? Colors.black
                                      : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_bookmarkedRecipes.contains(recipe.id)) {
                                  _bookmarkedRecipes.remove(recipe.id);
                                } else {
                                  _bookmarkedRecipes.add(recipe.id);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        RecipeDetailsPage(recipeId: recipe.id),
                              ),
                            ).then((_) {});
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
