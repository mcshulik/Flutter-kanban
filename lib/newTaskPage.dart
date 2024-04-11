import 'package:flutter_kanban/main.dart';

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

class NewTaskPage extends StatefulWidget {
  @override
  NewTaskPageState createState() => NewTaskPageState();
}

class NewTaskPageState extends State<NewTaskPage> {

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimationController = TextEditingController();
  String performersMenuString = "Исполнители";
  String selectedUUID = '';
  int selectedPriority = 1;
  Color lowPriorityColor = const Color(0xFFCDDBFF); // Начальный цвет для прямоугольника "Низкий"
  Color mediumPriorityColor = Colors.grey.withOpacity(0); // Начальный цвет для прямоугольника "Средний"
  Color highPriorityColor = Colors.grey.withOpacity(0); // Начальный цвет для прямоугольника "Высокий"
  double lowPriorityBorderWidth = 0;
  double mediumPriorityBorderWidth = 3;
  double highPriorityBorderWidth = 3;
  FontWeight lowPriorityFontWeight = FontWeight.bold;
  FontWeight mediumPriorityFontWeight = FontWeight.normal;
  FontWeight highPriorityFontWeight = FontWeight.normal;

  //bool _isExpanded = false;
  //bool _isTaskInfoExpanded = false;
  //bool _isCheckCriteriaExpanded = false;
  //bool _isDependenciesExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                    "Новая задача",
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
                  IconButton(
                    icon: Icon(
                        color: Colors.black.withOpacity(0.3),
                        Icons.check
                    ),
                    onPressed: () async {
                      if (_nameController.text != '' &&
                          _descriptionController.text != '' && selectedUUID != '') {
                        //List<String> parts = _estimationController.text.split(RegExp(r'\D+')); // Разбиваем строку по всем нецифровым символам

                        //int days = int.parse(parts[0]); // Дни
                        //int hours = int.parse(parts[1]); // Часы
                        //int minutes = int.parse(parts[2]); // Минуты
                        int minutes = int.parse(_estimationController.text) * 60;

                        //int totalMinutes = days * 24 * 60 + hours * 60 + minutes; // Считаем общее количество минут

                        print (minutes.toString());

                        // Действие при нажатии на кнопку с галочкой
                        var messageJson = {
                          "project": 1,
                          "startDate": "2024-04-03T13:00:35.729Z",
                          "endDate": "2024-04-03T13:00:35.729Z",
                          "estimation": minutes,
                          "taskStatus": 1,
                          "taskType": 1,
                          "money": 1,
                          "targetEndProduct": "",
                          "shortDescription": _descriptionController.text,
                          "completionRate": 1,
                          "issueEncountered": "",
                          "profit": 1,
                          "title": _nameController.text,
                          "fullDescription": "",
                          "taskPriority": selectedPriority
                        };
                        var messageString = json.encode(messageJson);

                        final userId = selectedUUID;
                        selectedUUID = '';

                        var postTaskStatusUrl = apiUrl.replace(
                            path: '/task/user/$userId');

                        // Отправляем POST-запрос на сервер
                        final response = await http.post(
                          postTaskStatusUrl,
                          body: messageString,
                          headers: {
                            'Content-Type': 'application/json; charset=UTF-8',
                            // указываем тип контента
                            'Authorization': 'Bearer $token'
                          },
                        );
                        // Проверяем успешность запроса
                        if (response.statusCode == 200) {
                          // Если запрос успешен, можно обработать ответ сервера
                          print('Request successful');
                        } else {
                          // Если запрос не удался, можно вывести сообщение об ошибке
                          print('Request failed with status: ${response
                              .statusCode}');
                        }

                        Navigator.pop(context, _nameController
                            .text); // передаем текст из контроллера для создания новоого прямоугольника с таской
                      }
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 19.0, top: 5),
              // Отступ слева для дополнительного текста
              /*child: Text(
                //'Made by You',
                //'Сделано Антоном Ивановым',
                'Сделано Антоном Ивановым',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0x80666666), // Цвет текста
                  fontFamily: 'Inter', // Шрифт
                  height: 1.0, // Высота строки
                ),
              ),*/
            ),
            Container(
              //height: 30.0, // изменяем ширину контейнера
              margin: const EdgeInsets.only(left: 19.0),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 20.0, // Размер шрифта
                  fontWeight: FontWeight.bold, // Жирный шрифт
                ),
                maxLines: null, // Разрешить неограниченное количество строк
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
            /*Container(
              //height: 22.0, // изменяем ширину контейнера
              margin: EdgeInsets.only(left: 19.0),
              child: Text(
                'Tags',
                style: TextStyle(
                  fontSize: 18,
                  //color: Colors.black.withOpacity(1),
                  color: Color(0xFF808080),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 19.0, top: 2),
              child: TextButton(
                onPressed: () {
                  // Действие при нажатии на кнопку "Tags"
                  // Добавьте свой код для обработки нажатия
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          7.0), // Здесь можно установить желаемый радиус закругления
                    ),
                  ),
                  side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(color: Colors.black.withOpacity(0.15),
                        width: 1.0), // Здесь можно настроить цвет и толщину стенок
                  ),
                ),
                child: Text(
                  '+Add tag',
                  style: TextStyle(
                    fontSize: 14,
                    //color: Color(0xFFEDEDED), // Серый цвет
                    color: Colors.black.withOpacity(0.15), // Серый цвет
                    fontFamily: 'Inter',
                    height: 1, // Высота строки
                  ),
                ),
              ),
            ),*/
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
                              controller: _estimationController,
                              textAlign: TextAlign.center, // Align text in the center
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Это разрешит вводить только цифры
                              decoration: const InputDecoration(
                                //hintText: '00д 00ч 00мин',
                                hintText: 'Оценка затрат в часах',
                                hintStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFF818181), // Серый цвет текста
                                  fontFamily: 'Inter', // Семейство шрифтов
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none, // Устанавливаем прозрачную границу
                              ),
                              keyboardType: TextInputType.number, // Это позволит отображать клавиатуру только с числами
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
                  onTap: () {
                    setState(() {
                      // Изменяем цвет прямоугольника "Низкий"
                      lowPriorityColor = const Color(0xFFCDDBFF);
                      mediumPriorityColor = Colors.grey.withOpacity(0);
                      highPriorityColor = Colors.grey.withOpacity(0);
                      lowPriorityBorderWidth = 0;
                      mediumPriorityBorderWidth = 3;
                      highPriorityBorderWidth = 3;
                      selectedPriority = 1;
                      lowPriorityFontWeight = FontWeight.bold;
                      mediumPriorityFontWeight = FontWeight.normal;
                      highPriorityFontWeight = FontWeight.normal;
                    });
                  },
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
                  onTap: () {
                    setState(() {
                      // Изменяем цвет прямоугольника "Средний"
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
                    });
                  },
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
                  onTap: () {
                    setState(() {
                      // Изменяем цвет прямоугольника "Высокий"
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
                    });
                  },
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

                /*ExpansionPanelList(
                  expandedHeaderPadding: EdgeInsets.zero,
                  materialGapSize: 0,
                  elevation: 1,
                  // Устанавливаем тень на 0, чтобы не было тени у панели
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      switch (index) {
                        case 0:
                          _isTaskInfoExpanded = !_isTaskInfoExpanded;
                          break;
                        case 1:
                          _isCheckCriteriaExpanded = !_isCheckCriteriaExpanded;
                          break;
                        case 2:
                          _isDependenciesExpanded = !_isDependenciesExpanded;
                          break;
                      }
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          minVerticalPadding: 0,
                          title: Text(
                            //"Task info",
                            "Описание задачи",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: ListTile(
                          title: Text(
                            "Addition text",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //subtitle:
                          //const Text('To delete this panel, tap the trash can icon'),
                          onTap: () {
                            setState(() {
                              //_data.removeWhere((Item currentItem) => item == currentItem);
                            });
                          }),
                      isExpanded: _isTaskInfoExpanded,
                      backgroundColor: Color(
                          0xFFEDEDED), // Здесь меняем цвет прямоугольника
                    ),
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          minVerticalPadding: 0,
                          title: Text(
                            "Check criteria",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: ListTile(
                          title: Text("additional text"),
                          onTap: () {
                            setState(() {
                              //_data.removeWhere((Item currentItem) => item == currentItem);
                            });
                          }),
                      isExpanded: _isCheckCriteriaExpanded,
                      backgroundColor: Color(
                          0xFFEDEDED), // Здесь меняем цвет прямоугольника
                    ),
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          minVerticalPadding: 0,
                          title: Text(
                            "Check criteria",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: ListTile(
                          title: Text("additional text"),
                          onTap: () {
                            setState(() {
                              //_data.removeWhere((Item currentItem) => item == currentItem);
                            });
                          }),
                      isExpanded: _isDependenciesExpanded,
                      backgroundColor: Color(
                          0xFFEDEDED), // Здесь меняем цвет прямоугольника
                    ),
                  ],
                ),*/
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
                                  for (var userInfo in usersInfoList)
                                    PopupMenuItem(
                                      //value: userList['name'] + ' ' + userList['surname'],
                                      value: userInfo['uuid'],
                                      child: Text(userInfo['surname'] + ' ' +
                                          userInfo['name'] + ' ' + userInfo['patronymic']),
                                    ),
                                  /*const PopupMenuItem(
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
                                    ),*/
                                ],
                                onSelected: (value) {
                                  setState(() {
                                    selectedUUID = value as String;
                                    for (var userInfo in usersInfoList) {
                                      if (userInfo['uuid'] == selectedUUID) {
                                        performersMenuString =
                                            userInfo['surname'] + ' ' +
                                                userInfo['name'] + ' ' + userInfo['patronymic'];
                                        break;
                                      }
                                    }
                                  });
                                },
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
                          //for (var userList in usersInfoList)
                          /*Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0), // Отступы по вертикали
                              child: Text(
                                userList['name'] + ' ' + userList['surname'],
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF818181),
                                  fontFamily: 'Inter',
                                  height: 1.0,
                                ),
                                // Выравнивание текста по левому краю
                              ),
                            ),*/
                        ],
                      ),
                      /*child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Исполнители",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                              height: 1.0,
                              // line height
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),*/
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

