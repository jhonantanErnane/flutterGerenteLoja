import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/widgtes/order_header.dart';

class OrderTile extends StatelessWidget {
  final DocumentSnapshot order;
  final states = const [
    '',
    'Em preparação',
    'Em transporte',
    'Aguardando Entrega',
    'Entregue'
  ];

  const OrderTile({Key key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RoundedRectangleBorder _radius =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        child: ExpansionTile(
          key: Key(order.documentID),
          initiallyExpanded: order.data['status'] != 4,
          title: Text(
            '#${order.documentID.substring(order.documentID.length - 7, order.documentID.length)} - '
            '${states[order.data['status']]}',
            style: TextStyle(
                color: order.data['status'] != 4 ? Colors.white : Colors.green),
          ),
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  OrderHeader(
                    order: order,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: order.data['products'].map<Widget>((p) {
                      return ListTile(
                        title: Text(p['product']['title'] + ' ' + p['size']),
                        subtitle: Text(p['category'] + '/' + p['pid']),
                        trailing: Text(
                          p['quantity'].toString(),
                          style: TextStyle(fontSize: 20),
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        shape: _radius,
                        child: Text('Excluir'),
                        color: Colors.red,
                        onPressed: () {
                          Firestore.instance
                              .collection('users')
                              .document(order['clientId'])
                              .collection('orders')
                              .document(order.documentID)
                              .delete();
                          order.reference.delete();
                        },
                      ),
                      FlatButton(
                        shape: _radius,
                        child: Text('Regredir'),
                        color: Colors.grey[850],
                        onPressed: order.data['status'] <= 1
                            ? null
                            : () {
                                order.reference.updateData(
                                    {'status': order.data['status'] - 1});
                              },
                      ),
                      FlatButton(
                        shape: _radius,
                        child: Text('Avançar'),
                        color: Colors.green,
                        onPressed: order.data['status'] >= 4
                            ? null
                            : () {
                                order.reference.updateData(
                                    {'status': order.data['status'] + 1});
                              },
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
