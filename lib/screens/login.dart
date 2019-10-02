import 'package:flutter/material.dart';
import 'package:gerenteloja/blocs/login_bloc.dart';
import 'package:gerenteloja/screens/home.dart';
import 'package:gerenteloja/widgtes/input_field.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _loginBloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    _loginBloc.outLoginState.listen((state) {
      switch (state) {
        case LoginState.SUCCESS:
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) => Home()));
          break;
        case LoginState.FAIL:
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Erro'),
                    content: Text('Você não possui privilégios necessários'),
                  ));
          break;
        case LoginState.IDLE:
        case LoginState.LOADING:
      }
    });
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<LoginState>(
          stream: _loginBloc.outLoginState,
          initialData: LoginState.LOADING,
          builder: (context, snapshot) {
            print(snapshot.data);
            switch (snapshot.data) {
              case LoginState.LOADING:
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
                  ),
                );
                break;
              case LoginState.SUCCESS:
              case LoginState.FAIL:
              case LoginState.IDLE:
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(),
                    SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(
                              Icons.store_mall_directory,
                              color: Colors.pinkAccent,
                              size: 160,
                            ),
                            // TextFormField(
                            //   keyboardType: TextInputType.emailAddress,
                            //   decoration: InputDecoration(
                            //     hintText: 'Usuário',
                            //     icon: Icon(
                            //       Icons.person_outline,
                            //       color: Colors.white,
                            //     ),
                            //     focusedBorder: UnderlineInputBorder(
                            //         borderSide:
                            //             BorderSide(color: Colors.pinkAccent)),
                            //   ),
                            // ),
                            InputField(
                              hint: 'Usuário',
                              icon: Icons.person_outline,
                              obscure: false,
                              stream: _loginBloc.outEmail,
                              onChanged: _loginBloc.changeEmail,
                            ),
                            InputField(
                              hint: 'Senha',
                              icon: Icons.lock_outline,
                              obscure: true,
                              stream: _loginBloc.outPass,
                              onChanged: _loginBloc.changePass,
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            StreamBuilder<bool>(
                                stream: _loginBloc.outSubmitValid,
                                builder: (context, snapshot) {
                                  return SizedBox(
                                    height: 50,
                                    child: RaisedButton(
                                      onPressed: snapshot.hasData
                                          ? _loginBloc.submit
                                          : null,
                                      child: Text('Entrar'),
                                      color: Colors.pinkAccent,
                                    ),
                                  );
                                })
                          ],
                        ),
                      ),
                    ),
                  ],
                );
                break;
              default:
                return Container();
                break;
            }
          }),
    );
  }
}
