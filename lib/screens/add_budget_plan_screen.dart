import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/budget.dart';
import 'package:make_my_day/models/budget_helper.dart';
import 'package:sqflite/sqflite.dart';

class AddBudgetPlanScreen extends StatefulWidget {
  final String title;
  final Budget budget;
  AddBudgetPlanScreen(this.title, this.budget);
  @override
  _AddBudgetPlanScreenState createState() => _AddBudgetPlanScreenState();
}

class _AddBudgetPlanScreenState extends State<AddBudgetPlanScreen> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateTimeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<String> incomeCategory = ['Business', 'Loan', 'Salary'];
  List<String> expenseCategory = [
    'Clothing',
    'Drinks',
    'Education',
    'Food',
    'Fuel',
    'Fun',
    'Hospital',
    'Hotel',
    'Medical',
    'Merchandise',
    'Movie',
    'Personal',
    'Pets',
    'Restaurant',
    'Shopping',
    'Tips',
    'Transport',
    'Other'
  ];

  List<String> paymentMode = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Net Banking'
  ];
  List<String> categories;
  String _category;
  String _payment;
  Budget _budget;
  DateTime dt;
  BudgetHelper _helper = BudgetHelper();
  @override
  void initState() {
    super.initState();
    dt = DateTime.now();

    categories = List<String>();
    categories = widget.title == 'Income' ? incomeCategory : expenseCategory;

    if (widget.budget == null) {
      _category = categories[0];
      _payment = paymentMode[0];
      _budget = Budget(
          amount: '',
          description: '',
          category: _category,
          paymentMode: _payment,
          time: dt.toString(),
          type: widget.title);
    } else {
      _budget = widget.budget;
      _category = widget.budget.category;
      _payment = widget.budget.paymentMode;
      dt = DateTime.parse(widget.budget.time);
      _amountController.text = widget.budget.amount;
      _descriptionController.text = widget.budget.description;
    }

    _dateTimeController.text =
        DateFormat.yMMMd().add_jm().format(dt).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add  ' + widget.title,
          style: TextStyle(
              fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      _budget.amount = val;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 16, bottom: 8),
                      hasFloatingPlaceholder: true,
                      labelText: 'Enter ' + widget.title,
                      hintText: 'Eg: 1000 '),
                ),
                TextField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.text,
                  onChanged: (val) {
                    setState(() {
                      _budget.description = val;
                    });
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 24, bottom: 8),
                      hasFloatingPlaceholder: true,
                      labelText: 'Enter Descripion(Optional)',
                      hintText: 'Eg: Spent at hotel '),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _dateTimeController,
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.dateAndTime,
                              initialDateTime: DateTime.now(),
                              onDateTimeChanged: (val) {
                                log(val.toString());
                                setState(() {
                                  _dateTimeController.text = DateFormat.yMMMd()
                                      .add_jm()
                                      .format(DateTime.parse(val.toString()))
                                      .toString();
                                  _budget.time = val.toLocal().toString();
                                });
                              });
                        });
                  },
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 24, bottom: 8),
                    hasFloatingPlaceholder: true,
                    labelText: 'Enter Date & Time',
                  ),
                ),
                SizedBox(height: 16),
                DropdownButton(
                  items: categories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _category = val;
                      setState(() {
                        _budget.category = val;
                      });
                    });
                  },
                  value: _category,
                ),
                SizedBox(height: 16),
                DropdownButton(
                  items: paymentMode.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _payment = val;
                      setState(() {
                        _budget.paymentMode = val;
                      });
                    });
                  },
                  value: _payment,
                ),
                SizedBox(height: 16),
                FlatButton(
                    color: Colors.deepPurple,
                    textColor: Colors.white,
                    onPressed: () {
                      if (int.parse(_budget.amount) > 0 ||
                          _budget.amount != '') {
                        if (_budget.id == null)
                          _helper.insertBudget(_budget);
                        else
                          _helper.updateBudget(_budget);
                        _amountController.text = '';
                        _descriptionController.text = '';
                        Navigator.pop(context, true);
                      }
                    },
                    child: Text('Save'))
              ],
            )),
      ),
    );
  }
}
