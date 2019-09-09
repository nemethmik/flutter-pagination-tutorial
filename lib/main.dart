import 'package:pagination/model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pagination/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final PhotoBloc bloc = PhotoBloc();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagination App"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => FutureBuilder(
          future:MyApp.bloc.getPhoto(index),
          builder: (context,snapshot) {
            Widget listItem = Container(
                  margin: EdgeInsets.all(8),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                break; 
              case ConnectionState.done:
                Photo photo = snapshot.data;
                // print("Done _MyHomePageState.builder for index $index photo ${photo.id}");
                listItem = ListTile(
                  leading: CircleAvatar(
                    child: Image.network(photo.thumbnailUrl),
                  ),
                  title: Text("Photo ID ${photo.id} - Index $index"),
                  subtitle: Text(photo.title),
                );
            }
            return listItem;
          })
      ),
    );
  }
}
