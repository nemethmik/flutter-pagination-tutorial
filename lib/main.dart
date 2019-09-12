import 'package:flutter/material.dart';
import 'package:pagination/bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final PhotoBloc bloc = PhotoBloc();
  @override
  Widget build(BuildContext context) {
    // For testing dispose, the bloc is killed in 5 seconds.
    // But, since it was programed in a defensive way, the bloc automatically re-created
    // its infrastructure to serve the list view.
    Future.delayed(Duration(seconds: 5)).then((v)=>bloc.dispose());
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
        itemBuilder: (context, index) { 
        // print("ListView itemBuilder for $index");
        return FutureBuilder(
          future: MyApp.bloc.fetchPhotoAsync(index),
          builder: (context,snapshot) { 
            // print("Future Builder for $index state ${snapshot.connectionState} data ${snapshot.data}" );
            return snapshot.connectionState == ConnectionState.done
            ? ListTile(
                leading: CircleAvatar(
                  child: Image.network(snapshot.data.thumbnailUrl),
                ),
                title: Text("Photo ID ${snapshot.data.id} - Index $index"),
                subtitle: Text(snapshot.data.title),
              )
            : Container(
                margin: EdgeInsets.all(8),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );}
          );
        }
      ),
    );
  }
}
