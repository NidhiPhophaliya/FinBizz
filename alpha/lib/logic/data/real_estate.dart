import 'package:alpha/assets.dart';
import 'package:alpha/logic/real_estate_logic.dart';

final class RealEstates {
  static final List<RealEstate> listings = [
    RealEstate(
        name: "34 Jurong East St",
        type: RealEstateType.hdb,
        image: AlphaAsset.realEstateHdb,
        propertyValue: 120000.0,
        growthRate: 1.05,
        repaymentPeriod: 20),
    RealEstate(
        name: "6 Clementi St",
        type: RealEstateType.hdb,
        image: AlphaAsset.realEstateHdb2,
        propertyValue: 90000.0,
        growthRate: 1.03,
        repaymentPeriod: 20),
    RealEstate(
        name: "1 Marina Bay Sands",
        type: RealEstateType.condo,
        image: AlphaAsset.realEstateCondo,
        propertyValue: 170000.0,
        growthRate: 1.06,
        repaymentPeriod: 20),
    RealEstate(
        name: "1 Bukit Timah Road",
        type: RealEstateType.landed,
        image: AlphaAsset.realEstateBungalow,
        propertyValue: 500000.0,
        growthRate: 1.04,
        repaymentPeriod: 30),
    RealEstate(
        name: "12 Orchard Road ",
        type: RealEstateType.landed,
        image: AlphaAsset.realEstateBungalow2,
        propertyValue: 600000.0,
        growthRate: 1.03,
        repaymentPeriod: 40),
  ];
}
