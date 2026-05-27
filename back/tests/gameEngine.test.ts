import { describe, expect, it } from "vitest";
import { attackValue } from "../src/game/cards.js";
import { applyAction, createInitialState, currentPlayerId } from "../src/game/gameEngine.js";
import { enemyHealth } from "../src/game/cards.js";

describe("GameEngine", () => {
  const players = ["p1", "p2"];

  it("creates game with enemy and dealt hands", () => {
    const state = createInitialState("ROOM01", players);
    expect(state.currentEnemy).not.toBeNull();
    expect(state.currentEnemy?.rank).toBe("JACK");
    expect(state.hands.p1.length).toBe(7);
    expect(state.tavern.length).toBeGreaterThan(0);
    expect(state.phase).toBe("STEP1_PLAY_OR_YIELD");
  });

  it("solo mode has 8 cards and jesters aside", () => {
    const state = createInitialState("SOLO", ["solo"]);
    expect(state.hands.solo.length).toBe(8);
    expect(state.soloJestersAside.length).toBe(2);
  });

  it("applies damage from a played card", () => {
    const state = createInitialState("R1", players);
    const pid = currentPlayerId(state);
    const hand = state.hands[pid];
    const number = hand.find((c) => c.kind === "number" && c.rank === 5);
    if (!number) {
      return;
    }
    applyAction(state, pid, { type: "play", cardIds: [number.id] });
    expect(state.fightDamage).toBeGreaterThanOrEqual(5);
  });

  it("yield sets pending damage step", () => {
    const state = createInitialState("R2", players);
    const pid = currentPlayerId(state);
    applyAction(state, pid, { type: "yield" });
    expect(state.phase).toBe("STEP4_DISCARD");
    expect(state.pendingDamage).not.toBeNull();
  });

  it("loses when hand cannot pay required discard at step 4", () => {
    const state = createInitialState("R-pay", ["p1"]);
    const pid = currentPlayerId(state);
    const low: (typeof state.hands.p1)[0] = {
      id: "n2",
      kind: "number",
      suit: "hearts",
      rank: 2,
    };
    state.hands[pid] = [
      low,
      { id: "j1", kind: "jester", suit: "clubs", rank: "JOKER" },
    ];
    applyAction(state, pid, { type: "play", cardIds: [low.id] });
    expect(state.outcome).toBe("lost");
    expect(state.phase).toBe("GAME_OVER");
    expect(state.pendingDamage).toBeNull();
  });

  it("enters step 4 with zero required damage when spades fully block", () => {
    const state = createInitialState("R0b", ["p1"]);
    const pid = currentPlayerId(state);
    const low: (typeof state.hands.p1)[0] = {
      id: "n2",
      kind: "number",
      suit: "hearts",
      rank: 2,
    };
    state.hands[pid] = [low];
    state.fightSpadeShield = 99;
    applyAction(state, pid, { type: "play", cardIds: [low.id] });
    expect(state.phase).toBe("STEP4_DISCARD");
    expect(state.pendingDamage).toBe(0);
    expect(state.outcome).toBe("playing");
  });

  it("allows zero-card discard when pending damage is 0 (spades blocked attack)", () => {
    const state = createInitialState("R0", ["p1"]);
    state.phase = "STEP4_DISCARD";
    state.pendingDamage = 0;
    state.fightSpadeShield = 15;
    state.currentEnemy = {
      id: "e1",
      kind: "enemy",
      suit: "spades",
      rank: "QUEEN",
    };
    applyAction(state, "p1", { type: "discard", cardIds: [] });
    expect(state.phase).toBe("STEP1_PLAY_OR_YIELD");
    expect(state.pendingDamage).toBeNull();
  });

  it("wins when castle deck is exhausted after last king", () => {
    const state = createInitialState("R3", ["p1"]);
    state.castle = [];
    state.currentEnemy = {
      id: "k1",
      kind: "enemy",
      suit: "spades",
      rank: "KING",
    };
    state.fightDamage = enemyHealth(state.currentEnemy) - 1;
    const kingInHand = {
      id: "kh",
      kind: "enemy" as const,
      suit: "hearts" as const,
      rank: "KING" as const,
    };
    state.hands.p1 = [kingInHand];
    applyAction(state, "p1", { type: "play", cardIds: [kingInHand.id] });
    expect(state.outcome).toBe("won");
  });

  it("allows animal companion paired with one number (not a combo)", () => {
    const state = createInitialState("R-ace", ["p1"]);
    const pid = currentPlayerId(state);
    const ace: (typeof state.hands.p1)[0] = {
      id: "ace-1",
      kind: "ace",
      suit: "hearts",
      rank: "A",
    };
    const seven: (typeof state.hands.p1)[0] = {
      id: "num-7",
      kind: "number",
      suit: "diamonds",
      rank: 7,
    };
    state.hands[pid] = [ace, seven];
    applyAction(state, pid, { type: "play", cardIds: [ace.id, seven.id] });
    expect(state.fightDamage).toBe(8); // 7 + 1 from ace
    expect(state.fightPlayed[0].cards).toHaveLength(2);
  });

  it("rejects ace with two-card same-rank combo (ace cannot be in combo)", () => {
    const state = createInitialState("R-ace2", ["p1"]);
    const pid = currentPlayerId(state);
    const ace: (typeof state.hands.p1)[0] = {
      id: "ace-1",
      kind: "ace",
      suit: "hearts",
      rank: "A",
    };
    const four1: (typeof state.hands.p1)[0] = {
      id: "n1",
      kind: "number",
      suit: "clubs",
      rank: 4,
    };
    const four2: (typeof state.hands.p1)[0] = {
      id: "n2",
      kind: "number",
      suit: "diamonds",
      rank: 4,
    };
    state.hands[pid] = [ace, four1, four2];
    expect(() =>
      applyAction(state, pid, {
        type: "play",
        cardIds: [ace.id, four1.id, four2.id],
      }),
    ).toThrow(/ace/i);
  });

  it("keeps hand intact after an invalid combo so a follow-up play still works", () => {
    const state = createInitialState("R-invalid-combo", ["p1"]);
    const pid = currentPlayerId(state);
    const four: (typeof state.hands.p1)[0] = {
      id: "n4",
      kind: "number",
      suit: "hearts",
      rank: 4,
    };
    const five: (typeof state.hands.p1)[0] = {
      id: "n5",
      kind: "number",
      suit: "clubs",
      rank: 5,
    };
    state.hands[pid] = [four, five];

    expect(() =>
      applyAction(state, pid, {
        type: "play",
        cardIds: [four.id, five.id],
      }),
    ).toThrow();
    expect(state.hands[pid].map((c) => c.id).sort()).toEqual([
      four.id,
      five.id,
    ].sort());

    applyAction(state, pid, { type: "play", cardIds: [four.id] });
    expect(state.fightDamage).toBeGreaterThanOrEqual(4);
    expect(state.hands[pid].map((c) => c.id)).not.toContain(four.id);
    expect(state.hands[pid].map((c) => c.id)).toContain(five.id);
  });

  it("keeps hand intact when discard is insufficient", () => {
    const state = createInitialState("R-bad-discard", ["p1"]);
    const pid = currentPlayerId(state);
    const two: (typeof state.hands.p1)[0] = {
      id: "n2",
      kind: "number",
      suit: "hearts",
      rank: 2,
    };
    state.hands[pid] = [two];
    state.phase = "STEP4_DISCARD";
    state.pendingDamage = 10;

    expect(() =>
      applyAction(state, pid, { type: "discard", cardIds: [two.id] }),
    ).toThrow();
    expect(state.hands[pid].map((c) => c.id)).toEqual([two.id]);
  });
});

describe("attackValue", () => {
  it("animal companion adds 1 when paired with a number", () => {
    const cards = [
      { id: "a", kind: "ace" as const, suit: "hearts" as const, rank: "A" as const },
      { id: "n", kind: "number" as const, suit: "clubs" as const, rank: 7 },
    ];
    expect(attackValue(cards)).toBe(8);
  });

  it("combo of two 4s equals 8", () => {
    const cards = [
      { id: "1", kind: "number" as const, suit: "hearts" as const, rank: 4 },
      { id: "2", kind: "number" as const, suit: "clubs" as const, rank: 4 },
    ];
    expect(attackValue(cards)).toBe(8);
  });
});
