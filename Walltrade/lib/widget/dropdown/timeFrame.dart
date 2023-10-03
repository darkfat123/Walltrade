import 'package:flutter/material.dart';

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
          const Text(
            'Timeframe',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              value: selectedInterval,
              onChanged: onChanged,
              items: const [
                DropdownMenuItem(
                  value: '1h',
                  child: Text(
                    '1 hour',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '4h',
                  child: Text(
                    '4 hours',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '1D',
                  child: Text(
                    '1 day',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '1W',
                  child: Text(
                    '1 week',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.info,
              size: 20,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timeline_sharp,
                            color: Colors.amber,
                            size: 72,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Text(
                            'Timeframe คืออะไร?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'ระยะเวลาที่ใช้ในการวิเคราะห์และตัดสินใจในการซื้อหรือขายสินทรัพย์ทางการเงิน เช่น หุ้นหรือสกุลเงิน ระยะเวลาในการเทรดมักถูกแบ่งออกเป็นหลายช่วง โดยที่แต่ละช่วงมีลักษณะและค่าทางเทคนิคในการเทรดต่างกัน',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color(0xFFEC5B5B)),
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.all(12))),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'ออก',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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