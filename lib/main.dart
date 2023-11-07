import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';


const API_URL = 'https://lmqg-api-ijnzg4eymq-uc.a.run.app/question_generation';
const sampleFileDict = {
  "English": 'assets/squad_test_sample.txt',
  "Japanese": 'assets/squad_test_sample_ja.txt',
  "German": 'assets/squad_test_sample_de.txt',
  "Spanish": 'assets/squad_test_sample_es.txt',
  "Italian": 'assets/squad_test_sample_it.txt',
  "Korean": 'assets/squad_test_sample_ko.txt',
  "Russian": 'assets/squad_test_sample_ru.txt',
  "French": 'assets/squad_test_sample_fr.txt'
};
const itemsLanguage = ['English', 'Japanese', 'German', 'Spanish', 'Italian', 'Korean', 'Russian', 'French'];
const itemsQAGProcessItem = ['Paragraph', 'Sentence'];
const itemsQAGTypeDict = {
  "English": ['End2End', 'Pipeline'],
  "Japanese": ['End2End', 'Pipeline'],
  "German": ['Pipeline'],
  "Spanish": ['End2End', 'Pipeline'],
  "Italian": ['End2End', 'Pipeline'],
  "Korean": ['End2End', 'Pipeline'],
  "Russian": ['End2End', 'Pipeline'],
  "French": ['End2End', 'Pipeline']
};
const itemsQAGModelDict = {
  "English": ['T5 SMALL', 'T5 BASE', 'Flan-T5 SMALL', 'Flan-T5 BASE'],
  "Japanese": ['mT5 SMALL (JA)', 'mT5 BASE (JA)'],
  "German": ['mT5 SMALL (DE)'],
  "Spanish": ['mT5 SMALL (ES)', 'mT5 BASE (ES)'],
  "Italian": ['mT5 SMALL (IT)', 'mT5 BASE (IT)'],
  "Korean": ['mT5 SMALL (KO)', 'mT5 BASE (KO)'],
  "Russian": ['mT5 SMALL (RU)', 'mT5 BASE (RU)'],
  'French': ['mT5 SMALL (FR)', 'mT5 BASE (FR)']
};
const fontDict = {
  "English": 'RobotoMono',
  "Japanese": "Noto Sans JP",
  "German": 'RobotoMono',
  "Spanish": 'RobotoMono',
  "Italian": 'RobotoMono',
  "Korean": 'RobotoMono',
  "Russian": 'RobotoMono',
  'French': 'RobotoMono',
};
const sentenceTextBoxError = {
  "English": 'Please enter some text',
  "Japanese": '文章を入力してください。',
  "German": 'Please enter some text',
  "Spanish": 'Please enter some text',
  "Italian": 'Please enter some text',
  "Korean": 'Please enter some text',
  "Russian": 'Please enter some text',
  'French': 'Please enter some text',
};
const sentenceTextBox = {
  "English": "Enter text or press `Example` below to try sample documents.",
  "Japanese": '文章を入力もしくは`Example`をクリック。',
  "German": 'Enter text or press `Example` below to try sample documents.',
  "Spanish": 'Enter text or press `Example` below to try sample documents.',
  "Italian": 'Enter text or press `Example` below to try sample documents.',
  "Korean": 'Enter text or press `Example` below to try sample documents.',
  "Russian": 'Enter text or press `Example` below to try sample documents.',
  'French': 'Enter text or press `Example` below to try sample documents.',
};
const sentenceTextBoxHighlight = {
  "English": '[Optional] Specify an answer from the text.',
  "Japanese": '[任意] 解答を指定する。',
  "German": '[Optional] Specify an answer from the text.',
  "Spanish": '[Optional] Specify an answer from the text.',
  "Italian": '[Optional] Specify an answer from the text.',
  "Korean": '[Optional] Specify an answer from the text.',
  "Russian": '[Optional] Specify an answer from the text.',
  'French': '[Optional] Specify an answer from the text.',
};
const subTitleQAGModel = {
  "English": 'QAG Model',
  "Japanese": '生成モデル',
  "German": 'QAG Model',
  "Spanish": 'QAG Model',
  "Italian": 'QAG Model',
  "Korean": 'QAG Model',
  "Russian": 'QAG Model',
  'French': 'QAG Model',
};
const subTitleQAGType = {
  "English": 'QAG Type',
  "Japanese": '生成タイプ',
  "German": 'QAG Type',
  "Spanish": 'QAG Type',
  "Italian": 'QAG Type',
  "Korean": 'QAG Type',
  "Russian": 'QAG Type',
  'French': 'QAG Type',
};

const subTitleQAGProcess = {
  "English": 'Split',
  "Japanese": '分割方法',
  "German": 'Split',
  "Spanish": 'Split',
  "Italian": 'Split',
  "Korean": 'Split',
  "Russian": 'Split',
  'French': 'Split',
};


const Title = {
  "English": 'Generate QA with AI',
  "Japanese": '機械学習AIによるQA生成デモ',
  "German": 'Generate QA with AI',
  "Spanish": 'Generate QA with AI',
  "Italian": 'Generate QA with AI',
  "Korean": 'Generate QA with AI',
  "Russian": 'Generate QA with AI',
  'French': "Generate QA with AI"
};

const Desc = {
  "English": 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.',
  "Japanese": '右上のタブで言語を選択し、テキストボックスに入力して RUN をクリックすると、AI が質問と回答を生成します。',
  "German": 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.',
  "Spanish": 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.',
  "Italian": 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.',
  "Korean": 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.',
  "Russian": 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.',
  'French': 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.'
};


Future<String> loadAsset(String sampleFile) async {
  return await rootBundle.loadString(sampleFile);
}

Future<Album> createAlbum(
    String inputText,
    String language,
    String qagType,
    String qagModel,
    String highlight,
    int numBeams,
    double topP,
    String split,
    ) async {
  final response = await http.post(
    Uri.parse(API_URL),
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode({
      'input_text': inputText,
      'language': language,
      'qag_type': qagType,
      'model': qagModel,
      'highlight': highlight,
      'num_beams': numBeams,
      'split': split,
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
        utf8.decode(response.bodyBytes)
    )
    );
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Something went wrong! Please try other inputs!');
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

_launchPaper() async {
  const url = 'https://aclanthology.org/2022.emnlp-main.42/';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
_launchGithub() async {
  const url = 'https://github.com/asahi417/lm-question-generation';
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
      title: 'AutoQG: Multilingual automatic question & answer generation powered by AI', // shown on the tab
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
  bool isSwitched = false;
  double numBeams = 4;
  double topP = 0.95;
  String language = 'English';
  var qagSplit = "Paragraph";
  var qagType = {
    "English": "End2End",
    "Japanese": "Pipeline",
    "German": "Pipeline",
    "Spanish": "End2End",
    "Italian": "End2End",
    "Korean": "End2End",
    "Russian": "Pipeline",
    'French': "End2End"
  };
  var qagModel = {
    "English": 'T5 SMALL',
    "Japanese": 'mT5 SMALL (JA)',
    "German": 'mT5 SMALL (DE)',
    "Spanish": "mT5 SMALL (ES)",
    "Italian": "mT5 SMALL (IT)",
    "Korean": "mT5 SMALL (KO)",
    "Russian": "mT5 SMALL (RU)",
    'French': "mT5 SMALL (FR)"
  };

  var resultHeader = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
        style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
            color: Colors.black45,
            fontFamily: "RobotoMono"
        ),
        text: "Generated QA Pairs"
    ),
  );

  // load sample from SQuAD test split
  var sampleListDict = {
    "English": [],
    "Japanese": [],
    "German": [],
    "Spanish": [],
    "Italian": [],
    "Korean": [],
    "Russian": [],
    "French": []
  };
  _MyHomePageState() {
    loadAsset(sampleFileDict['English']!).then((val) => setState(() {
      sampleListDict['English'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['Japanese']!).then((val) => setState(() {
      sampleListDict['Japanese'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['German']!).then((val) => setState(() {
      sampleListDict['German'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['Spanish']!).then((val) => setState(() {
      sampleListDict['Spanish'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['Italian']!).then((val) => setState(() {
      sampleListDict['Italian'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['Korean']!).then((val) => setState(() {
      sampleListDict['Korean'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['Russian']!).then((val) => setState(() {
      sampleListDict['Russian'] = val.split("\n");
    }));
    loadAsset(sampleFileDict['French']!).then((val) => setState(() {
      sampleListDict['French'] = val.split("\n");
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
                tooltip: "About Developer",
                onPressed: _launchHP),
            IconButton(
                icon: const Icon(Icons.article),
                tooltip: "Read Article",
                onPressed: _launchPaper),
            IconButton(
                icon: const Icon(Icons.computer),
                tooltip: "LMQG: Python Library for QG",
                onPressed: _launchGithub),
            IconButton(
                icon: const Icon(Icons.group_outlined),
                tooltip: "CardiffNLP",
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
                      new RichText(
                        textAlign: TextAlign.center,
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: 'RobotoMono',
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                              text: Title[language],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20),
                            Expanded(child:
                              new RichText(
                              textAlign: TextAlign.center,
                              text: new TextSpan(
                                text: Desc[language],
                                style: new TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                  fontFamily: 'RobotoMono',
                                ),
                              ),
                            )
                            ),
                            SizedBox(width: 20),
                          ]
                      ),
                      SizedBox(height: 20),
                      Row(
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
                                                    text: subTitleQAGModel[language],
                                                    style: new TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.blue,
                                                        fontFamily: 'RobotoMono'
                                                    ),
                                                  ),
                                                ),
                                                DropdownButton(
                                                  value: qagModel[language],
                                                  icon: Icon(Icons.keyboard_arrow_down),
                                                  items: itemsQAGModelDict[language]!.map((String items) {
                                                    return DropdownMenuItem(value: items, child: Text(items));
                                                  }).toList(),
                                                  onChanged: (String? newValue){
                                                    setState(() {qagModel[language] = newValue!;});
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
                                                      text: subTitleQAGType[language],
                                                      style: new TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: Colors.blue,
                                                          fontFamily: 'RobotoMono'
                                                      ),
                                                    ),
                                                ),
                                                DropdownButton(
                                                  value: qagType[language],
                                                  icon: Icon(Icons.keyboard_arrow_down),
                                                  items: itemsQAGTypeDict[language]!.map((String items) {
                                                    return DropdownMenuItem(value: items, child: Text(items));
                                                  }).toList(),
                                                  onChanged: (String? newValue){
                                                    setState(() {qagType[language] = newValue!;});
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
                                                    text: subTitleQAGProcess[language],
                                                    style: new TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.blue,
                                                        fontFamily: 'RobotoMono'
                                                    ),
                                                  ),
                                                ),
                                                DropdownButton(
                                                  value: qagSplit,
                                                  icon: Icon(Icons.keyboard_arrow_down),
                                                  items: itemsQAGProcessItem.map((String items) {
                                                    return DropdownMenuItem(value: items, child: Text(items));
                                                  }).toList(),
                                                  onChanged: (String? newValue){
                                                    setState(() {qagSplit = newValue!;});
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
                                                        label: " Beam Size (degree of exploration at inference) : ${numBeams.round().toString()} ",
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
                                                        label: " Top-P (less noisy but less diverse with smaller value): ${double.parse((topP).toStringAsFixed(2))} ",
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
                                                    backgroundColor: Colors.pink[800],
                                                    foregroundColor: Colors.white,
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
                                                            qagType[language]!,
                                                            qagModel[language]!,
                                                            controllerHighlight.text,
                                                            numBeams.round(),
                                                            topP,
                                                            qagSplit
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
                            SizedBox(width: 20)
                          ],
                        ),
                      SizedBox(height: 40),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 550.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 20),
                            Expanded(child:
                            SingleChildScrollView(
                              child:Container(
                                child: (_futureAlbum == null) ? initialReturnView() : buildFutureBuilder(language),
                            ),)
                            ),
                            SizedBox(width: 20)
                          ],
                        ),
                      )
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
                  Container(
                      width: double.infinity,
                      color: Color(0xFFFFFFF6),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            resultHeader,
                            SizedBox(height: 8,),
                            Container(
                                height: 3,
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.black45
                                )
                            ),
                          ]
                      )
                  ),
                  SizedBox(height: 14),
                  InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: snapshot.data!.qa.join("\n")));
                        },
                      child: RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(text: "Copy to clipboard! ", style: new TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.pink[800],
                                    fontFamily: fontDict[language]
                                )),
                                WidgetSpan(child: Icon(Icons.copy_all_outlined, size: 16, color: Colors.pink[800])),
                              ]
                          )
                      )
                  ),
                  SizedBox(height: 6),
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
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: fontDict[language]
                                ),
                              ),
                              new TextSpan(text: '\n'),
                              new TextSpan(
                                text: 'Confidence: ' + i['score'].toStringAsFixed(2),
                                style: new TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.teal,
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