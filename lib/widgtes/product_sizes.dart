import 'package:flutter/material.dart';
import 'package:gerenteloja/widgtes/addSizeDialog.dart';

class ProductSizes extends FormField<List> {
  ProductSizes(
      {List initialValue,
      BuildContext context,
      FormFieldSetter<List> onSaved,
      FormFieldSetter<List> validator})
      : super(
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            builder: (state) {
              return SizedBox(
                height: 34,
                child: GridView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.5),
                  children: state.value.map<Widget>((v) {
                    return GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            border:
                                Border.all(color: Colors.pinkAccent, width: 3)),
                        child: Text(
                          v,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onLongPress: () {
                        state.didChange(state.value..remove(v));
                      },
                    );
                  }).toList()
                    ..add(GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            border: Border.all(
                                color: state.hasError
                                    ? Colors.red
                                    : Colors.pinkAccent,
                                width: 3)),
                        child: Text(
                          '+',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onTap: () async {
                        String size = await showDialog(
                            context: context,
                            builder: (context) => AddSizeDialog());
                        if (size != null && size.isNotEmpty) {
                          state.didChange(state.value..add(size));
                        }
                      },
                    )),
                ),
              );
            });
}
