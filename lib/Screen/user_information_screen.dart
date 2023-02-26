import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phone_auth/Model/user_model.dart';
import 'package:phone_auth/Provider/auth_provider.dart';
import 'package:phone_auth/Screen/home_screen.dart';
import 'package:phone_auth/Utilities/utili.dart'; //pickImage
import 'package:phone_auth/Widget/custom_button.dart';
import 'package:provider/provider.dart';

class userInfo extends StatefulWidget {
  const userInfo({Key? key}) : super(key: key);

  @override
  State<userInfo> createState() => _userInfoState();
}

class _userInfoState extends State<userInfo> {
  //
  File? image;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  //user selected img
  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          selectImage();
                        },
                        child: image == null
                            ? const CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 50,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(image!),
                                radius: 50,
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            //Name filed
                            TextFeld(
                              hintText: "Enter your name...",
                              icon: Icons.account_circle,
                              inputType: TextInputType.name,
                              maxLine: 1,
                              controller: nameController,
                            ),
                            TextFeld(
                              hintText: "Enter your email address...",
                              icon: Icons.email,
                              inputType: TextInputType.emailAddress,
                              maxLine: 1,
                              controller: emailController,
                            ),
                            TextFeld(
                              hintText: "Enter your bio here...",
                              icon: Icons.edit,
                              inputType: TextInputType.name,
                              maxLine: 2,
                              controller: bioController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: CustomButton(
                          text: "Continue",
                          onPressed: () => storeData(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  //re-useable widget
  Widget TextFeld({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLine,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.blue,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLine,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.blue,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.blue.shade50,
          filled: true,
        ),
      ),
    );
  }

  //store in the firebase database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      bio: bioController.text.trim(),
      profilePic: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );
    if (image != null) {
      //from saveUserDataToFirebase the provider
      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        profilePic: image!,
        onSuccess: () {
          //
          ap.saveUserDataToSp().then(
            (value) {
              //navigating to home page
              ap.setSignIn().then(
                    (value) => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false),
                  );
            },
          );
        },
      );
    } else {
      //show
      showSnaskBar(context, "please upload your profile photo");
    }
  }
}
