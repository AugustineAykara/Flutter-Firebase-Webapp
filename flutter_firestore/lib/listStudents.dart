import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ListStudents(),
    );
  }
}

class ListStudents extends StatefulWidget {
  final String documentIdValue;
  final String subjectName;
  ListStudents({Key key, this.documentIdValue, this.subjectName})
      : super(key: key);
  @override
  _ListStudentsState createState() => _ListStudentsState();
}

class _ListStudentsState extends State<ListStudents> {
 
  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> studentNameSnapshot = Firestore.instance
        .collection('subjectCards')
        .document('${widget.documentIdValue}')
        .snapshots();

    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 0),
      appBar: AppBar(
        title: Text(
          '${widget.subjectName}'.toUpperCase(),
        ),
        backgroundColor: Color.fromRGBO(18, 18, 18, 0),
      ),
      body: StreamBuilder(
        stream: studentNameSnapshot,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData)
            return new Center(child: Text("Loading..."));
          else {
            return listStudents(snapshot);
          }
        },
      ),
    );
  }

// LIST NAME WIDGET
  Widget listStudents(snapshot) {
    var documentData = snapshot.data.data;
    var studentNameList = documentData['studentName'];
    return ListView.builder(
      itemCount: studentNameList != null ? studentNameList.length : 0,
      itemBuilder: (context, index) {
        studentNameList.sort();
        return Container(
          color: Colors.white10,
          margin: EdgeInsets.all(3),
          child: ListTile(
            leading: listLeadingText(index),
            title: listTitleText(studentNameList[index]),
            trailing: listTrailingText(studentNameList[index], context),
          ),
        );
      },
    );
  }

// LEADING TEXT STYLE
  Widget listLeadingText(value) {
    return Text(
      (value + 1).toString() + ".",
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

// NAME TEXT STYLE
  Widget listTitleText(name) {
    return Row(
      children: <Widget>[
        Text(
          name.toUpperCase(),
          style: TextStyle(
            color: name.substring(name.length - 1) == '\$'
                ? Colors.green
                : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(Icons.attach_money,color: Colors.green),

      ],
    );
  }

// TRAILING TEXT STYLE
  Widget listTrailingText(name, context) {
    return IconButton(
      icon: Icon(Icons.delete),
      iconSize: 28,
      color: Colors.red,
      splashColor: Colors.red,
      onPressed: () {
        Firestore.instance
            .collection('subjectCards')
            .document('${widget.documentIdValue}')
            .updateData({
          'studentName': FieldValue.arrayRemove([name])
        });
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content:
                Text("${name.toUpperCase()} has been deleted from the list"),
          ),
        );
      },
    );
  }
}
