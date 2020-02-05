import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import './ThisMonth.dart';
import './model/billing.dart';
class History extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new state_History();
  }

}

class state_History extends State<History> {
  Database database;
  var count=0;
  List<Days> History;
  @override
  Widget build(BuildContext context) {
    if(History==null){
      History=List<Days>();
      updateListView();
    }

    return Scaffold(
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
                  this.History[index].date,
                  style: TextStyle(
                      fontSize: 20
                  ),
                ),
                subtitle: Text(
                    "Fare :${(this.History[index].total).toString()}"
                ),
                trailing: new Container(
                   padding: EdgeInsets.only(top:10,left: 15,right: 15,bottom: 10),
                    child: Text(
                     this.History[index].ways,

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

    )
    );
}


  void updateListView() {
    final Future<Database> dbFuture=databaseHelper.Initializedatabase();
    dbFuture.then((database){
      Future<List<Days>> daysList=databaseHelper.getDays("History");
      daysList.then((daylist){
        if(daylist.length>60){
          databaseHelper.deleteH();
          daysList=databaseHelper.getDays("History");
          daysList.then((daylist){
            setState(() {
              this.History=daylist;
              this.count=daylist.length;
            });
          });
        }
        else {
          setState(() {
            this.History = daylist;
            this.count = daylist.length;
          });
        }
      });
    });

  }



}