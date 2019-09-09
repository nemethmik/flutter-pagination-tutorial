# pagination

This is a rework of the original [Tensor Programming Flutter navigation project](https://github.com/tensor-programming/flutter-pagination-tutorial).
I think there is a kind-of much simpler solution than his original solution:
no need for streams, stream-builders, rx-dart, neither scroll notifications.
My solution is based on FutureBuilder and async/await.
When I [learned how brilliantly sliver list](https://www.youtube.com/watch?v=wN2lpqxkB4M) handles unbound number of items, I think forward and backward paging can be done easily.
My idea was just load up pages when list bulder is requesting items. When a HTTP request is pending, no any other request is allowed, which was a challenge with Dart's async/await. For backward paging, I'd keep all pages in memory.

The future builder defined for the list view calls the BloC's async getPhoto function, which is sync-locked. The internal _getPhotos is using loadPhoto, which is sync-locked, too. Both sync-locks are required, otherwise the application doesn't work as expected.

```dart
  Future<Photo> syncLock;// VERY IMPORTANT TO serve list view items sequentially
  Future<Photo> getPhoto(int index) async {
    if(syncLock != null) await syncLock; // Check out what's happening, if you uncomment this
    syncLock = _getPhoto(index);
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
I didn't use any provider for the BloC obejct, I simply used a static object in the main application class. Of course, fancy dependency injection machinery could be used, too, sure.

With this solution it was possible to change the home page into a stateless widget.

The solution works excellently, but it keeps all data in memory, it doesn't drop pages, which is pretty OK and mostly desirable for 99% of the situations.

For a demo and explanation check out the video [Flutter 96 Unbounded/Infinite Pagination with Future Builder and List View](https://youtu.be/fCOhWlDiwCE)