import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/screens/product_screen.dart';
import 'package:gerenteloja/widgtes/edit_category_dialog.dart';

class CategoryTile extends StatelessWidget {
  final DocumentSnapshot category;
  const CategoryTile({Key key, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          leading: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => EditCategoryDialog(
                        category: category,
                      ));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(category.data['icon']),
              backgroundColor: Colors.white,
            ),
          ),
          title: Text(
            category.data['title'],
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          children: <Widget>[
            FutureBuilder<QuerySnapshot>(
              future: category.reference.collection('items').getDocuments(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return Column(
                  children: snapshot.data.documents.map<Widget>((doc) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(doc.data['images'][0]),
                        backgroundColor: Colors.white,
                      ),
                      title: Text(doc.data['title']),
                      trailing:
                          Text('R\$${doc.data['price'].toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProductScreen(
                                  categoryId: category.documentID,
                                  product: doc,
                                )));
                      },
                    );
                  }).toList()
                    ..add(ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      title: Text('Adicionar Produto'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProductScreen(
                                  categoryId: category.documentID,
                                )));
                      },
                    )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
