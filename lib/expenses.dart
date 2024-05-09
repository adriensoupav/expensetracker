import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class expenses extends StatefulWidget {
  final User user;

  expenses({required this.user});

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<expenses> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController categoryController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  DateTime? selectedDate;
  bool includeTax = false;
  List<String> categories = ['Food', 'Travel', 'Healthcare', 'Entertainment', 'Utilities'];

  void addExpense() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    double price = double.parse(priceController.text.trim());
    if (includeTax && taxController.text.isNotEmpty) {
      double taxRate = double.parse(taxController.text.trim()) / 100;
      price *= (1 + taxRate);
    }

    DocumentReference ref = FirebaseFirestore.instance
        .collection('expenses')
        .doc(widget.user.uid)
        .collection('userExpenses')
        .doc();

    await ref.set({
      'category': categoryController.text.trim(),
      'title': titleController.text.trim(),
      'price': price,
      'includeTax': includeTax,
      'taxRate': includeTax ? (taxController.text.isEmpty ? 0 : double.parse(taxController.text.trim())) : 0,
      'date': selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(), // Store date
    });

    Fluttertoast.showToast(msg: "Success");
    setState(() {
      categoryController.clear();
      titleController.clear();
      priceController.clear();
      taxController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expenses"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField(
                value: categories.first,
                onChanged: (String? newValue) {
                  categoryController.text = newValue ?? categories.first;
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty ? 'Price cannot be left empty' : null,
              ),
              SwitchListTile(
                title: Text('Include tax?'),
                value: includeTax,
                onChanged: (bool value) {
                  setState(() {
                    includeTax = value;
                  });
                },
              ),
              if (includeTax) TextFormField(
                controller: taxController,
                decoration: InputDecoration(labelText: 'Tax Percentage'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Tax cannot be left empyt';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text("Select Date: ${selectedDate?.toString().substring(0, 10) ?? 'Not Set'}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ElevatedButton(
                onPressed: addExpense,
                child: Text('Enter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}