import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends BlocBase {
  final _titleCtrl = BehaviorSubject<String>();
  final _imageCtrl = BehaviorSubject();
  final _deleteCtrl = BehaviorSubject<bool>();

  DocumentSnapshot category;
  File image;
  String title;

  Stream<String> get outTitle => _titleCtrl.stream.transform(
          StreamTransformer<String, String>.fromHandlers(
              handleData: (title, sink) {
        if (title.isEmpty) {
          sink.addError('Insira um titulo');
        } else {
          sink.add(title);
        }
      }));
  Stream get outImage => _imageCtrl.stream;
  Stream<bool> get outDelete => _deleteCtrl.stream;
  Stream<bool> get submitValid =>
      Observable.combineLatest2(outTitle, outImage, (a, b) => true);

  CategoryBloc(this.category) {
    if (category != null) {
      title = category.data['title'];
      _titleCtrl.add(category.data['title']);
      _imageCtrl.add(category.data['icon']);
      _deleteCtrl.add(true);
    } else {
      _deleteCtrl.add(false);
    }
  }

  Future delete() async {
    await category.reference.delete();
  }

  Future saveData() async {
    if (image == null && category != null && title == category.data['title']) {
      return null;
    }
    Map<String, dynamic> dataToUpdate = {};
    if (image != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child('icons')
          .child(title)
          .putFile(image);
      StorageTaskSnapshot snap = await task.onComplete;
      dataToUpdate['icon'] = await snap.ref.getDownloadURL();
    }

    if (category == null || title != category.data['title']) {
      dataToUpdate['title'] = title;
    }

    if (category == null) {
      await Firestore.instance
          .collection('products')
          .document(title.toLowerCase())
          .setData(dataToUpdate);
    } else {
      await category.reference.updateData(dataToUpdate);
    }
  }

  void setTitle(String title) {
    this.title = title;
    _titleCtrl.add(title);
  }

  void setImage(File file) {
    image = file;
    _imageCtrl.add(file);
  }

  @override
  void dispose() {
    _titleCtrl.close();
    _imageCtrl.close();
    _deleteCtrl.close();
  }
}
