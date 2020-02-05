class Days{
  int _id;
  String _date;
  String _ways;
  int _price;
  var _total;

  Days(this._date,this._ways,this._total);
  Days.perDay(this._price);
  int get id => _id;
  String get date=> _date;
  String get ways=> _ways;

   get total=>_total;

  int get price=>_price;

  set price(int price){
    this._price=price;
  }
  set total(int total){
    this._total=total;
  }

  set date(String date){
   this._date=date;
  }
  set ways(String ways){
    this._ways=ways;
  }

  Map<String,dynamic> toMap(){
    var map = new Map<String,dynamic>();
    map['Dates']=_date;
    map['Ways']=_ways;
    map['Fare']=_total;

    return map;
  }
  Days.bills(Map<String,dynamic> map){
    this._date=map['Date'];
    this._total=map['Amount'];
  }
  Days.fromMapObject(Map<String,dynamic> map){
    this._id=map['id'];
    this._date=map['Dates'];
    this._ways=map['Ways'];
    this._total=map['Fare'];
  }

}