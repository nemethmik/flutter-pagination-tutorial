import 'dart:async';
import "package:async/async.dart";
import 'package:pagination/model.dart';
import 'package:pagination/network.dart'; 

class PhotoBloc {
  final API api = API();
  int get lastAlbum => photos.isEmpty ? 1 : photos.last.albumId;
  List<Photo> photos = [];
  Future<void> loadPhotosAsync(int albumId,int index) async {
    if(index >= photos.length) {// Double check agains race conditions, if data is really needed
      print("==== loadPhotos entry: albumId $albumId index $index LA $lastAlbum S ${photos.length}");
      photos.addAll(await api.getPhotos(albumId));
      print("==== loadPhotos exit: albumId $albumId index $index LA $lastAlbum S ${photos.length}");
    }
  }
  // This stream is receiving the index numbers from the list view builder
  StreamController<int> photoRequests;
  // Future functions are created for each of the future builders for each line,
  // and that function is awaiting the response in the photoResponses stream.
  StreamController<PhotoResponse> photoResponses;
  Future<Photo> fetchPhotoAsync(int index) {
    if(photoRequests == null) photoRequests = StreamController<int>();
    startPhotoRequestProcessor();
    Future((){
      // print("Photo request ${photoRequest.index}");
      photoRequests.add(index);
    }); 
    return Future<Photo>(() async {
      // This is the most straightforward solution and works great
      // PhotoResponse photoResponse = await photoResponses.stream.firstWhere((pr) {
      //     return pr.index == index;
      //   });
      // return photoResponse.photo;
      // Here is the one-liner version
      return (await photoResponses.stream.firstWhere((pr) => pr.index == index)).photo;
      // For the sake of fun, I gave a try to StreamQueue from package:async/async.dart 
      // and this worked great, too, but a lot more verbose than firstWhere.
      // StreamQueue<PhotoResponse> sq = StreamQueue<PhotoResponse>(photoResponses.stream);
      // while(await sq.hasNext) {
      //   PhotoResponse photoResponse = await sq.next;
      //   if(photoResponse.index == index) {
      //     return photoResponse.photo;
      //   } 
      // }
      // return null; //This never happens with the logic implemented with StreamQueue
    }); 
  }
  // When to call the dispose? 
  // The State classe of stateful widgets has a dispose functionality.
  void dispose() async {
    // There is no direct way to kill a running future, but setting a timeout
    // kills it.
    if(photoRequestProcessorAsync != null) {
      // Since onTimeout was defined, no need for timeout error handling
      await photoRequestProcessorAsync.timeout(Duration(milliseconds: 1),onTimeout: (){});
      print("Photo Request Processor Killed");
      photoRequestProcessorAsync = null;
    }
    if(photoRequests != null) {
      photoRequests.close();
      photoRequests = null;
    }
    if(photoResponses != null) {
      photoResponses.close();
      photoResponses = null;
    }
  }
  // There is always only one request processor; after it is started it runs infinitely
  // as a future in the event loop, it is really efficient.
  // The dispose is killing it.
  // The actual processor is an anonymous function created by the startPhotoRequestProcessor.
  // This solution works excellently with the non-preemptive loop event machinery of Dart;
  // no need for isolates for this job.
  Future photoRequestProcessorAsync;
  void startPhotoRequestProcessor() {
    if(photoRequestProcessorAsync == null) {
      // This could be refactored into a named function
      photoRequestProcessorAsync = Future(() async {
        // This was my initial test if the requests arrived nicely
        // photoRequests.stream.listen((req) async {
        //   print("Processing ${req.index}");    
        // });
        if(photoResponses == null) photoResponses = StreamController<PhotoResponse>.broadcast();
        StreamIterator<int> photoRequestIterator = StreamIterator<int>(photoRequests.stream);
        while(await photoRequestIterator.moveNext()) {
          int index = photoRequestIterator.current;
          await Future(() async {
            if(photos.isEmpty) {
              await loadPhotosAsync(1,index);
            }
            if(index >= photos.length) {
              await loadPhotosAsync(lastAlbum + 1,index);
            }
            assert(index < photos.length);
            // print("Processing ${photoRequest.index}");
            return PhotoResponse(index,photos[index]);
          }).then((photoResponse){
            if(photoResponse != null) {
              photoResponses.add(photoResponse);
            }
          });
        }       
      });
    }
  } 
}
// PhotoResponse is for the response stream, 
// it IS IMPORTANT to map the index number from the list view request to the photo
// The photo ID in this example is coincidentally always index + 1, 
// but you shouldn't rely the solution on that coincidence.
class PhotoResponse {
  final int index;
  final Photo photo;
  PhotoResponse(this.index,this.photo);
}
