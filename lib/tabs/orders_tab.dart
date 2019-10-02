import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/blocs/orders_bloc.dart';
import 'package:gerenteloja/widgtes/order_tile.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ordersBloc = BlocProvider.of<OrdersBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: StreamBuilder<List>(
          stream: _ordersBloc.outOrders,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
              ));
            } else if (snapshot.data.length == 0) {
              return Center(
                child: Text(
                  'Nenhum pedido encontrado',
                  style: TextStyle(color: Colors.pinkAccent),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return OrderTile(
                    order: snapshot.data[index],
                  );
                },
              );
            }
          }),
    );
  }
}
