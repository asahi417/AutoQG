import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


const API_URL = 'https://lm-question-generation-ijnzg4eymq-uc.a.run.app/question_generation';
const API_URL_JA = 'https://lm-question-generation-ja-ijnzg4eymq-uc.a.run.app/question_generation';
const SAMPLE_FILE = 'assets/squad_test_sample.txt';
const SAMPLE_FILE_JA = 'assets/squad_test_sample_ja.txt';

Future<String> loadAsset(String sampleFile) async {
  return await rootBundle.loadString(sampleFile);
}

Future<Album> createAlbum(
    String inputText,
    String highlight,
    int numQuestions,
    String answerModel,
    String language,
    ) async {
  String apiUrl = language == 'English' ? API_URL : API_URL_JA;
  // String apiUrl = language == 'Japanese' ? API_URL_JA : API_URL_EN;
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode({
      'input_text': inputText,
      'highlight': highlight,
      'num_questions': numQuestions,
      'answer_model': answerModel.replaceAll('span', 'language_model').replaceAll('keyword', 'keyword_extraction')
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
  double numQuestions = 5;
  String answerModel = 'keyword';
  var items =  ['keyword', 'span'];
  String language = 'English';
  var itemsLanguage =  ['English', 'Japanese'];

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
            tooltip: 'E-mail'))
        ]
    )
  );

  // load sample from SQuAD test split
  List<String> listExample = [];
  List<String> listExampleJa = [];
  _MyHomePageState() {
    loadAsset(SAMPLE_FILE).then((val) => setState(() {
      listExample = val.split("\n");
    }));
    loadAsset(SAMPLE_FILE_JA).then((val) => setState(() {
      listExampleJa = val.split("\n");
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
                onPressed: _launchEmail),
            IconButton(
              icon: const Icon(Icons.supervised_user_circle),
              tooltip: 'About the developer',
              onPressed: _launchHP),
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
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 450.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 20),
                            Expanded(
                                child: Column(
                                    children: [
                                      TextFormField(
                                        style: TextStyle(
                                            fontFamily:language == 'English' ? 'RobotoMono' : "Noto Sans JP"
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return language == 'English' ? 'Please enter some text' : '文章を入力してください。';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            labelText: language == 'English' ? 'Enter text or press `Sample` below to try sample documents.' : '文章を入力もしくは`Sample`をクリック。',
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
                                                fontFamily:language == 'English' ? 'RobotoMono' : "Noto Sans JP"
                                            ),
                                            decoration: InputDecoration(
                                                labelText: language == 'English' ? '[Optional] Specify an answer from the text.' : '[任意] 解答を指定する。',
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
                                                      text: language == 'English' ? 'Answer Type' : '解答抽出モデル',
                                                      style: new TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: Colors.blue,
                                                          fontFamily: 'RobotoMono'
                                                      ),
                                                    ),
                                                ),
                                                DropdownButton(
                                                  value: answerModel,
                                                  icon: Icon(Icons.keyboard_arrow_down),
                                                  items: items.map((String items) {
                                                    return DropdownMenuItem(value: items, child: Text(items));
                                                  }).toList(),
                                                  onChanged: (String? newValue){
                                                    setState(() {answerModel = newValue!;});
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
                                                      value: numQuestions,
                                                      min: 1,
                                                      max: 15,
                                                      divisions: 14,
                                                      label: "Number of questions: ${numQuestions.round().toString()}",
                                                      onChanged: (double value) {
                                                        setState(() {numQuestions = value;});
                                                      }),
                                                ),
                                              ]
                                            ),
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
                                                            numQuestions.round(),
                                                            answerModel,
                                                            language
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
                                                    controllerContext = TextEditingController(
                                                        text: language == 'English' ? (listExample..shuffle()).first : (listExampleJa..shuffle()).first
                                                    );
                                                    controllerHighlight = TextEditingController();
                                                  },
                                                  icon: Icon(Icons.sports_esports_outlined),
                                                  label: Text('Sample'),
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
                                fontFamily: language == 'English' ? 'Roboto' : "Noto Sans JP"
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
                                    fontFamily: language == 'English' ? 'Roboto' : "Noto Sans JP"
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