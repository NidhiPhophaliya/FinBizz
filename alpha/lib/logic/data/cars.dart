import 'package:alpha/logic/car_logic.dart';

final class Cars {
  static final List<Car> listings = [
    Car(
        name: "Toyota Corolla",
        price: 16000.0,
        type: CarType.petrol,
        happinessBonus: 20,
        esgBonus: 0),
    Car(
        name: "Toyota Prius",
        price: 18000,
        type: CarType.hybrid,
        esgBonus: 15,
        happinessBonus: 18),
    Car(
        name: "Nissan Leaf",
        price: 21000,
        type: CarType.electric,
        esgBonus: 30,
        happinessBonus: 15),
    Car(
        name: "Tesla Model 3",
        price: 24000,
        type: CarType.electric,
        esgBonus: 40,
        happinessBonus: 20),
  ];
}
