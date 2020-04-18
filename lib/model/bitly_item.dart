class BitlyItem {
  String url;

  BitlyItem({this.url});

  factory BitlyItem.fromJson(Map<String, dynamic> json) {
    return BitlyItem(url: json['link']);
  }
}
