import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './ThisMonth.dart';
import './History.dart';
import './model/billing.dart';
void main() => runApp(MyApp());
enum choice {generateBill,perDay}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          title: new TextStyle(
          )
        )
      ),
      home: MyHomePage(title: 'Billing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}
var price="20";
class MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController controller;
  TextEditingController txtController= new TextEditingController();
  static Days setPrice;

 @override
 void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this,initialIndex: 0);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext contextMain) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<choice>(
              onSelected: (choice value) async {
                if(value==choice.generateBill){
                  generateBill(contextMain);

              }
              else{
                _enterPerday(contextMain);
              }

              },
              itemBuilder: (BuildContext contextMain){
            return [
              PopupMenuItem<choice>(
              value: choice.generateBill,
                child: Text("Generate Bill"),

            ),
              PopupMenuItem<choice>(
                value:choice.perDay,
                  child: Text("Update PerDay"))
            ];

          })
        ],
        bottom: new TabBar(
          controller: controller,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            new Tab(
              child: new Text("This Month",
              style:  new TextStyle(
                fontSize: 17
              ),),
            ),
            new Tab(
              child: new Text("History",
                  style:  new TextStyle(
                      fontSize: 17
                  ),),
            )
          ],
        ),
      ),
      body: new TabBarView(
        controller:controller,
        children: <Widget>[
          ThisMonth(),
          History()
        ],
      ),

    );

  }


  void _enterPerday(BuildContext contextMain) async {
    await setperday();
    showDialog(context: context,
        builder: (context)=>
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('Enter New Per Day'),
                content: new  TextField(
                  controller: txtController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide:BorderSide(
                        color: Colors.blueAccent,
                        style: BorderStyle.solid,
                      )
                    ),
                   hintText: "Current "+price
                  ),

                ),
              actions: <Widget>[
                FlatButton(onPressed: () {
                  setPrice=Days.perDay(int.parse(txtController.text));
                  databaseHelper.updatePrice(setPrice);
                  Navigator.of(contextMain).pop();
                  txtController.text="";
                  },
                child: Text('Update'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),)
              ],
            )
    );

  }
  setperday() async {
    var p= await databaseHelper.getPrice();
    setState(() {
      price=p[0]['price'].toString();
    });
  }
}

generateBill(BuildContext contextMain) {
  showDialog(context: contextMain,
      builder: (context)=>
          FutureBuilder<List>(
            future: getbill() ,
            builder: (contextMain, snapshot) {
              if (snapshot.hasData) {
                if(snapshot.data[0]==null){
                  return AlertDialog(
                    content: Text("No Transaction yet!!!"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Ok"),
                        onPressed: ()=>Navigator.of(context).pop(),
                      )
                    ],
                  );
                }
                  return AlertDialog(
                      title: Text("Bill",
                      textAlign: TextAlign.center,),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Ok"),
                          onPressed: () {
                          Navigator.of(context).pop();
                        }
                        )
                      ],
                      content: SizedBox(
                        height: 170,
                        width: 100,
                      child:Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("One Way"),
                            trailing: Text("${snapshot.data[1]}"),
                          ),
                          ListTile(
                            title: Text('Two Way'),
                            trailing: Text('${snapshot.data[2]}'),

                          ),
                          ListTile(
                            title: Text('Total'),
                            trailing: Text('${snapshot.data[0]}'),
                          )
                        ],
                      )
                      )
                  );

              }
              else if (snapshot.hasError) {
                return AlertDialog(
                  title: Text("${snapshot.error}"),
                );
              }
              // By default, show a loading spinner
              return AlertDialog(
                title : Text("Generating...."),
                  content : LinearProgressIndicator(),
              );

            },
          )
  );

}

void ShowBill(BuildContext context,snapshot) {
  showDialog(context: context,
  builder: (context)=>
   AlertDialog(
    title: Text("Bill"),
  content: Text("One Way : ${snapshot.data[1]}\nTwo Way : ${snapshot.data[2]}\nTotal : ${snapshot.data[0]}"),
   )

);
}

Future<List> getbill()  async {
  await new Future.delayed(const Duration(milliseconds: 500), () {
  });
  return  await databaseHelper.Billgenerate();
}

