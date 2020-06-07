import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hexcolor/hexcolor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid Tracker',
      home: MyHomePage(title: 'Covid Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  static List<String> values = new List<String>();
  static List<String> valuesIndia = new List<String>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  void initState() {
    super.initState();
  }
  String dropdownValue, dropdownValueIndia;

  List<String> getTotalValues(url, data) {
    List<String> total = new List<String>();
    Map<String, dynamic> dataJson = json.decode(data.body);
    total.add(dataJson['confirmed']['value'].toString());
    total.add(dataJson['recovered']['value'].toString());
    total.add(dataJson['deaths']['value'].toString());
    return total;
  }

  List<String> getCountries(url, data) {
    List<String> countries = new List();
    Map<String, dynamic> dataJson = json.decode(data.body);
    for(int i=0;i<dataJson['countries'].length;i++)
      countries.add(dataJson['countries'][i]['name'].toString());
    return countries;
  }

  Future<List<String>> _fetchData() async {
    var countriesUrl = 'https://covid19.mathdro.id/api/countries';
    var response = await http.get(countriesUrl);
    if (response.statusCode == 200) {
      var countriesData = await http.get(countriesUrl);
      List<String> countries = getCountries(countriesUrl, countriesData);
      return countries;
    } else {
      throw Exception('Failed to load internet');
    }
  }

  List<String> getTotalIndiaValues(url, data) {
    List<String> total = new List<String>();
    Map<String, dynamic> dataJson = json.decode(data.body);
    for(int i=0;i<dataJson['statewise'].length;i++) {
      if(dataJson['statewise'][i]['state'] == dropdownValueIndia){
        total.add(dataJson['statewise'][i]['confirmed']);  
        total.add(dataJson['statewise'][i]['recovered']);
        total.add(dataJson['statewise'][i]['deaths']);
        break;
      }
    }
    return total;
  }

  Future<List<String>> fetchIndiaData() async {
    var indiaUrl = 'https://api.covid19india.org/data.json';
    var data = await http.get(indiaUrl);
    List<String> stateTotal = getTotalIndiaValues(indiaUrl, data);
    return stateTotal;
  }

  List<String> getStates(url, data) {
    List<String> states = new List<String>();
    Map<String, dynamic> dataJson = json.decode(data.body);
    for(int i=0;i<dataJson['statewise'].length;i++)
      if(dataJson['statewise'][i]['state'].toString() != 'Total')
        states.add(dataJson['statewise'][i]['state'].toString());
    states.sort();
    return states;
  }

  Future<List<String>> fetchStates() async {
    var indiaUrl = 'https://api.covid19india.org/data.json';
    var response = await http.get(indiaUrl);
    if (response.statusCode == 200) {
      var stateData = await http.get(indiaUrl);
      List<String> states = getStates(indiaUrl, stateData);
      return states;
     } else {
      throw Exception('Failed to load internet');
    }
  }

  Future<List<String>> countryValues() async {
    var countryUrl = 'https://covid19.mathdro.id/api/countries/'+dropdownValue;
    var countryData = await http.get(countryUrl);
    List<String> countryTotal = getTotalValues(countryUrl, countryData);
    return countryTotal;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Image.asset('./assets/images/funny_corona_gif.gif', width: 250, height: 250),
              ),
              new Text('For Countries..',style: TextStyle(fontSize: 50, fontFamily: 'DancingScript', color: Hexcolor('#00BFFF'))),
              new FutureBuilder<List<String>>(
                future: _fetchData(),
                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    return new Container(
                      width: 280,
                      height: 50,
                      child: new Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Hexcolor('#708090'),
                        ),
                        child: new DropdownButton<String>(
                          hint: Text('Select a country', style: TextStyle(fontSize: 20, color: Colors.white)),
                          value: dropdownValue,
                          items: snapshot.data.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: 20,color: Colors.white)),
                            );
                          }).toList(),
                          style: TextStyle(color: Colors.black),
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              dropdownValue = value;
                            });
                          },
                        ),
                      ),
                    );
                  }
                }
              ),
              new FutureBuilder<List<String>>(
                future: countryValues(),
                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.hasData) {
                    MyHomePage.values = snapshot.data;
                    try{
                      return RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.warning, size: 24, color: Colors.orange),
                            ),
                            TextSpan(
                              text: '   Infected: ${MyHomePage.values[0]}\n',
                              style: TextStyle(fontSize: 24, color: Colors.white)                  
                            ),
                            WidgetSpan(
                              child: Icon(Icons.check, size: 24, color: Colors.lightGreen,),
                            ),
                            TextSpan(
                              text: '   Recovered: ${MyHomePage.values[1]}\n',
                              style: TextStyle(fontSize: 24, color: Colors.white)
                            ),
                            WidgetSpan(
                              child: Icon(Icons.close, size: 24, color: Colors.red),
                            ),
                            TextSpan(
                              text: '   Deaths: ${MyHomePage.values[2]}',
                              style: TextStyle(fontSize: 24, color: Colors.white)
                            ),
                          ],
                        ),
                      );
                    }catch(e) {
                      return new Text("", style: TextStyle(fontSize: 20));
                    }
                  } else {
                    return new Text("", style: TextStyle(fontSize: 20));
                  }
                }
              ),
              SizedBox(height: 40),
              new Text('For Indian States..',
                style: TextStyle(fontSize: 50, fontFamily: 'DancingScript', color: Hexcolor('#00BFFF')),
              ),
              new FutureBuilder<List<String>>(
                future: fetchStates(),
                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  } else {
                    return new Container(
                      width: 280,
                      height: 50,
                      child: new Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Hexcolor('#708090'),
                        ),
                        child: new DropdownButton<String>(
                          hint: Text('Select a state', style: TextStyle(fontSize: 20, color: Colors.white)),
                          value: dropdownValueIndia,
                          items: snapshot.data.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: 20, color: Colors.white))
                            );
                          }).toList(),
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              dropdownValueIndia = value;
                            });
                          },
                        ),
                      ),
                    );
                  }
                }
              ),
              new FutureBuilder<List<String>>(
                future: fetchIndiaData(),
                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.hasData) {
                    MyHomePage.valuesIndia = snapshot.data;
                    try{
                      return RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.warning, size: 24, color: Colors.orange,),
                            ),
                            TextSpan(
                              text: '   Infected: ${MyHomePage.valuesIndia[0]}\n',
                              style: TextStyle(fontSize: 24, color: Colors.white)                  
                            ),
                            WidgetSpan(
                              child: Icon(Icons.check, size: 24, color: Colors.lightGreen),
                            ),
                            TextSpan(
                              text: '   Recovered: ${MyHomePage.valuesIndia[1]}\n',
                              style: TextStyle(fontSize: 24, color: Colors.white)
                            ),
                            WidgetSpan(
                              child: Icon(Icons.close, size: 24, color: Colors.red,),
                            ),
                            TextSpan(
                              text: '   Deaths: ${MyHomePage.valuesIndia[2]}\n',
                              style: TextStyle(fontSize: 24, color: Colors.white)
                            ),
                          ],
                        ),
                      );
                    } catch(e) {
                      return new Text("", style: TextStyle(fontSize: 20));
                    }
                  } else {
                    return new Text("", style: TextStyle(fontSize: 20));
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
