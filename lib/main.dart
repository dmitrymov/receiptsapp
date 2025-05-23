import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';

final Map<String, IconData> categoryIcons = {
  'groceries': Icons.local_grocery_store,
  'dining': Icons.restaurant,
  'shopping': Icons.shopping_cart,
  'other': Icons.category,
};

String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}

void main() {
  // Example usage of Recipe class
  final recipe1 = Recipe(
    id: '1',
    name: 'Spaghetti Carbonara',
    instructions: "Cook pasta. Fry pancetta. Mix eggs and cheese. Combine all.",
    category: 'Groceries',
    ingredients: ['Spaghetti', 'Pancetta', 'Eggs', 'Cheese'],
  );

  final recipe2 = Recipe(
    id: '2',
    name: 'Chicken Stir-Fry',
    instructions: "Cut chicken. Stir-fry with vegetables. Add sauce.",
    category: 'Dining',
    ingredients: ['Chicken', 'Vegetables', 'Soy Sauce', 'Rice'],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final List<String> ingredients;
  final String instructions;
  final String category;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.join(','),
      'instructions': instructions,
      'category': category,
    };
  }

  static Recipe fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      ingredients: map['ingredients'].split(','),
      instructions: map['instructions'],
      category: map['category'],
    );
  }

  @override
  String toString() {
    return 'Recipe{id: $id, name: $name, ingredients: $ingredients, instructions: $instructions, category: $category}';
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], name: map['name']);
  }
}

class CategoriesPage extends StatefulWidget {
  final List<Recipe> recipes;
  final List<Category> categories;

  const CategoriesPage({
    super.key,
    required this.categories,
    required this.recipes,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return ListTile(
            title: Text(category.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RecipesByCategoryPage(
                        category: category,
                        recipes: widget.recipes,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipesByCategoryPage extends StatelessWidget {
  final Category category;
  final List<Recipe> recipes;
  const RecipesByCategoryPage({
    super.key,
    required this.category,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    final filteredRecipes =
        recipes.where((recipe) => recipe.category == category.id).toList();
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: ListView.builder(
        itemCount: filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = filteredRecipes[index];
          final categoryIcon = categoryIcons[recipe.category] ?? Icons.category;
          return ListTile(
            leading: Icon(categoryIcon, size: 30),
            title: Text(recipe.name),
            subtitle: Text(recipe.category),
          );
        },
      ),
    );
  }
}

class AddEditRecipePage extends StatefulWidget {
  final Recipe? recipe;
  final List<Category> categories;

  const AddEditRecipePage({super.key, this.recipe, required this.categories});

  @override
  _AddEditRecipePageState createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _instructionsController = TextEditingController();
  String? _selectedCategoryId;
  final newCategoryNameController = TextEditingController();
  void _addNewCategory(String newCategoryName) {
    if (newCategoryName.isNotEmpty) {
      final newCategory = Category(
        id: newCategoryName.toLowerCase(),
        name: newCategoryName,
      );
      setState(() {
        final otherCategory = widget.categories.firstWhere(
          (cat) => cat.id == 'other',
        );
        widget.categories.remove(otherCategory);
        widget.categories.add(newCategory);
        widget.categories.add(otherCategory);
        _selectedCategoryId = newCategory.id;
      });
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Category'),
          content: TextField(controller: newCategoryNameController),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed:
                  () => {
                    _addNewCategory(newCategoryNameController.text),
                    newCategoryNameController.clear(),
                    Navigator.pop(context),
                  },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _ingredientsController.text = widget.recipe!.ingredients.join(', ');
      _instructionsController.text = widget.recipe!.instructions;
      _selectedCategoryId = widget.recipe!.category;
    } else {}
    _selectedCategoryId = widget.categories.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Add New Recipe' : 'Edit Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),

        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Recipe Name',
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  hintText: 'Enter Ingredients (comma separated)',
                  labelText: 'Ingredients',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40, // Adjust the height as needed
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      widget.categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(category.name),
                            selected: _selectedCategoryId == category.id,
                            onSelected: (bool selected) {
                              if (category.id == 'other' && selected) {
                                _showAddCategoryDialog(context);
                                setState(() {
                                  _selectedCategoryId = null;
                                });
                                return;
                              }

                              setState(() {
                                _selectedCategoryId =
                                    selected ? category.id : null;
                              });
                            },
                            selectedColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        );
                      }).toList(),
                ),
              ),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  hintText: 'Enter Recipe Instructions',
                  labelText: 'Instructions',
                ),
                maxLines: null,
                minLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final recipe = Recipe(
                      id: widget.recipe?.id ?? const Uuid().v4(),
                      name: _nameController.text,
                      category: _selectedCategoryId!,
                      ingredients:
                          _ingredientsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList(),
                      instructions: _instructionsController.text,
                    );
                    Navigator.pop(context, recipe);
                  }
                },
                child: Text(
                  widget.recipe != null ? 'Update Recipe' : 'Create Recipe',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Recipe> _recipes = [];
  final List<Category> _categories = [Category(id: 'other', name: 'Other')];
  late DatabaseHelper dbHelper;

  void _addCategory(String newCategoryName) {
    if (newCategoryName.isNotEmpty) {
      final newCategory = Category(
        id: newCategoryName.toLowerCase().replaceAll(' ', '_'),
        name: newCategoryName,
      );
      final otherCategory = _categories.firstWhere((cat) => cat.id == 'other');
      _categories.remove(otherCategory);
      _categories.add(newCategory);
      _categories.add(otherCategory);
      setState(() {});
    }
  }

  void _addOrEditRecipe(Recipe? recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddEditRecipePage(recipe: recipe, categories: _categories),
      ),
    );
    final db = await dbHelper.database;
    if (result is Recipe) {
      await db.insert('recipes', result.toMap());
    }
    if (result is Recipe) {
      setState(() {
        if (recipe == null) {
          _recipes.add(result);
        } else {
          db.update(
            'recipes',
            result.toMap(),
            where: 'id = ?',
            whereArgs: [result.id],
          );
          final index = _recipes.indexOf(recipe);
          _recipes[index] = result;
        }
      });
    }
  }

  void _navigateToCategoriesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                CategoriesPage(categories: _categories, recipes: _recipes),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _loadCategories();
    _loadRecipes();
  }

  Future<void> _loadCategories() async {
    final categories = await dbHelper.getCategories();
    setState(() {
      _categories.addAll(categories.map((e) => Category.fromMap(e)).toList());
      if (_categories.isEmpty) {
        _categories.add(Category(id: 'salad', name: 'Salad'));

        _categories.add(Category(id: 'soup', name: 'Soup'));
        _categories.add(Category(id: 'dessert', name: 'Dessert'));
        _categories.add(Category(id: 'other', name: 'Other'));
        _categories.add(Category(id: 'other', name: 'Other'));
      }
    });
  }

  Future<void> _loadRecipes() async {
    final recipesFromDb = await dbHelper.getRecipes();
    setState(() {
      _recipes = recipesFromDb.map((e) => Recipe.fromMap(e)).toList();
      if (_recipes.isEmpty) {
        _recipes.add(
          Recipe(
            id: '1',
            name: 'Spaghetti Carbonara',
            instructions:
                "Cook pasta. Fry pancetta. Mix eggs and cheese. Combine all.",
            category: 'groceries',
            ingredients: ['Spaghetti', 'Pancetta', 'Eggs', 'Cheese'],
          ),
        );
        _recipes.add(
          Recipe(
            id: '2',
            name: 'Chicken Stir-Fry',
            instructions: "Cut chicken. Stir-fry with vegetables. Add sauce.",
            category: 'dining',
            ingredients: ['Chicken', 'Vegetables', 'Soy Sauce', 'Rice'],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Recips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _navigateToCategoriesPage,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          final categoryIcon = categoryIcons[recipe.category] ?? Icons.category;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(categoryIcon, size: 30.0),
                title: Text(recipe.name, style: const TextStyle(fontSize: 18)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Text(recipe.category)],
                  ),
                ),
                onTap: () => _addOrEditRecipe(recipe),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditRecipe(null),
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add),
      ),
    );
  }
}
