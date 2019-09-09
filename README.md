# pagination

This is a rework of the original [Tensor Programming Flutter navigation project](https://github.com/tensor-programming/flutter-pagination-tutorial).
I think there is a kind-of much simpler solution than his original solution:
no need for streams, stream-builders, rx-dart, neither scroll notifications.
My solution is based on FutureBuilder and async/await.
When I [learned how brilliantly sliver list](https://www.youtube.com/watch?v=wN2lpqxkB4M) handles unbound number of items, I think forward and backward paging can be done easily.
My idea was just load up pages when list bulder is requesting items. When a HTTP request is pending, no any other request is allowed, which was a challenge with Dart's async/await. For backward paging, I'd keep all pages in memory.

The commit "Excellently working simple solution with two future-awaiting-sync-locks" is based on two very important syncronizations trick:
- getPhoto in MyHomePage
- loadPhotos in BloC

```dart
  Future<Photo> syncLock;// VERY IMPORTANT TO serve list view items sequentially
  Future<Photo> getPhoto(int index) async {
    if(syncLock != null) await syncLock; // Check out what's happening, if you uncomment this
    syncLock = MyApp.bloc.getPhoto(index);
    return await syncLock;
  }
  ...
      runningQuery = loadPhotos(lastAlbum + 1,index); //Set the "sync lock"
      await runningQuery;
  ...  
  Future runningQuery; // A sync lock mechanism to control race conditions
  Future<void> loadPhotos(int albumId,int index) async {
    if(runningQuery != null) await runningQuery; //THIS IS A KIND OF SYNC LOCK, VERY IMPORTANT
    if(index >= photos.length) {// Double check agains race conditions, if data is really needed
      photos.addAll(await api.getPhotos(albumId));
    }
  }
```
This version works excellently, but saves all data in memory, it never drops pages, which is pretty OK and desirable for 99% of the situations.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
