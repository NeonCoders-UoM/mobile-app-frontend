import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DocumentCard extends StatefulWidget {
  final String text;

  const DocumentCard({super.key, required this.text});

  @override
  _DocumentCardState createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = !_isTapped;
        });
      },
      child: Container(
        width: 400,
        height: 76,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          color: _isTapped ? AppColors.neutral450 : AppColors.neutral500,
          child: Container(
            margin: EdgeInsets.fromLTRB(68, 0, 32, 0),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/document_card_icon.svg',
                  width: 20,
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text(
                    widget.text,
                    style: AppTextStyles.textMdSemibold.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
