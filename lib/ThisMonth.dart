import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import './model/billing.dart';
import './model/database_helper.dart';
import './main.dart';

class ThisMonth extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new state_ThisMonth();

}
DatabaseHelper databaseHelper=DatabaseHelper();

class state_ThisMonth extends State<ThisMonth> {
  Days dayc;
  var count=0;
  List<Days> day;
  var _price;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(day==null){
      day=List<Days>();
      updateListView();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAlert(context);
        },
        tooltip: 'Add a date',
        child: Icon(Icons.add),

      ),
      body: new ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context,int index){
          return new Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: Card(
                  child: new ListTile(
                    contentPadding: EdgeInsets.all(10),
                    title: new Text(
                      this.day[index].date,
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                    subtitle: Text(
                        "Fare :${(this.day[index].total).toString()}"
                    ),
                    trailing: new Container(
                      padding: EdgeInsets.only(top:10,left: 15,right: 15,bottom: 10),
                      child: Text(
                        this.day[index].ways,

                      ),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blueAccent,
                              width: 2
                          ),
                          borderRadius: BorderRadius.circular(30)
                      ),
                    ),
                  )

              )
          );
        },

      ),
    );
  }

  setperday() async {
    var p= await databaseHelper.getPrice();
    setState(() {
      _price=p[0]['price'];
    });
  }
  void _showAlert(BuildContext context) async {
    TextEditingController dateController= new TextEditingController();
    dateController.text=DateFormat.MMMEd().format(DateTime.now());
    await setperday();
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: new Text("Add A Date",
              textAlign: TextAlign.center,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              content: new Container(
                height: 300,
                child: new Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(10)),
                    DateTimeField(
                      format: DateFormat.MMMEd(),
                      controller: dateController,
                      initialValue: DateTime.now(),
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                      ),
                      onShowPicker: (context,initialValue){
                        return showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));

                      },

                    ),
                    Padding(padding: EdgeInsets.all(30)),

                    RaisedButton(
                        elevation: 20,
                        color: Colors.white,
                        padding: new EdgeInsets.only(left: 100,right: 100),
                        child: new Text("One Way"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.blueAccent,
                            width: 1.6
                          )
                        ),
                        onPressed:(){
                          dayc=Days(dateController.text,"One Way",_price*0.5);
                            _insert(dayc);
                            updateListView();
                          Navigator.pop(context);

                        }),
                    new Padding(padding: EdgeInsets.all(10)),
                    RaisedButton(
                        elevation: 20,
                        color: Colors.white,
                        padding: new EdgeInsets.only(left: 100,right: 100),
                        child: new Text("Two Way"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Colors.blueAccent,
                              width: 1.6
                            )
                        ),
                        onPressed:(){
                          dayc=Days(dateController.text,"Two Way",_price);
                          _insert(dayc);
                          updateListView();
                          Navigator.pop(context);
                         }),

                  ],
                ),

              ),

            )
    );
  }

  void updateListView(){
    final Future<Database> dbFuture=databaseHelper.Initializedatabase();
    dbFuture.then((database){
      Future<List<Days>> daysList=databaseHelper.getDays("ThisMonth");
      daysList.then((daylist) async {
        if(daylist.length<=29){

          setState(() {
            this.day=daylist;
            this.count=daylist.length;
          });
        }
        else{
          _AskForBill(context);
          await new Future.delayed(const Duration(milliseconds: 1500), () {
            databaseHelper.delete();
          });
            setState(() {
              this.count = 0;
            });

        }

      });
    });

  }

  void _insert(Days day) async {
    int a=await databaseHelper.insert(day);

  }

  void _AskForBill(BuildContext context) {
    showDialog(context: context,
    builder: (BuildContext context){
      return AlertDialog(
       content: Text("Month Complete Generate Bill?"),
       actions: <Widget>[
         FlatButton(onPressed: () {
           Navigator.pop(context);
           generateBill(context);

         }, child: Text('OK'))
       ],
      );
    });
  }




}
