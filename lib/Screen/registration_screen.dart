import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth/Provider/auth_provider.dart';
import 'package:phone_auth/Widget/custom_button.dart';
import 'package:provider/provider.dart';

class Registration_Screen extends StatefulWidget {
  const Registration_Screen({Key? key}) : super(key: key);

  @override
  State<Registration_Screen> createState() => _Registration_ScreenState();
}

class _Registration_ScreenState extends State<Registration_Screen> {
  //text controller
  final TextEditingController phoneController = TextEditingController();

  //country code api
  Country Selectedcountry = Country(
    phoneCode: "234",
    countryCode: "NG",
    e164Sc: 0,
    geographic: true,
    level: 2,
    name: "Nigeria",
    example: "Nigeria",
    displayName: "Nigeria",
    displayNameNoCountryCode: "NG",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    //setting the position of the text
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35.0),
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: 200,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.purple.shade50),
                  child: Image.asset("images/background.png"),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  cursorColor: Colors.purple,
                  controller: phoneController,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  //changing the  value
                  onChanged: (value) {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Enter your Phone Number",
                    helperStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            countryListTheme: const CountryListThemeData(
                                bottomSheetHeight: 400),
                            onSelect: (value) {
                              setState(() {
                                Selectedcountry = value;
                              });
                            },
                          );
                        },
                        child: Text(
                          "${Selectedcountry.flagEmoji} + ${Selectedcountry.phoneCode}",
                          style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                    suffixIcon: phoneController.text.length > 9
                        ? Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.green),
                            child: const Icon(Icons.done,
                                color: Colors.white, size: 20),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  "Add your phone number, we'll send you a verification code ",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    text: 'Login',
                    onPressed: () {
                      sendPhoneNumber();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    //adding the phone number
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String PhoneNumber = phoneController.text.trim();
    ap.signInWithPhone(context, "+${Selectedcountry.phoneCode}$PhoneNumber");
  }
}
