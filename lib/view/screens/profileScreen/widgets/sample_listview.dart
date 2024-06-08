import 'package:flutter/material.dart';

class ListViewSample extends StatelessWidget {
  const ListViewSample({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context,index){
      return ListTile(
        leading: CircleAvatar(),
        title: Text(index.toString()),
      );
    },
    );
  }
}