import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/text_manager.dart';
import 'all_top_brands_widget.dart';

class BrandSectionWidget extends StatelessWidget {
  const BrandSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextManager.topBrands.tr(),
          style:
          TextStyle(fontSize: 0.02.sh, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 0.001.sh),

        const AllTopBrandsWidget(),
        SizedBox(height: 0.04.sh),
      ],
    );
  }
}
