import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class News2 {
  String title;
  String image;
  String description;
  String source_name;

  News2({
    required this.title,
    required this.image,
    required this.description,
    required this.source_name,
  });
}

class NewsListPage extends StatefulWidget {
  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  List<News2> news = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
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
        final description = article['description'] ?? '';
        final image = article['urlToImage'];
        final source_name = article['source']['name'];

        if (image != null) {
          final newsItem = News2(
            title: title,
            description: description,
            image: image,
            source_name: source_name,
          );
          setState(() {
            news.add(newsItem);
          });
        }
      }
    } else {
      throw Exception('Failed to load news');
    }
  }

  void navigateToDetailPage(News2 newsItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(newsItem: newsItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการข่าวต่างประเทศ',style: TextStyle(fontFamily: "IBMPlexSansThai"),),
        titleTextStyle: TextStyle(fontSize: 18,color:Colors.white),
        backgroundColor: Color(0xFF212436),
      ),
      body: Container(decoration: BoxDecoration(color: Color(0xFFECF8F9),),
        child: ListView.builder(
          itemCount: news.length,
          itemBuilder: (context, index) {
            final newsItem = news[index];
            return GestureDetector(
              onTap: () => navigateToDetailPage(newsItem),
              child: Container(
                margin: EdgeInsets.all(12.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3.0,
                      ),
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        //let's add the height
      
                        image: DecorationImage(
                            image: NetworkImage(newsItem.image),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      padding: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        newsItem.source_name,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      newsItem.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final News2 newsItem;

  const NewsDetailPage({required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF212436),
        title: Text(newsItem.title,style: TextStyle(fontSize: 16),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                  10.0), // Adjust the border radius as needed
              child: Image.network(newsItem.image),
            ),
            SizedBox(height: 16.0),
            Text(newsItem.title, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
            SizedBox(height: 10.0),
            Text(newsItem.description,style: TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );
  }
}
