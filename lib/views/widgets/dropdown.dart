import 'package:flutter/material.dart';

class DropdownButtonWidget extends StatefulWidget {
  final List<String> items;
  DropdownButtonWidget({Key? key, required this.items}) : super(key: key);

  @override
  DropdownButtonWidgetState createState() => DropdownButtonWidgetState();
}

class DropdownButtonWidgetState extends State<DropdownButtonWidget> {
  String selectedItem = 'Rock';

  String getSelectedItem() {
    return selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedItem,
      items: widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedItem = newValue!;
        });
      },
    );
  }
}
