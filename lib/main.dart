import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:async';
import 'package:flutter/services.dart';

import 'package:flutter_kanban/loginPage.dart';
import 'package:flutter_kanban/editTaskPage.dart';


final apiUrl = Uri.parse('http://91.149.187.115:8060');
String token = ""; // Переменная для хранения токена
int luid = 0; // Переменная для хранения LUID
String? uuid; // Переменная для хранения UUID
//List<String> mainMenuList = <String>['Все проекты', 'Сельпо', 'Аграр', 'Химизация'];
List<String> mainMenuList = <String>['Все проекты'];
List<dynamic> tasksInfoList = [];
List<dynamic> usersInfoList = [];
final controllerForAdmin = StreamController<int>();
final controllerForUser = StreamController<int>();
String destinationForGetTasks = '';
StreamController<int> _controllerTemp = StreamController<int>();
StreamSubscription subscription = _controllerTemp.stream.listen((value) {});
List<String> roles = [];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class MyTextView extends StatefulWidget {
  @override
  MyTextViewState createState() => MyTextViewState();
}

class MyTextViewState extends State<MyTextView> {
  //String mainWindowText = "Everything";
  String mainWindowText = "Все проекты";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 19.0, top: 47.0),
      child: Row(
        children: [
          /*ElevatedButton(
            onPressed: () {
              // Действие при нажатии на кнопку (вывод сообщения в консоль)
              print('Кнопка назад нажата');
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              size: 30.0,
            ),
          ),*/
          Text(
            mainWindowText,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              height: 1.2,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0), // Отступ слева
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: PopupMenuButton(
                offset: const Offset(-30, 0), // сдвиг по вертикали
                itemBuilder: (context) =>
                [
                  const PopupMenuItem(
                    value: "Все проекты",
                    child: Text("Все проекты"),
                  ),
                  const PopupMenuItem(
                    value: "Сельпо",
                    child: Text("Сельпо"),
                  ),
                  const PopupMenuItem(
                    value: "Аграр",
                    child: Text("Аграр"),
                  ),
                  const PopupMenuItem(
                    value: "Химизация",
                    child: Text("Химизация"),
                  ),
                ],
                onSelected: (value) {
                  setState(() {
                    mainWindowText = value;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(left: 5.0),
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ),

            ),
          ),
        ],
      ),
    );
  }
}

// class MyRectangle extends StatefulWidget {
//   final String text;
//   final Function(String) onTextChanged;
//
//   const MyRectangle({Key? key, required this.text, required this.onTextChanged}) : super(key: key);
//
//   @override
//   MyRectangleState createState() => MyRectangleState();
// }
//
// class MyRectangleState extends State<MyRectangle> {
//   String _text = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _text = widget.text;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         final editedText = await Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => EditTaskPage(initialText: _text)),
//         );
//         if (editedText != null && editedText != "") {
//           setState(() {
//             _text = editedText;
//           });
//           widget.onTextChanged(editedText);
//         }
//       },
//       child: Container(
//         width: 321.0,
//         margin: const EdgeInsets.only(left: 11.0),
//         decoration: BoxDecoration(
//           color: const Color(0xFF818181),
//           borderRadius: BorderRadius.circular(15.0),
//         ),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: AutoSizeText(
//               _text,
//               style: const TextStyle(
//                 fontSize: 16.0,
//                 color: Colors.white,
//               ),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
