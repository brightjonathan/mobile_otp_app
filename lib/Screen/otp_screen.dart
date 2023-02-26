import 'package:flutter/material.dart';
import 'package:phone_auth/Provider/auth_provider.dart';
import 'package:phone_auth/Screen/home_screen.dart';
import 'package:phone_auth/Screen/user_information_screen.dart';
import 'package:phone_auth/Utilities/utili.dart';
import 'package:phone_auth/Widget/custom_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class otpScreen extends StatefulWidget {
  //created a variable
  final String verificationId;
  const otpScreen({required this.verificationId});

  @override
  State<otpScreen> createState() => _otpScreenState();
}

class _otpScreenState extends State<otpScreen> {
  //otpCode string
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true)
        .isLoading; //from our provider
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 25.0, horizontal: 30.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      Container(
                        height: 200,
                        width: 200,
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple.shade50),
                        child: Image.asset("images/login.png"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Verification",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        "Enter the OTP sent to your phone number",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() {
                            otpCode = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: CustomButton(
                          text: 'Verify',
                          onPressed: () {
                            if (otpCode != null) {
                              verifyOTp(context, otpCode!);
                            } else {
                              //showSnaskBar from utili folder
                              showSnaskBar(context, "Enter 6-digit code");
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Didn't recieve any code ?",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      const Text(
                        "Resend new code",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  //otp verification
  void verifyOTp(BuildContext context, String userotp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyotp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userotp,
      onSuccess: () {
        //checking if user exits
        ap.checkingExistingUser().then((value) async {
          if (value == true) {
            ap.getDataFromFireStore().then(
                  (value) => ap.saveUserDataToSp().then(
                        (value) => ap.setSignIn().then(
                              (value) => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                  (route) => false),
                            ),
                      ),
                );
          } else {
            //
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const userInfo(),
                ),
                (route) => false);
          }
        });
      },
    );
  }
}
