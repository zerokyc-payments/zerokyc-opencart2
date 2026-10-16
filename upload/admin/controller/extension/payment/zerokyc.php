<?php
/**
 * ZeroKYC Pay for OpenCart 2.3 — Admin Controller.
 *
 * Route: extension/payment/zerokyc
 */

require_once DIR_SYSTEM . 'library/zerokyc/bootstrap.php';

use ZeroKYC\Config as SdkConfig;
use ZeroKYC\Exception\ZeroKYCException;
use ZeroKYC\Http\HttpClientInterface;
use ZeroKYC\ZeroKYC;
use ZeroKyc\OpenCart\EventStore;
use ZeroKyc\OpenCart\InvoiceMap;
use ZeroKyc\OpenCart\Settings;

class ControllerExtensionPaymentZerokyc extends Controller
{
    /** @var array<string, string> */
    private $error = [];

    /** @var HttpClientInterface|null Optional HTTP client override for testing */
    private $httpClient = null;

    public function setHttpClient(?HttpClientInterface $httpClient): void
    {
        $this->httpClient = $httpClient;
    }

    public function index(): void
    {
        $this->load->language('extension/payment/zerokyc');
        $this->document->setTitle($this->language->get('heading_title'));
        $this->load->model('setting/setting');

        if (($this->request->server['REQUEST_METHOD'] === 'POST') && $this->validate()) {
            $post = $this->sanitizePost($this->request->post);
            $this->model_setting_setting->editSetting('zerokyc', $post);
            $this->session->data['success'] = $this->language->get('text_success');

            $this->response->redirect(
                $this->url->link('extension/extension', 'token=' . $this->session->data['token'] . '&type=payment', true)
            );
            return;
        }

        // Language strings
        $languageKeys = [
            'heading_title',
            'text_edit',
            'text_enabled',
            'text_disabled',
            'text_all_zones',
            'text_yes',
            'text_no',
            'text_testing',
            'text_copied',
            'text_currency_notice',
            'entry_status',
            'entry_title',
            'entry_description',
            'entry_api_key',
            'entry_webhook_secret',
            'entry_webhook_url',
            'entry_cron_url',
            'entry_payment_currency',
            'entry_ttl_minutes',
            'entry_auto_cancel',
            'entry_double_check',
            'entry_debug',
            'entry_total',
            'entry_pending_status',
            'entry_confirming_status',
            'entry_paid_status',
            'entry_underpaid_status',
            'entry_expired_status',
            'entry_geo_zone',
            'entry_sort_order',
            'help_api_key',
            'help_webhook_secret',
            'help_webhook_url',
            'help_cron_url',
            'help_payment_currency',
            'help_ttl_minutes',
            'help_auto_cancel',
            'help_double_check',
            'help_debug',
            'help_total',
            'button_save',
            'button_cancel',
            'button_ping',
            'button_copy',
        ];

        $data = [];
        foreach ($languageKeys as $key) {
            $data[$key] = $this->language->get($key);
        }

        // Errors
        $data['error_warning']        = $this->error['warning'] ?? '';
        $data['error_api_key']        = $this->error['api_key'] ?? '';
        $data['error_webhook_secret'] = $this->error['webhook_secret'] ?? '';
        $data['error_ttl_minutes']    = $this->error['ttl_minutes'] ?? '';

        // Store currency check warning
        $storeCurrency = strtoupper((string) $this->config->get('config_currency'));
        $data['store_currency']            = $storeCurrency;
        $data['is_supported_fiat']         = Settings::isSupportedFiatCurrency($storeCurrency);
        $data['supported_fiat_currencies'] = implode(', ', ['USD', 'EUR', 'RUB']);

        // Breadcrumbs
        $data['breadcrumbs'] = [
            [
                'text' => $this->language->get('text_home'),
                'href' => $this->url->link('common/dashboard', 'token=' . $this->session->data['token'], true),
            ],
            [
                'text' => $this->language->get('text_extension'),
                'href' => $this->url->link('extension/extension', 'token=' . $this->session->data['token'] . '&type=payment', true),
            ],
            [
                'text' => $this->language->get('heading_title'),
                'href' => $this->url->link('extension/payment/zerokyc', 'token=' . $this->session->data['token'], true),
            ],
        ];

        $data['action']   = $this->url->link('extension/payment/zerokyc', 'token=' . $this->session->data['token'], true);
        $data['cancel']   = $this->url->link('extension/extension', 'token=' . $this->session->data['token'] . '&type=payment', true);
        $data['ping_url'] = str_replace('&amp;', '&', $this->url->link('extension/payment/zerokyc/ping', 'token=' . $this->session->data['token'], true));

        $catalogBase = (defined('HTTPS_CATALOG') && HTTPS_CATALOG !== '') ? HTTPS_CATALOG : HTTP_CATALOG;
        $data['webhook_url'] = rtrim($catalogBase, '/') . '/index.php?route=extension/payment/zerokyc/callback';
        $data['cron_url']    = rtrim($catalogBase, '/') . '/index.php?route=extension/payment/zerokyc/cron';

        // Settings fields with defaults
        $fields = [
            'zerokyc_status'               => '0',
            'zerokyc_title'                => 'Crypto (ZeroKYC Pay)',
            'zerokyc_description'          => 'Pay with USDT, USDC, BTC, ETH, TON, SOL, XMR and more. Instant confirmation, no account required.',
            'zerokyc_api_key'              => '',
            'zerokyc_webhook_secret'       => '',
            'zerokyc_payment_currency'     => 'any',
            'zerokyc_ttl_minutes'          => '30',
            'zerokyc_auto_cancel'          => '1',
            'zerokyc_double_check'         => '1',
            'zerokyc_debug'                => '0',
            'zerokyc_total'                => '',
            'zerokyc_pending_status_id'    => '1',
            'zerokyc_confirming_status_id' => '1',
            'zerokyc_paid_status_id'       => '2',
            'zerokyc_underpaid_status_id'  => '1',
            'zerokyc_expired_status_id'    => '7',
            'zerokyc_geo_zone_id'          => '0',
            'zerokyc_sort_order'           => '1',
        ];

        foreach ($fields as $field => $default) {
            if (isset($this->request->post[$field])) {
                $data[$field] = $this->request->post[$field];
            } else {
                $configured = $this->config->get($field);
                $data[$field] = ($configured !== null && $configured !== '') ? $configured : $default;
            }
        }

        $data['payment_currencies'] = Settings::PAYMENT_CURRENCIES;

        $this->load->model('localisation/order_status');
        $data['order_statuses'] = $this->model_localisation_order_status->getOrderStatuses();

        $this->load->model('localisation/geo_zone');
        $data['geo_zones'] = $this->model_localisation_geo_zone->getGeoZones();

        $data['header']      = $this->load->controller('common/header');
        $data['column_left'] = $this->load->controller('common/column_left');
        $data['footer']      = $this->load->controller('common/footer');

        $this->response->setOutput($this->load->view('extension/payment/zerokyc', $data));
    }

    /**
     * Creates `{DB_PREFIX}zerokyc_events` and `{DB_PREFIX}zerokyc_invoices` tables.
     */
    public function install(): void
    {
        $prefix = defined('DB_PREFIX') ? (string) DB_PREFIX : 'oc_';
        (new EventStore($this->db, $prefix))->install();
        (new InvoiceMap($this->db, $prefix))->install();
    }

    /**
     * Extension uninstall hook. Keeps audit tables intact by default.
     */
    public function uninstall(): void
    {
        // Intentionally preserve zerokyc_events and zerokyc_invoices tables so
        // historical order audit trails and idempotency records are not lost.
    }

    /**
     * AJAX endpoint: tests connectivity and API key against ZeroKYC Pay.
     */
    public function ping(): void
    {
        $this->load->language('extension/payment/zerokyc');
        $this->response->addHeader('Content-Type: application/json');

        if (!$this->user->hasPermission('modify', 'extension/payment/zerokyc')) {
            $this->response->setOutput((string) json_encode([
                'ok'      => false,
                'message' => $this->language->get('error_permission'),
            ]));
            return;
        }

        $apiKey = '';
        if (isset($this->request->post['api_key'])) {
            $apiKey = trim((string) $this->request->post['api_key']);
        }
        if ($apiKey === '') {
            $apiKey = trim((string) $this->config->get('zerokyc_api_key'));
        }

        if ($apiKey === '') {
            $this->response->setOutput((string) json_encode([
                'ok'      => false,
                'message' => $this->language->get('error_api_key_empty'),
            ]));
            return;
        }

        if (strpos($apiKey, 'pk_live_') !== 0 && strpos($apiKey, 'pk_test_') !== 0) {
            $this->response->setOutput((string) json_encode([
                'ok'      => false,
                'message' => $this->language->get('error_api_key_prefix'),
            ]));
            return;
        }

        try {
            $cfg = SdkConfig::fromArray([
                'api_key'     => $apiKey,
                'max_retries' => 1,
            ]);
            $sdk  = new ZeroKYC($cfg, $this->httpClient);
            $pong = $sdk->ping();

            $mode = strpos($apiKey, 'pk_test_') === 0 ? 'sandbox' : 'production';
            $this->response->setOutput((string) json_encode([
                'ok'      => true,
                'mode'    => $mode,
                'message' => sprintf($this->language->get('text_ping_ok'), $mode),
                'data'    => $pong,
            ]));
        } catch (ZeroKYCException $e) {
            $this->response->setOutput((string) json_encode([
                'ok'      => false,
                'message' => sprintf($this->language->get('error_ping_failed'), $e->getMessage()),
            ]));
        } catch (Throwable $e) {
            $this->response->setOutput((string) json_encode([
                'ok'      => false,
                'message' => sprintf($this->language->get('error_ping_failed'), $e->getMessage()),
            ]));
        }
    }

    protected function validate(): bool
    {
        if (!$this->user->hasPermission('modify', 'extension/payment/zerokyc')) {
            $this->error['warning'] = $this->language->get('error_permission');
        }

        $enabled       = !empty($this->request->post['zerokyc_status']);
        $apiKey        = trim((string) ($this->request->post['zerokyc_api_key'] ?? ''));
        $webhookSecret = trim((string) ($this->request->post['zerokyc_webhook_secret'] ?? ''));
        $ttlRaw        = (int) ($this->request->post['zerokyc_ttl_minutes'] ?? 30);

        if ($apiKey !== '' && strpos($apiKey, 'pk_live_') !== 0 && strpos($apiKey, 'pk_test_') !== 0) {
            $this->error['api_key'] = $this->language->get('error_api_key_prefix');
        } elseif ($enabled && $apiKey === '') {
            $this->error['api_key'] = $this->language->get('error_api_key_empty');
        }

        if ($enabled && $webhookSecret === '') {
            $this->error['webhook_secret'] = $this->language->get('error_webhook_secret');
        }

        if ($ttlRaw < 10 || $ttlRaw > 1440) {
            $this->error['ttl_minutes'] = $this->language->get('error_ttl_minutes');
        }

        return $this->error === [];
    }

    /**
     * @param array<string, mixed> $post
     * @return array<string, mixed>
     */
    private function sanitizePost(array $post): array
    {
        $post['zerokyc_api_key']        = trim((string) ($post['zerokyc_api_key'] ?? ''));
        $post['zerokyc_webhook_secret'] = trim((string) ($post['zerokyc_webhook_secret'] ?? ''));
        $post['zerokyc_title']          = trim((string) ($post['zerokyc_title'] ?? 'Crypto (ZeroKYC Pay)'));
        $post['zerokyc_description']    = trim((string) ($post['zerokyc_description'] ?? ''));

        $ttl = (int) ($post['zerokyc_ttl_minutes'] ?? 30);
        if ($ttl <= 0) {
            $ttl = 30;
        }
        $post['zerokyc_ttl_minutes'] = (string) max(10, min(1440, $ttl));

        $currency = (string) ($post['zerokyc_payment_currency'] ?? 'any');
        if (!array_key_exists($currency, Settings::PAYMENT_CURRENCIES)) {
            $currency = 'any';
        }
        $post['zerokyc_payment_currency'] = $currency;

        return $post;
    }
}
