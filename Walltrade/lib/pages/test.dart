import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> containers = [];
  Set<String> selectedMenus = {};
  Map<String, bool> menuSelectionStatus = {
    'RSI': false,
    'STO': false,
    'MACD': false,
    'EMA': false,
  };

  Color getMenuColor(String menu) {
    final bool? isSelected = menuSelectionStatus[menu];
    return isSelected == true ? Colors.green : Colors.grey;
  }

  void toggleContainer(String menu) {
    setState(() {
      if (selectedMenus.contains(menu)) {
        selectedMenus.remove(menu);
        containers.removeWhere(
            (container) => (container.key as ValueKey).value == menu);
        menuSelectionStatus[menu] = false;
      } else {
        selectedMenus.add(menu);
        containers.add(
          Container(
            key: ValueKey(menu),
            width: 100,
            height: 100,
            color: Colors.blue, // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู
            margin: EdgeInsets.all(10),
            child: Center(
              child: Text(
                menu,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
        menuSelectionStatus[menu] = true;
      }
    });
    print("$menu : ${menuSelectionStatus[menu]}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("สร้างคำสั่งแบบหลายเทคนิค"),
            Row(
              children: [
                IconButton(
                  iconSize: 24,
                  icon: Icon(Icons.access_time),
                  onPressed: () {
                    // Handle settings button press here
                  },
                ),
                IconButton(
                  iconSize: 24,
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Handle settings button press here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => toggleContainer("RSI"),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getMenuColor("RSI"),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "RSI",
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => toggleContainer("STO"),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getMenuColor("STO"),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "STO",
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => toggleContainer("MACD"),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getMenuColor("MACD"),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "MACD",
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => toggleContainer("EMA"),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getMenuColor("EMA"),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Text(
                    "EMA",
                  ),
                ),
              ),
            ],
          ),
          selectedMenus.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: Text("เลือกเทคนิค: ${selectedMenus.join(', ')}"),
                )
              : SizedBox(),
          Expanded(
            child: ListView.builder(
              itemCount: containers.length,
              itemBuilder: (context, index) {
                return containers[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}
