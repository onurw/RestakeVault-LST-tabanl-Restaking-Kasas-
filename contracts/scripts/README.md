# RestakeVault — LST tabanlı Restaking Kasası (ERC-4626)

**Amaç:** LST (ör. stETH/rETH/wstETH) mevduatlarını tek kasada toplayıp, operatör/DAO tarafından aktarılan getirileri pay sahiplerine otomatik yansıtmak.  
**Model:** ERC-4626 kasa + `donate()` → pay başına değer artışı.

## Özellikler
- **ERC-4626** standardı (uyumlu cüzdan/araçlarla çalışır)
- `deposit/mint` ve `withdraw/redeem`
- `donate(amount)`: kasaya LST akıtır, pay fiyatını yükseltir
- Operatör listesi (`setOperator`) ile kontrollü getiri besleme
- `pricePerShare()` görünümü (1 rstLST ≈ kaç LST)

## Hızlı Başlangıç (yerel)
```bash
npm install
npm run build
npm run node
# yeni terminal
npm run deploy:local
