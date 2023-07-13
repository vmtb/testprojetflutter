import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:testproject/components/app_button.dart';
import 'package:testproject/components/app_text.dart';
import 'package:testproject/pages/profile_page.dart';
import 'package:testproject/utils/app_func.dart';

import '../splash_page.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {

  var darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ref.read(darkModeEnabled)?Colors.black:Colors.white,
      appBar: AppBar(
        // leading: InkWell(
        //     onTap: (){
        //       Navigator.pop(context);
        //     },
        //     child: AppText("Retour", color: Colors.white,)),
        foregroundColor: Colors.white,
        title: AppText(
          "Paramètres",
          color: Colors.white,
        ),
      ),

      body: Column(
        children: [
          AppText("nbTimes provider ${ref.read(nbTimes)}"),

          SizedBox(height: 40,),
          SwitchListTile(value: ref.watch(darkModeEnabled), onChanged: (e){
            ref.read(darkModeEnabled.notifier).state = e;
          }, title: AppText("Activer mode sombre"),),


          SizedBox(height: 40,),
          Center(
            child: AppButtonRound(text: "Page profile ", width: 250, onTap: (){
              navigateToWidget(context, const ProfilePage(), back: false);
            }),
          ),
          SizedBox(height: 40,),


          Center(
            child: AppButtonRound(text: "Show success", width: 250, onTap: (){
             showSuccessError(context, "Echec d'ajout du fichier", error: true);
            }),
          ),

          SizedBox(height: 40,),

          Center(
            child: AppButtonRound(text: "Show snackbar", width: 250, onTap: (){
              showSnackbar(context, "Echec de création...");
            }),
          ),


        ],
      ),
    );
  }
}
