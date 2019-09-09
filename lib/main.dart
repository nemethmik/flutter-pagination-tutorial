import 'package:pagination/model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pagination/bloc.dart';
import './main.dart';

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

// class PhotoListItem extends StatefulWidget {
//   final int index;
//   PhotoListItem(this.index);
//   @override
//   _PhotoListItemState createState() => _PhotoListItemState();
// }
// class _PhotoListItemState extends State<PhotoListItem> {
//   bool _loading = false;
//   Photo _photo;
//   Future getPhoto(int index) async {
//     setState(() {
//       _loading = true;      
//     });
//     await Future.delayed(Duration(seconds: 1));
//     // _photo = await MyApp.bloc.getPhoto(index);
//     _photo = Photo(id: index,title: "Photo for $index",thumbnailUrl: "https://via.placeholder.com/150/92c952");
//     setState(() {
//       _loading = false;      
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     getPhoto(this.widget.index);
//     return _loading
//       ? Container(
//           margin: EdgeInsets.all(8),
//           child: Center(
//             child: CircularProgressIndicator(),
//           ),
//         )
//       : ListTile(
//           leading: CircleAvatar(
//             child: Image.network(_photo.thumbnailUrl),
//           ),
//           title: Text(_photo.id.toString()),
//           subtitle: Text(_photo.title),
//         );
//   }
// }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  Future<Photo> runningGetPhoto;
  Future<Photo> getPhoto(int index) async {
    print("Entering _MyHomePageState.getPhoto for index $index");
    if(runningGetPhoto != null) await runningGetPhoto;
    // print("Calling _MyHomePageState.getPhoto for index $index");
    runningGetPhoto = MyApp.bloc.getPhoto(index);
    // print("Awaiting _MyHomePageState.getPhoto for index $index");
    return await runningGetPhoto;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagination App"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => FutureBuilder(
          future:getPhoto(index),
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
                print("Done _MyHomePageState.builder for index $index photo ${photo.id}");
                listItem = ListTile(
                  leading: CircleAvatar(
                    child: Image.network(photo.thumbnailUrl),
                  ),
                  title: Text("${photo.id} - $index"),
                  subtitle: Text(photo.title),
                );
            }
            return listItem;
          })
      ),
    );
  }
}
