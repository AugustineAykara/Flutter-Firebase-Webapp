import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'listStudents.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        "/listStudents": (BuildContext context) => ListStudents(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String subject = '';
  String descp = '';
  int price;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromRGBO(18, 18, 18, 0),
        resizeToAvoidBottomPadding: false,
        floatingActionButton: floatingButton(),
        body: StreamBuilder(
          stream: Firestore.instance.collection('subjectCards').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Text("Loading...");
            else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot cards = snapshot.data.documents[index];
                  return Dismissible(
                    background: dismissableContainer(),
                    direction: DismissDirection.startToEnd,
                    key: UniqueKey(),
                    child: Card(
                      color: Colors.white12,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.white12,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 6,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => ListStudents(
                                  documentIdValue: cards.documentID,
                                  subjectName: cards['subjectName']),
                            ),
                          );
                        },
                        onLongPress: () {
                          copyLink(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              subjectText(cards),
                              priceText(cards),
                              descriptionText(cards),
                            ],
                          ),
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "${cards['subjectName']} has been deleted from the list"),
                        ),
                      );
                      setState(() {
                        Firestore.instance
                            .collection('subjectCards')
                            .document(cards.documentID)
                            .delete();
                      });
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  // FLOATING BUTTON WIDGET
  Widget floatingButton() {
    return FloatingActionButton(
      backgroundColor: Colors.teal,
      child: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.teal[100],
              title: Text("Add Card"),
              content: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Enter Subject',
                          icon: Icon(Icons.subject)),
                      style: TextStyle(fontSize: 18),
                      onChanged: (text) {
                        subject = text;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Enter Price',
                          icon: Icon(Icons.attach_money)),
                      style: TextStyle(fontSize: 18),
                      onChanged: (text) {
                        price = int.parse(text);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          icon: Icon(Icons.note)),
                      style: TextStyle(fontSize: 18),
                      onChanged: (text) {
                        descp = text;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Add"),
                  onPressed: () {
                    setState(() {
                      if (subject == '' || price == null) {
                        print("null");
                      } else {
                        Firestore.instance
                            .collection('subjectCards')
                            .document()
                            .setData({
                          'subjectName': subject,
                          'cost': price,
                          'description': descp
                        });
                        subject = '';
                        descp = '';
                        price = null;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // CARD TEXT STYLE FOR SUBJECT
  Widget subjectText(cards) {
    return Text(
      cards['subjectName'].toUpperCase(),
      style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline),
    );
  }

// CARD TEXT STYLE FOR PRICE
  Widget priceText(cards) {
    return Text(
      "Rs." + cards['cost'].toString(),
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );
  }

// CARD TEXT STYLE FOR DESCRIPTION
  Widget descriptionText(cards) {
    return Text(
      cards['description'],
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontStyle: FontStyle.italic,
      ),
    );
  }

// DISMISSABLE CONTAINER STYLE
  Widget dismissableContainer() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete_outline,
        color: Colors.black,
        size: 54,
      ),
    );
  }

// TO COPY WEB LINK TO CLIPBOARD
  void copyLink(context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Link copied to clipboard"),
      ),
    );
    Clipboard.setData(
      new ClipboardData(
          text: "https://augustineaykara.github.io/Flutter-Firebase-Webapp/"),
    );
  }
}
