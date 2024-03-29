import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  final Stream<String> stream;
  final Function(String) onChanged;

  const InputField(
      {Key key,
      @required this.icon,
      @required this.hint,
      @required this.obscure,
      @required this.stream,
      @required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: stream,
        builder: (context, snapshot) {
          return TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                    left: 5, right: 30, bottom: 30, top: 30),
                icon: Icon(
                  icon,
                  color: Colors.white,
                ),
                hintText: hint,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent)),
                errorText: snapshot.hasError ? snapshot.error : null),
            obscureText: obscure,
          );
        });
  }
}
