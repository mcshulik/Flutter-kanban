import 'package:flutter_kanban/main.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class UserPage extends StatefulWidget {
  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {

  List<String> myTexts = [];

  List<dynamic> toDoItems = [];
  List<dynamic> doingItems = [];
  List<dynamic> doneItems = [];


  @override
  void initState() {
    super.initState();
    subscription = controllerForUser.stream.listen((value) {
      setState(() {
        toDoItems.clear();
        doingItems.clear();
        doneItems.clear();
        for (var task in tasksInfoList) {
          final taskStatus = task['taskStatus'];
          int id = taskStatus['id'];
          switch (id) {
            case 1:
              {
                //toDoItems.add('${task['fullDescription']}');
                toDoItems.add(task);
                break;
              }
            case 2:
              {
                //doingItems.add('${task['fullDescription']}');
                doingItems.add(task);
                break;
              }
            case 3:
              {
                //doneItems.add('${task['fullDescription']}');
                doneItems.add(task);
                break;
              }
          }
          //id = taskStatus;
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
    _controller.stream.listen((value) {
      setState(() {
        //_value = value;
        myTexts.clear();
        for (var task in taskInfoList) {
          myTexts.add('${task['fullDescription']}');
          // Вывести информацию о задаче
        }
      });
    });
  }*/


  @override
  Widget build(BuildContext context) {
    //int myTextCount = myTexts.length;

    return Scaffold(
      body: Column(
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
                        ],
                        child: const Icon(
                          Icons.menu,
                          size: 25, // Размер иконки
                        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0)),
                  ),
                  child: const Text(
                    "Выполнить", // ваш текст
                    style: TextStyle(
                      fontSize: 16, // размер текста
                      color: Color(0x80424242), // цвет текста
                      fontFamily: 'Inter', // шрифт текста
                    ),
                    textAlign: TextAlign.center, // выравнивание текста
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0)),
                  ),
                  child: const Text(
                    "В процессе", // ваш текст
                    style: TextStyle(
                      fontSize: 16, // размер текста
                      color: Color(0x80424242), // цвет текста
                      fontFamily: 'Inter', // шрифт текста
                    ),
                    textAlign: TextAlign.center, // выравнивание текста
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0)),
                  ),
                  child: const Text(
                    "Выполнено", // ваш текст
                    style: TextStyle(
                      fontSize: 16, // размер текста
                      color: Color(0x80424242), // цвет текста
                      fontFamily: 'Inter', // шрифт текста
                    ),
                    textAlign: TextAlign.center, // выравнивание текста
                  ),
                ),
              ),
            ],
          ),
          Container(
            //width: 361,
            height: 1,
            //margin: EdgeInsets.only(top: 156),
            color: const Color(0x4D000000), // Цвет линии
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      //padding: EdgeInsets.all(8),
                      padding: const EdgeInsets.all(0),
                      child: _buildDraggableRectangleUser(toDoItems, 1),
                    ),
                  ),
                ),
                const VerticalDivider(
                  color: Color(0x4D000000),
                  thickness: 1.0, // Толщина вертикальной линии
                  width: 0, // Убираем ширину вертикальной линии
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      //padding: EdgeInsets.all(8),
                      padding: const EdgeInsets.all(0),
                      child: _buildDraggableRectangleUser(doingItems, 2),
                    ),
                  ),
                ),
                const VerticalDivider(
                  color: Color(0x4D000000),
                  thickness: 1.0, // Толщина вертикальной линии
                  width: 0, // Убираем ширину вертикальной линии
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      //padding: EdgeInsets.all(8),
                      padding: const EdgeInsets.all(0),
                      child: _buildDraggableRectangleUser(doneItems, 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableRectangleUser(List<dynamic> items, int columnNumber) {
    Color rectangleColor = const Color(0xFFF3C0C0);
    switch (columnNumber) {
      case 2:
        {
          rectangleColor = const Color(0xFFF5F2D4);
          break;
        }
      case 3:
        {
          rectangleColor = const Color(0xFFDAF6D5);
          break;
        }
    }
    return Column(
      children: items.map(
            (item) =>
            LongPressDraggable(
              delay: const Duration(milliseconds: 200),
              data: item,
              feedback: Container(
                //width: feedbackRectangleWidth,
                decoration: BoxDecoration(
                  color: rectangleColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 5),
                //alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"],
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 14,
                        // Размер текста из стиля
                        color: const Color(0xFF818181).withOpacity(0.5),
                        // Цвет текста из стиля
                        fontFamily: 'Inter',
                        // Семейство шрифтов Inter
                        fontWeight: FontWeight
                            .bold, // Жирный шрифт для заголовка
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Расстояние между заголовком и основной частью
                    Text(
                      item["shortDescription"],
                      textAlign: TextAlign.start,
                      // Выравнивание текста по левому краю
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        fontSize: 12,
                        // Размер текста из стиля
                        color: const Color(0xFF818181).withOpacity(0.5),
                        // Цвет текста из стиля
                        fontFamily: 'Inter', // Семейство шрифтов Inter
                      ),
                    ),
                  ],
                ),
              ),
              childWhenDragging: Container(),
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  // Определяем индекс перемещаемого элемента
                  //int index = items.indexOf(item);
                  // Переменная для хранения вертикальной позиции перемещаемого элемента
                  //double itemPositionY = offset.dy;


                  //double a = textSize + indentation * 2 + ((paddingBetweenRectangles * 2 + rectangleHeight)  * (items.length - 2));

                  /*if(itemPositionY > textSize + indentation * 2 + ((paddingBetweenRectangles * 2 + rectangleHeight)  * (items.length - 2))) {
                    // Удаляем перемещаемый элемент из текущего места
                    items.removeAt(index);
                    // Добавляем перемещаемый элемент в конец столбца
                    items.add(item);
                  }
                  else if (itemPositionY < textSize + indentation * 2) {
                    // Удаляем перемещаемый элемент из текущего места
                    items.removeAt(index);
                    // Добавляем перемещаемый элемент в конец столбца
                    //items.add(item);
                    todoItems.insert(0, item);
                  }*/


                  Size screenSize = MediaQuery
                      .of(context)
                      .size;
                  // Определяем ширину экрана
                  double screenWidth = screenSize.width;

                  double itemPositionX = offset.dx + ((screenSize.width - 20) / 3) / 2;
                  // Определяем высоту экрана
                  //double screenHeight = screenSize.height;

                  // Определяем центральную точку экрана
                  //double screenCenter = screenWidth / 2;
                  // Проверяем, перемещался ли элемент внутри той же колонки

                  bool isMovedWithinSameColumn = (
                      (columnNumber == 1 && itemPositionX < screenWidth / 3) ||
                          (columnNumber == 2 &&
                              itemPositionX < screenWidth / 3 * 2 &&
                              itemPositionX > screenWidth / 3) ||
                          (columnNumber == 3 &&
                              itemPositionX > screenWidth / 3 * 2));

                  //bool isMovedWithinSameColumn = (isToDoColumn && offset.dx + rectangleWidth / 2 < screenCenter) ||
                  //   (!isToDoColumn && offset.dx + rectangleWidth / 2 >= screenCenter);
                  if (!isMovedWithinSameColumn) {
                    setState(() async {
                      int statusId = 1;
                      /*switch (columnNumber) {
                        case 1:
                          {
                            //toDoItems.remove(item);
                          }
                        case 2:
                          {
                            //doingItems.remove(item);
                          }
                        case 3:
                          {
                            //doneItems.remove(item);
                          }
                      }*/
                      if (itemPositionX < screenWidth / 3) {
                        //toDoItems.add(item);
                      } else if (itemPositionX < screenWidth / 3 * 2 &&
                          itemPositionX > screenWidth / 3) {
                        //doingItems.add(item);
                        statusId = 2;
                      } else {
                        //doneItems.add(item);
                        statusId = 3;
                      }

                      //taskInfoList.remove(item);

                      var taskId = item["id"];
                      //final taskStatus = item['taskStatus'];
                      // URL, куда будет отправлен PUT-запрос
                      final taskSendUrl = apiUrl.replace(
                          path: '/task/$taskId/status/$statusId');

                      // Отправляем PUT-запрос
                      try {
                        final response = await http.put(
                          taskSendUrl,
                          //body: jsonEncode(requestBody),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization': 'Bearer $token'
                          },
                        );
                        // Проверяем успешность запроса
                        if (response.statusCode == 200) {
                          // Если запрос был успешным, вы можете обработать ответ здесь
                          print('Успешный PUT-запрос: ${response.body}');
                        } else {
                          // Если запрос не удался, вы можете обработать ошибку здесь
                          print(
                              'Ошибка при выполнении PUT-запроса: ${response
                                  .statusCode}');
                        }
                      } catch (e) {
                        // Если возникла ошибка в процессе выполнения запроса, вы можете обработать её здесь
                        print('Ошибка при выполнении PUT-запроса: $e');
                      } finally {

                      }
                    });
                  }
                });
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: rectangleColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 14, // Размер текста из стиля
                        color: Color(0xFF818181), // Цвет текста из стиля
                        fontFamily: 'Inter', // Семейство шрифтов Inter
                        fontWeight: FontWeight
                            .bold, // Жирный шрифт для заголовка
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Расстояние между заголовком и основной частью
                    Text(
                      item['shortDescription'],
                      textAlign: TextAlign.start,
                      // Выравнивание текста по левому краю
                      style: const TextStyle(
                        fontSize: 12, // Размер текста из стиля
                        color: Color(0xFF818181), // Цвет текста из стиля
                        fontFamily: 'Inter', // Семейство шрифтов Inter
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ).toList(),
    );
  }

}