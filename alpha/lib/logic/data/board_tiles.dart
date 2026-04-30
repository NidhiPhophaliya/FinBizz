import 'package:alpha/assets.dart';

enum BoardTile {
  startTile(
      name: "Start",
      description:
          "You're back at the starting point. Gain \$2000 as a reward.",
      image: AlphaAsset.startTile),

  careerTile(
      name: "Career",
      description:
          "Earn a salary by working a job and progressing thrugh your career",
      image: AlphaAsset.careerTile),

  educationTile(
      name: "Education",
      description:
          "Invest in your education to increase your earning potential.",
      image: AlphaAsset.educationTile),

  opportunityTile(
      name: "Opportunity",
      description:
          "Draw a card to reveal an opportunity or setback that awaits you.",
      image: AlphaAsset.opportunityTile),

  personalLifeTile(
      name: "Personal Life",
      description: "Progress in your personal life to improve your happiness.",
      image: AlphaAsset.personalLifeTile),

  worldEventTile(
      name: "World Event",
      description: "Trigger a world event that affects all players.",
      image: AlphaAsset.worldEventTile),

  realEstatesTile(
      name: "Real Estates",
      description: "Build wealth through property investment opportunities.",
      image: AlphaAsset.realEstatesTile),

  carTile(
      name: "Car",
      description: "Purchase vehicles to boost your happiness and ESG score.",
      image: AlphaAsset.carTile),

  businessTechnologyTile(
      name: "Business Technology",
      description: "Start a tech business to sell software and hardware.",
      image: AlphaAsset.businessTechnologyTile),

  businessFnBTile(
      name: "Business Food & Beverages",
      description: "Start a food business to sell food and beverages.",
      image: AlphaAsset.businessFnBTile),

  businessEcommerceTile(
      name: "Business E-commerce",
      description: "Start an e-commerce business to sell products online.",
      image: AlphaAsset.businessEcommerceTile),

  businessPharmaTile(
      name: "Business Pharmaceuticals",
      description:
          "Start a pharmaceutical business to develop and sell medicine.",
      image: AlphaAsset.businessPharmaTile),

  businessSocialMediaTile(
      name: "Business Social Media",
      description: "Start a social media business to influence others.",
      image: AlphaAsset.businessSocialMediaTile);

  final String name;
  final String description;
  final AlphaAsset image;

  const BoardTile(
      {required this.name, required this.description, required this.image});
}
