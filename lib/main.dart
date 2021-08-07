import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';


const API_URL = String.fromEnvironment('API_URL', defaultValue: 'https://t5qg-ijnzg4eymq-uc.a.run.app/question_generation');

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/squad_test_sample.txt');
}

Future<Album> createAlbum(
    String inputText,
    String highlight,
    int beamSize
    ) async {
  final response = await http.post(
    Uri.parse(API_URL),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode({
      'input_text': inputText,
      'highlight': highlight,
      'num_beam': beamSize
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Ops something went wrong! Please try other inputs!');
  }
}

class Album {
  final List qa;
  Album({required this.qa});
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(qa: json['qa']);
  }
}


void main() => runApp(MyApp());

// const _url = 'mailto:asahi1992ushio@gmail.com?subject=Inquiry about AutoQG &body=';
// void _launchEmail() async =>
//     await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

_launchEmail() async {
  const url = 'mailto:asahi1992ushio@gmail.com?subject=Inquiry about AutoQG &body=';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchHP() async {
  const url = 'https://asahi417.github.io/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoQG: Automatic question generation powered by AI', // shown on the tab
      theme: ThemeData(fontFamily: 'RobotoMono', backgroundColor: Color(0xFFFFFFF6),
          scaffoldBackgroundColor: const Color(0xFFFFFFF6)
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var controllerContext = TextEditingController();
  var controllerHighlight = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<Album>? _futureAlbum;
  double beamSize = 4;

  var subTitle = new RichText(
    text: new TextSpan(
      style: new TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.w100,
        color: Colors.black,
        fontFamily: 'RobotoMono',
      ),
      children: <TextSpan>[
        new TextSpan(text: 'Automatic'),
        new TextSpan(
            text: ' Question & Answer ',
            style: new TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.pink[800]
            )
        ),
        new TextSpan(text: 'Generation'),
      ],
    ),
  );

  var conceptHeader = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
      style: new TextStyle(
        fontSize: 25.0,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        fontFamily: 'Raleway',
      ),
      text: "End-to-end Language Models Training on Complex Sentence Generation",
    ),
  );

  var conceptBody = new RichText(
    textAlign: TextAlign.left,
    text: new TextSpan(
      style: new TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w100,
          color: Colors.white,
          fontFamily: 'Roboto'
      ),
      children: [
        new TextSpan(
          text: "Automatic question & answer generation achieved by AI models trained on an end-to-end sentence generation.",
          style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
        ),
        new TextSpan(text: "\n\n"),
        WidgetSpan(child: Icon(Icons.chevron_right_sharp , size: 18, color: Colors.white,),),
        new TextSpan(text: " Model Variation: ", style: new TextStyle(fontWeight: FontWeight.w300,),),
        new TextSpan(text: "The quality depends on the model size, and this live demo relies on the smallest model so "
            "it would not reach the bar yet larger models might be able to overcome it.\n"
        ),
        WidgetSpan(child: Icon(Icons.chevron_right_sharp , size: 18, color: Colors.white,),),
        new TextSpan(text: " Custom Training: ", style: new TextStyle(fontWeight: FontWeight.w300,),),
        new TextSpan(text: "All the models so far are trained on public datasets but they can further train on any private datasets, "
            "which is usually recommended to boost end task accuracy.\n"
        ),
        WidgetSpan(child: Icon(Icons.chevron_right_sharp , size: 18, color: Colors.white,),),
        new TextSpan(text: " Multilinguality: ", style: new TextStyle(fontWeight: FontWeight.w300,),),
        new TextSpan(text: "The state-of-the-art mutilingual language models cover more than 100 languages that enables the QA generation on non-English locales."),
        new TextSpan(text: "\n\n"),
        new TextSpan(
          text: "Questions? Send to us!",
          style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500,),),
        WidgetSpan(child: IconButton(
          icon: const Icon(Icons.email_outlined, size: 20, color: Colors.white,),
          onPressed: _launchEmail,
          tooltip: 'Send an e-mail',
        ))
        ,
      ],
    ),
  );

  var solutionHeaderTop = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
        style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.black45,
            fontFamily: "Hahmlet"
        ),
        text: "SOLUTIONS"
    ),
  );

  var solutionHeaderBottom = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
        style: new TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
            color: Colors.black45,
            fontFamily: "Roboto"),
        text: "QA generation has a huge potential."
    ),
  );

  var footerHeader = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
        style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            fontFamily: "Raleway"),
        children: [
          new TextSpan(text: "We are open to any collaborations, supporters, and contributors. "),
          new TextSpan(text: "Reach out to us!", style: new TextStyle(fontWeight: FontWeight.w700))
        ]
    ),
  );

  var footerBody = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
        style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w300,
            color: Colors.black45,
            fontFamily: "Roboto"),
        text: " "
    ),
  );

  // load sample from SQuAD test split
  List<String> listExample = [];
  _MyHomePageState() {
    loadAsset().then((val) => setState(() {
      listExample = val.split("\n");
    }));
  }

  @override
  Widget build(BuildContext context) {

    ScrollController _scrollController = ScrollController();

    return Scaffold(
        appBar: AppBar(
          actionsIconTheme: IconThemeData(
              size: 30.0,
              color: Colors.black,
              opacity: 10.0),
          leadingWidth: 150,
          centerTitle: true,
          leading: Transform.scale(
            scale: 0.9,
            child: Image.asset('assets/logo_transparent.vertical.png'),
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.email),
                tooltip: 'Contact',
                onPressed: _launchEmail
            ),
            IconButton(
              icon: const Icon(Icons.supervised_user_circle),
              tooltip: 'About Developer',
              onPressed: _launchHP,
            ),
            // IconButton(
            //   icon: const Icon(Icons.free_breakfast),
            //   tooltip: 'Contact Us',
            //   onPressed: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('This is a snackbar')));
            //   },
            // ),
            // IconButton(
            //   icon: const Icon(Icons.language),
            //   tooltip: 'Contact Us',
            //   onPressed: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('This is a snackbar')));
            //   },
            // )
          ],
          // <Widget>[
          backgroundColor: Color(0xFFFFFFF6),
          // backgroundColor: Colors.white,
          // elevation: 0.0,
          // bottomOpacity: 0.0,
          // toolbarOpacity: 0.0
        ),
        body: SingleChildScrollView(
            controller: _scrollController,
            child:
            Form(
                key: _formKey,
                child:
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      subTitle,
                      SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 430.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 20),
                            Expanded(
                                child: Column(
                                    children: [
                                      TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            labelText: 'Enter a document to generate question & answer.',
                                            border: OutlineInputBorder()
                                        ),
                                        maxLines: 10,
                                        controller: controllerContext,
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        // initialValue: 'aa',
                                        decoration: InputDecoration(
                                            labelText: '(Optional) Specify the term that should be the answer.',
                                            border: OutlineInputBorder()
                                        ),
                                        maxLines: 1,
                                        controller: controllerHighlight,
                                      ),
                                      SizedBox(height: 20),
                                      Column(
                                          children: [
                                            Slider(
                                                value: beamSize,
                                                min: 1,
                                                max: 8,
                                                divisions: 7,
                                                label: "Beam size: ${beamSize.round().toString()} (improve generation quality)",
                                                onChanged: (double value) {
                                                  setState(() {beamSize = value;});
                                                }),
                                            // SizedBox(width: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    if (_formKey.currentState!.validate()) {
                                                      setState(() {});
                                                      setState(() {
                                                        _futureAlbum = createAlbum(
                                                            controllerContext.text,
                                                            controllerHighlight.text,
                                                            beamSize.round()
                                                        );
                                                      });
                                                      controllerContext = TextEditingController(text: controllerContext.text);
                                                      controllerHighlight = TextEditingController(text: controllerHighlight.text);
                                                  }},
                                                  icon: Icon(Icons.upload_outlined),
                                                  label: Text('Generate'),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.teal,
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                      controllerContext.clear();
                                                      controllerHighlight.clear();
                                                  },
                                                  icon: Icon(Icons.delete_outline),
                                                  label: Text('Reset'),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.black87,
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {});
                                                    controllerContext = TextEditingController(text: (listExample..shuffle()).first);
                                                    controllerHighlight = TextEditingController();
                                                  },
                                                  icon: Icon(Icons.sports_esports_outlined),
                                                  label: Text('Example'),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.pink[800],
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.grey,
                                                  ),
                                                )
                                              ],
                                            )
                                          ]
                                      ),
                                    ]
                                )
                            ),
                            SizedBox(width: 30),
                            Expanded(child:
                            SingleChildScrollView(child:Container(
                              child: (_futureAlbum == null) ? initialReturnView() : buildFutureBuilder(),
                            ),)
                            ),
                            SizedBox(width: 20)
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        // width: 1500.0,
                        color: Color(0xFFA8906F),
                        child:  Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 30,),
                            conceptHeader,
                            SizedBox(height: 8,),
                            Container(
                                height: 3,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                )),
                            SizedBox(height: 20),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(width: 40,),
                                  // Container(width: 20, color: Colors.white),
                                  Expanded(child: conceptBody),
                                  Expanded(child: Container(
                                    width: 160,
                                    height: 160,
                                    child: FittedBox(child: Image.asset('assets/model.png'),),
                                  ),
                                  ),
                                  SizedBox(width: 40,),
                                ]
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          // width: 1500.0,
                          color: Color(0xFFFFFFF6),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 20,),
                                solutionHeaderTop,
                                SizedBox(height: 8,),
                                Container(
                                    height: 3,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.black45,
                                        border: Border.all(color: Colors.black45),
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                    )
                                ),
                                solutionHeaderBottom,
                                Container(
                                  width: 500,
                                  height: 400,
                                  child: FittedBox(child: Image.asset('assets/solutions.png'),),
                                ),
                                // SizedBox(height: 10,),
                                SizedBox(height: 20),
                              ]
                          )
                      ),
                      Container(
                          width: double.infinity,
                          // width: 1500.0,
                          color: Color(0xFF444729),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 20,),
                                footerHeader,
                                SizedBox(height: 20),
                              ]
                          )
                      ),
                    ]
                )
            )
        )
    );
  }

  Container initialReturnView() {return Container();}

  FutureBuilder<Album> buildFutureBuilder() {
    return FutureBuilder<Album>(
      future: _futureAlbum,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting && !snapshot.hasError) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for ( var i in snapshot.data!.qa)
                      new RichText(
                          text: new TextSpan(
                              style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.lightBlue[900],
                                  fontFamily: 'Roboto'
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: i[0].toString()),
                                new TextSpan(text: '\n'),
                                new TextSpan(
                                  text: i[1].toString(),
                                  style: new TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Roboto'
                                  ),
                                ),
                                new TextSpan(text: '\n'),
                              ]
                          )
                      )
                  ],
                ),
              ]
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return LinearProgressIndicator(
            backgroundColor: Colors.teal[100],
            valueColor:new AlwaysStoppedAnimation<Color>(Colors.teal)
        );
      },
    );
  }
}