import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:intl/intl.dart';

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

  @override
  String toString() {
    return 'Recipe{id: $id, name: $name, ingredients: $ingredients, instructions: $instructions, category: $category}';
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class CategoriesPage extends StatelessWidget {
  final List<Category> categories;

  const CategoriesPage({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(categories[index].name));
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

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _ingredientsController.text = widget.recipe!.ingredients.join(', ');
      _instructionsController.text = widget.recipe!.instructions;
      _selectedCategoryId = widget.recipe!.category;
    } else {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Add New Recipe' : 'Edit Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                
                controller: _nameController,
                decoration: const InputDecoration(
                    hintText: 'Enter Recipe Name',
                    labelText: 'Name'),
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Category'),
                value: _selectedCategoryId,
                
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                },
                items:
                    widget.categories.map<DropdownMenuItem<String>>((
                      Category category,
                    ) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
              ),
              TextFormField(
                controller: _instructionsController,
                 decoration: const InputDecoration(
                  hintText: 'Enter Recipe Instructions',
                  labelText: 'Instructions'),
                maxLines: null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
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
                child: const Text('Create Recipe', style: TextStyle(fontSize: 18)),
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
  final List<Category> _categories = [
    Category(id: 'groceries', name: 'Groceries'),
    Category(id: 'dining', name: 'Dining'),
    Category(id: 'shopping', name: 'Shopping'),
    Category(id: 'other', name: 'Other'),
  ];

  void _addOrEditRecipe(Recipe? recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddEditRecipePage(recipe: recipe, categories: _categories),
      ),
    );
    if (result is Recipe) {
      setState(() {
        if (recipe == null) {
          _recipes.add(result);
        } else {
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
        builder: (context) => CategoriesPage(categories: _categories),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _recipes = [
      Recipe(
        id: '1',
        name: 'Spaghetti Carbonara',
        instructions:
            "Cook pasta. Fry pancetta. Mix eggs and cheese. Combine all.",
        category: 'groceries',
        ingredients: ['Spaghetti', 'Pancetta', 'Eggs', 'Cheese'],
      ),
      Recipe(
        id: '2',
        name: 'Chicken Stir-Fry',
        instructions: "Cut chicken. Stir-fry with vegetables. Add sauce.",
        category: 'dining',
        ingredients: ['Chicken', 'Vegetables', 'Soy Sauce', 'Rice'],
      ),
    ];
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
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  /*void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something hase
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }*/
}
