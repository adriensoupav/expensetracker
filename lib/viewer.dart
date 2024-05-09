import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Viewer extends StatefulWidget {
  final User user;

  Viewer({required this.user});

  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  List<DateTime> months = [];
  DateTime? selectedMonth;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeMonths();
  }

  void initializeMonths() async {
    DateTime earliestDate = await getEarliestExpenseDate();
    DateTime currentDate = DateTime.now();
    for (int year = earliestDate.year; year <= currentDate.year; year++) {
      int startMonth = year == earliestDate.year ? earliestDate.month : 1;
      int endMonth = year == currentDate.year ? currentDate.month : 12;
      for (int month = startMonth; month <= endMonth; month++) {
        months.add(DateTime(year, month));
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<DateTime> getEarliestExpenseDate() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .doc(widget.user.uid)
        .collection('userExpenses')
        .orderBy('date', descending: false)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return widget.user.metadata.creationTime ?? DateTime.now();
    } else {
      Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
      return DateTime.parse(data['date']);
    }
  }

  void deleteExpense(String docId) async {
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(widget.user.uid)
        .collection('userExpenses')
        .doc(docId)
        .delete();
    if (selectedMonth != null) {
      setState(() {});
    }
  }

  Stream<List<DocumentSnapshot>> getExpensesForMonth(DateTime month) {
    DateTime start = DateTime(month.year, month.month, 1);
    DateTime end = (month.month == 12) ? DateTime(month.year + 1, 1, 1) : DateTime(month.year, month.month + 1, 1);
    return FirebaseFirestore.instance
        .collection('expenses')
        .doc(widget.user.uid)
        .collection('userExpenses')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Viewer"),
        leading: selectedMonth != null ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => setState(() => selectedMonth = null),
        ) : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Wrap(
            children: months.map((month) {
              return ElevatedButton(
                child: Text(DateFormat('MMMM yyyy').format(month)),
                onPressed: () => setState(() => selectedMonth = month),
              );
            }).toList(),
          ),
          Expanded(
            child: selectedMonth == null
                ? Center(child: Text("Select a month to view expenses"))
                : StreamBuilder<List<DocumentSnapshot>>(
              stream: getExpensesForMonth(selectedMonth!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No expenses found for this month"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var expense = snapshot.data![index].data() as Map<String, dynamic>;
                    String docId = snapshot.data![index].id;
                    return ListTile(
                      title: Text(expense['title']),
                      subtitle: Text('\$${(expense['price'] as num).toDouble().toStringAsFixed(2)} on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(expense['date']))} - Category: ${expense['category']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteExpense(docId),
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
