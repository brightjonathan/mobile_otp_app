import 'package:flutter/material.dart';
import 'package:phone_auth/Provider/auth_provider.dart';
import 'package:phone_auth/Screen/home_screen.dart';
import 'package:phone_auth/Screen/registration_screen.dart';
import 'package:phone_auth/Widget/custom_button.dart';
import 'package:provider/provider.dart';

class WelcomScreen extends StatefulWidget {
  const WelcomScreen({Key? key}) : super(key: key);

  @override
  State<WelcomScreen> createState() => _WelcomScreenState();
}

class _WelcomScreenState extends State<WelcomScreen> {
  @override
  Widget build(BuildContext context) {
    //provider widget
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/welcome.png", height: 300),
                const SizedBox(height: 20.0),
                const Text(
                  "Let's get started",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  "Never a better time than now to start.",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  //customer button Reusable widget
                  child: CustomButton(
                    onPressed: () async {
                      if (ap.isSignin == true) {
                        await ap.getdataFromSp().whenComplete(
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              ),
                            );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Registration_Screen(),
                          ),
                        );
                      }
                    },
                    text: 'Get Started',
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
