export type FlashcardDeckKey = "basics" | "investing" | "trading" | "macroeconomics" | "crypto";

export interface Flashcard {
  id: string;
  deck: FlashcardDeckKey;
  front: string;
  back: string;
  difficulty: 1 | 2 | 3;
}

const cardsByDeck: Record<FlashcardDeckKey, Omit<Flashcard, "id" | "deck">[]> = {
  basics: [
    { front: "What is income?", back: "Money you receive from salary, business, interest, rent, or investments.", difficulty: 1 },
    { front: "What is an expense?", back: "Money that leaves your pocket to pay for needs, wants, or obligations.", difficulty: 1 },
    { front: "What is a budget?", back: "A plan for how income will be spent, saved, invested, and protected.", difficulty: 1 },
    { front: "What is an emergency fund?", back: "Cash kept aside for unexpected events, usually 3-6 months of expenses.", difficulty: 1 },
    { front: "What is net worth?", back: "Assets minus liabilities. It is a snapshot of financial position.", difficulty: 1 },
    { front: "What is compound interest?", back: "Interest earning interest over time, creating accelerating growth.", difficulty: 1 },
    { front: "What is inflation?", back: "A rise in prices that reduces purchasing power over time.", difficulty: 2 },
    { front: "What is liquidity?", back: "How easily an asset can be converted to cash without a big price change.", difficulty: 2 },
  ],
  investing: [
    { front: "What is a stock?", back: "A share of ownership in a company.", difficulty: 1 },
    { front: "What is a bond?", back: "A loan to a company or government that pays interest.", difficulty: 1 },
    { front: "What is diversification?", back: "Spreading money across assets so one mistake does not sink the plan.", difficulty: 1 },
    { front: "What is an index fund?", back: "A fund that tracks a market index instead of picking individual stocks.", difficulty: 2 },
    { front: "What is P/E ratio?", back: "Price-to-earnings ratio, a valuation measure comparing share price to earnings.", difficulty: 2 },
    { front: "What is risk tolerance?", back: "How much volatility and loss you can emotionally and financially handle.", difficulty: 2 },
    { front: "What is asset allocation?", back: "The mix of stocks, bonds, cash, and other assets in a portfolio.", difficulty: 2 },
    { front: "What is dollar-cost averaging?", back: "Investing fixed amounts regularly regardless of market price.", difficulty: 2 },
  ],
  trading: [
    { front: "What is bid price?", back: "The highest price buyers are willing to pay right now.", difficulty: 1 },
    { front: "What is ask price?", back: "The lowest price sellers are willing to accept right now.", difficulty: 1 },
    { front: "What is spread?", back: "The gap between bid and ask prices.", difficulty: 1 },
    { front: "What is volatility?", back: "How sharply an asset price moves over time.", difficulty: 2 },
    { front: "What is a stop-loss?", back: "An order designed to limit losses by selling at a chosen price.", difficulty: 2 },
    { front: "What is short selling?", back: "Borrowing and selling an asset hoping to buy it back cheaper later.", difficulty: 3 },
    { front: "What is leverage?", back: "Borrowed exposure that magnifies gains and losses.", difficulty: 3 },
    { front: "What is market depth?", back: "The visible supply and demand at different price levels.", difficulty: 3 },
  ],
  macroeconomics: [
    { front: "What is GDP?", back: "The total value of goods and services produced by an economy.", difficulty: 1 },
    { front: "What is a recession?", back: "A broad decline in economic activity that lasts for months.", difficulty: 1 },
    { front: "What is fiscal policy?", back: "Government spending and taxation decisions.", difficulty: 2 },
    { front: "What is monetary policy?", back: "Central bank action on rates and money supply.", difficulty: 2 },
    { front: "What is a central bank?", back: "An institution that manages money supply, rates, and financial stability.", difficulty: 1 },
    { front: "What is unemployment rate?", back: "The share of people seeking work who cannot find jobs.", difficulty: 1 },
    { front: "What is exchange rate?", back: "The price of one currency in terms of another.", difficulty: 2 },
    { front: "What is a trade deficit?", back: "When imports exceed exports over a period.", difficulty: 2 },
  ],
  crypto: [
    { front: "What is blockchain?", back: "A shared ledger maintained by a network rather than one central database.", difficulty: 2 },
    { front: "What is Bitcoin?", back: "A decentralized digital asset with a fixed issuance schedule.", difficulty: 1 },
    { front: "What is a wallet?", back: "Software or hardware used to manage crypto keys.", difficulty: 2 },
    { front: "What is a private key?", back: "A secret that controls access to crypto funds.", difficulty: 3 },
    { front: "What is stablecoin?", back: "A crypto token designed to track another asset such as the US dollar.", difficulty: 2 },
    { front: "What is DeFi?", back: "Financial applications built on blockchains and smart contracts.", difficulty: 3 },
    { front: "What is gas fee?", back: "A transaction fee paid to use a blockchain network.", difficulty: 2 },
    { front: "What is custody?", back: "Who controls the keys and therefore the asset access.", difficulty: 2 },
  ],
};

export const flashcards: Flashcard[] = Object.entries(cardsByDeck).flatMap(([deck, cards]) =>
  cards.map((card, index) => ({
    id: `${deck}-${index + 1}`,
    deck: deck as FlashcardDeckKey,
    ...card,
  })),
);
