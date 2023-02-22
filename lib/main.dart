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
const itemsQAGProcessItem = ['sentence', 'paragraph'];
const itemsQAGTypeDict = {
  // "English": ['Default', 'End2End', 'Pipeline', 'Multitask'],
  // "Japanese": ['Default', 'End2End', 'Pipeline', 'Multitask'],
  // "German": ['Default', 'End2End', 'Pipeline', 'Multitask'],
  // "Spanish": ['Default', 'End2End', 'Pipeline', 'Multitask'],
  // "Italian": ['Default', 'End2End', 'Pipeline', 'Multitask'],
  // "Korean": ['Default', 'End2End', 'Pipeline', 'Multitask'],
  // "Russian": ['Default', 'End2End', 'Pipeline', 'Multitask'],
  // "French": ['Default', 'End2End', 'Pipeline', 'Multitask']
  "English": ['Default'],
  "Japanese": ['Default'],
  "German": ['Default'],
  "Spanish": ['Default'],
  "Italian": ['Default'],
  "Korean": ['Default'],
  "Russian": ['Default'],
  "French": ['Default']
};
const itemsQAGModelDict = {
  "English": ['Default', 'T5 SMALL', 'T5 BASE', 'T5 LARGE', 'BART BASE', 'BART LARGE'],
  "Japanese": ['Default', 'mT5 SMALL (JA)', 'mT5 BASE (JA)', 'mBART LARGE (JA)'],
  "German": ['Default', 'mT5 SMALL (DE)', 'mT5 BASE (DE)', 'mBART LARGE (DE)'],
  "Spanish": ['Default', 'mT5 SMALL (ES)', 'mT5 BASE (ES)', 'mBART LARGE (ES)'],
  "Italian": ['Default', 'mT5 SMALL (IT)', 'mT5 BASE (IT)', 'mBART LARGE (IT)'],
  "Korean": ['Default', 'mT5 SMALL (KO)', 'mT5 BASE (KO)', 'mBART LARGE (KO)'],
  "Russian": ['Default', 'mT5 SMALL (RU)', 'mT5 BASE (RU)', 'mBART LARGE (RU)'],
  'French': ['Default', 'mT5 SMALL (FR)', 'mT5 BASE (FR)', 'mBART LARGE (FR)']
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
  "German": 'Bitte geben Sie einen Text ein',
  "Spanish": 'Por favor, introduzca un texto',
  "Italian": 'Per favore, inserisci del testo',
  "Korean": '텍스트를 입력하세요',
  "Russian": 'Пожалуйста, введите текст',
  'French': 'Veuillez saisir du texte',
};
const sentenceTextBox = {
  "English": "Enter text or press `Example` below to try sample documents.",
  "Japanese": '文章を入力もしくは`Example`をクリック。',
  "German": 'Geben Sie Text ein oder klicken Sie unten auf `Example`, um Beispieldokumente auszuprobieren.',
  "Spanish": 'Ingrese texto o presione `Example` a continuación para probar documentos de muestra.',
  "Italian": 'Immettere il testo o premere `Example` di seguito per provare documenti di esempio.',
  "Korean": '텍스트를 입력하거나 아래의 `Example`를 눌러 샘플 문서를 사용해 보세요.',
  "Russian": 'Введите текст или нажмите `Example` ниже, чтобы попробовать образцы документов.',
  'French': 'Saisissez du texte ou appuyez sur "Exemple" ci-dessous pour essayer des exemples de documents.',
};
const sentenceTextBoxHighlight = {
  "English": '[Optional] Specify an answer from the text.',
  "Japanese": '[任意] 解答を指定する。',
  "German": '[Optional] Geben Sie eine Antwort aus dem Text an.',
  "Spanish": '[Opcional] Especifique una respuesta del texto.',
  "Italian": '[Facoltativo] Specificare una risposta dal testo.',
  "Korean": '[선택 사항] 텍스트에서 답변을 지정합니다.',
  "Russian": '[Необязательно] Укажите ответ из текста.',
  'French': '[Facultatif] Spécifiez une réponse à partir du texte.',
};
const subTitleQAGModel = {
  "English": 'QAG Model',
  "Japanese": '生成モデル',
  "German": 'Generatives Modell',
  "Spanish": 'modelo generativo',
  "Italian": 'Modello generativo',
  "Korean": '생성 모델',
  "Russian": 'Генеративная модель',
  'French': 'Modèle Génératif',
};
const subTitleQAGType = {
  "English": 'QAG Type',
  "Japanese": '生成タイプ',
  "German": 'Generationstyp',
  "Spanish": 'Tipo de generación',
  "Italian": 'Tipo di generazione',
  "Korean": '세대 유형',
  "Russian": 'Тип генерации',
  'French': 'Type de génération',
};

const subTitleQAGProcess = {
  "English": 'Split',
  "Japanese": '分割方法',
  "German": 'Teilen',
  "Spanish": 'Terrible',
  "Italian": 'Scissione',
  "Korean": '파편',
  "Russian": 'Разделение',
  'French': 'Scission',
};


const Title = {
  "English": 'Write QA with AI',
  "Japanese": '機械学習AIによるQA生成デモ',
  "German": 'Schreiben Sie QA mit KI',
  "Spanish": 'Escribir control de calidad con IA',
  "Italian": 'Scrivi QA con AI',
  "Korean": 'AI로 QA 작성',
  "Russian": 'Пишите QA с ИИ',
  'French': "Rédiger le QA avec l'IA"
};

const Desc = {
  "English": 'Select LANGUAGE on the right top tab, TYPE into the text box, and click RUN to get question & answer generated by AI.',
  "Japanese": '右上のタブで言語を選択し、テキストボックスに入力して RUN をクリックすると、AI が質問と回答を生成します。',
  "German": 'Wählen Sie SPRACHE auf der rechten oberen Registerkarte, geben Sie sie in das Textfeld ein und klicken Sie auf AUSFÜHREN, um die von der KI generierten Fragen und Antworten zu erhalten.',
  "Spanish": 'Selecciona IDIOMA en la pestaña superior derecha, ESCRIBE en el cuadro de texto y haz clic en EJECUTAR para obtener preguntas y respuestas generadas por IA.',
  "Italian": "Seleziona LINGUA nella scheda in alto a destra, DIGITA nella casella di testo e fai clic su ESEGUI per ottenere domande e risposte generate dall'IA.",
  "Korean": '오른쪽 상단 탭에서 LANGUAGE를 선택하고 텍스트 상자에 TYPE을 입력한 다음 RUN을 클릭하면 AI가 생성한 질문과 답변을 받을 수 있습니다.',
  "Russian": 'Выберите «ЯЗЫК» на правой верхней вкладке, ВВЕДИТЕ в текстовое поле и нажмите «Выполнить», чтобы получить вопросы и ответы, сгенерированные ИИ.',
  'French': "Sélectionnez LANGUE dans l'onglet supérieur droit, TAPEZ dans la zone de texte et cliquez sur EXÉCUTER pour obtenir la question et la réponse générées par l'IA."
};

// const Footer = {
//   "English": 'Powered by language model fine-tuning on sequence generation.',
//   "Japanese": 'Se',
//   "German": 'Wählen Sie SPRACHE auf der rechten oberen Registerkarte, geben Sie sie in das Textfeld ein und klicken Sie auf AUSFÜHREN, um die von der KI generierten Fragen und Antworten zu erhalten.',
//   "Spanish": 'Selecciona IDIOMA en la pestaña superior derecha, ESCRIBE en el cuadro de texto y haz clic en EJECUTAR para obtener preguntas y respuestas generadas por IA.',
//   "Italian": "Seleziona LINGUA nella scheda in alto a destra, DIGITA nella casella di testo e fai clic su ESEGUI per ottenere domande e risposte generate dall'IA.",
//   "Korean": '오른쪽 상단 탭에서 LANGUAGE를 선택하고 텍스트 상자에 TYPE을 입력한 다음 RUN을 클릭하면 AI가 생성한 질문과 답변을 받을 수 있습니다.',
//   "Russian": 'Работает на тонкой настройке языковой модели при генерации последовательности.',
//   'French': "Sélectionnez LANGUE dans l'onglet supérieur droit, TAPEZ dans la zone de texte et cliquez sur EXÉCUTER pour obtenir la question et la réponse générées par l'IA."
// };


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
  double numBeams = 5;
  double topP = 0.95;
  String language = 'English';
  var qagSplit = "sentence";
  var qagType = {
    "English": "Default",
    "Japanese": "Default",
    "German": "Default",
    "Spanish": "Default",
    "Italian": "Default",
    "Korean": "Default",
    "Russian": "Default",
    'French': "Default"
  };
  var qagModel = {
    "English": "Default",
    "Japanese": "Default",
    "German": "Default",
    "Spanish": "Default",
    "Italian": "Default",
    "Korean": "Default",
    "Russian": "Default",
    'French': "Default"
  };

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

  // var description = new RichText(
  //   textAlign: TextAlign.center,
  //   text: new TextSpan(
  //     style: new TextStyle(
  //       fontSize: 15.0,
  //       fontWeight: FontWeight.w500,
  //       color: Colors.black54,
  //       fontFamily: 'RobotoMono',
  //     ),
  //     children: <TextSpan>[
  //       new TextSpan(text: 'Select'),
  //       new TextSpan(
  //           text: ' language ',
  //           style: new TextStyle(
  //               fontWeight: FontWeight.w800,
  //               fontStyle: FontStyle.italic,
  //               color: Colors.pink[800]
  //           )
  //       ),
  //       new TextSpan(text: 'on the right top tab,'),
  //       new TextSpan(
  //           text: ' type ',
  //           style: new TextStyle(
  //               fontWeight: FontWeight.w800,
  //               fontStyle: FontStyle.italic,
  //               color: Colors.pink[800]
  //           ),
  //       ),
  //       new TextSpan(text: 'into the text box, and click'),
  //       new TextSpan(
  //         text: ' Run ',
  //         style: new TextStyle(
  //             fontWeight: FontWeight.w800,
  //             fontStyle: FontStyle.italic,
  //             color: Colors.pink[800]
  //         ),
  //       ),
  //       new TextSpan(text: 'to get question & answer written by AI models.\n'),
  //       new TextSpan(
  //         text: '*First run may take longer for model loading.',
  //         style: new TextStyle(
  //             fontSize: 12.0,
  //             // fontWeight: FontWeight.w800,
  //             fontStyle: FontStyle.italic,
  //             // color: Colors.pink[800]
  //         ),
  //       ),
  //     ],
  //   ),
  // );

  var conceptHeader = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
      style: new TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w200,
        color: Colors.white,
        fontFamily: 'RobotoMono',
      ),
      text: "Powered by language model fine-tuning on sequence generation.",
    ),
  );

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

  var footerHeader = new RichText(
    textAlign: TextAlign.center,
    text: new TextSpan(
        style: new TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w100,
            color: Colors.white,
            fontFamily: "RobotoMono"),
        children: [
          new TextSpan(text: "Send to us any questions or inquiries"),
          WidgetSpan(child: IconButton(
            icon: const Icon(Icons.email_outlined, size: 14, color: Colors.white,),
            onPressed: _launchEmail,
            tooltip: 'Contact')),
          // SizedBox(height: 13,),
          new TextSpan(text: "\nCheck our NLP group"),
          WidgetSpan(child: IconButton(
              icon: const Icon(Icons.group_outlined, size: 14, color: Colors.white,),
              onPressed: _launchCardiffNLP,
              tooltip: 'Cardiff NLP'))
        ]
    )
  );

  // IconButton(
  // icon: Image.asset('assets/cardiff_nlp_logo_black.png'),
  // tooltip: "Cardiff NLP Group",
  // onPressed: _launchCardiffNLP),

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
            // IconButton(
            //     icon: const Icon(Icons.email),
            //     tooltip: 'Contact',
            //     onPressed: _launchEmail),
            // IconButton(
            //     icon: Image.asset('assets/cardiff_nlp_logo_black.png'),
            //     tooltip: "Cardiff NLP Group",
            //     onPressed: _launchCardiffNLP),
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
                                          // SizedBox(width: 20),
                                          // SwitchListTile(
                                          //   title: Text("sample"),
                                          //   value: isSwitched,
                                          //   onChanged: (value) {
                                          //     setState(() {
                                          //       isSwitched = value;
                                          //       print(isSwitched);
                                          //     });
                                          //   },
                                          //   activeTrackColor: Colors.lightGreenAccent,
                                          //   activeColor: Colors.green,
                                          // )
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
                                                        label: "Top P Value (decrease to get less noisy but less diverse generation): ${double.parse((topP).toStringAsFixed(2))}",
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
                      ),
                      SizedBox(height: 30),
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
                            footerHeader,
                            SizedBox(height: 20,),
                          ],
                        ),
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
                  Container(
                      width: double.infinity,
                      color: Color(0xFFFFFFF6),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SizedBox(height: 20,),
                            resultHeader,
                            SizedBox(height: 8,),
                            Container(
                                height: 3,
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    // border: Border.all(color: Colors.black45),
                                    // borderRadius: BorderRadius.all(Radius.circular(20))
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