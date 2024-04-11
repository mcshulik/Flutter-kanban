import 'package:flutter_kanban/main.dart';
import 'package:flutter_kanban/adminPage.dart';
import 'package:flutter_kanban/userPage.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';


class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> loginUser( String username, String password) async {

    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserPage()),
    );*/


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
        luid = responseData['luid'];
        uuid = responseData['user'];
      });
      //print(token);

      if (roles.contains('ADMIN')) {
        destinationForGetTasks = '/app/tasks';
      }
      else {
        destinationForGetTasks = '/app/user/$uuid/tasks';
      }

      //stompClient.activate(); //подключаемся к сокету

      if(uuid != null) {

        stompTasks.activate();

        if (roles.contains('ADMIN')) {
          await fetchData();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
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
            //ForgotPasswordButton(), // Добавляем кнопку "Forgot password?"
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
                  String username = usernameController.text;
                  String password = passwordController.text;
                  if (username.isNotEmpty && password.isNotEmpty) {
                    // Вызываем функцию для выполнения запроса
                    loginUser(username, password);
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
            /*print('Role ID: ${role['id']}');
            print('Title: ${role['title']}');
            print('Description: ${role['description']}');
            print('Luid: ${role['luid']}');
            print('Deleted: ${role['deleted']}');
            print('--------------------------------------------');*/
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
      destination: destinationForGetTasks,
      //destination: '/app/user/$userId/tasks',
      //destination: '/app/tasks',
      callback: (frame) {
        print(userId);
        // Получаем данные из сообщения и декодируем JSON
        Map<String, dynamic>? data = json.decode(frame.body!);

        // Проверяем, что данные не пусты и содержат ожидаемую структуру
        if (data != null) {
          // Получаем список ролей пользователя
          if(data.containsKey('taskList')) {
            tasksInfoList = data['taskList'];
          }
          else {
            tasksInfoList.removeWhere((task) => task['id'] == data['id']);
            tasksInfoList.add(data);
          }
          tasksInfoList.removeWhere((task) => task['taskDeleted'] == true);

          if (roles.contains('ADMIN')) {
            controllerForAdmin.add(0);
          }
          else {
            controllerForUser.add(0);
          }

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


Future<void> fetchData() async {
  var getUsersUrl = apiUrl.replace(path: '/user');

  try {
    var response = await http.get(
      getUsersUrl,
      headers: {
        'Content-Type': 'application/json', // указываем тип контента
        'Authorization': 'Bearer $token'
      },
    );

    // Проверяем статус ответа
    if (response.statusCode == 200) {
      //Map<String, dynamic>? data = json.decode(response.body);
      Map<String, dynamic>? data = jsonDecode(utf8.decode(response.bodyBytes));
      //jsonDecode(utf8.decode(response.bodyBytes))
      // Проверяем, что данные не пусты и содержат ожидаемую структуру
      if (data != null && data.containsKey('userList')) {
        // Получаем список ролей пользователя
        usersInfoList = data['userList'];
      }
    } else {
      // Если сервер вернул ошибку, выводим статус и сообщение об ошибке
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (error) {
    // Если произошла ошибка во время выполнения запроса, выводим её
    print('Error during GET request: $error');
  }
}
