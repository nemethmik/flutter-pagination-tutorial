import 'dart:async';
import 'package:pagination/model.dart';
import 'package:pagination/network.dart'; 

class PhotoBloc {
  // static const int MAXPHOTOS = 4 * 50;
  final API api = API();
  int get firstAlbum => photos.isEmpty ? 1 : photos[0].albumId;  
  int get lastAlbum => photos.isEmpty ? 1 : photos.last.albumId;
  List<Photo> photos = []; //page size = phtoros.length
  Future<Photo> _getPhoto(int index) async {
    if(photos.isEmpty) {
      await loadPhotos(firstAlbum,index); 
    }
    if(index >= photos.length) {
      runningQuery = loadPhotos(lastAlbum + 1,index); //Set the "sync lock"
      await runningQuery;
    }
    assert(index < photos.length);
    return photos[index];
  }
  Future runningQuery; // A sync lock mechanism to control race conditions
  Future<void> loadPhotos(int albumId,int index) async {
    if(runningQuery != null) await runningQuery; //THIS IS A KIND OF SYNC LOCK, VERY IMPORTANT
    if(index >= photos.length) {// Double check agains race conditions, if data is really needed
      print("==== loadPhotos entry: albumId $albumId index $index FA $firstAlbum LA $lastAlbum S ${photos.length}");
      photos.addAll(await api.getPhotos(albumId));
      print("==== loadPhotos exit: albumId $albumId index $index FA $firstAlbum LA $lastAlbum S ${photos.length}");
    }
  }
  Future<Photo> syncLock;// VERY IMPORTANT TO serve list view items sequentially
  Future<Photo> getPhoto(int index) async {
    if(syncLock != null) await syncLock; // Check out what's happening, if you uncomment this
    syncLock = _getPhoto(index);
    return await syncLock;
  }
}
