import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class ProductBloc extends BlocBase {
  final _dataCtrl = BehaviorSubject<Map>();
  final _loadingCtrl = BehaviorSubject<bool>();
  final _createdCtrl = BehaviorSubject<bool>();

  Stream<Map> get dataCtrlOut => _dataCtrl.stream;
  Stream<bool> get loadingOut => _loadingCtrl.stream;
  Stream<bool> get createdOut => _createdCtrl.stream;

  String categoryId;
  DocumentSnapshot product;

  Map<String, dynamic> unsavedData;

  ProductBloc({this.categoryId, this.product}) {
    if (product != null) {
      unsavedData = Map.of(product.data);
      unsavedData['images'] = List.of(product.data['images']);
      unsavedData['sizes'] = List.of(product.data['sizes']);
      _createdCtrl.add(true);
    } else {
      _createdCtrl.add(false);
      unsavedData = {
        'title': null,
        'description': null,
        'price': null,
        'images': [],
        'sizes': []
      };
    }

    _dataCtrl.add(unsavedData);
  }

  void saveTitle(String title) {
    unsavedData['title'] = title;
  }

  void saveDescription(String description) {
    unsavedData['description'] = description;
  }

  void savePrice(String price) {
    unsavedData['price'] = double.parse(price);
  }

  void saveImages(List images) {
    unsavedData['images'] = images;
  }

  void saveSizes(List sizes) {
    unsavedData['sizes'] = sizes;
  }

  Future<bool> saveProduct() async {
    _loadingCtrl.add(true);
    try {
      if (product != null) {
        await _uploadImages(product.documentID);
        await product.reference.updateData(unsavedData);
      } else {
        DocumentReference dr = await Firestore.instance
            .collection('products')
            .document(categoryId)
            .collection('items')
            .add(Map.from(unsavedData)..remove('images'));
        await _uploadImages(dr.documentID);
        await dr.updateData(unsavedData);
      }
      _loadingCtrl.add(false);
      _createdCtrl.add(false);
      return true;
    } catch (e) {
      _loadingCtrl.add(false);
      return false;
    }
  }

  Future _uploadImages(String productId) async {
    for (var i = 0; i < unsavedData['images'].length; i++) {
      if (!(unsavedData['images'][i] is String)) {
        StorageUploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child(categoryId)
            .child(productId)
            .child(DateTime.now().millisecondsSinceEpoch.toString())
            .putFile(unsavedData['images'][i]);
        StorageTaskSnapshot s = await uploadTask.onComplete;
        unsavedData['images'][i] = await s.ref.getDownloadURL();
      }
    }
  }

  Future<bool> removeProduct() async {
    print(product.documentID);
    _loadingCtrl.add(true);
    try {
      await Firestore.instance
          .collection('products')
          .document(categoryId)
          .collection('items')
          .document(product.documentID)
          .delete();
      _loadingCtrl.add(false);
      return true;
    } catch (e) {
      _loadingCtrl.add(false);
      return false;
    }
  }

  @override
  void dispose() {
    _dataCtrl.close();
    _loadingCtrl.close();
    _createdCtrl.close();
  }
}
