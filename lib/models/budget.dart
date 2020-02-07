class Budget {
  int id;
  String amount;
  String description;
  String category;
  String paymentMode;
  String time;
  String type;

  Budget(
      {this.amount,
      this.description,
      this.category,
      this.paymentMode,
      this.time,
      this.type});
  Budget.withId(this.id, this.amount, this.description, this.category,
      this.paymentMode, this.time, this.type);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }

    map['amount'] = amount;
    map['description'] = description;
    map['category'] = category;
    map['paymentMode'] = paymentMode;
    map['time'] = time;
    map['type'] = type;
    return map;
  }

  Budget.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.description = map['description'];
    this.amount = map['amount'];
    this.paymentMode = map['paymentMode'];
    this.category = map['category'];
    this.time = map['time'];
    this.type = map['type'];
  }
}
