
class ImageItem {
  final String id;
  final String? path;
  final String? url;
  final String? caption;
  final String? title;
  final String? alt;
  final int? pageNo;
  ImageItem({
    required this.id, 
    this.path, 
    this.url, 
    this.caption,
    this.title, 
    this.alt,
    this.pageNo
  });
}
