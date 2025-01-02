import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
class Storage{
  final FirebaseStorage storage=FirebaseStorage.instance;
  Future<String> uploadImageToStorage({required String childPath,required File file,required String id})async {
    Reference ref=storage.ref().child(childPath).child('$id${p.extension(file.path)}');
    print("Uploading to path: Locations/${id}${p.extension(file.path)}");
    UploadTask uploadTask =ref.putFile(file);
    String downloadUrl= await uploadTask.then((res){
      return res.ref.getDownloadURL();
    } );
    return downloadUrl;
  }
}