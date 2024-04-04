import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:async';


final apiUrl = Uri.parse('http://91.149.187.115:8060');
String token = ""; // Переменная для хранения токена
int luid = 0; // Переменная для хранения LUID
String? uuid; // Переменная для хранения UUID
List<String> mainMenuList = <String>['Все проекты', 'Сельпо', 'Аграр', 'Химизация'];
List<dynamic> taskInfoList = [];
StreamController<int> _controller = StreamController<int>();
double feedbackRectangleWidth = 400;


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

void onConnectAuthorization(StompFrame frame) async{
  // Подписываемся на топик /app/credentials/users
  stompClient.subscribe(
    destination: '/app/credentials/users',
    callback: (frame) {
      // Получаем данные из сообщения и декодируем JSON
      Map<String, dynamic>? data = json.decode(frame.body!);

      // Проверяем, что данные не пусты и содержат ожидаемую структуру
      if (data != null && data.containsKey('loginList')) {
        // Получаем список пользователей
        List<dynamic> loginList = data['loginList'];

        // Выводим информацию о каждом пользователе
        for (var user in loginList) {
          uuid = user['uuid']; // Сохранение uuid в переменную
          /*print('UUID: ${user['uuid']}');
          print('Login: ${user['login']}');
          print('Last Login: ${user['lastLogin']}');
          print('Credentials Status ID: ${user['credentialsStatus']['id']}');
          print('Credentials Status Title: ${user['credentialsStatus']['title']}');
          print('Credentials Status Description: ${user['credentialsStatus']['description']}');
          print('Credentials Status Icon: ${user['credentialsStatus']['icon']}');
          print('--------------------------------------------');*/

        }
      } else {
        print('Received invalid data from server');
      }
    },
  );


  void getRolesForUserId(int userId) async{
    stompClient.subscribe(
      destination: '/app/credentials/$userId/roles',
      callback: (frame) {
        // Получаем данные из сообщения и декодируем JSON
        Map<String, dynamic>? data = json.decode(frame.body!);

        // Проверяем, что данные не пусты и содержат ожидаемую структуру
        if (data != null && data.containsKey('roleDtoList')) {
          // Получаем список ролей пользователя
          List<dynamic> roleList = data['roleDtoList'];

          // Выводим информацию о каждой роли
          for (var role in roleList) {
            print('Role ID: ${role['id']}');
            print('Title: ${role['title']}');
            print('Description: ${role['description']}');
            print('Luid: ${role['luid']}');
            print('Deleted: ${role['deleted']}');
            print('--------------------------------------------');
          }
        } else {
          print('Received invalid data from server');
        }
      },
    );
  }

  // Пример вызова функции для получения ролей пользователя
  //getRolesForUserId(luid);

  // Отправляем сообщение на тестовый эндпоинт каждые 10 секунд
  /*Timer.periodic(const Duration(seconds: 1), (_) {
    stompClient.send(
      destination: '/app/test/endpoints',
      body: json.encode({'a': 123}),
    );
  });*/
}

void onConnectTasks(StompFrame frame) async{
  // Подписываемся на топик /app/tasks
  void getUserTasks(String? userId) async{
    stompTasks.subscribe(
      destination: '/app/user/$userId/tasks',
      //destination: '/app/tasks',
      callback: (frame) {
        print(userId);
        // Получаем данные из сообщения и декодируем JSON
        Map<String, dynamic>? data = json.decode(frame.body!);

        // Проверяем, что данные не пусты и содержат ожидаемую структуру
        if (data != null) {
          // Получаем список ролей пользователя
          if(data.containsKey('taskList')) {
            taskInfoList = data['taskList'];
          }
          else {
            taskInfoList.add(data);
          }


          _controller.add(0);

          print('--------------------------------------------');
          // Выводим информацию о каждой роли
          /*for (var role in roleList) {
            print('Role ID: ${role['id']}');
            print('Title: ${role['title']}');
            print('Description: ${role['description']}');
            print('Luid: ${role['luid']}');
            print('Deleted: ${role['deleted']}');
            print('--------------------------------------------');
          }*/
        } else {
          print('Received invalid data from server');
        }
      },
    );
  }


  getUserTasks(uuid);

  // Пример вызова функции для получения ролей пользователя

  // Отправляем сообщение на тестовый эндпоинт каждые 10 секунд
  /*Timer.periodic(const Duration(seconds: 1), (_) {
    stompClient.send(
      destination: '/app/test/endpoints',
      body: json.encode({'a': 123}),
    );
  });*/
}

final stompClient = StompClient(
  config: StompConfig(
    url: Uri(scheme: 'ws', host: apiUrl.host, port: apiUrl.port, path: '/ws/websocket/authorization').toString(),
    onConnect: onConnectAuthorization,
    beforeConnect: () async {
      print('waiting to connect...');
      await Future.delayed(const Duration(milliseconds: 200));
      print('connecting...');
    },
    onWebSocketError: (dynamic error) => print(error.toString()),
    stompConnectHeaders: {'Authorization': 'Bearer $token'},
    webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
  ),
);

final stompTasks = StompClient(
  config: StompConfig(
    url: Uri(scheme: 'ws', host: apiUrl.host, port: apiUrl.port, path: '/ws/websocket/task').toString(),
    onConnect: onConnectTasks,
    beforeConnect: () async {
      print('waiting to connect...');
      await Future.delayed(const Duration(milliseconds: 200));
      print('connecting...');
    },
    onWebSocketError: (dynamic error) => print(error.toString()),
    stompConnectHeaders: {'Authorization': 'Bearer $token'},
    webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
  ),
);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class ForgotPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Реализуйте здесь действия для восстановления пароля
      },
      child: const Text(
        //'Forgot password?',
        'Забыли пароль?',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF424242), // Цвет текста
          fontFamily: 'Inter', // Семейство шрифтов
          height: 18 / 14, // Соотношение высоты строки к размеру шрифта
        ),
      ),
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<String> roles = [];

  Future<void> loginUser( String username, String password) async {

    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserPage()),
    );*/


    //раскомментить
    final authorizationUrl = apiUrl.replace(path: '/authorization/authenticate');
    final response = await http.post(
      authorizationUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'login': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      // код для обработки успешного ответа
      final responseData = jsonDecode(response.body);
      setState(() {
        token = responseData['token']; // Сохраняем токен в переменную token
        roles = List<String>.from(responseData['roles']); // Получаем и сохраняем роли
        luid = responseData['luid']; // Получаем и сохраняем роли
        uuid = responseData['user']; // Получаем и сохраняем роли
      });
      //print(token);

      //stompClient.activate(); //подключаемся к сокету

      if(uuid != null) {

        stompTasks.activate();

        if (roles.contains('ADMIN')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RectanglePage()),
          );
        }
        else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserPage()),
          );
        }
      }

    } else {
      // обработка ошибки
      print('Failed to login. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        //padding: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 100),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF818181),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration.collapsed(
                  //hintText: 'Login',
                  hintText: 'Логин',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF818181),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(
                  //hintText: 'Password',
                  hintText: 'Пароль',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ForgotPasswordButton(), // Добавляем кнопку "Forgot password?"
            //SizedBox(height: 16),
            Container(
              //margin: EdgeInsets.symmetric(vertical: 10.0),
              width: 200.0, // изменяем ширину контейнера
              height: 50.0, // изменяем высоту контейнера
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.grey),
              ),
              child: ElevatedButton(
                onPressed: () {
                  String _username = usernameController.text;
                  String _password = passwordController.text;
                  if (_username.isNotEmpty && _password.isNotEmpty) {
                    // Вызываем функцию для выполнения запроса
                    loginUser(_username, _password);
                    /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RectanglePage()),
                    );*/
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder( // задаем форму для границ кнопки
                    borderRadius: BorderRadius.circular(15.0), // задаем загругленность границ кнопки
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20.0,
                    color: Color(0xFF818181),
                  ),
                ),
                child: Container(
                  alignment: Alignment.center, // размещаем текст по центру
                  child: const Text(
                    //'Log-In',
                    'Войти',
                    style: TextStyle(
                      fontSize: 14.0, // размер шрифта
                      color: Color(0xFFA0A0A0), // цвет текста
                      height: 18.0 / 14.0, // соотношение высоты строки к размеру шрифта
                      fontFamily: 'Inter', // семейство шрифтов
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RectanglePage extends StatefulWidget {
  @override
  _RectanglePageState createState() => _RectanglePageState();
}

class _RectanglePageState extends State<RectanglePage> {
  //List<String> myTexts = taskInfoList[0];
  //int i = 0;
  /*List<String> myTexts = [
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей'
  ];*/

  List<String> myTexts = [];

  // Добавьте контроллер
  //final ScrollController _scrollController = ScrollController();

  // Переменная для отслеживания видимости стрелки вправо
  bool showRightArrow = true;
  bool showLeftArrow = false;


  @override
  void initState() {
    super.initState();
    _controller.stream.listen((value) {
      setState(() {
        //_value = value;
        myTexts.clear();
        for (var task in taskInfoList) {
          myTexts.add('${task['fullDescription']}');
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

    int myTextCount = myTexts.length;
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
                    PlusButton(
                      onAddText: (newText) {
                        setState(() {
                          myTexts.add(newText);
                        });
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      child: PopupMenuButton(
                        itemBuilder: (context) => [
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
              border: Border.all(color: Colors.grey.withOpacity(0)), //прозрачные границы
            ),
            //child: Center(child: Text(text)),
            child: Text(
              //myTextCount.toString() + " matching tasks found",
              myTextCount.toString() + " подходящий задач найдено",
              style: const TextStyle(
                fontSize: 14, // Размер текста
                color: Color(0xFFC0C0C0), // Цвет текста
                fontFamily: 'Inter', // Шрифт текста
                height: 1.0, // Межстрочный интервал
              ),
            ),
          ),
          Expanded( //серые прямоугольники
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      for (var text in myTexts)
                        Column(
                          children: [
                            MyRectangle(
                              text: text,
                              onTextChanged: (newText) {
                                setState(() {
                                  myTexts[myTexts.indexOf(text)] = newText;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {

  List<String> myTexts = [];

  //List<String> toDoItems = ['fds\nnhgnhg\nhnhnh\h\\n\nh'];
  //List<String> doingItems = ['fds'];
  //List<String> doneItems = ['fdsvgfd'];

  List<dynamic> toDoItems = [];
  List<dynamic> doingItems = [];
  List<dynamic> doneItems = [];


  @override
  void initState() {
    super.initState();
    _controller.stream.listen((value) {
      setState(() {
        //_value = value;
        toDoItems.clear();
        doingItems.clear();
        doneItems.clear();
        for (var task in taskInfoList) {
          //myTexts.add('${task['fullDescription']}');
          final taskStatus = task['taskStatus'];
          //print(taskStatus.runtimeType);
          int id = taskStatus['id'];
          switch (id) {
            case 1:
              {
                //toDoItems.add('${task['fullDescription']}');
                toDoItems.add(task);
              }
            case 2:
              {
                //doingItems.add('${task['fullDescription']}');
                doingItems.add(task);
              }
            case 3:
              {
                //doneItems.add('${task['fullDescription']}');
                doneItems.add(task);
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
                      child: _buildDraggableRectangle(toDoItems, 1),
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
                      child: _buildDraggableRectangle(doingItems, 2),
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
                      child: _buildDraggableRectangle(doneItems, 3),
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

  Widget _buildDraggableRectangle(List<dynamic> items, int columnNumber) {
    Color rectangleColor = const Color(0xFFF3C0C0);
    switch (columnNumber) {
      case 2:
        {
          rectangleColor = const Color(0xFFF5F2D4);
        }
      case 3:
        {
          rectangleColor = const Color(0xFFDAF6D5);
        }
    }
    return Column(
      children: items.map(
            (item) =>
            Draggable(
              data: item,
              feedback: Container(
                //width: 400,
                width: feedbackRectangleWidth,
                height: 50,
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
                      item["fullDescription"],
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
                  double itemPositionX = offset.dx + feedbackRectangleWidth / 2;


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
                      switch (columnNumber) {
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
                      }
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

                      taskInfoList.remove(item);

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
                      item['fullDescription'],
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


class MyTextView extends StatefulWidget {
  @override
  _MyTextViewState createState() => _MyTextViewState();
}

class _MyTextViewState extends State<MyTextView> {
  //String mainWindowText = "Everything";
  String mainWindowText = "Все проекты";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 19.0, top: 47.0),
      child: Row(
        children: [
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
                itemBuilder: (context) => [
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
                    mainWindowText = value as String;
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


/*class _MyTextViewState extends State<MyTextView> {
  String dropdownValue = mainMenuList.first;

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 100,
      child: DropdownMenu<String>(
        initialSelection: mainMenuList.first,
        onSelected: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        dropdownMenuEntries: mainMenuList.map<DropdownMenuEntry<String>>((
            String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent, // Установка прозрачного цвета границы
            ),
          ),
        ),
      ),
    );
  }
}*/




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
              final newText = await Navigator.push(context, MaterialPageRoute(builder: (context) => NewTextScreen()));
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

class MyRectangle extends StatefulWidget {
  final String text;
  final Function(String) onTextChanged;

  const MyRectangle({Key? key, required this.text, required this.onTextChanged}) : super(key: key);

  @override
  _MyRectangleState createState() => _MyRectangleState();
}

class _MyRectangleState extends State<MyRectangle> {
  String _text = '';

  @override
  void initState() {
    super.initState();
    _text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final editedText = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditTextScreen(initialText: _text)),
        );
        if (editedText != null && editedText != "") {
          setState(() {
            _text = editedText;
          });
          widget.onTextChanged(editedText);
        }
      },
      child: Container(
        width: 321.0,
        margin: const EdgeInsets.only(left: 11.0),
        decoration: BoxDecoration(
          color: const Color(0xFF818181),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(
              _text,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class NewTextScreen extends StatefulWidget {
  @override
  NewTextScreenState createState() => NewTextScreenState();
}

class NewTextScreenState extends State<NewTextScreen> {



  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
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
                    onPressed: () async{
                      // Действие при нажатии на кнопку с галочкой
                      var messageJson = {
                        "project": 1,
                        "startDate": "2024-04-03T13:00:35.729Z",
                        "endDate": "2024-04-03T13:00:35.729Z",
                        "estimation": 1,
                        "taskStatus": 1,
                        "taskType": 1,
                        "money": 1,
                        "targetEndProduct": "",
                        "shortDescription": "string1",
                        "completionRate": 1,
                        "issueEncountered": "",
                        "profit": 1,
                        "title": "string",
                        "fullDescription": "string5",
                        "taskPriority": 1
                      };
                      var messageString = json.encode(messageJson);

                      var url = Uri.parse('http://91.149.187.115:8060/task/user/$uuid');

                      // Отправляем POST-запрос на сервер
                      final response = await http.post(
                        url,
                        body: messageString,
                        headers: {
                          'Content-Type': 'application/json', // указываем тип контента
                          'Authorization': 'Bearer $token'
                        },
                      );
                      // Проверяем успешность запроса
                      if (response.statusCode == 200) {
                        // Если запрос успешен, можно обработать ответ сервера
                        print('Request successful');
                      } else {
                        // Если запрос не удался, можно вывести сообщение об ошибке
                        print('Request failed with status: ${response.statusCode}');
                      }

                      Navigator.pop(context, _nameController
                          .text); // передаем текст из контроллера для создания новоого прямоугольника с таской
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 19.0, top: 5),
              // Отступ слева для дополнительного текста
              child: Text(
                //'Made by You',
                'Сделано Антоном Ивановым',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0x80666666), // Цвет текста
                  fontFamily: 'Inter', // Шрифт
                  height: 1.0, // Высота строки
                ),
              ),
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
                  hintText: 'Введите ваш текст',
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
                '(до 55 символов)',
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
                      Expanded(
                        child: Text(
                          //'Spent time',
                          'Затрачено',
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
                    //mainAxisAlignment: MainAxisAlignment.center,
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
                        child: const Center(
                          child: Text(
                            //'00d 00h 00min',
                            '00д 00ч 00мин',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF818181), // Серый цвет текста
                              fontFamily: 'Inter', // Семейство шрифтов
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Пространство между прямоугольниками
                      Container(
                        width: 166.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(
                              10), // Закругление углов
                        ),
                        child: const Center(
                          child: Text(
                            //'00d 00h 00min',
                            '00д 00ч 00мин',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xFF818181), // Серый цвет текста
                              fontFamily: 'Inter', // Семейство шрифтов
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                'Статус',
                //'Task status',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF808080),
                ),
              ),
            ),
            const SizedBox(height: 2.0,),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 19),
                  width: 106.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFEDEDED), // Цвет границы
                      width: 3.0, // Толщина границы
                    ),
                    borderRadius: BorderRadius.circular(
                        10), // Закругление углов
                  ),
                  child: Center(
                    child: Text(
                      'Выполнить',
                      //'To do',
                      style: TextStyle(
                        fontSize: 14.0,
                        //color: Color(0xFFEDEDED), //цвет текста
                        color: Colors.grey.withOpacity(0.4), //цвет текста
                        fontFamily: 'Inter', // Семейство шрифтов
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Пространство между прямоугольниками
                Container(
                  width: 106.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFEDEDED), // Цвет границы
                      width: 3.0, // Толщина границы
                    ),
                    borderRadius: BorderRadius.circular(
                        10), // Закругление углов
                  ),
                  child: Center(
                    child: Text(
                      'В процессе',
                      //'Doing',
                      style: TextStyle(
                        fontSize: 14.0,
                        //color: Color(0xFFEDEDED), //цвет текста
                        color: Colors.grey.withOpacity(0.4), //цвет текста
                        fontFamily: 'Inter', // Семейство шрифтов
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Пространство между прямоугольниками
                Container(
                  width: 106.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFEDEDED), // Цвет границы
                      width: 3.0, // Толщина границы
                    ),
                    borderRadius: BorderRadius.circular(
                        10), // Закругление углов
                  ),
                  child: Center(
                    child: Text(
                      'Выполнено',
                      //'Done',
                      style: TextStyle(
                        fontSize: 14.0,
                        //color: Color(0xFFEDEDED), //цвет текста
                        color: Colors.grey.withOpacity(0.4), //цвет текста
                        fontFamily: 'Inter', // Семейство шрифтов
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                              height: 1.0, // line height
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Исполнители",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF808080),
                              fontFamily: 'Inter',
                              height: 1.0, // line height
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
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

class EditTextScreen extends StatefulWidget {
  final String initialText;

  const EditTextScreen({Key? key, required this.initialText}) : super(key: key);

  @override
  _EditTextScreenState createState() => _EditTextScreenState();
}

class _EditTextScreenState extends State<EditTextScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter your text',
              ),
            ),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
