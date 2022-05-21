import 'dart:async';
import 'dart:convert';
import 'dart:html' as html; // or package:universal_html/prefer_universal/html.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const API_URL = 'https://lmqg-app-ijnzg4eymq-uc.a.run.app/question_generation';
const sampleFileDict = {
  "English": 'assets/squad_test_sample.txt',
  "Japanese": 'assets/squad_test_sample_ja.txt'
};
const itemsLanguage = ['English', 'Japanese'];
const itemsAnswerModel = {
  "English": ['Keyword', 'T5 SMALL', 'T5 BASE'],
  "Japanese": ['Keyword', 'mT5 SMALL (JA)']
};
const itemsQgModelDict = {
  "English": ['T5 SMALL', 'T5 BASE', 'T5 LARGE', 'BART BASE', 'BART LARGE'],
  "Japanese": ['mT5 SMALL (JA)', 'mT5 BASE (JA)']
};
const fontDict = {
  "English": 'RobotoMono',
  "Japanese": "Noto Sans JP"
};
const sentenceTextBoxError = {
  "English": 'Please enter some text',
  "Japanese": '文章を入力してください。'
};
const sentenceTextBox = {
  "English": "Enter text or press `Example` below to try sample documents.",
  "Japanese": '文章を入力もしくは`Example`をクリック。'
};
const sentenceTextBoxHighlight = {
  "English": '[Optional] Specify an answer from the text.',
  "Japanese": '[任意] 解答を指定する。'
};
const sentenceQGModel = {
  "English": 'Question Model',
  "Japanese": '質問生成モデル'
};
const sentenceAnswerModel = {
  "English": 'Answer Model',
  "Japanese": '解答抽出モデル'
};

Future<String> loadAsset(String sampleFile) async {
  return await rootBundle.loadString(sampleFile);
}

Future<Album> createAlbum(
    String inputText,
    String language,
    String answerModel,
    String qgModel,
    String highlight,
    int numBeams,
    double topP,
    ) async {
  final response = await http.post(
    Uri.parse(API_URL),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode({
      'input_text': inputText,
      'language': language,
      'answer_model': answerModel,
      'qg_model': qgModel,
      'highlight': highlight,
      'num_beams': numBeams,
      'use_gpu': false,
      'do_sample': true,
      'top_p': topP,
      'max_length': 64,
    }),
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(
        language == 'English' ? response.body : utf8.decode(response.bodyBytes))
    );
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

_launchEmail() async {
  const url = 'mailto:asahi1992ushio@gmail.com?subject=Inquiry about AutoQG &body=';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchHP() async {
  const url = 'https://asahiushio.com';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
_launchCardiffNLP() async {
  const url = 'https://cardiffnlp.github.io/';
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
  double numBeams = 4;
  double topP = 0.9;
  String language = 'English';
  var answerModel = {
    "English": "T5 SMALL",
    "Japanese": "mT5 SMALL"
  };
  var qgModel = {
    "English": "T5 BASE",
    "Japanese": "mT5 BASE"
  };

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

  var warningMessage = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
      style: new TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w800,
        color: Colors.red,
        fontFamily: 'Raleway',
      ),
      text: "WARNING: RUNNING WITH LIMITED RESOURCE NOW, SO IT GETS TO BE VERY SLOW OR UNREACHABLE!",
    ),
  );

  var description = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
      style: new TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w900,
        color: Colors.black54,
        fontFamily: 'RobotoMono',
      ),
      children: <TextSpan>[
        new TextSpan(text: 'Select'),
        new TextSpan(
            text: ' language ',
            style: new TextStyle(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Colors.pink[800]
            )
        ),
        new TextSpan(text: 'from the tab on the right top,'),
        new TextSpan(
            text: ' type ',
            style: new TextStyle(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Colors.pink[800]
            ),
        ),
        new TextSpan(text: 'into the text box, click'),
        new TextSpan(
          text: ' `Run`!',
          style: new TextStyle(
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: Colors.pink[800]
          ),
        )
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
      text: "Powered by language model fine-tuning on sequence generation.",
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

  var footerHeader = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
        style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            fontFamily: "Raleway"),
        children: [
          new TextSpan(
            text: "If you have any questions or inquiries, send to us!",
            style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
          WidgetSpan(child: IconButton(
            icon: const Icon(Icons.email_outlined, size: 20, color: Colors.white,),
            onPressed: _launchEmail,
            tooltip: 'Contact'))
        ]
    )
  );

  // load sample from SQuAD test split
  var sampleListDict = {
    "English": [],
    "Japanese": []
  };
  _MyHomePageState() {
    loadAsset(sampleFileDict['English']!).then((val) => setState(() {
      sampleListDict['English'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['Japanese']!).then((val) => setState(() {
      sampleListDict['Japanese'] = val.split("\n");
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
                icon: const Icon(Icons.tag_faces_rounded),
                // icon: Image.asset('assets/a.png'),
                tooltip: "Jump to developer's page",
                onPressed: _launchHP),
            IconButton(
                icon: const Icon(Icons.email),
                tooltip: 'Contact',
                onPressed: _launchEmail),
            IconButton(
                icon: Image.asset('assets/cardiff_nlp_logo_black.png'),
                tooltip: "Cardiff NLP Group",
                onPressed: _launchCardiffNLP),
            SizedBox(width: 15),
            DropdownButton(
              value: language,
              iconEnabledColor: Colors.black,
              icon: const Icon(Icons.language),
              items: itemsLanguage.map((String items) {
                return DropdownMenuItem(value: items, child: Text(items));
              }).toList(),
              onChanged: (String? newValue){
                setState(() {language = newValue!;});
              },
            ),
          ],
          backgroundColor: Color(0xFFFFFFF6),
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
                      description,
                      SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 550.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 20),
                            Expanded(
                                child: Column(
                                    children: [
                                      TextFormField(
                                        style: TextStyle(
                                            fontFamily: fontDict[language]
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return sentenceTextBox[language];
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            labelText: sentenceTextBox[language],
                                            border: OutlineInputBorder()
                                        ),
                                        maxLines: 10,
                                        controller: controllerContext,
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(child: TextFormField(
                                            style: TextStyle(
                                                fontFamily: fontDict[language]
                                            ),
                                            decoration: InputDecoration(
                                                labelText: sentenceTextBoxHighlight[language],
                                                border: OutlineInputBorder()
                                            ),
                                            maxLines: 1,
                                            controller: controllerHighlight,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children:[
                                                RichText(
                                                  textAlign: TextAlign.center,
                                                  text: new TextSpan(
                                                    text: sentenceQGModel[language],
                                                    style: new TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.blue,
                                                        fontFamily: 'RobotoMono'
                                                    ),
                                                  ),
                                                ),
                                                DropdownButton(
                                                  value: qgModel[language],
                                                  icon: Icon(Icons.keyboard_arrow_down),
                                                  items: itemsQgModelDict[language]!.map((String items) {
                                                    return DropdownMenuItem(value: items, child: Text(items));
                                                  }).toList(),
                                                  onChanged: (String? newValue){
                                                    setState(() {qgModel[language] = newValue!;});
                                                  },
                                                ),
                                              ]
                                          ),
                                          SizedBox(width: 20),
                                          Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children:[
                                                RichText(
                                                    textAlign: TextAlign.center,
                                                    text: new TextSpan(
                                                      text: sentenceAnswerModel[language],
                                                      style: new TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: Colors.blue,
                                                          fontFamily: 'RobotoMono'
                                                      ),
                                                    ),
                                                ),
                                                DropdownButton(
                                                  value: answerModel[language],
                                                  icon: Icon(Icons.keyboard_arrow_down),
                                                  items: itemsAnswerModel[language]!.map((String items) {
                                                    return DropdownMenuItem(value: items, child: Text(items));
                                                  }).toList(),
                                                  onChanged: (String? newValue){
                                                    setState(() {answerModel[language] = newValue!;});
                                                  },
                                                ),
                                              ]
                                          ),
                                        ]
                                      ),
                                      SizedBox(height: 20),
                                      Column(
                                          children: [
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Slider(
                                                        value: numBeams,
                                                        min: 1,
                                                        max: 10,
                                                        divisions: 9,
                                                        label: "Number of Beam (degree of exploration at inference): ${numBeams.round().toString()}",
                                                        onChanged: (double value) {
                                                          setState(() {numBeams = value;});
                                                        }),
                                                  ),
                                                ]
                                            ),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Slider(
                                                        value: topP,
                                                        min: 0.1,
                                                        max: 1,
                                                        divisions: 18,
                                                        label: "Top P Value (set small for less noisy generation): ${double.parse((topP).toStringAsFixed(2))}",
                                                        onChanged: (double value) {
                                                          setState(() {topP = value;});
                                                        }),
                                                  ),
                                                ]
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
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
                                                    controllerContext = TextEditingController(
                                                        text: (sampleListDict[language]!..shuffle()).first
                                                    );
                                                    controllerHighlight = TextEditingController();
                                                  },
                                                  icon: Icon(Icons.sports_esports_outlined),
                                                  label: Text('Example'),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.pink[800],
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    if (_formKey.currentState!.validate()) {
                                                      setState(() {});
                                                      setState(() {
                                                        _futureAlbum = createAlbum(
                                                            controllerContext.text,
                                                            language,
                                                            answerModel[language]!,
                                                            qgModel[language]!,
                                                            controllerHighlight.text,
                                                            numBeams.round(),
                                                            topP
                                                        );
                                                      });
                                                      controllerContext = TextEditingController(text: controllerContext.text);
                                                      controllerHighlight = TextEditingController(text: controllerHighlight.text);
                                                    }},
                                                  icon: Icon(Icons.upload_outlined),
                                                  label: Text('Run'),
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.teal,
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ]
                                      ),
                                    ]
                                )
                            ),
                            SizedBox(width: 35),
                            Expanded(child:
                            SingleChildScrollView(child:Container(
                              child: (_futureAlbum == null) ? initialReturnView() : buildFutureBuilder(language),
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
                            // SizedBox(height: 20),
                            Container(
                              width: 400,
                              height: 150,
                              child: FittedBox(child: Image.asset('assets/model.png'),),
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
                                Container(
                                  width: 500,
                                  height: 400,
                                  child: FittedBox(child: Image.asset('assets/solutions.png'),),
                                ),
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
                                SizedBox(height: 10,),
                                footerHeader,
                                SizedBox(height: 15),
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

  FutureBuilder<Album> buildFutureBuilder(String language) {
    return FutureBuilder<Album>(
      future: _futureAlbum,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting && !snapshot.hasError) {
          return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for ( var i in snapshot.data!.qa)
                    new SelectableText.rich(
                        new TextSpan(
                            style: new TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.lightBlue[900],
                                fontFamily: fontDict[language]
                            ),
                            children: <TextSpan>[
                              new TextSpan(text: i['question'].toString()),
                              new TextSpan(text: '\n'),
                              new TextSpan(
                                text: i['answer'].toString(),
                                style: new TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: fontDict[language]
                                ),
                              ),
                              new TextSpan(text: '\n'),
                            ]
                        )
                    )
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