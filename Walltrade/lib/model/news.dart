import 'dart:convert';
import 'package:http/http.dart' as http;

class News {
  String title;
  String image;
  String description;

  News({
    required this.title,
    required this.image,
    required this.description,
  });
}

class StaticValues {
  List<News> news = [];

  Future<List<News>> fetchNews() async {
    final response = await http.get(
      Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=2a062b05d3424b8ea2bfc6d1eb328133',
      ),
    );

    if (response.statusCode == 200) {
      final parsedResponse = jsonDecode(response.body);
      final articles = parsedResponse['articles'];

      for (var article in articles.reversed) {
        final title = article['title'];
        final description = article['description'] ?? ''; // Provide default value when description is null
        final image = article['urlToImage'];
        
        if (image != null && image.startsWith("https")) {
          final newsItem = News(
            title: title,
            description: description,
            image: image,
          );
          news.add(newsItem);
        }
      }
      return news.take(5).toList();
    } else {
      throw Exception(response.statusCode);
    }
  }
}
