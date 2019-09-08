# pagination

This is a rework of the original Tensor Programming Flutter navigation project.
I think there is a much simpler solution than his original solution.
No need for streams, stream-builders, rx-dart, scroll notifications.
When I learned how brilliantly sliver list handles unbound lists, I think forward and backward paging can be done easily.
My idea is just load up to three pages altogether in memory. When a HTTP request is pending no any other request is allowed. When backward paging, I'd keep the previous page in memory, but when the user starts paging in that direction I'd start loading the previous page, dropping the trailing pages at the sae time, So eventually three pages would be kept in memory.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
