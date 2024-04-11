import 'package:flutter/material.dart';
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

import 'package:flutter_kanban/main.dart';

class EditTaskPage extends StatefulWidget {
  final int taskId;

  const EditTaskPage({Key? key, required this.taskId}) : super(key: key);

  @override
  EditTaskPageState createState() => EditTaskPageState();
}

class EditTaskPageState extends State<EditTaskPage> {

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimationController = TextEditingController();
  String performersMenuString = "Исполнители";
  String selectedUUID = '';
  int selectedPriority = 1;
  Color lowPriorityColor = const Color(
      0xFFCDDBFF); // Начальный цвет для прямоугольника "Низкий"
  Color mediumPriorityColor = Colors.grey.withOpacity(
      0); // Начальный цвет для прямоугольника "Средний"
  Color highPriorityColor = Colors.grey.withOpacity(
      0); // Начальный цвет для прямоугольника "Высокий"
  double lowPriorityBorderWidth = 0;
  double mediumPriorityBorderWidth = 3;
  double highPriorityBorderWidth = 3;
  FontWeight lowPriorityFontWeight = FontWeight.bold;
  FontWeight mediumPriorityFontWeight = FontWeight.normal;
  FontWeight highPriorityFontWeight = FontWeight.normal;

  @override
  Widget build(BuildContext context) {
    var currentTask = tasksInfoList.firstWhere((task) =>
    task['id'] == widget.taskId);
    _descriptionController.text = currentTask['shortDescription'];
    _nameController.text = currentTask['title'];
    var taskPriority = currentTask['taskPriority']['id'];
    var workerId = currentTask['workerId'];
    var estimation = currentTask['estimation'] ~/ 60;
    _estimationController.text = estimation.toString();

    switch (taskPriority) {
      case 2:
        {
          lowPriorityColor = Colors.grey.withOpacity(0);
          mediumPriorityColor = const Color(0xFFFBD676);
          highPriorityColor = Colors.grey.withOpacity(0);
          lowPriorityBorderWidth = 3;
          mediumPriorityBorderWidth = 0;
          highPriorityBorderWidth = 3;
          selectedPriority = 2;
          lowPriorityFontWeight = FontWeight.normal;
          mediumPriorityFontWeight = FontWeight.bold;
          highPriorityFontWeight = FontWeight.normal;
        }
      case 3:
        {
          lowPriorityColor = Colors.grey.withOpacity(0);
          mediumPriorityColor = Colors.grey.withOpacity(0);
          highPriorityColor = const Color(0xFFFF8080);
          lowPriorityBorderWidth = 3;
          mediumPriorityBorderWidth = 3;
          highPriorityBorderWidth = 0;
          selectedPriority = 3;
          lowPriorityFontWeight = FontWeight.normal;
          mediumPriorityFontWeight = FontWeight.normal;
          highPriorityFontWeight = FontWeight.bold;
        }
    }

    for (var userInfo in usersInfoList) {
      if (userInfo['uuid'] == workerId) {
        performersMenuString =
            userInfo['surname'] + ' ' +
                userInfo['name'] + ' ' + userInfo['patronymic'];
        break;
      }
    }


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Располагаем дочерние элементы слева
          children: [
            Container(
              margin: const EdgeInsets.only(left: 19.0, top: 47.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // Выравниваем дочерние элементы по левому краю
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // Действие при нажатии на кнопку с крестиком
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    //"New task",
                    "Текущая задача",
                    style: TextStyle(
                      fontSize: 20.0,
                      // Размер шрифта
                      color: Color(0xFF424242),
                      // Цвет текста
                      fontFamily: "Inter",
                      // Семейство шрифтов
                      fontWeight: FontWeight.bold,
                      // Жирный текст
                      height: 1.0, // Высота строки
                    ),
                  ),
                  const Spacer(),
                  // Размещает пробел между текстом и следующей кнопкой
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 19.0, top: 5),
            ),
            Container(
              //height: 30.0, // изменяем ширину контейнера
              margin: const EdgeInsets.only(left: 19.0),
              child: TextField(
                readOnly: true,
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 20.0, // Размер шрифта
                  fontWeight: FontWeight.bold, // Жирный шрифт
                ),
                maxLines: null,
                // Разрешить неограниченное количество строк
                decoration: const InputDecoration(
                  hintText: 'Введите номер задачи',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none, // Устанавливаем прозрачную границу
                ),
              ),
            ),
            Container(
              height: 22.0, // изменяем ширину контейнера
              margin: const EdgeInsets.only(left: 19.0),
              child: Text(
                //'(up to 55 symbols)',
                '(до 10 символов)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.15),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              //margin: EdgeInsets.only(left: 19.0, top: 10),
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          //'Estimation',
                          'Оценка затрат',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Пространство между текстами и прямоугольниками
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 19),
                        width: 166.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(
                              10), // Закругление углов
                        ),
                        child: Center(
                          child: Padding(
                            //padding: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: TextField(
                              readOnly: true,
                              controller: _estimationController,
                              textAlign: TextAlign.center,
                              // Align text in the center
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              // Это разрешит вводить только цифры
                              decoration: const InputDecoration(
                                //hintText: '00д 00ч 00мин',
                                hintText: 'Оценка затрат в часах',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFF818181), // Серый цвет текста
                                  fontFamily: 'Inter', // Семейство шрифтов
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder
                                    .none, // Устанавливаем прозрачную границу
                              ),
                              keyboardType: TextInputType.number,
                              // Это позволит отображать клавиатуру только с числами
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFF818181), // Серый цвет текста
                                fontFamily: 'Inter', // Семейство шрифтов
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Пространство между прямоугольниками
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              //height: 22.0, // изменяем ширину контейнера
              margin: const EdgeInsets.only(left: 19.0),
              child: const Text(
                'Приоритет',
                //'Task status',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF808080),
                ),
              ),
            ),
            const SizedBox(height: 5.0,),
            Row(
              children: [
                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(left: 19),
                    width: 106.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: lowPriorityColor,
                      border: Border.all(
                        color: const Color(0xFFEDEDED),
                        width: lowPriorityBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Низкий',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: const Color(0xFF818181),
                          fontFamily: 'Inter',
                          //fontWeight: FontWeight.bold,
                          fontWeight: lowPriorityFontWeight,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  child: Container(
                    width: 106.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: mediumPriorityColor,
                      border: Border.all(
                        color: const Color(0xFFEDEDED),
                        width: mediumPriorityBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Средний',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: const Color(0xFF818181),
                          fontFamily: 'Inter',
                          fontWeight: mediumPriorityFontWeight,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  child: Container(
                    width: 106.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: highPriorityColor,
                      border: Border.all(
                        color: const Color(0xFFEDEDED),
                        width: highPriorityBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Высокий',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: const Color(0xFF818181),
                          fontFamily: 'Inter',
                          fontWeight: highPriorityFontWeight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                // Устанавливаем радиус закругления углов
                child: Wrap(
                  children: <Widget>[
                    Container(
                      width: 343,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFEDEDED),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            "Описание задачи",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                              height: 1.0,
                              // line height
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            readOnly: true,
                            controller: _descriptionController,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Введите ваш текст',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF808080),
                              ),
                              border: InputBorder.none,
                              /*suffixIcon: IconButton(
                                icon: Icon(Icons.add_a_photo_outlined),
                                onPressed: () {
                                  // Здесь можно добавить обработчик нажатия на иконку фотоаппарата
                                  // Например, вызов диалога для выбора изображения из галереи
                                },
                              ),*/
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                // Устанавливаем радиус закругления углов
                child: Wrap(
                  children: <Widget>[
                    Container(
                      width: 343,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFEDEDED),
                      ),
                      padding: const EdgeInsets.all(8),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            performersMenuString,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF818181),
                              fontFamily: 'Inter',
                              height: 1.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Расстояние между заголовком и основной частью
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            // Отступ слева
                            child: Transform.rotate(
                              angle: -math.pi / 2,
                              child: PopupMenuButton(
                                offset: const Offset(-30, 0),
                                // сдвиг по вертикали
                                itemBuilder: (context) =>
                                [
                                  /*for (var userInfo in usersInfoList)
                                    PopupMenuItem(
                                      //value: userList['name'] + ' ' + userList['surname'],
                                      value: userInfo['uuid'],
                                      child: Text(userInfo['surname'] + ' ' +
                                          userInfo['name'] + ' ' +
                                          userInfo['patronymic']),
                                    ),*/
                                ],
                                // onSelected: (value) {
                                //   setState(() {
                                //     selectedUUID = value as String;
                                //     for (var userInfo in usersInfoList) {
                                //       if (userInfo['uuid'] == selectedUUID) {
                                //         performersMenuString =
                                //             userInfo['surname'] + ' ' +
                                //                 userInfo['name'] + ' ' +
                                //                 userInfo['patronymic'];
                                //         break;
                                //       }
                                //     }
                                //   });
                                // },
                                child: Container(
                                  padding: const EdgeInsets.only(left: 15.0),
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
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 361,
              height: 1,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0x4D000000), // Цвет рамки
                  width: 1, // Толщина рамки
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              //height: 22.0, // изменяем ширину контейнера
              margin: const EdgeInsets.only(left: 19.0),
              child: const Text(
                //'Attachments: 0',
                'Вложения: 0',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF818181),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class EditTaskPageState extends State<EditTaskPage> {
//   late TextEditingController _textController;
//
//   @override
//   void initState() {
//     super.initState();
//     _textController = TextEditingController(text: widget.initialText);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Text'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _textController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your text',
//               ),
//             ),
//             const SizedBox(height: 16),
//             IconButton(
//               icon: const Icon(Icons.check),
//               onPressed: () {
//                 Navigator.pop(context, _textController.text);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _textController.dispose();
//     super.dispose();
//   }
// }