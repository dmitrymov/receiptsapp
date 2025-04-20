import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  // Example usage of Receipt class
  final receipt1 = Receipt(
    id: '1',
    date: DateTime.now(),
    amount: 100.50,
    category: 'Groceries',
    items: ['Milk', 'Bread', 'Eggs'],
  );

  final receipt2 = Receipt(
    id: '2',
    date: DateTime.now(),
    amount: 50.00,
    category: 'Dining',
    items: ['Pizza', 'Drinks'],
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

class Receipt {
  final String id;
  final DateTime date;
  final double amount;
  final String category;
  final List<String> items;

  Receipt({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.items,
  });
  @override
  String toString() {
    return 'Receipt{id: $id, date: $date, amount: $amount, category: $category, items: $items}';
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

class AddEditReceiptPage extends StatefulWidget {
  final Receipt? receipt;
  final List<Category> categories;

  const AddEditReceiptPage({super.key, this.receipt, required this.categories});

  @override
  _AddEditReceiptPageState createState() => _AddEditReceiptPageState();
}

class _AddEditReceiptPageState extends State<AddEditReceiptPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _itemsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.receipt != null) {
      _selectedDate = widget.receipt!.date;
      _dateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.receipt!.date);
      _amountController.text = widget.receipt!.amount.toString();
      _selectedCategoryId = widget.receipt!.category;
      _itemsController.text = widget.receipt!.items.join(', ');
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receipt == null ? 'Add Receipt' : 'Edit Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () => _selectDate(context),
                readOnly: true,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
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
                controller: _itemsController,
                decoration: const InputDecoration(
                  labelText: 'Items (comma separated)',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final receipt = Receipt(
                      id: widget.receipt?.id ?? const Uuid().v4(),
                      date: _selectedDate,
                      amount: double.parse(_amountController.text),
                      category: _selectedCategoryId!,
                      items:
                          _itemsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList(),
                    );
                    Navigator.pop(context, receipt);
                  }
                },
                child: const Text('Submit'),
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
  List<Receipt> _receipts = [];
  final List<Category> _categories = [
    Category(id: 'groceries', name: 'Groceries'),
    Category(id: 'dining', name: 'Dining'),
    Category(id: 'shopping', name: 'Shopping'),
    Category(id: 'other', name: 'Other'),
  ];

  void _addOrEditReceipt(Receipt? receipt) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddEditReceiptPage(receipt: receipt, categories: _categories),
      ),
    );
    if (result is Receipt) {
      setState(() {
        if (receipt == null) {
          _receipts.add(result);
        } else {
          final index = _receipts.indexOf(receipt);
          _receipts[index] = result;
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
    _receipts = [
      Receipt(
        id: '1',
        date: DateTime.now(),
        amount: 100.50,
        category: 'groceries',
        items: ['Milk', 'Bread', 'Eggs'],
      ),
      Receipt(
        id: '2',
        date: DateTime.now(),
        amount: 50.00,
        category: 'dining',
        items: ['Pizza', 'Drinks'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Receipts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _navigateToCategoriesPage,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _receipts.length,
        itemBuilder: (context, index) {
          final receipt = _receipts[index];
          return ListTile(
            title: Text(DateFormat('yyyy-MM-dd').format(receipt.date)),
            subtitle: Text(
              '${receipt.amount.toStringAsFixed(2)} - ${receipt.category}',
            ),
            onTap: () => _addOrEditReceipt(receipt),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditReceipt(null),
        tooltip: 'Add Receipt',
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
