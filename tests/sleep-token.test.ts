import { Clarinet, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';

Clarinet.test({
  name: "Can earn sleep tokens for good sleep",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("sleep-tracker", "start-session", [], wallet1.address),
      // Mine enough blocks to simulate 8 hours sleep
      ...Array(28800).fill(null),
      Tx.contractCall("sleep-tracker", "end-session", [types.uint(1), types.uint(8)], wallet1.address),
      Tx.contractCall("sleep-token", "reward-sleep", [types.uint(1)], wallet1.address)
    ]);
    
    block.receipts[2].result.expectOk().expectUint(100);
  }
});
