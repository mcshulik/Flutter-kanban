import 'package:flutter_kanban/editTaskPage.dart';
import 'package:flutter_kanban/main.dart';
import 'package:flutter_kanban/newTaskPage.dart';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class AdminPage extends StatefulWidget {
  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {

  //Color color Color(0xFFF5F2D4);
  //List<String> myTexts = taskInfoList[0];
  //int i = 0;
  /*List<String> myTexts = [
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей'
  ];*/

  //List<String> myTexts = [];

  // Добавьте контроллер
  //final ScrollController _scrollController = ScrollController();

  // Переменная для отслеживания видимости стрелки вправо
  bool showRightArrow = true;
  bool showLeftArrow = false;
  Color toDoStatusColor = const Color(0xFFF3C0C0);
  Color doingStatusColor = const Color(0xFFF5F2D4);
  Color doneStatusColor = const Color(0xFFDAF6D5);
  bool showTrashIcon = false;
  int currentTaskId = 0;


  @override
  void initState() {
    super.initState();
    subscription = controllerForAdmin.stream.listen((value) {
      setState(() {
        //_value = value;
        //myTexts.clear();
        for (var task in tasksInfoList) {
          //myTexts.add('${task['shortDescription']}');
          // Вывести информацию о задаче
          /*print('ID: ${task['id']}');
          print('Start Date: ${task['startDate']}');
          print('End Date: ${task['endDate']}');
          print('Estimation: ${task['estimation']}');
          print('Target End Product: ${task['targetEndProduct']}');
          print('Short Description: ${task['shortDescription']}');
          print('Completion Rate: ${task['completionRate']}');
          print('Issue Encountered: ${task['issueEncountered']}');
          print('Profit: ${task['profit']}');
          print('Title: ${task['title']}');
          print('Full Description: ${task['fullDescription']}');
          print('Worker Updated: ${task['workerUpdated']}');
          print('-----------------------------------');*/
        }
      });
    });
  }

  /*@override
  void initState() {
    super.initState();

    // Добавьте слушателя для контроллера скроллинга
    _scrollController.addListener(() {
      // Проверяем, достиг ли скроллинг крайней правой точки
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Скроллинг достиг крайней правой точки, скрываем стрелку вправо
        setState(() {
          showRightArrow = false;
        });
      } else {
        // Скроллинг не достиг крайней правой точки, показываем стрелку вправо
        setState(() {
          showRightArrow = true;
        });
        if (_scrollController.position.pixels !=
            _scrollController.position.minScrollExtent) {
          setState(() {
            showLeftArrow = true;
          });
        }
        else {
          setState(() {
            showLeftArrow = false;
          });
        }
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    //int myTextCount = myTexts.length;
    return MaterialApp(
      home: Scaffold(
        body: GestureDetector( // Обернули все виджеты в GestureDetector
          onTap: () {
            // Закрываем иконку мусорки при нажатии в любом месте экрана
            setState(() {
              showTrashIcon = false;
            });
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyTextView(),
                        Row(
                          children: [
                            PlusButton(
                              onAddText: (newText) {
                                setState(() {
                                  //myTexts.add(newText);
                                });
                              },
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 50),
                              child: PopupMenuButton(
                                itemBuilder: (context) =>
                                [
                                  const PopupMenuItem(
                                    value: "Задачи",
                                    child: Text("Задачи"),
                                  ),
                                  const PopupMenuItem(
                                    value: "Диаграмма",
                                    child: Text("Диаграмма"),
                                  ),
                                  const PopupMenuItem(
                                    value: "Уведомления",
                                    child: Text("Уведомления"),
                                  ),
                                  const PopupMenuItem(
                                    value: "Учёт времени",
                                    child: Text("Учёт времени"),
                                  ),
                                  const PopupMenuItem(
                                    value: "Профиль",
                                    child: Text("Профиль"),
                                  ),
                                  const PopupMenuItem(
                                    value: "Ваши задачи",
                                    child: Text("Ваши задачи"),
                                  ),
                                ],
                                /*[
                          const PopupMenuItem(
                            value: "Tasks",
                            child: Text("Tasks"),
                          ),
                          const PopupMenuItem(
                            value: "Agile Desk",
                            child: Text("Agile Desk"),
                          ),
                          const PopupMenuItem(
                            value: "Notification",
                            child: Text("Notification"),
                          ),
                          const PopupMenuItem(
                            value: "Time tracking",
                            child: Text("Time tracking"),
                          ),
                          const PopupMenuItem(
                            value: "Profile",
                            child: Text("Profile"),
                          ),
                        ],*/
                                child: const Icon(
                                  Icons.menu,
                                  size: 25, // Размер иконки
                                ),
                                onSelected: (String value) {
                                  // Обработка выбора пункта меню
                                  switch (value) {
                                    case "Ваши задачи":
                                      {
                                        //subscription.cancel(); // Отменить подписку на поток
                                        //_controllerForAdmin.close();    // Закрыть контроллер
                                        /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserPage()),
                                );*/
                                      }
                                      break;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: 343,
                    height: 40,
                    margin: const EdgeInsets.only(left: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 0, left: 0),
                      child: TextField(
                        decoration: InputDecoration(
                          //hintText: 'Search...',
                          hintText: 'Поиск...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  /*Container(
            height: 40, // Установите высоту строки
            child: Row(
              children: [
                SizedBox(width: 10), // Добавляем пробел перед первой стрелкой
                showLeftArrow
                    ? Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Colors.black.withOpacity(0.3),
                )
                    : SizedBox(width: 12), // Пространство без иконки
                SizedBox(width: 5), // Добавляем пробел после стрелки вправо
                Expanded(
                  child: ListView(
                    controller: _scrollController, // Добавьте контроллер
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var text in [
                        'Data',
                        'Timer',
                        'Tags',
                        'Timer',
                        'Work Status',
                        'Executor',
                        'Type',
                        'Project',
                        'Update',
                        'Deadline'
                      ])
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0)),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  // Действие при нажатии на кнопку
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.grey.withOpacity(0)), // Устанавливаем прозрачную границу
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // Цвет фона кнопки
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF818181),
                                        fontFamily: 'Inter',
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: 5), // Добавляем небольшое пространство между текстом и иконкой
                                    Transform.rotate(
                                      angle: -math.pi / 2, // Поворачиваем иконку на 90 градусов против часовой стрелки
                                      child: Icon(
                                        Icons.arrow_back_ios, // Используем иконку стрелки вверх из пакета icons
                                        size: 15, // Устанавливаем размер иконки
                                        color: Colors.black, // Цвет иконки
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                SizedBox(width: 5), // Добавляем пробел перед стрелкой вправо
                showRightArrow
                    ? Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.black.withOpacity(0.3),
                )
                    : SizedBox(width: 12), // Пространство без иконки
                SizedBox(width: 10), // Добавляем пробел после последней стрелки
              ],
            ),
          ),*/
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.withOpacity(
                              0)), //прозрачные границы
                    ),
                    //child: Center(child: Text(text)),
                    /*child: Text(
              //myTextCount.toString() + " matching tasks found",
              //myTextCount.toString() + " подходящий задач найдено",
              tasksInfoList.length.toString() + " подходящий задач найдено",
              style: const TextStyle(
                fontSize: 14, // Размер текста
                color: Color(0xFFC0C0C0), // Цвет текста
                fontFamily: 'Inter', // Шрифт текста
                height: 1.0, // Межстрочный интервал
              ),
            ),*/
                  ),
                  Expanded( //серые прямоугольники
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              //for (var text in usersInfoList = data['userList'])
                              //for (var task in tasksInfoList)
                              Column(
                                children: tasksInfoList.map((taskInfo) {
                                  var uuidTemp = taskInfo['workerId'];

                                  dynamic userInfo;
                                  for (var user in usersInfoList) {
                                    if (user['uuid'] == uuidTemp) {
                                      userInfo = user;
                                      break;
                                    }
                                  }
                                  final taskId = taskInfo['id'];
                                  final taskStatusId = taskInfo['taskStatus']['id'];
                                  Color currentColor = toDoStatusColor;
                                  int hoursSpent = taskInfo['timeSpent'];
                                  //int currentSpent = hoursSpent ~/ 60;
                                  int currentSpent = hoursSpent;
                                  int hoursEstimation = taskInfo['estimation'];
                                  int currentEstimation = hoursEstimation;
                                  switch (taskStatusId) {
                                    case 2:
                                      {
                                        currentColor = doingStatusColor;
                                        break;
                                      }
                                    case 3:
                                      {
                                        currentColor = doneStatusColor;
                                        break;
                                      }
                                  }
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 10),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              //color: const Color(0xFF818181),
                                              color: currentColor,
                                              borderRadius: BorderRadius
                                                  .circular(
                                                  15.0),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onLongPressStart: (details) {
                                            setState(() {
                                              currentTaskId = taskId;
                                              showTrashIcon = true;
                                            });
                                            print('Начало удержания нажатия!');
                                          },
                                          onLongPressEnd: (details) {
                                            setState(() {
                                              //showTrashIcon = false;
                                            });
                                            print(
                                                'Окончание удержания нажатия!');
                                          },
                                          onTap: () async {
                                    // Открываем экран редактирования текста
                                    final editedText = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>
                                          EditTaskPage(taskId: taskId)),
                                    );
                                    // Обрабатываем результат редактирования, если это необходимо
                                    /*if (editedText != null) {
                                      // код для обработки отредактированного текста
                                    }*/
                                  },
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(
                                              //отступы для цветного прямоугольника
                                                top: 0, left: 10, right: 40),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF818181),
                                              borderRadius: BorderRadius
                                                  .circular(
                                                  15.0),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      left: 5.0),
                                                  // Добавляем отступ слева для заголовка
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        taskInfo['title'],
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFFD8D8D8),
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight
                                                              .bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        (currentSpent ~/ 60)
                                                                .toString() +
                                                            "ч" + ' ' + (currentSpent % 60).toString() + 'мин  / ' +
                                                        (currentEstimation ~/ 60).toString() + "ч" + ' ' + (currentEstimation % 60).toString() + 'мин'
                                                        // "Оценочное: " +
                                                        //   (currentEstimation ~/ 60)
                                                        //         .toString() +
                                                        //     "ч" + ' ' + (currentEstimation % 60).toString() + 'мин   '
                                                        //     "Затраченное: " +
                                                        //     (currentSpent ~/ 60)
                                                        //         .toString() + "ч" + ' ' + (currentSpent % 60).toString() + 'мин'
                                                            ,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFFD8D8D8),
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight
                                                              .bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Text(
                                                        //surname
                                                        'Исполнитель: ' +
                                                            userInfo['surname'] +
                                                            ' ' +
                                                            userInfo['name'] +
                                                            ' ' +
                                                            userInfo['patronymic'],
                                                        //вставить сюда
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Color(
                                                              0xFFD8D8D8),
                                                          fontFamily: 'Inter',
                                                          //fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                /*Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0),
                                          // Добавляем отступ слева для заголовка
                                          child: Text(
                                            //task['title'],
                                            taskInfo['title'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFFD8D8D8),
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),*/
                                                const SizedBox(height: 5),
                                                // Расстояние между заголовком и основной частью
                                                Text(
                                                  //task['shortDescription'],
                                                  taskInfo['shortDescription'],
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFFD8D8D8),
                                                    fontFamily: 'Inter', // Семейство шрифтов Inter
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  /*MyRectangle(
                              text: task[],
                              onTextChanged: (newText) {
                                setState(() {
                                  myTexts[myTexts.indexOf(text)] = newText;
                                });
                              },
                            ),*/
                                  //const SizedBox(height: 10),

                                }).toList(),
                              ),
                              // if (showTrashIcon)
                              //   Center(
                              //     child: GestureDetector(
                              //       onTap: () {
                              //         setState(() {
                              //           showTrashIcon = false;
                              //           var currentTask = tasksInfoList.firstWhere((
                              //               task) => task['id'] == currentTaskId);
                              //           deleteTask(currentTask['id']);
                              //           //final test = deleteTask(tasksInfoList[taskNumber]);
                              //           //deleteTask(tasksInfoList[taskNumber]);
                              //         });
                              //       },
                              //       child: Icon(
                              //         Icons.delete,
                              //         color: Colors.red,
                              //         size: 50,
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (showTrashIcon)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showTrashIcon = false;
                        var currentTask = tasksInfoList.firstWhere((
                            task) => task['id'] == currentTaskId);
                        deleteTask(currentTask['id']);
                        //final test = deleteTask(tasksInfoList[taskNumber]);
                        //deleteTask(tasksInfoList[taskNumber]);
                      });
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


Future<void> deleteTask(int taskId) async {
  var deleteUserUrl = apiUrl.replace(path: '/task/$taskId'); // apiUrl - адрес вашего API
  try {
    var response = await http.delete(
      deleteUserUrl,
      headers: {
        'Content-Type': 'application/json', // указываем тип контента
        'Authorization': 'Bearer $token', // токен аутентификации
      },
    );
    // Проверяем статус ответа
    if (response.statusCode == 200) {
      print('User with id $taskId deleted successfully');
    } else {
      // Если сервер вернул ошибку, выводим статус и сообщение об ошибке
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (error) {
    // Если произошла ошибка во время выполнения запроса, выводим её
    print('Error during DELETE request: $error');
  }
}


class PlusButton extends StatelessWidget {
  final Function(String) onAddText;

  PlusButton({required this.onAddText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0, top: 49.0),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(
              size: 25,
              Icons.add,
            ),
            onPressed: () async {
              final newText = await Navigator.push(context, MaterialPageRoute(builder: (context) => NewTaskPage()));
              if (newText != null && newText is String && newText.isNotEmpty) {
                onAddText(newText);
              }
            },
          ),
        ],
      ),
    );
  }
}
