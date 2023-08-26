import 'package:flutter/material.dart';

class MoreTechnicalOrder extends StatefulWidget {
  final String username;
  MoreTechnicalOrder({required this.username});
  @override
  _MoreTechnicalOrderState createState() =>
      _MoreTechnicalOrderState(username: username);
}

class _MoreTechnicalOrderState extends State<MoreTechnicalOrder> {
  final String username;
  _MoreTechnicalOrderState({required this.username});
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
    return isSelected == true ? Color(0xFF1D5B79) : Color(0xFF2A3547);
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
                        padding: EdgeInsets.symmetric(vertical: 18),
                        margin: EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Color(0xFF2A3547),
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
                              style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
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
                      SizedBox(
                        height: 10,
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

                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            margin: EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: Color(0xFF2A3547),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0,
                                      3), // changes the position of the shadow
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'STO (Stochastic Oscillator)',
                                  style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('ระบุค่า STO %K และ %D ที่ต้องการซื้อ'),
                                SizedBox(width: 5),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'ค่าที่ต้องการซื้อ',
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
                                Text('STO %K ตัดขึ้น %D และมีโซนที่ต่ำกว่า'),
                                SizedBox(width: 5),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'ค่าที่ซื้อเมื่อต่ำกว่า',
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
                        ],
                      ),
                    ),
                  )
                : menu == 'MACD'
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
                                  offset: Offset(0,
                                      3), // changes the position of the shadow
                                ),
                              ],
                            ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  margin: EdgeInsets.symmetric(horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2A3547),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0,
                                            3), // changes the position of the shadow
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'MACD (Moving Average Convergence Divergence)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                          'MACD ตัดขึ้น Signal และมีโซนที่ต่ำกว่า 0'),
                                      Checkbox(
                                        value: true,
                                        onChanged: (bool? newValue) {
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(width: 5),
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
                                                      Navigator.of(context)
                                                          .pop();
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                          'ระบุโซน MACD & Signal ที่ต้องการซื้อ'),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'ค่าที่ต้องการซื้อ',
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
                                                      Navigator.of(context)
                                                          .pop();
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
                              ],
                            )),
                      )
                    : containers.add(
                        Container(
                            key: ValueKey(menu),
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0,
                                      3), // changes the position of the shadow
                                ),
                              ],
                            ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  margin: EdgeInsets.symmetric(horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2A3547),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0,
                                            3), // changes the position of the shadow
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'EMA (Exponential Moving Average)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('ระบุวันของ EMA'),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'จำนวนวันที่ต้องการใช้',
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
                                                      Navigator.of(context)
                                                          .pop();
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
                              ],
                            )),
                      );
        menuSelectionStatus[menu] = true;
      }
    });

    print("${menuSelectionStatus}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF8F9),
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
          SizedBox(
            height: 10,
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              child: Text(
                "โปรดเลือกเทคนิคที่ต้องการใช้",
                style: TextStyle(color: Colors.amber.shade800),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFEEE2DE),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Row(
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
                          offset: Offset(
                              0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Text(
                      "RSI",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
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
                          offset: Offset(
                              0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Text(
                      "STO",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
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
                          offset: Offset(
                              0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Text(
                      "MACD",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
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
                          offset: Offset(
                              0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Text(
                      "EMA",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          selectedMenus.isNotEmpty
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(vertical:10,horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey,
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
                    child: Column(
                      children: [
                        Text(
                            "เทคนิคที่ต้องการใช้: ${selectedMenus.join(', ')}",style: TextStyle(),),
                        TimeframeDropdown(
                          selectedInterval: selectedInterval,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedInterval = newValue!;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('สัญลักษณ์หุ้น'),
                            SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'เช่น META,AAPL,PTT,SCB' ,
                                  labelStyle: TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('จำนวนหุ้น'),
                            SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'เช่น 0.1 ,1000 ,5',
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
                      ],
                    ),
                  ),
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
