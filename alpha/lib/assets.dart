class ImagePaths {
  static const String root = "assets/images";
}

enum AlphaAsset {
  // Logos
  logoCashflow(path: "${ImagePaths.root}/logo/cashflow.png"),
  logoNcf(path: "${ImagePaths.root}/logo/ncf.png"),
  logoIIC(path: "${ImagePaths.root}/logo/iic.jpg"),

  // Goals
  goalHappiness(path: "${ImagePaths.root}/goals/happiness.png"),
  goalCareer(path: "${ImagePaths.root}/goals/career.png"),
  goalWealth(path: "${ImagePaths.root}/goals/wealth.png"),

  // Avatars
  avatarBrownHair(path: "${ImagePaths.root}/avatars/avatar1.png"),
  avatarBlackGuy(path: "${ImagePaths.root}/avatars/avatar2.png"),
  avatarGreenBuns(path: "${ImagePaths.root}/avatars/avatar4.png"),
  avatarOrangePonytail(path: "${ImagePaths.root}/avatars/avatar5.png"),
  avatarBlueTShirt(path: "${ImagePaths.root}/avatars/avatar6.png"),
  avatarOrangeHoodie(path: "${ImagePaths.root}/avatars/avatar7.png"),
  avatarBlueEarphones(path: "${ImagePaths.root}/avatars/avatar8.png"),
  avatarBlueHairWhiteBlouse(path: "${ImagePaths.root}/avatars/avatar9.png"),

  // Board Tiles
  startTile(path: "${ImagePaths.root}/board_tiles/start.png"),
  careerTile(path: "${ImagePaths.root}/board_tiles/career.png"),
  educationTile(path: "${ImagePaths.root}/board_tiles/education.png"),
  opportunityTile(path: "${ImagePaths.root}/board_tiles/opportunity.png"),
  personalLifeTile(path: "${ImagePaths.root}/board_tiles/personal_life.png"),
  worldEventTile(path: "${ImagePaths.root}/board_tiles/world_event.png"),
  realEstatesTile(path: "${ImagePaths.root}/board_tiles/real_estate.png"),
  businessTechnologyTile(
      path: "${ImagePaths.root}/board_tiles/business_technology.png"),
  businessEcommerceTile(
      path: "${ImagePaths.root}/board_tiles/business_ecommerce.png"),
  businessFnBTile(path: "${ImagePaths.root}/board_tiles/business_fnb.png"),
  businessPharmaTile(
      path: "${ImagePaths.root}/board_tiles/business_pharma.png"),
  businessSocialMediaTile(
      path: "${ImagePaths.root}/board_tiles/business_social_media.png"),
  carTile(path: "${ImagePaths.root}/board_tiles/car.png"),

  // Budgeting
  budgetingJar0(path: "${ImagePaths.root}/budgeting/0.png"),
  budgetingJar25(path: "${ImagePaths.root}/budgeting/25.png"),
  budgetingJar50(path: "${ImagePaths.root}/budgeting/50.png"),
  budgetingJar75(path: "${ImagePaths.root}/budgeting/75.png"),
  budgetingJar100(path: "${ImagePaths.root}/budgeting/100.png"),

  // Dashboard Icons
  dashboardBusiness(path: "${ImagePaths.root}/dashboard/business.png"),
  dashboardInvestment(path: "${ImagePaths.root}/dashboard/investments.png"),
  dashboardAssets(path: "${ImagePaths.root}/dashboard/assets.png"),
  dashboardWorldEvent(path: "${ImagePaths.root}/dashboard/world_event.png"),

  // Business Sectors
  businessFoodAndBeverages(path: "${ImagePaths.root}/business_fnb.png"),
  businessPharmaceutical(path: "${ImagePaths.root}/business_pharma.png"),
  businessEcommerce(path: "${ImagePaths.root}/business_ecommerce.png"),
  businessSocialMediaInfluencer(
      path: "${ImagePaths.root}/business_social_media.png"),
  businessTechnology(path: "${ImagePaths.root}/business_technology.png"),

  // Career
  careerFoodDelivery(path: "${ImagePaths.root}/career/food_delivery.png"),

  careerCulinaryChefAssistant(
      path: "${ImagePaths.root}/career/culinary_chef_assistant.png"),
  careerCulinaryExecutiveChef(
      path: "${ImagePaths.root}/career/culinary_executive_chef.png"),

  careerMarketingAssistant(
      path: "${ImagePaths.root}/career/marketing_assistant.png"),
  careerMarketingManager(
      path: "${ImagePaths.root}/career/marketing_manager.png"),

  careerBankingAnalyst(path: "${ImagePaths.root}/career/banking_analyst.png"),
  careerBankingAssociate(
      path: "${ImagePaths.root}/career/banking_associate.png"),
  careerBankingManager(path: "${ImagePaths.root}/career/banking_manager.png"),

  careerMedicineResident(
      path: "${ImagePaths.root}/career/mediciine_resident.png"),
  careerMedicineDoctor(path: "${ImagePaths.root}/career/medicine_doctor.png"),
  careerMedicineHouseman(
      path: "${ImagePaths.root}/career/medicine_houseman.png"),
  careerMedicineSpecialist(
      path: "${ImagePaths.root}/career/medicine_specialist.png"),
  careerMedicineSurgeon(path: "${ImagePaths.root}/career/medicine_surgeon.png"),

  careerProgrammerJunior(
      path: "${ImagePaths.root}/career/programmer_junior.png"),
  careerProgrammerSenior(
      path: "${ImagePaths.root}/career/programmer_senior.png"),
  careerProgrammerManager(
      path: "${ImagePaths.root}/career/programmer_manager.png"),

  careerEngineerJunior(path: "${ImagePaths.root}/career/engineer_junior.png"),
  careerEngineerSenior(path: "${ImagePaths.root}/career/engineer_senior.png"),
  careerEngineerExecutive(
      path: "${ImagePaths.root}/career/engineer_executive.png"),

  // Opportunity Icons
  opportunityQuestionMark(path: "${ImagePaths.root}/question_mark_icon.png"),
  opportunityAudited(path: "${ImagePaths.root}/opportunity/audit.png"),
  opportunityLottery(path: "${ImagePaths.root}/opportunity/lottery.png"),
  opportunityLawsuit(path: "${ImagePaths.root}/opportunity/lawsuit.png"),
  opportunityCharity(path: "${ImagePaths.root}/opportunity/charity.png"),
  opportunityAngelInvestor(path: "${ImagePaths.root}/opportunity/angel.png"),

  // Real Estate
  realEstateHdb(path: "${ImagePaths.root}/real_estate/hdb.png"),
  realEstateHdb2(path: "${ImagePaths.root}/real_estate/hdb2.png"),
  realEstateCondo(path: "${ImagePaths.root}/real_estate/condo.png"),
  realEstateBungalow(path: "${ImagePaths.root}/real_estate/bungalow.png"),
  realEstateBungalow2(path: "${ImagePaths.root}/real_estate/bungalow2.png"),

  // Car
  car(path: "${ImagePaths.root}/car/car.png"),
  carPetrol(path: "${ImagePaths.root}/car/petrol.png"),
  carElectric(path: "${ImagePaths.root}/car/electric.png"),
  carHybrid(path: "${ImagePaths.root}/car/hybrid.png"),

  // Personal Life
  personalLifeSingle(path: "${ImagePaths.root}/personal_life/single.png"),
  personalLifeDating(path: "${ImagePaths.root}/personal_life/dating.png"),
  personalLifeMarried(path: "${ImagePaths.root}/personal_life/married.png"),
  personalLifeFamily(path: "${ImagePaths.root}/personal_life/family.png"),
  ;

  const AlphaAsset({required this.path});

  final String path;
}
