import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_validator/form_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testproject/components/app_button.dart';
import 'package:testproject/pages/settings_page.dart';
import 'package:testproject/splash_page.dart';
import 'package:testproject/utils/app_const.dart';
import 'package:testproject/utils/app_func.dart';
import 'package:testproject/components/app_input.dart';
import 'package:testproject/components/app_text.dart';
import 'package:testproject/utils/app_pref.dart';

import 'components/app_image.dart';

class HomePage extends ConsumerStatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  var key = GlobalKey<FormState>();

  var hidePassword = true;
  var isLoading = false;
  int times = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    PreferenceHelper.setBool("home", true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ref.watch(darkModeEnabled)?Colors.black:Colors.white,
      appBar: AppBar(
        title: const AppText(
          "Home Page",
          color: Colors.white,
        ),
        actions: [
          IconButton(
              onPressed: () {
                log("go to setting page");
                navigateToWidget(context, const SettingPage());
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {
                log("go to profile page");
              },
              icon: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log("fab is pressed");
          setState(() {
            times++;
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    AppText("nbTimes provider ${ref.read(nbTimes)}"),
                    SizedBox(height: 20,),


                    SimpleFormField(
                      controller: nameController,
                      validation:
                          ValidationBuilder(requiredMessage: "Champ requis"),
                      prefixI: const Icon(Icons.person),
                    ),

                    const SizedBox(
                      height: 40,
                    ),

                    SimpleFilledFormField(
                      controller: passwordController,
                      obscure: hidePassword,
                      validation:
                          ValidationBuilder(requiredMessage: "Champ requis"),
                      prefixI: const Icon(Icons.person),
                      suffixI: IconButton(
                          onPressed: () {
                            hidePassword = !hidePassword;
                            log(hidePassword);
                            setState(() {});
                          },
                          icon: hidePassword
                              ? const Icon(Icons.remove_red_eye)
                              : const Icon(Icons.password_outlined)),
                    ),

                    TextButton(
                        onPressed: () {
                          if (key.currentState!.validate()) {
                            log("cool");
                          } else {
                            log("bad");
                          }
                        },
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.green),
                        child: const AppText(
                          "Valider le formulaire",
                          color: Colors.white,
                        )),

                    AppText(
                      "Vous avez appuyé sur le FAB $times fois...",
                      size: 24,
                      align: TextAlign.center,
                    ),

                    TextButton(
                        onPressed: () {

                          showConfirm(context, "Voulez-vous vraiment réinitialiser?", (){
                            times = 0;
                            isLoading = false;
                            setState(() {});
                            Navigator.pop(context);
                          });

                          // showDialog(context: context, builder: (context){
                          //   return AlertDialog(
                          //     title: const AppText("Confirmation", weight: FontWeight.bold, size: 22,),
                          //     content: const AppText("Voulez-vous vraiment réinitialiser? "),
                          //     actions: [
                          //       TextButton(child: const AppText("Oui"), onPressed: (){
                          //         times = 0;
                          //         isLoading = false;
                          //         setState(() {});
                          //         Navigator.pop(context);
                          //       },  ),
                          //
                          //       TextButton(child: const AppText("Non"), onPressed: (){
                          //         Navigator.pop(context);
                          //       },  ),
                          //     ],
                          //   );
                          // });

                        },
                        child: const AppText("Réïnitialiser")),
                    /* IMAGES */
                    // ""

                    InkWell(
                      onTap: () {
                        log("on tap is pressed");
                      },
                      onLongPress: () {
                        log("on long p is pressed");
                      },
                      child:   AppText("Click me ${ref}"),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    AppButtonRound(text: "Our 1st custom button", onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                    }, isLoading: isLoading,),

                    const SizedBox(
                      height: 150,
                    ),
                    InkWell(
                      onTap: () {
                        log("image is pressed");
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: const AppImage(
                            url:
                                "https://static.vecteezy.com/system/resources/previews/000/390/524/original/modern-company-logo-design-vector.jpg"),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
