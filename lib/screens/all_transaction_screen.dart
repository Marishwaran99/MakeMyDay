import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/budget.dart';
import 'package:make_my_day/models/budget_helper.dart';
import 'package:make_my_day/screens/add_budget_plan_screen.dart';
import 'package:sqflite/sqflite.dart';

class AllTransactionScreen extends StatefulWidget {
  @override
  _AllTransactionScreenState createState() => _AllTransactionScreenState();
}

class _AllTransactionScreenState extends State<AllTransactionScreen> {
  List<Budget> budgets;
  BudgetHelper _helper = BudgetHelper();
  @override
  void initState() {
    super.initState();
    if (budgets == null) {
      budgets = List<Budget>();
      updateBudgetList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: budgets == null
            ? CircularProgressIndicator()
            : budgets.length > 0
                ? ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _transCard(context, budgets.elementAt(index));
                    })
                : Center(child: Text('No Transactions yet')));
  }

  Widget _transCard(BuildContext context, Budget budget) {
    return Container(
        width: MediaQuery.of(context).size.width - 16.0,
        child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Material(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
                child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    splashColor: Colors.grey[300],
                    hoverColor: Colors.grey[300],
                    focusColor: Colors.grey[300],
                    onTap: () async {
                      bool result = await Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return budget.type == 'Income'
                            ? AddBudgetPlanScreen('Income', budget)
                            : AddBudgetPlanScreen('Expense', budget);
                      }));

                      if (result) {
                        updateBudgetList();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        budget.type == 'Income'
                                            ? Text(
                                                '+' + budget.amount.toString(),
                                                style: TextStyle(
                                                    color: Colors.deepPurple,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5),
                                              )
                                            : Text(
                                                '-' + budget.amount.toString(),
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5),
                                              ),
                                        IconButton(
                                            alignment: Alignment.centerRight,
                                            icon: Icon(
                                              CupertinoIcons.delete_simple,
                                              color: Colors.red[300],
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CupertinoAlertDialog(
                                                    title: Text(
                                                      'Delete ' + budget.type,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                    content: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        'Are you sure to delete this ' +
                                                            budget.type +
                                                            ' ?',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat',
                                                            letterSpacing: 0.5),
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text('Keep',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        ),
                                                        onPressed: () {
                                                          _helper.deleteBudget(
                                                              budget.id);
                                                          updateBudgetList();
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            })
                                      ]),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      budget.time != ''
                                          ? Column(children: <Widget>[
                                              SizedBox(
                                                height: 16.0,
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 8.0),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                  child: Text(DateFormat.yMMMd()
                                                      .add_jm()
                                                      .format(DateTime.parse(
                                                          budget.time))))
                                            ])
                                          : Container(),
                                      Container(
                                          margin: EdgeInsets.only(left: 16.0),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Text(budget.category))
                                    ],
                                  )
                                ])),
                      ],
                    )))));
  }

  updateBudgetList() {
    Future<Database> dbFuture = _helper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Budget>> budgetFuture = _helper.getBudgetList();
      budgetFuture.then((budgetDb) {
        setState(() {
          this.budgets = budgetDb;
        });
      });
    });
  }
}
