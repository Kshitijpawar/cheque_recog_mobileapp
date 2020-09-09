import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Cheque Validation'),
      debugShowCheckedModeBanner: false,
    );
  }
}

// enum BankName { SBI, Axis }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String flaskEndPoint = "http://20.186.97.73:8080/imagehandling";
  // 'https://chequevalidation.herokuapp.com/imagehandling';
  // final String flaskEndPoint = 'http://192.168.43.254:5000/imagehandling';
  // final String flaskEndPoint = 'https://chequeappvalidation.azurewebsites.net/imagehandling';
  // final String flaskEndPoint = 'http://192.168.43.254:7071/api/HttpTrigger1';
  // final String flaskEndPoint =
  // 'https://chequevalidation.azurewebsites.net/api/HttpTrigger1?code=3Ms4iAsy3mpx32Tf9Fy9kU3oDJrQZC9PQ%2FtmADpJPmRNPI7JCXhCnQ%3D%3D';

  // BankName _character = BankName.SBI;
  bool _animationFlag = false;
  File _image;

  final picker = ImagePicker();
  Map<String, dynamic> parsed;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.);
    // for camera module instead of gallery
    // final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _upload() async {
    setState(() {
      parsed = null;
      _animationFlag = true;
    });
    if (_image == null) return;
    String filename = _image.path.split("/").last;
    var request = http.MultipartRequest('POST', Uri.parse(flaskEndPoint));
    request.files.add(http.MultipartFile(
        'hello', _image.readAsBytes().asStream(), _image.lengthSync(),
        filename: filename));
    var res = await request.send();
    var repr = await res.stream.bytesToString();
    parsed = json.decode(repr);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Radio(
            //         value: BankName.SBI,
            //         groupValue: _character,
            //         onChanged: (BankName value) {
            //           setState(() {
            //             _character = value;
            //           });
            //         }),
            //     Text('SBI'),
            //     Radio(
            //         value: BankName.Axis,
            //         groupValue: _character,
            //         onChanged: (BankName value) {
            //           setState(() {
            //             _character = value;
            //           });
            //         }),
            //     Text('Axis'),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: getImage,
                  child: Text('Choose Image'),
                ),
                SizedBox(
                  width: 10.0,
                ),
                RaisedButton(
                  onPressed: _upload,
                  child: Text('Upload Image'),
                ),
              ],
            ),
            SizedBox(
              width: 20.0,
            ),
            _image == null
                ? Text("No Image Selected")
                : Image.file(
                    _image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.scaleDown,
                  ),
            parsed == null
                ? _animationFlag
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Text('Please Upload an Image')
                : Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        String key = parsed.keys.elementAt(index);
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 5,
                          ),
                          // child: Text('${key} : ${parsed[key]}'),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: parsed[key] == 'Invalid'
                                  ? Colors.red
                                  : Colors.green,
                              child: Icon(
                                parsed[key] == 'Invalid'
                                    ? Icons.warning
                                    : Icons.check_circle,
                                size: 40,
                              ),
                            ),
                            title: Text(
                              '${key}',
                            ),
                            subtitle: Text(
                              '${parsed[key]}',
                            ),
                          ),
                        );
                      },
                      itemCount: parsed.length,
                    ),
                  ),
          ],
        ));
  }
}
