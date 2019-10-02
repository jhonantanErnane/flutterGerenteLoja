import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/blocs/category_bloc.dart';
import 'package:gerenteloja/widgtes/image_source_sheet.dart';

class EditCategoryDialog extends StatefulWidget {
  final DocumentSnapshot category;

  EditCategoryDialog({Key key, this.category}) : super(key: key);

  _EditCategoryDialogState createState() =>
      _EditCategoryDialogState(category: category);
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final CategoryBloc _categoryBloc;
  final TextEditingController _textEditingController;
  _EditCategoryDialogState({DocumentSnapshot category})
      : _categoryBloc = CategoryBloc(category),
        _textEditingController = TextEditingController(
            text: category != null ? category.data['title'] : '');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: GestureDetector(
                child: StreamBuilder(
                    stream: _categoryBloc.outImage,
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: snapshot.data is File
                              ? Image.file(
                                  snapshot.data,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  snapshot.data,
                                  fit: BoxFit.cover,
                                ),
                        );
                      } else {
                        return Icon(Icons.image);
                      }
                    }),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) => ImageSourceSheet(
                            onImageSelected: (image) {
                              Navigator.of(context).pop();
                              _categoryBloc.setImage(image);
                            },
                          ));
                },
              ),
              title: StreamBuilder<String>(
                  stream: _categoryBloc.outTitle,
                  builder: (context, snapshot) {
                    return StreamBuilder<String>(
                        stream: _categoryBloc.outTitle,
                        builder: (context, snapshot) {
                          return TextField(
                            controller: _textEditingController,
                            onChanged: _categoryBloc.setTitle,
                            decoration: InputDecoration(
                                errorText:
                                    snapshot.hasError ? snapshot.error : null),
                          );
                        });
                  }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: _categoryBloc.outDelete,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      return FlatButton(
                        child: Text('Excluir'),
                        textColor: Colors.red,
                        onPressed: snapshot.data
                            ? () async {
                                await _categoryBloc.delete();
                                Navigator.of(context).pop();
                              }
                            : null,
                      );
                    }),
                StreamBuilder<bool>(
                    stream: _categoryBloc.submitValid,
                    builder: (context, snapshot) {
                      return FlatButton(
                        child: Text('Salvar'),
                        onPressed: snapshot.data != null && snapshot.data
                            ? () async {
                                await _categoryBloc.saveData();
                                Navigator.of(context).pop();
                              }
                            : null,
                      );
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
