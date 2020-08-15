import 'package:flutter/material.dart';
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:regexpattern/regexpattern.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _processUrl() {
    _getUrlData().then((value) {
      if (value == null) return;
      debugPrint(value['og:title']);
      debugPrint(value['og:description']);
      debugPrint(value['og:site_name']);
      debugPrint(value['og:image']);
      debugPrint(value['og:type']);
      // debugPrint(value['og:url']);
    }).catchError((e) {
      debugPrint('error: $e');
    });
  }

  Future<Map> _getUrlData() async {
    if (!RegexValidation.hasMatch(_controller.text, RegexPattern.url)) {
      return null;
    }

    var response = await get(_controller.text);
    if (response.statusCode != 200) {
      return null;
    }

    var document = parse(response.body);
    Map data = {};
    _extractOGData(document, data, 'og:title');
    _extractOGData(document, data, 'og:description');
    _extractOGData(document, data, 'og:site_name');
    _extractOGData(document, data, 'og:image');
    _extractOGData(document, data, 'og:type');
    // _extractOGData(document, data, 'og:url');

    if (!this.mounted) return null;
    return data;
  }

  void _extractOGData(Document document, Map data, String parameter) {
    var titleMetaTag = document.getElementsByTagName("meta")?.firstWhere(
        (meta) => meta.attributes['property'] == parameter,
        orElse: () => null);
    if (titleMetaTag != null) {
      data[parameter] = titleMetaTag.attributes['content'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _controller,
            ),
            RaisedButton(
              onPressed: _processUrl,
              child: Text('Process'),
            ),
          ],
        ),
      ),
    );
  }
}
