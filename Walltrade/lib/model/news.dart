import 'dart:convert';
import 'package:Walltrade/variables/serverURL.dart';
import 'package:http/http.dart' as http;

class News {
  String title;
  String image;
  String symbol;
  String url;

  News({
    required this.title,
    required this.image,
    required this.symbol,
    required this.url,
  });
}

class StaticValues {
  List<News> news = [];

  Future<List<News>> fetchNews({required String username}) async {
    final Map<String, dynamic> requestData = {
      'username': username,
    };

    final response2 = await http.post(
      Uri.parse('${Constants.serverUrl}/news'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );
    if (response2.statusCode == 200) {
      print(jsonDecode(response2.body));
      final parsedResponse = jsonDecode(response2.body);
      if (parsedResponse is Map<String, dynamic> &&
          parsedResponse.containsKey('message') &&
          parsedResponse['message'] == 'Failed to fetch news.') {
        return news; // คืนค่า news อย่างเดียว
      }

      final articles = parsedResponse;
      for (var article in articles) {
        final title = article['Headline'];
        final image = article['Image'];
        final symbol = article['Symbols'];
        final url = article['URL'];

        final newsItem =
            News(title: title, symbol: symbol, image: image, url: url);
        news.add(newsItem);
      }
      return news.take(5).toList();
    } else {
      throw Exception(response2.statusCode);
    }
  }
}
