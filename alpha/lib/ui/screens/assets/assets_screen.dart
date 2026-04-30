// ignore_for_file: prefer_const_constructors

import 'package:alpha/assets.dart';
import 'package:alpha/extensions.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/screens/assets/screens/owned_cars_screen.dart';
import 'package:alpha/ui/screens/assets/screens/owned_real_estate_screen.dart';
import 'package:alpha/ui/screens/assets/widgets/select_asset.dart';
import 'package:flutter/material.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Assets",
        onTapBack: () => Navigator.of(context).pop(),
        children: <Widget>[
          SizedBox(height: 35.0),
          Text(
            "Choose an asset type to manage",
            style: TextStyles.medium20,
          ),
          SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableAsset(
                title: "Manage Owned Cars",
                description:
                    "Manage and sell the cars you own. Check the car's value, happiness bonus and more.",
                image: AlphaAsset.car,
                color: const Color(0xFFEBFFE4),
                onTap: () => context.navigateTo(const OwnedCarsScreen()),
              ),
              SizedBox(width: 40.0),
              SelectableAsset(
                title: "Manage Owned Real Estate",
                description:
                    "Manage and sell the real estate you own. Check the property's value, mortgage and more.",
                image: AlphaAsset.realEstateBungalow,
                color: const Color(0xFFE4F1FF),
                onTap: () => context.navigateTo(const OwnedRealEstateScreen()),
              )
            ],
          )
        ]);
  }
}
