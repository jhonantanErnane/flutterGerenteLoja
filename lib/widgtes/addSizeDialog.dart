import 'package:flutter/material.dart';

class AddSizeDialog extends StatelessWidget {
  // const AddSizeDialog({Key key}) : super(key: key);
  final _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _textCtrl,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.pinkAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop(_textCtrl.text);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
