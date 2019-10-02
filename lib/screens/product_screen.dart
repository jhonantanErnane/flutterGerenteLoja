import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/blocs/product_bloc.dart';
import 'package:gerenteloja/validators/product_validators.dart';
import 'package:gerenteloja/widgtes/image_widget.dart';
import 'package:gerenteloja/widgtes/product_sizes.dart';

class ProductScreen extends StatefulWidget {
  final String categoryId;
  final DocumentSnapshot product;

  ProductScreen({this.categoryId, this.product});

  @override
  _ProductScreenState createState() =>
      _ProductScreenState(this.categoryId, this.product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProductBloc _productBloc;

  _ProductScreenState(String categoryId, DocumentSnapshot product)
      : _productBloc = ProductBloc(categoryId: categoryId, product: product);
  var _titleFormCtrl = TextEditingController();
  var _priceFormCtrl = TextEditingController();
  var _descriptionFormCtrl = TextEditingController();

  FocusNode _titleFocus;
  FocusNode _priceFocus;
  FocusNode _descriptionFocus;

  @override
  void initState() {
    super.initState();
    _titleFocus = FocusNode();
    _priceFocus = FocusNode();
    _descriptionFocus = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final _fieldStyle = TextStyle(color: Colors.white, fontSize: 16);

    InputDecoration _buildDecoration(String label) {
      return InputDecoration(
          labelText: label, labelStyle: TextStyle(color: Colors.grey));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        title: StreamBuilder<bool>(
            stream: _productBloc.createdOut,
            initialData: false,
            builder: (context, snapshot) {
              return Text(snapshot.data ? 'Editar Produto' : 'Criar Produto');
            }),
        actions: <Widget>[
          StreamBuilder<bool>(
              stream: _productBloc.createdOut,
              builder: (context, snapshot) {
                return IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (snapshot.data) {
                        deleteProduct(context);
                      }
                      return null;
                    });
              }),
          StreamBuilder<bool>(
              stream: _productBloc.loadingOut,
              initialData: false,
              builder: (context, snapshot) {
                return IconButton(
                  icon: Icon(Icons.save),
                  onPressed: snapshot.data ? null : saveProduct,
                );
              })
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
                stream: _productBloc.dataCtrlOut,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    _titleFormCtrl.text = snapshot.data['title'];
                    _priceFormCtrl.text =
                        snapshot.data['price']?.toStringAsFixed(2);
                    _descriptionFormCtrl.text = snapshot.data['description'];

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        Text('Imagens',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                        ImagesWidget(
                          context: context,
                          initialValue: snapshot.data['images'],
                          validator: validateImages,
                          onSaved: _productBloc.saveImages,
                        ),
                        TextFormField(
                          controller: _titleFormCtrl,
                          focusNode: _titleFocus,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          style: _fieldStyle,
                          decoration: _buildDecoration('Título'),
                          onFieldSubmitted: (v) {
                            _fieldFocusChange(
                                context, _titleFocus, _priceFocus);
                          },
                          onSaved: _productBloc.saveTitle,
                          validator: validateTitle,
                        ),
                        TextFormField(
                          controller: _priceFormCtrl,
                          focusNode: _priceFocus,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          style: _fieldStyle,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: _buildDecoration('Preço'),
                          onFieldSubmitted: (v) {
                            _fieldFocusChange(
                                context, _priceFocus, _descriptionFocus);
                          },
                          onSaved: _productBloc.savePrice,
                          validator: validatePrice,
                        ),
                        TextFormField(
                          controller: _descriptionFormCtrl,
                          focusNode: _descriptionFocus,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.sentences,
                          style: _fieldStyle,
                          maxLines: 6,
                          decoration: _buildDecoration('Descrição'),
                          onFieldSubmitted: (v) {},
                          onSaved: _productBloc.saveDescription,
                          validator: validateDescription,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text('Tamanhos',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                        ProductSizes(
                          initialValue: snapshot.data['sizes'],
                          context: context,
                          onSaved: _productBloc.saveSizes,
                          validator: (s) {
                            if (s.isEmpty) {
                              return 'Adicione um tamanho';
                            }
                            return null;
                          },
                        )
                      ],
                    );
                  }
                }),
          ),
          StreamBuilder<bool>(
              stream: _productBloc.loadingOut,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(
                    color: snapshot.data ? Colors.black54 : Colors.transparent,
                  ),
                );
              })
        ],
      ),
    );
  }

  Future saveProduct() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.pinkAccent,
        content: Text(
          'Salvando produto...',
          style: TextStyle(color: Colors.white),
        ),
      ));
      bool success = await _productBloc.saveProduct();

      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.pinkAccent,
        content: Text(
          success ? 'Produto salvo' : 'Erro ao salvar produto',
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
  }

  Future deleteProduct(BuildContext context) async {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.pinkAccent,
      content: Text(
        'Apagando produto...',
        style: TextStyle(color: Colors.white),
      ),
    ));
    bool success = await _productBloc.removeProduct();
    _scaffoldKey.currentState.removeCurrentSnackBar();

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.pinkAccent,
      content: Text(
        success ? 'Produto apagado' : 'Erro ao apagar produto',
        style: TextStyle(color: Colors.white),
      ),
    ));
    if (success) {
      Navigator.of(context).pop();
    }
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }
}
