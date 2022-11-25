import 'dart:convert';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:locationtracker/Screens/Home.dart';

import '../Providers/LoginProvider.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

TextEditingController email = TextEditingController();
TextEditingController password = TextEditingController();
ScheduledTask scheduledTask;

class _LoginState extends State<Login> {
  @override
  void initState() {
    cancelSheduleTask();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 248, 248, 248),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login",
              style: GoogleFonts.poppins(
                  fontSize: 40, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 30,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: TextFormField(
                    controller: email,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        label: Text("Email"),
                        labelStyle: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 30,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: TextFormField(
                    controller: password,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        label: Text("Password"),
                        labelStyle: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            InkWell(
              onTap: () {
                String emailString = email.text.toString();
                String passwordString = password.text.toString();

                if (emailString != "" || passwordString != "") {
                  login();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Fill Email & Password',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    "Login",
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  login() async {
    var data = {
      'email': email.text.toString(),
      'password': password.text.toString()
    };
    var res = await UserProvider().authData(data);
    print(res.body);
    final body = json.decode(res.body);

    print(res.body);

    if (res.statusCode == 200) {
      await Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Home()), (route) => false);
    } else if (body["message"] == "Invalid username or password") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Error!',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  void cancelSheduleTask() async {
    if (scheduledTask != null) {
      scheduledTask.cancel();

      print("cancel");
    }
  }
}
