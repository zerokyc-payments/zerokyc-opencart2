# ZeroKYC Pay for OpenCart 2.3

Official **ZeroKYC Pay** cryptocurrency payment gateway extension for **OpenCart 2.3.x** (`2.3.0.0` – `2.3.0.2`), with native support for **Simple Checkout (`simplecheckout`)**.

Accept **USDT** (TRC-20, BEP-20, Arbitrum, Polygon, Ethereum, TON, Solana), **USDC** (Polygon, Arbitrum, Solana), **BTC**, **ETH**, **TON**, **SOL**, **XMR**, **BNB**, **TRX**, **LTC**, **DOGE**, and **BCH** with instant on-chain confirmation and zero KYC.

---

## Features

- **Zero runtime Composer dependencies** — ships with the official `zerokyc/zkp-sdk-php` vendored inside `upload/system/library/zerokyc/vendor/`.
- **Hosted Checkout Redirect Flow** — creates an invoice via `POST /v1/invoices` with deterministic per-attempt `Idempotency-Key` (`zkp_opencart_order_<sha256(orderId:seq)>`) and redirects the buyer to `https://pay.zerokycpay.com/i/{id}`.
- **Smart Live Invoice Reuse** — if the buyer refreshes or re-submits checkout while a non-terminal invoice is still valid (`> 60s` remaining) and the order total/currency/asset have not changed, the existing invoice is reused.
- **Simple Checkout (`simplecheckout`) Compatible** — works out-of-the-box with one-page checkout flows, dynamic AJAX payment reloads, hidden address fields, and in-place cart/shipping updates on the same `order_id`.
- **Cryptographic Webhook Verification** — verifies `X-Zkp-Signature: t=<unix>,v1=<hex>` using HMAC-SHA256 over the exact raw request body (`php://input`) with a 300-second replay window and constant-time `hash_equals`.
- **Atomic Database Deduplication** — claims webhook `event_id`s in `{DB_PREFIX}zerokyc_events` via `INSERT IGNORE` (`PRIMARY KEY (event_id)`) so concurrent deliveries can never double-complete an order.
- **ReplayGuard & Server-Side Double Check** — verifies `invoice_id`, `received_amount >= expected_amount`, and pinned `asset`, then optionally queries `GET /v1/invoices/{id}` before marking an order paid.
- **Background Cron Reconciliation** — optional cron endpoint (`index.php?route=extension/payment/zerokyc/cron`) polls open orders from the last 24 hours in batches of 50 in case webhooks are blocked by a firewall or local environment.
- **Bilingual Admin & Storefront** — full English (`en-gb`) and Russian (`ru-ru`) translations included.

---

## Requirements

- **OpenCart**: `2.3.x` (`2.3.0.0` – `2.3.0.2`)
- **PHP**: `8.1+` with `ext-curl` and `ext-json`
- **Store Currency**: `USD`, `EUR`, or `RUB` configured in **System → Localisation → Currencies**

---

## Installation

### Option A: OpenCart Extension Installer (`.ocmod.zip`)

1. Build or download `zerokyc-pay.ocmod.zip`:
   ```bash
   bash bin/build-zip.sh
   ```
2. In your OpenCart Admin panel, navigate to **Extensions → Extension Installer** and upload `dist/zerokyc-pay.ocmod.zip`.
3. Navigate to **Extensions → Extensions**, select **Payments** from the filter dropdown, find **ZeroKYC Pay (Crypto)**, and click **Install** (`+`).

### Option B: Manual Upload

1. Copy the contents of the `upload/` directory into your OpenCart root directory (no core files are overwritten).
2. In OpenCart Admin, go to **Extensions → Extensions → Payments**, find **ZeroKYC Pay (Crypto)**, and click **Install** (`+`).

---

## Configuration

1. Open **Extensions → Extensions → Payments → ZeroKYC Pay (Crypto) → Edit**.
2. Enter your **API Key** (`pk_live_...` for production or `pk_test_...` for sandbox) from [dashboard.zerokycpay.com](https://dashboard.zerokycpay.com).
3. Click **Test Connection** to verify connectivity and key mode (`production` / `sandbox`).
4. Copy the **Webhook URL** displayed in the settings form:
   ```text
   https://your-store.com/index.php?route=extension/payment/zerokyc/callback
   ```
   Register this URL in your ZeroKYC Dashboard under **Webhooks** and paste the generated **Webhook Secret** (`whsec_...`) into the plugin settings.
5. *(Optional)* Configure a system cron job every 5 minutes for background reconciliation:
   ```bash
   */5 * * * * curl -fsS "https://your-store.com/index.php?route=extension/payment/zerokyc/cron" >/dev/null 2>&1
   ```
6. Set **Status** to **Enabled** and click **Save**.

---

## Development & Testing

Run the full PHPUnit test suite and syntax checks via Composer or Docker:

```bash
composer install
vendor/bin/phpunit
```

Build the release `.ocmod.zip` archive:

```bash
bash bin/build-zip.sh
```

---

## License

MIT © [ZeroKYC Pay](https://zerokycpay.com)
