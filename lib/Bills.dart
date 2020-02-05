import 'package:flutter/material.dart';
import './model/database_helper.dart';
import './model/billing.dart';
class Bills extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new state_bills();
  }

}
class state_bills extends State<Bills> {
  int count=0;
  DatabaseHelper databaseHelper=DatabaseHelper();
  List<Days> bills;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(bills==null){
      bills=List<Days>();
      updateListView();
    }

    return Scaffold(
      body: ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context,index){
        return new Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: Card(
                child: new ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: new Text(
                    this.bills[index].date,
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  subtitle: Text(
                      "Total :${(this.bills[index].total).toString()}"
                  ),
                )

            )
        );
    },

    ));
  }
  void updateListView() async {
    Future<List<Days>> billList=databaseHelper.getDays("Bills");
        billList.then((bills){
            setState(() {
            this.count = bills.length;
            this.bills=bills;

      });
    });

  }


  }