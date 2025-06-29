import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

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
  var _confirmPassword = "";
  var _enteredUsername = "";
  var _isLoading = false;
  File? _pickedImage;
  void _submitForm() async {
    final isValid = _form.currentState!.validate();
    setState(() {
      _isLoading = true;
    });
    if (!isValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (!_isSignedIn && _pickedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Set your avatar image to continue.",
        style: TextStyle(color: Theme.of(context).colorScheme.errorContainer),
      )));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _form.currentState!.save();
    try {
      if (_isSignedIn) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredentials.user!.uid}.jpg");

        await storageRef.putFile(_pickedImage!);
        final imageURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageURL,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Authentication failed.")));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Container(
        padding: EdgeInsets.only(top: 56),
        alignment: Alignment.topCenter,
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
                margin: const EdgeInsets.only(
                    top: 24, bottom: 24, left: 16, right: 16),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _form,
                        child: Column(
                          spacing: 20,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              spacing: 8,
                              children: [
                                Text(
                                  _isSignedIn ? "Welcome back!" : "Welcome",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                Text(
                                  _isSignedIn
                                      ? "Enter your credentials to continue."
                                      : "Create an account to continue.",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            if (!_isSignedIn)
                              UserImagePicker(
                                onPickedImage: (pickedImage) {
                                  _pickedImage = pickedImage;
                                },
                              ),
                            if (!_isSignedIn)
                              TextFormField(
                                enabled: !_isLoading ? true : false,
                                decoration: const InputDecoration(
                                  labelText: "Username",
                                  border: OutlineInputBorder(),
                                ),
                                enableSuggestions: false,
                                autocorrect: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.trim().length < 4) {
                                    return "Usernames should be at least 4 characters";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredUsername = value!;
                                },
                              ),
                            TextFormField(
                              enabled: !_isLoading ? true : false,
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
                              enabled: !_isLoading ? true : false,
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
                              onChanged: (value) {
                                _confirmPassword = value;
                              },
                            ),
                            if (!_isSignedIn)
                              TextFormField(
                                enabled: !_isLoading ? true : false,
                                decoration: InputDecoration(
                                  labelText: "Confirm password",
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value != _confirmPassword) {
                                    return "It doesn't match with the password";
                                  }

                                  // Add more validation if needed
                                  return null;
                                },
                                obscureText: true,
                              ),
                            Column(
                              spacing: 8,
                              children: [
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ButtonStyle(
                                        shape: WidgetStatePropertyAll<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        backgroundColor:
                                            WidgetStatePropertyAll<Color>(
                                                !_isLoading
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Colors.grey)),
                                    onPressed: !_isLoading ? _submitForm : null,
                                    label: Text(
                                      _isSignedIn
                                          ? "Sign in"
                                          : "Create account",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    ),
                                    icon: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeCap: StrokeCap.round,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                TextButton(
                                    onPressed: !_isLoading
                                        ? () {
                                            setState(() {
                                              _isSignedIn = !_isSignedIn;
                                            });
                                          }
                                        : null,
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
