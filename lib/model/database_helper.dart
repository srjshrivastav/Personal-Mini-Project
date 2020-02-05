import 'package:flutter/material.dart';
import 'package:personal/main.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import './billing.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;
  String tableName1='ThisMonth';
  String tableName2='History';
  String colId='id';
  String colDates='Dates';
  String colWays='Ways';
  String colTotal='Fare';

  DatabaseHelper.createInstance();
  factory DatabaseHelper(){
    if(_databaseHelper==null){
      _databaseHelper=DatabaseHelper.createInstance();
    }
    return _databaseHelper;

  }

  Future<Database> get database async{
    if(_database==null){
      _database=await Initializedatabase();
    }
    return _database;
  }
  Future<Database> Initializedatabase() async{

    String path= await getDatabasesPath();
    var daysdatabse=openDatabase(path+"personal.db",version: 1,onCreate: _createDatabase);
    return daysdatabse;
  }


  void _createDatabase(Database db,int version) async{
    await db.execute('CREATE TABLE $tableName1($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colDates TEXT NOT NULL,$colWays TEXT,$colTotal INTEGER)');
    await db.execute('CREATE TABLE $tableName2($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colDates TEXT NOT NULL,$colWays TEXT,$colTotal INTEGER)');
    await db.execute('CREATE TABLE PERDAY(price INTEGER DEFAULT 20)');
    await db.execute('CREATE TABLE SETS(a INTERGER,b INTEGER)');
    await db.rawQuery("INSERT INTO SETS VALUES(1,30)");
    await db.rawQuery("INSERT INTO PERDAY VALUES(20)");

  }

  //Fetching Data

 Future<List<Map<String,dynamic>>> fetchData(String tname) async{
    Database db= await this.database;
    var result= await db.query(tname);
    return result;
}

Future<int> insert(Days day) async{
    Database db = await this.database;
    db.insert(tableName1, day.toMap());
    db.insert(tableName2, day.toMap());
}

Future<List<Days>> getDays(String tname) async{
     var data=await fetchData(tname);
     int count=data.length;
     List<Days> days= List<Days>();
     for (int i=0;i<count;i++){
       days.add(Days.fromMapObject(data[i]));
     }

     return days;

}
delete() async{
    Database db = await this.database;
    await db.rawDelete("DELETE FROM ThisMonth;" ) ;
}
  deleteH() async{
    Database db = await this.database;
    var c = await db.rawQuery("SELECT a FROM SETS");
    var d = await db.rawQuery("SELECT b FROM SETS");
    await db.rawDelete('DELETE FROM History Where id BETWEEN ${c[0]['a']} AND ${d[0]['b']}');
    await db.rawUpdate('UPDATE SETS SET a=${c[0]['a']+30},b=${d[0]['b']+30}');
  }

updatePrice(Days setPrice) async{
    Database db = await this.database;
    await db.rawUpdate('UPDATE PERDAY SET price=${setPrice.price}');
}
 Future<List<Map<String,dynamic>>> getPrice() async{
    Database db= await this.database;
      var result = await db.query('PERDAY');
      return result;
}

Future<List> Billgenerate() async{
    Database db =await this.database;
    var total= await db.rawQuery("SELECT SUM(Fare) AS Total FROM ThisMonth ");
    var oneWay=await db.rawQuery("SELECT COUNT(Ways) AS One_way FROM ThisMonth where Ways='One Way'");
    var TwoWay=await db.rawQuery("SELECT COUNT(Ways) AS Two_way FROM ThisMonth where Ways='Two Way'");

    return [total[0]['Total'],oneWay[0]['One_way'],TwoWay[0]['Two_way']];

}


}