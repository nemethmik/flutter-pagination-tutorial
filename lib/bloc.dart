import 'dart:async';
import 'package:pagination/model.dart';
import 'package:pagination/network.dart'; 

class PhotoBloc {
  final API api = API();
  int get lastAlbum => photos.isEmpty ? 1 : photos.last.albumId;
  List<Photo> photos = [];
  Future<void> loadPhotos(int albumId,int index) async {
    if(index >= photos.length) {// Double check agains race conditions, if data is really needed
      print("==== loadPhotos entry: albumId $albumId index $index LA $lastAlbum S ${photos.length}");
      photos.addAll(await api.getPhotos(albumId));
      print("==== loadPhotos exit: albumId $albumId index $index LA $lastAlbum S ${photos.length}");
    }
  }
  StreamController<PhotoRequest> photoRequests = StreamController<PhotoRequest>();
  Stream<Photo> fetchPhoto(int index) {
    startPhotoRequestProcessor();
    var photoRequest = PhotoRequest(index);
    Future((){
      // print("Photo request ${photoRequest.index} stream ${photoRequest.photo.stream.hashCode}");
      photoRequests.add(photoRequest);
    }); 
    return photoRequest.photo.stream;
  }
  void dispose() {
    if(photoRequestProcessor != null) {
      photoRequestProcessor.timeout(Duration(milliseconds: 1)
        ,onTimeout: (){print("Photo Request Processor Killed");});
    }
    photoRequests.close();
  }
  Future photoRequestProcessor;
  void startPhotoRequestProcessor() {
    if(photoRequestProcessor == null) {
      photoRequestProcessor = Future(() async {
        // photoRequests.stream.listen((req) async {
        //   print("Processing ${req.index}");    
        // });
        StreamIterator<PhotoRequest> photoRequestIterator = StreamIterator<PhotoRequest>(photoRequests.stream);
        while(await photoRequestIterator.moveNext()) {
          int index = photoRequestIterator.current.index;
          await Future(() async {
            if(photos.isEmpty) {
              await loadPhotos(1,index);
            }
            if(index >= photos.length) {
              await loadPhotos(lastAlbum + 1,index);
            }
            assert(index < photos.length);
            //print("Processing $index");
            return photos[index];
          }).then((photo){
            if(photo != null) {
              photoRequestIterator.current.photo.add(photo);
            }
          });
        }       
      });
    }
  } 
}

class PhotoRequest {
  final int index;
  final StreamController<Photo> photo = StreamController<Photo>.broadcast();
  PhotoRequest(this.index);
  void dispose() {photo.close();}
}
