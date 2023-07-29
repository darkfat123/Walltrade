class Knowledge {
  String title;
  String image;
  String description;

  Knowledge({
    required this.title,
    required this.image,
    required this.description,
  });
}

Future<List<Knowledge>> fetchKnowledge() {
  return Future.delayed(Duration(seconds: 1), () {
    return BuildKnowledge().knowledgeList;
  });
}

class BuildKnowledge {
  List<Knowledge> knowledgeList = [
    Knowledge(
      title: "การทำงานและการใช้งานของระบบสร้างคำสั่งเทรดอัตโนมัติ",
      image: "https://blog.cloudflare.com/content/images/2022/01/Super-Bot-Fight-mode-1.png",
      description: "การทำงานของระบบเพื่อผู้ใช้ไม่ต้องคอยเฝ้าเทคนิคต่างๆเพื่อเข้าซื้อ",
    ),
    Knowledge(
      title: "RSI คืออะไร?",
      image: "https://i.ytimg.com/vi/VH84ppzmq9Q/maxresdefault.jpg",
      description: "RSI มีไว้เพื่อประโยชน์ดังนี้",
    ),
    Knowledge(
      title: "STO คืออะไร?",
      image:
          "https://iqtradingpro.com/wp-content/uploads/2021/10/stochastic-indicator.jpg",
      description: "STO มีไว้เพื่อประโยชน์ดังนี้",
    ),
    Knowledge(
      title: "MACD คืออะไร?",
      image:
          "https://goodcrypto.app/wp-content/uploads/2021/09/MACD-indicator.jpg",
      description: "MACD มีไว้เพื่อประโยชน์ดังนี้",
    ),
    Knowledge(
      title: "MA คืออะไร?",
      image:
          "https://images.ctfassets.net/hzjmpv1aaorq/LF6vkvvSH2gTEeYAZohVb/362379dd875062eae691afb580543aa6/Blog_Images_-_Skilling.png?q=70",
      description: "MA มีไว้เพื่อประโยชน์ดังนี้",
    ),
  ];
}
