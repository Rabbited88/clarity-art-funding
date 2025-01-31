import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can create a new art project",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const block = chain.mineBlock([
            Tx.contractCall('art-funding', 'create-project', [
                types.ascii("Public Mural"),
                types.ascii("A beautiful mural for the community"),
                types.uint(1000)
            ], deployer.address)
        ]);
        block.receipts[0].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Can fund an existing project",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('art-funding', 'create-project', [
                types.ascii("Public Mural"),
                types.ascii("A beautiful mural for the community"),
                types.uint(1000)
            ], deployer.address),
            Tx.contractCall('art-funding', 'fund-project', [
                types.principal(deployer.address),
                types.uint(500)
            ], wallet1.address)
        ]);
        
        block.receipts[1].result.expectOk().expectBool(true);
    }
});

Clarinet.test({
    name: "Can complete a fully funded project",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('art-funding', 'create-project', [
                types.ascii("Public Mural"),
                types.ascii("A beautiful mural for the community"),
                types.uint(1000)
            ], deployer.address),
            Tx.contractCall('art-funding', 'fund-project', [
                types.principal(deployer.address),
                types.uint(1000)
            ], wallet1.address),
            Tx.contractCall('art-funding', 'complete-project', [], deployer.address)
        ]);
        
        block.receipts[2].result.expectOk().expectBool(true);
    }
});
