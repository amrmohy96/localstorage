import 'package:flutter/material.dart';
import 'package:localstorage/models/contact.dart';
import 'package:localstorage/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.lightBlueAccent,
        accentColor: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'sqlite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Contact _contact = Contact();
  List<Contact> _contacts = [];
  DatabaseHelper databasehelper;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      databasehelper = DatabaseHelper.instance;
    });
    _refreshContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _form(),
            _list(),
          ],
        ),
      ),
    );
  }

  Container _form() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'enter your name',
                prefixIcon: Icon(Icons.person),
              ),
              onSaved: (val) {
                setState(() {
                  _contact.name = val;
                });
              },
              validator: (val) => val.length == 0
                  ? 'invalid name , the name must be at least 6 characters'
                  : null,
            ),
            TextFormField(
              controller: mobileController,
              decoration: InputDecoration(
                hintText: 'enter your phone number',
                prefixIcon: Icon(Icons.contact_phone),
              ),
              onSaved: (val) {
                setState(() {
                  _contact.mobile = val;
                });
              },
              validator: (val) => val.length < 10
                  ? 'invalid number, a number must be at least 10 numbers'
                  : null,
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                onPressed: _submit,
                child: Text(
                  'submit',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.lightBlueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _list() {
    return Expanded(
      child: Card(
          child: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, int index) {
          return Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: Text(_contacts[index].name),
                subtitle: Text(_contacts[index].mobile),
                trailing: IconButton(
                    icon: Icon(Icons.delete_sweep),
                    onPressed: () async {
                      await databasehelper.deleteContact(_contacts[index].id);
                      _resetForm();
                      _refreshContacts();
                    }),
                onTap: () {
                  setState(() {
                    _contact = _contacts[index];
                    nameController.text = _contacts[index].name;
                    mobileController.text = _contacts[index].mobile;
                  });
                },
              )
            ],
          );
        },
      )),
    );
  }

  _refreshContacts() async {
    List<Contact> contacts = await databasehelper.fetchContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  _submit() async {
    final _form = _formKey.currentState;
    if (_formKey.currentState.validate()) {
      _form.save();
      if (_contact.id == null) {
        print(_contact.name );
        await databasehelper.createContact(_contact);
      } else {
         await databasehelper.updateContact(_contact);
      }
      _refreshContacts();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      nameController.clear();
      mobileController.clear();
      _contact.id = null;
    });
  }

  showSnackBar(String txt, Color colour) {
    SnackBar snackbar = SnackBar(
      content: Text(
        txt,
        style: TextStyle(fontSize: 16.0, color: colour),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
