import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/text_manager.dart';
import 'top_brands_widget.dart';

// done
class AllTopBrandsWidget extends StatelessWidget {
  const AllTopBrandsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Top Brands
      child: Row(
        children: [
          // Toyota
          TopBrandsWidget(
            imagePath: AssetsManager.toyotaLogo,
            name: TextManager.toyotaCar.tr(),
          ),

          // BMW
          TopBrandsWidget(
            imagePath: AssetsManager.BMWLogo,
            name: TextManager.bmwCar.tr(),
          ),

          // Honda
          TopBrandsWidget(
            imagePath: AssetsManager.hondaLogo,
            name: TextManager.hondaCar.tr(),
          ),

          // Ford
          TopBrandsWidget(
            imagePath: AssetsManager.fordLogo,
            name: TextManager.fordCar.tr(),
          ),

          // Mercedes
          TopBrandsWidget(
            imagePath: AssetsManager.mercedesLogo,
            name: TextManager.mercedesBenzCar.tr(),
          ),

          // Nissan
          TopBrandsWidget(
            imagePath: AssetsManager.nissanLogo,
            name: TextManager.nissanCar.tr(),
          ),

          // Lexus
          TopBrandsWidget(
            imagePath: AssetsManager.lexusLogo,
            name: TextManager.lexusCar.tr(),
          ),

          // Mazda
          TopBrandsWidget(
            imagePath: AssetsManager.mazdaLogo,
            name: TextManager.mazdaCar.tr(),
          ),

          // Subaru
          TopBrandsWidget(
            imagePath: AssetsManager.subaruLogo,
            name: TextManager.subaruCar.tr(),
          ),

          // Chevrolet
          TopBrandsWidget(
            imagePath: AssetsManager.chevroletLogo,
            name: TextManager.chevroletCar.tr(),
          ),

          // Hyundai
          TopBrandsWidget(
            imagePath: AssetsManager.hyundaiLogo,
            name: TextManager.hyundaiCar.tr(),
          ),

          // Kia
          TopBrandsWidget(
            imagePath: AssetsManager.kaiLogo,
            name: TextManager.kiaCar.tr(),
          ),

          // Porsche
          TopBrandsWidget(
            imagePath: AssetsManager.porscheLogo,
            name: TextManager.porscheCar.tr(),
          ),

          // Renault
          TopBrandsWidget(
            imagePath: AssetsManager.renaultLogo,
            name: TextManager.renaultCar.tr(),
          ),

          // Tesla
          TopBrandsWidget(
            imagePath: AssetsManager.teslaLogo,
            name: TextManager.teslaCar.tr(),
          ),

          // Volkswagen
          TopBrandsWidget(
            imagePath: AssetsManager.volkswagenLogo,
            name: TextManager.volkswagenCar.tr(),
          ),

          // Volvo
          TopBrandsWidget(
            imagePath: AssetsManager.volvoLogo,
            name: TextManager.volvoCar.tr(),
          ),
        ],
      ),
    );
  }
}
