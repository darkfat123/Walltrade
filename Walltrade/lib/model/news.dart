import 'dart:convert';
import 'package:http/http.dart' as http;

class News {
  String title;
  String image;
  String symbol;

  News({
    required this.title,
    required this.image,
    required this.symbol,
  });
}

class StaticValues {
  List<News> news = [];

  Future<List<News>> fetchNews() async {
    final response2 = await http.get(
      Uri.parse('http://192.168.1.36:5000/news'),
    );
    if (response2.statusCode == 200) {
      final parsedResponse = jsonDecode(response2.body);
      final articles = parsedResponse;
      for (var article in articles) {
        final title = article['Headline'];
        final image = article['Image'];
        final symbol = article['Symbols'];

        final newsItem = News(
          title: title,
          symbol: symbol,
          image: image,
        );
        news.add(newsItem);
      }
      return news.take(5).toList();
    } else {
      throw Exception(response2.statusCode);
    }
  }
}
