export interface BudgetEvent {
  id: string;
  title: string;
  cost: number;
  category: "needs" | "wants" | "savings" | "investments";
}

export const budgetEvents: BudgetEvent[] = [
  { id: "rent-hike", title: "Rent increase", cost: 9000, category: "needs" },
  { id: "car-repair", title: "Car repair", cost: 8000, category: "needs" },
  { id: "medical-bill", title: "Medical bill", cost: 15000, category: "needs" },
  { id: "birthday", title: "Birthday party", cost: 3000, category: "wants" },
  { id: "phone", title: "Phone upgrade", cost: 18000, category: "wants" },
  { id: "course", title: "Career course", cost: 7000, category: "investments" },
  { id: "emergency", title: "Emergency fund top-up", cost: 5000, category: "savings" },
  { id: "wedding", title: "Family wedding travel", cost: 12000, category: "wants" },
  { id: "insurance", title: "Insurance premium", cost: 6000, category: "needs" },
  { id: "laptop", title: "Work laptop repair", cost: 10000, category: "needs" },
  { id: "mutual-fund", title: "Mutual fund SIP", cost: 4000, category: "investments" },
  { id: "dinner", title: "Dining out weekend", cost: 2500, category: "wants" },
  { id: "utilities", title: "Higher utility bill", cost: 3500, category: "needs" },
  { id: "gym", title: "Annual gym plan", cost: 12000, category: "wants" },
  { id: "cert", title: "Professional certification", cost: 14000, category: "investments" },
  { id: "tax", title: "Tax shortfall", cost: 9500, category: "needs" },
  { id: "gift", title: "Festival gifts", cost: 5500, category: "wants" },
  { id: "dental", title: "Dental treatment", cost: 11000, category: "needs" },
  { id: "bike", title: "Bike maintenance", cost: 2800, category: "needs" },
  { id: "book", title: "Finance books", cost: 1800, category: "investments" },
  { id: "trip", title: "Short vacation", cost: 22000, category: "wants" },
  { id: "security", title: "Home security deposit", cost: 20000, category: "savings" },
  { id: "petrol", title: "Fuel price spike", cost: 2500, category: "needs" },
  { id: "subscription", title: "Streaming renewals", cost: 2400, category: "wants" },
  { id: "parent", title: "Parent support", cost: 10000, category: "needs" },
  { id: "conference", title: "Industry conference", cost: 16000, category: "investments" },
  { id: "repairs", title: "Home repairs", cost: 13000, category: "needs" },
  { id: "wardrobe", title: "Office wardrobe", cost: 7000, category: "wants" },
  { id: "gold", title: "Gold savings plan", cost: 5000, category: "investments" },
  { id: "buffer", title: "Cash buffer month", cost: 6500, category: "savings" },
];
