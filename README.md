# pagination

This is a rework of the original Tensor Programming Flutter navigation project.
I think there is a much simpler solution than his original solution.
No need for streams, stream-builders, rx-dart, scroll notifications.
When I learned how brilliantly sliver list handles unbound lists, I think forward and backward paging can be done easily.
My idea is just load up to three pages altogether in memory. When a HTTP request is pending no any other request is allowed. When backward paging, I'd keep the previous page in memory, but when the user starts paging in that direction I'd start loading the previous page, dropping the trailing pages at the sae time, So eventually three pages would be kept in memory.

I committed a version with message "Managing photo buffer with Current Position doesn't work :(" and it really doesn't, because of the intricacies of race situations, which I wasn't able to decypher.
Serializing async calls was possible but it wasn't enough for a working solution.

In the next iteration I am planning to use a list for all indexes already loaded, and when the list view request the item I return it. The fisrt version will keep all photos/albums ever loaded in memory. Later I'll try to remove the actual data of the albums/pages from the beginning and end of the list while keeping the mapping list (index, id, page/album, data/photo, which is set to null after memory consumption optimization). When the data is needed, the corresponding album is going to be reloaded.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
