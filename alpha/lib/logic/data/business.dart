import 'package:alpha/assets.dart';
import 'package:flutter/material.dart';

enum BusinessSector {
  foodAndBeverage(
      name: "Food and Beverages",
      shortName: "F&B",
      baseRevenue: 8000.0,
      sectorColor: Color(0xFFFFC68D),
      asset: AlphaAsset.businessFoodAndBeverages),

  eCommerce(
      name: "E-commerce",
      shortName: "E-commerce",
      baseRevenue: 10000.0,
      sectorColor: Color(0xFF8BC7FF),
      asset: AlphaAsset.businessEcommerce),

  technology(
      name: "Technology",
      shortName: "Technology",
      baseRevenue: 13000.0,
      sectorColor: Color(0xFFACFFC5),
      asset: AlphaAsset.businessTechnology),

  pharmaceutical(
      name: "Pharmaceutical",
      shortName: "Pharma",
      baseRevenue: 18000.0,
      sectorColor: Color(0xFFE3A1FF),
      asset: AlphaAsset.businessPharmaceutical),

  socialMedia(
      name: "Social Media",
      shortName: "Social Media",
      baseRevenue: 5000.0,
      sectorColor: Color(0xFFFAD370),
      asset: AlphaAsset.businessSocialMediaInfluencer),

  noBusiness(
    name: "No Business",
    shortName: "No Business",
    baseRevenue: 0.0,
    sectorColor: Colors.white,
    asset: AlphaAsset.businessTechnology,
  );

  const BusinessSector(
      {required this.name,
      required this.asset,
      required this.shortName,
      required this.sectorColor,
      required this.baseRevenue});

  final String name;
  final AlphaAsset asset;
  final String shortName;
  final Color sectorColor;
  final double baseRevenue;
}
