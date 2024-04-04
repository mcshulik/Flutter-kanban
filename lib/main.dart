import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Проверка логина и пароля может быть добавлена здесь
                // В данном случае мы просто переходим к отображению прямоугольников
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RectanglePage()),
                );
              },
              child: Text('Login'),
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
  List<String> myTexts = [
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей',
    'Оформление документации и создание плюшевых медведей'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyTextView(),
                PlusButton(
                  onAddText: (newText) {
                    setState(() {
                      myTexts.add(newText);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
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
                              SizedBox(height: 10),
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
      ),
    );
  }
}

class MyTextView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 19.0, top: 47.0),
      child: Text(
        'Everything',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.black,
          height: 1.2,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

class PlusButton extends StatelessWidget {
  final Function(String) onAddText;

  PlusButton({required this.onAddText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.0,
      height: 25.0,
      margin: EdgeInsets.only(right: 24.0, top: 48.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/plus_math.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          final newText = await Navigator.push(context, MaterialPageRoute(builder: (context) => NewTextScreen()));
          if (newText != null && newText is String && newText.isNotEmpty) {
            onAddText(newText);
          }
        },
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
        margin: EdgeInsets.only(left: 11.0),
        decoration: BoxDecoration(
          color: Color(0xFF818181),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(
              _text,
              style: TextStyle(
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
  _NewTextScreenState createState() => _NewTextScreenState();
}

class _NewTextScreenState extends State<NewTextScreen> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController, // Привязываем контроллер к текстовому полю
              decoration: InputDecoration(
                labelText: 'Enter your first text',
              ),
            ),
            SizedBox(height: 16),
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                Navigator.pop(context, _textController.text); // Передаем текст из контроллера
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose(); // Не забываем освободить ресурсы контроллера
    super.dispose();
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
        title: Text('Edit Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter your text',
              ),
            ),
            SizedBox(height: 16),
            IconButton(
              icon: Icon(Icons.check),
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
