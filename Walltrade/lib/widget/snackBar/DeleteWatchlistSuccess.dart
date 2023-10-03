import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DeleteWatchlistSnackBar extends SnackBar {
   DeleteWatchlistSnackBar({required String symbol})
      : super(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                height: 100,
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
                            'ลบสำเร็จ!',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansThai',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'ลบ $symbol ออกจากรายการเฝ้าดูเรียบร้อยแล้ว',
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
                  child: SvgPicture.asset(
                    'assets/img/bubble.svg',
                    height: 50,
                    width: 36,
                    color: Color(0xFF952323),
                  ),
                ),
              ),
              Positioned(
                right: -10,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(60),
                  ),
                  child: SvgPicture.asset(
                    'assets/img/success.svg',
                    height: 100,
                    width: 70,
                    color: Color(0xFF952323),
                  ),
                ),
              ),
            ],
          ),
        );
}
