import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isSignedIn = true;
  var _enteredEmail = "";
  var _enteredPassword = "";

  void _submitForm() {
    final isValid = _form.currentState!.validate();

    if (isValid) {
      _form.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(16, 32, 16, 20),
                  child: Image(
                      width: 200,
                      image: AssetImage(
                        "assets/images/chat.png",
                      ))),
              Card(
                margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _form,
                        child: Column(
                          spacing: 20,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Email",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains("@")) {
                                  return "Please enter a valid email address";
                                }
                                // Add more validation if needed
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!.trim();
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter a password";
                                }
                                if (value.length < 8) {
                                  return "Password must be at least 8 characters long";
                                }
                                // Add more validation if needed
                                return null;
                              },
                              obscureText: true,
                              onSaved: (value) {
                                _enteredPassword = value!.trim();
                              },
                            ),
                            Column(
                              spacing: 8,
                              children: [
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          shape: WidgetStatePropertyAll<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                      8))),
                                          backgroundColor:
                                              WidgetStatePropertyAll<Color>(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
                                      onPressed: _submitForm,
                                      child: Text(
                                          _isSignedIn ? "Sign in" : "Create account",
                                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary))),
                                ),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isSignedIn = !_isSignedIn;
                                      });
                                    },
                                    child: Text(_isSignedIn
                                        ? "Create account"
                                        : "Login instead")),
                              ],
                            ),
                          ],
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
