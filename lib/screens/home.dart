import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:gerenteloja/blocs/orders_bloc.dart';
import 'package:gerenteloja/blocs/user_bloc.dart';
import 'package:gerenteloja/tabs/orders_tab.dart';
import 'package:gerenteloja/tabs/products_tab.dart';
import 'package:gerenteloja/tabs/users_tab.dart';
import 'package:gerenteloja/widgtes/edit_category_dialog.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController _pageCtrl;
  int _page = 0;
  UserBloc _userBloc;
  OrdersBloc _ordersBloc;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _userBloc = UserBloc();
    _ordersBloc = OrdersBloc();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        backgroundColor: Colors.pinkAccent,
        selectedItemColor: Colors.white,
        onTap: (p) {
          _pageCtrl.animateToPage(p,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              title: Text('Clientes')),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), title: Text('Pedidos')),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), title: Text('Produtos')),
        ],
      ),
      body: SafeArea(
        child: BlocProvider<UserBloc>(
          bloc: _userBloc,
          child: BlocProvider<OrdersBloc>(
            bloc: _ordersBloc,
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (p) {
                setState(() {
                  _page = p;
                });
              },
              children: <Widget>[
                UsersTab(),
                OrdersTab(),
                ProductsTab(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloating(),
    );
  }

  Widget _buildFloating() {
    switch (_page) {
      case 0:
        return null;
        break;
      case 1:
        return SpeedDial(
          child: Icon(
            Icons.sort,
            color: Colors.white,
          ),
          backgroundColor: Colors.pinkAccent,
          overlayOpacity: 0.4,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
                child: Icon(
                  Icons.arrow_downward,
                  color: Colors.pinkAccent,
                ),
                backgroundColor: Colors.white,
                label: 'Concluidos Abaixo',
                labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                onTap: () {
                  _ordersBloc.setOrderCriteria(SortCriteria.READY_LAST);
                }),
            SpeedDialChild(
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.pinkAccent,
                ),
                backgroundColor: Colors.white,
                label: 'Concluidos Acima',
                labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                onTap: () {
                  _ordersBloc.setOrderCriteria(SortCriteria.READY_FIRST);
                })
          ],
        );
        break;
      case 2:
        return FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
                context: context, builder: (context) => EditCategoryDialog());
          },
        );
        break;
      default:
    }
  }
}
