import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testproject/components/app_image.dart';
import 'package:testproject/utils/app_func.dart';
import 'package:testproject/utils/app_pref.dart';

import '../components/app_text.dart';
import '../utils/providers.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {

  var image = "assets/img/default_img.png";

  var percentage = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppText("Gallerie", color:Colors.white, size: 22,),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell( onTap: (){
            uploadFile();
          }, child: AppImage(url: image)),
          const SpacerHeight(),
          AppText(percentage),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        uploadFile();
      }, child: const Icon(Icons.add, color: Colors.white,),),
    );
  }
  // Function to pick an image from the gallery
  Future<XFile?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  Future<void> uploadFile() async {
    XFile? file = await pickImageFromGallery();
    if(file!=null){
      String? path = await uploadImageToFirebase(file);
      try {
        image = path!;
        log(image);
        //ref.read(imgRef).add({"path": path});
        PreferenceHelper.setString("image", image);
      } catch (e) {
        print(e);
      }
      setState(() {

      });
    }else{
      showSnackbar(context, "Echec");
    }
  }

  Future<String?> uploadImageToFirebase(XFile? imageFile) async {
    if (imageFile == null) return null;

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final imageName = 'image_$timestamp.jpg';
    final uploadTask = ref.read(mStorage).child('images/$imageName').putFile(File(imageFile.path));
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      percentage = ('Upload progress: $progress%');
      setState(() {

      });
    });

    try {
      await uploadTask;
      final imageUrl = await ref.read(mStorage).child('images/$imageName').getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  void getImage() {
    String lastImage = PreferenceHelper.getString("image");
    if(lastImage.isNotEmpty){
      image = lastImage;
      setState(() {

      });
    }
  }


}
