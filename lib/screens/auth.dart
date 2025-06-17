import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(16, 32, 16, 20),
                  child: Image(image: AssetImage("assets/image/chat.png"))),
              Card(
                margin: const EdgeInsets.only(top: 24),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [TextFormField()],
                    )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
