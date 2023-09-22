class TechnicalAnaylyze {
  String title;
  String image;
  String description;

  TechnicalAnaylyze({
    required this.title,
    required this.image,
    required this.description,
  });
}

Future<List<TechnicalAnaylyze>> fetchTechnicalAnaylyze() {
  return Future.delayed(Duration(seconds: 1), () {
    return BuildTechnicalAnaylyze().TechnicalAnaylyzeList;
  });
}

class BuildTechnicalAnaylyze {
  List<TechnicalAnaylyze> TechnicalAnaylyzeList = [
    TechnicalAnaylyze(
      title: "Apple -> Massive Breakdown And Now?",
      image: "https://s3.tradingview.com/p/pJxXcVqi_mid.png",
      description: "การทำงานของระบบเพื่อผู้ใช้ไม่ต้องคอยเฝ้าเทคนิคต่างๆเพื่อเข้าซื้อ",
    ),
   TechnicalAnaylyze(
      title: "Heading to 440s early next week",
      image: "https://s3.tradingview.com/b/BVURE2ac_mid.png",
      description: "RSI มีไว้เพื่อประโยชน์ดังนี้",
    ),
    TechnicalAnaylyze(
      title: "Tesla Update: Wave (2) vs (A)",
      image:
          "https://s3.tradingview.com/s/S7bZ3mjV_mid.png",
      description: "STO มีไว้เพื่อประโยชน์ดังนี้",
    ),
    TechnicalAnaylyze(
      title: "BAC: Dividend Day May Help The Price To Grow Even More",
      image:
          "https://s3.tradingview.com/u/Ub2mCTbB_mid.png",
      description: "MACD มีไว้เพื่อประโยชน์ดังนี้",
    ),
    TechnicalAnaylyze(
      title: "GRPN raising wage",
      image:
          "https://s3.tradingview.com/8/8kJIF6OT_mid.png",
      description: "MA มีไว้เพื่อประโยชน์ดังนี้",
    ),
  ];
}
