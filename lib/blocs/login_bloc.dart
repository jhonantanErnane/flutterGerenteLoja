import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerenteloja/validators/login_validator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

enum LoginState { IDLE, LOADING, SUCCESS, FAIL }

class LoginBloc extends BlocBase with LoginValidators {
  final _emailCtrl = BehaviorSubject<String>();
  final _passCtrl = BehaviorSubject<String>();
  final _stateCtrl = BehaviorSubject<LoginState>();

  Stream<String> get outEmail => _emailCtrl.stream.transform(validateEmail);
  Stream<String> get outPass => _passCtrl.stream.transform(validatePass);

  Stream<LoginState> get outLoginState => _stateCtrl.stream;

  Stream<bool> get outSubmitValid =>
      Observable.combineLatest([outEmail, outPass], (combiner) {
        print(combiner);
        return true;
      });
  // Observable.combineLatest2(outEmail, outPass, (a, b) => true);

  Function(String) get changeEmail => _emailCtrl.sink.add;
  Function(String) get changePass => _passCtrl.sink.add;

  StreamSubscription<FirebaseUser> _streamSubscription;

  LoginBloc() {
    // FirebaseAuth.instance.signOut();
    _streamSubscription =
        FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      if (user != null) {
        if (await verifyPrivileges(user)) {
          _stateCtrl.add(LoginState.SUCCESS);
        } else {
          _stateCtrl.add(LoginState.FAIL);
          FirebaseAuth.instance.signOut();
        }
      } else {
        _stateCtrl.add(LoginState.IDLE);
      }
    });
  }

  void submit() {
    final email = _emailCtrl.value;
    final pass = _passCtrl.value;
    _stateCtrl.add(LoginState.LOADING);
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: pass)
        .catchError((e) => _stateCtrl.add(LoginState.FAIL));
  }

  Future<bool> verifyPrivileges(FirebaseUser user) async {
    return await Firestore.instance
        .collection('admins')
        .document(user.uid)
        .get()
        .then((doc) {
      if (doc.data != null) {
        return true;
      } else {
        return false;
      }
    }).catchError((e) => false);
  }

  @override
  void dispose() {
    _emailCtrl.close();
    _passCtrl.close();
    _streamSubscription.cancel();
    _stateCtrl.close();
  }
}
