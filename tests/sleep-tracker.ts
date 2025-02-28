import { Clarinet, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';

Clarinet.test({
  name: "Can start and end sleep session with valid quality score",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("sleep-tracker", "start-session", [], wallet1.address),
    ]);
    
    block.receipts[0].result.expectOk().expectUint(1);
    
    block = chain.mineBlock([
      Tx.contractCall("sleep-tracker", "end-session", [types.uint(1), types.uint(8)], wallet1.address),  
    ]);
    
    block.receipts[0].result.expectOk().expectBool(true);
  }
});

Clarinet.test({
  name: "Cannot end session with invalid quality score",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("sleep-tracker", "start-session", [], wallet1.address),
      Tx.contractCall("sleep-tracker", "end-session", [types.uint(1), types.uint(11)], wallet1.address),  
    ]);
    
    block.receipts[0].result.expectOk().expectUint(1);
    block.receipts[1].result.expectErr().expectUint(400);
  }
});
