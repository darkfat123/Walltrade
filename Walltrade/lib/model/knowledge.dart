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

Future<List<Knowledge>> fetchKnowledge() async {
  return BuildKnowledge().knowledgeList;
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
      description: "<b>RSI</b> ย่อมาจาก 'Relative Strength Index' ซึ่งเป็นตัวชี้วัดทางเทคนิคที่ใช้ในการวิเคราะห์และประเมินความเปลี่ยนแปลงในราคาของหลักทรัพย์ เครื่องมือนี้ช่วยให้นักลงทุนและผู้ซื้อขายสามารถระบุว่าหลักทรัพย์นั้นมีความแข็งแกร่งหรืออ่อนแอ และว่ามีการซื้อขายที่เกิดขึ้นมากแค่ไหนในระยะเวลาที่กำหนดไว้ \n\nRSI คำนวณจากอัตราส่วนของการเพิ่มขึ้นของราคาที่เป็นบวกกับการลดลงของราคาที่เป็นลบ ซึ่งคำนวณตามสูตรที่ซับซ้อนเล็กน้อย ค่า RSI จะอยู่ในช่วง 0 ถึง 100 โดยทั่วไปแล้วมีเกณฑ์ดังนี้:\n RSI ตั้งแต่ 0 ถึง 30: หมายถึงหลักทรัพย์อาจจะมีการขายเกินไป (oversold) และอาจเป็นสัญญาณว่าอาจมีการกลับขึ้นในอนาคต\n RSI ตั้งแต่ 70 ถึง 100: หมายถึงหลักทรัพย์อาจจะมีการซื้อเกินไป (overbought) และอาจเป็นสัญญาณว่าอาจมีการกลับลงในอนาคต\n RSI ระหว่าง 30 ถึง 70: หมายถึงสภาวะที่สมดุลระหว่างการซื้อและการขาย\n\n วิธีการใช้งาน RSI อย่างเบื้องต้นได้แก่:\n 1.การระบุสัญญาณซื้อขาย: ในกรณีที่ RSI เข้าสู่ช่วง overbought หรือ oversold มากๆ (ค่าต่ำกว่า 30 หรือสูงกว่า 70) อาจเป็นสัญญาณว่าตลาดอาจกำลังพร้อมที่จะกลับซื้อหรือขายตามลำดับ\n 2.การระบุการเปลี่ยนแนวโน้ม: การเปลี่ยนแนวโน้มของ RSI อาจเป็นสัญญาณว่ามีการเปลี่ยนแปลงในแนวโน้มราคาเกิดขึ้น ยกตัวอย่างเช่น RSI ที่เริ่มเพิ่มขึ้นอาจแสดงถึงการเข้าสู่แนวโน้มขาขึ้นของราคา\n 3.การใช้ร่วมกับตัวชี้วัดอื่นๆ: ความแม่นยำของ RSI สามารถเพิ่มขึ้นเมื่อใช้ร่วมกับตัวชี้วัดทางเทคนิคอื่น ๆ เช่น moving averages หรือ trendlines เพื่อเพิ่มความมั่นใจในการตัดสินใจ\n 4.การเปรียบเทียบกับราคา: การเปรียบเทียบค่า RSI กับการเปลี่ยนแปลงในราคาหลักทรัพย์สามารถช่วยในการระบุสัญญาณเพิ่มเติม",
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
