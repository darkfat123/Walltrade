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
  String selectedInterval = '1 hour';
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
        menu == 'RSI'
            ? containers.add(
                Container(
                  key: ValueKey(menu),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู
                  child: Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 18),
                        margin:
                            EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(
                                  0, 3), // changes the position of the shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'RSI (Relative Strength Index)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TimeframeDropdown(
                        selectedInterval: selectedInterval,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedInterval = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('ระบุค่า RSI ที่ต้องการซื้อ'),
                            SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: '0-100',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.info,
                                size: 24,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('More Info'),
                                      content: Text(
                                          'Additional information about timeframes.'),
                                      actions: [
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('จำนวน'),
                            SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'จำนวน',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.info,
                                size: 24,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('More Info'),
                                      content: Text(
                                          'Additional information about timeframes.'),
                                      actions: [
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('ยืนยัน'),
                      ),
                    ],
                  ),
                ),
              )
            : menu == 'STO'
                ? containers.add(
                    Container(
                      key: ValueKey(menu),
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                      ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

                      child: Center(
                        child: Text(
                          "$menu stoeiei",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : menu == 'MACD'
                    ? containers.add(
                        Container(
                          key: ValueKey(menu),
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.all(12),
                          color: Colors
                              .pink, // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

                          child: Center(
                            child: Text(
                              "$menu macdeiei",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    : containers.add(
                        Container(
                          key: ValueKey(menu),
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.all(12),
                          color: Colors
                              .blueGrey, // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

                          child: Center(
                            child: Text(
                              "$menu EMAeiei",
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

    print("${menuSelectionStatus}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("สร้างคำสั่งซื้อแบบหลายเทคนิค"),
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

class TimeframeDropdown extends StatelessWidget {
  final String selectedInterval;
  final Function(String?) onChanged;

  const TimeframeDropdown({
    required this.selectedInterval,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('โปรดเลือก Timeframe'),
          DropdownButton<String>(
            value: selectedInterval,
            onChanged: onChanged,
            items: [
              DropdownMenuItem(
                value: '1 hour',
                child: Text('1 hour'),
              ),
              DropdownMenuItem(
                value: '4 hours',
                child: Text('4 hours'),
              ),
              DropdownMenuItem(
                value: '1 day',
                child: Text('1 day'),
              ),
              DropdownMenuItem(
                value: '1 week',
                child: Text('1 week'),
              ),
              DropdownMenuItem(
                value: '1 month',
                child: Text('1 month'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.info,
              size: 24,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('More Info'),
                    content: Text('Additional information about timeframes.'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
