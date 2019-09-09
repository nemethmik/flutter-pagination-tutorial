import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:pagination/model.dart';
import 'package:pagination/network.dart'; 

class PhotoBloc {
  static const int MAXPHOTOS = 4 * 50;
  final API api = API();
  int get firstAlbumId => photos.isEmpty ? 1 : photos[0].albumId; //page number
  int get lastAlbumId => photos.isEmpty ? 1 : photos[photos.length - 1].albumId;
  List<Photo> photos = []; //page size = phtoros.length
  int lastPosition = -1; //The position of the photo last returned from the buffer to the list view
  int lastIndex = -1; //The index of the list view item last served
  //currentPosition is recalculated by getPhoto but it is maintained when photos
  //are inserted or deleted from the head of the list.
  int currentPosition = 0; //The position we need to serve for the current request
  //int currentIndex = -1; //The current index list view is requesting data
  // int direction = 0; // = CI - LI Forward when CI > LI, Backward when CI < LI
  Future<Photo> getPhoto(int currentIndex) async {
    // if(runningQuery != null) {
    //   await runningQuery;
    // }
    if(photos.isEmpty) {
      runningQuery = _loadPhotos(firstAlbumId,currentIndex); 
      await runningQuery;
    }
    Photo photo;
    //When the 0th index is requested first, lastIndex is -1, so direction is 0 - (-1) => +1
    int direction = currentIndex - lastIndex;
    //Then the current position for current index is -1 + +1 => 0
    currentPosition = lastPosition + direction;
    if(currentPosition >= 0 && currentPosition < photos.length ) {
      photo = photos[currentPosition];
    } else {
      if(currentPosition >= photos.length) {
        print("getPhoto: loading photos CI $currentIndex CP $currentPosition LP $lastPosition LI $lastIndex FA $firstAlbumId LA $lastAlbumId S ${photos.length}");
        runningQuery = _loadPhotos(lastAlbumId + 1,currentIndex);
        await runningQuery;
        photo = photos[currentPosition];
        print("getPhoto: photos loaded CI $currentIndex CP $currentPosition LP $lastPosition LI $lastIndex FA $firstAlbumId LA $lastAlbumId S ${photos.length}");
      } else {
        if(firstAlbumId > 1) {
          runningQuery = _loadPhotos(firstAlbumId - 1,currentIndex);
          await runningQuery;
        }
        photo = photos[currentPosition];          
      }
    }
    lastPosition = currentPosition;
    lastIndex = currentIndex;
    return photo;
  }
  Future runningQuery;
  Future<void> _loadPhotos(int albumId,int currentIndex) async {
    // if(runningQuery != null) await runningQuery;
    print("==== _loadPhotos entry: albumId $albumId CI $currentIndex CP $currentPosition LP $lastPosition LI $lastIndex FA $firstAlbumId LA $lastAlbumId S ${photos.length}");
    List<Photo> justReceivedPhotos = await api.getPhotos(albumId);
    if(albumId < firstAlbumId) {
      //Add just received photos to the beginning and drop the last album
      print("++ Inserting album $albumId, current pos $currentPosition, last pos $lastPosition");
      photos.insertAll(0, justReceivedPhotos);
      currentPosition += justReceivedPhotos.length;
      lastPosition += justReceivedPhotos.length;
      print("++ Album $albumId inserted, current pos $currentPosition, last pos $lastPosition, size ${photos.length}");
      if(photos.length > MAXPHOTOS && firstAlbumId != lastAlbumId) {
        int lastAlbumIdBeforeDeleting = lastAlbumId;
        print("-- Removing tail album $lastAlbumIdBeforeDeleting, current pos $currentPosition, last pos $lastPosition");
        while(photos.last.albumId == lastAlbumIdBeforeDeleting) {
          photos.removeLast();
        }
        print("-- Album $lastAlbumIdBeforeDeleting removed, current pos $currentPosition, last pos $lastPosition, size ${photos.length}");
        assert(currentPosition < photos.length);
      } 
    } else if(albumId >= lastAlbumId) {
      photos.addAll(justReceivedPhotos);
      if(photos.length > MAXPHOTOS && firstAlbumId != lastAlbumId) {
        int firstAlbumIdBeforeDeleting = firstAlbumId;
        print("-- Removing head album $firstAlbumIdBeforeDeleting, CP $currentPosition LP $lastPosition 1stPhoto ${photos[0].id} lastPhoto ${photos.last.id}");
        while(photos.first.albumId == firstAlbumIdBeforeDeleting) {
          photos.removeAt(0);
          currentPosition--;
          lastPosition--;
        }
        print("-- Album $firstAlbumIdBeforeDeleting removed, CI $currentIndex CP $currentPosition LP $lastPosition 1stPhoto ${photos[0].id} lastPhoto ${photos.last.id}");
        assert(currentPosition >= 0);
      } 
    }
    print("==== _loadPhotos exit: albumId $albumId CI $currentIndex CP $currentPosition LP $lastPosition LI $lastIndex FA $firstAlbumId LA $lastAlbumId S ${photos.length}");
  }
}
