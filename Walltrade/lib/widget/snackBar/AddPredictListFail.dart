import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddPredictListFailSnackBar extends SnackBar {
  AddPredictListFailSnackBar({super.key, required String symbol})
      : super(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                height: 90,
                decoration: BoxDecoration(
                  color: Color(0xFFBB2525),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 60),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'เกิดข้อผิดพลาด!',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansThai',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'โปรดพิมพ์ชื่อหุ้นก่อนเพิ่มลงในรายการสำหรับทำนาย',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansThai',
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 15,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                  ),
                  child: Icon(Icons.remove_circle_rounded,color: Color(0xFF952323),size: 40,)
                ),
              ),
              Positioned(
                right: -25,
                top: -20,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    size: 90,
                    color: Color(0xFF952323),
                  ),
                ),
              ),
            ],
          ),
        );
}
