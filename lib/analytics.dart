import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Analytics extends StatefulWidget {
  final User user;

  Analytics({required this.user});

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  double totalExpenses = 0.0;
  List<MapEntry<String, double>> sortedCategoryTotals = [];
  String selectedTimeRange = 'Overall';
  double averageSpending = 0.0;
  final colorList = List<Color>.generate(10, (index) => Colors.primaries[index % Colors.primaries.length]);

  @override
  void initState() {
    super.initState();
    calculateTotalExpenses();
  }

  DateTime getStartDate() {
    switch (selectedTimeRange) {
      case 'Past Week':
        return DateTime.now().subtract(Duration(days: 7));
      case 'Past Two Weeks':
        return DateTime.now().subtract(Duration(days:14));
      case 'Past Month':
        return DateTime.now().subtract(Duration(days: 30));
      case 'Past Three Months':
        return DateTime.now().subtract(Duration(days:90));
      case 'Past Six Months':
        return DateTime.now().subtract(Duration(days:180));
      default:
        return DateTime.now().subtract(Duration(days: 365 * 5));
    }
  }

  void calculateTotalExpenses() async {
    DateTime startDate = getStartDate();
    FirebaseFirestore.instance
        .collection('expenses')
        .doc(widget.user.uid)
        .collection('userExpenses')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .get()
        .then((snapshot) {
      double total = 0.0;
      Map<String, double> totals = {};
      snapshot.docs.forEach((doc) {
        double price = (doc.data()['price'] as num).toDouble();
        String category = doc.data()['category'] as String;
        total += price;
        totals.update(category, (existing) => existing + price, ifAbsent: () => price);
      });

      var sortedTotals = totals.entries.toList();
      sortedTotals.sort((a, b) => b.value.compareTo(a.value));

      if (mounted) {
        setState(() {
          totalExpenses = total;
          sortedCategoryTotals = sortedTotals;
          averageSpending = total / (snapshot.docs.length > 0 ? snapshot.docs.length : 1);
        });
      }
    });
  }

  Future<Map<DateTime, double>> calculateSpendingData({required bool isWeekly}) async {
    DateTime now = DateTime.now();
    DateTime startDate = isWeekly ? now.subtract(Duration(days: now.weekday + 42)) : DateTime(now.year, now.month - 6, 1);
    DateTime endDate = DateTime(now.year, now.month + 1, 1);

    Map<DateTime, double> spendingData = {};

    var querySnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .doc(widget.user.uid)
        .collection('userExpenses')
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String(), isLessThan: endDate.toIso8601String())
        .orderBy('date')
        .get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime date = DateTime.parse(data['date']);
      double price = (data['price'] as num).toDouble();
      DateTime keyDate = isWeekly ? DateTime(date.year, date.month, date.day - date.weekday) : DateTime(date.year, date.month);

      spendingData.update(keyDate, (currentTotal) => currentTotal + price, ifAbsent: () => price);
    }

    return spendingData;
  }


  List<PieChartSectionData> getSections() {
    return sortedCategoryTotals.asMap().map((index, entry) {
      double percentage = (entry.value / totalExpenses) * 100;
      return MapEntry(
        index,
        PieChartSectionData(
          color: colorList[index % colorList.length],
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
          radius: 50,
        ),
      );
    }).values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analytics - Select time frame below"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedTimeRange,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedTimeRange = newValue;
                    calculateTotalExpenses();
                  });
                }
              },
              items: <String>['Overall', 'Past Week', 'Past Month', 'Past Two Weeks', 'Past Three Months', 'Past Six Months']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sortedCategoryTotals.length,
              itemBuilder: (context, index) {
                String category = sortedCategoryTotals[index].key;
                double amount = sortedCategoryTotals[index].value;
                double percentage = (amount / totalExpenses) * 100;
                return ListTile(
                  leading: Icon(Icons.label, color: colorList[index % colorList.length]),
                  title: Text('#${index + 1}: $category, \$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(2)}%)'),
                );
              },
            ),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: getSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 0,
                ),
              ),
            ),
            Text(
              'Total Spent: \$${totalExpenses.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Average Spending: \$${averageSpending.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),


        ],
        ),
      ),
    );
  }
}

