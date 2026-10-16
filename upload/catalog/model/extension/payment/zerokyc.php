<?php
/**
 * ZeroKYC Pay for OpenCart 2.3 — Catalog Payment Method Model.
 *
 * Compatible with standard OpenCart 2.3 checkout and Simple (simplecheckout).
 */

require_once DIR_SYSTEM . 'library/zerokyc/bootstrap.php';

use ZeroKyc\OpenCart\Settings;

class ModelExtensionPaymentZerokyc extends Model
{
    /**
     * Determines if ZeroKYC Pay is available for the current cart, address, and currency.
     *
     * @param array<string, mixed> $address
     * @param float                $total
     * @return array<string, mixed>
     */
    public function getMethod($address, $total): array
    {
        $this->load->language('extension/payment/zerokyc');

        $settings = new Settings($this->config);

        if (!$settings->isEnabled()) {
            return [];
        }

        if ($settings->apiKey() === '' || $settings->webhookSecret() === '') {
            return [];
        }

        $minTotal = $settings->totalMinimum();
        if ($minTotal > 0.0 && (float) $total < $minTotal) {
            return [];
        }

        // Check currency support (session currency or store default currency)
        $sessionCurrency = isset($this->session->data['currency']) ? (string) $this->session->data['currency'] : '';
        $storeCurrency   = (string) $this->config->get('config_currency');
        if (!Settings::isSupportedFiatCurrency($sessionCurrency) && !Settings::isSupportedFiatCurrency($storeCurrency)) {
            return [];
        }

        // Geo-zone check (safe when Simple Checkout omits country_id / zone_id)
        $geoZoneId = $settings->geoZoneId();
        if ($geoZoneId > 0) {
            $countryId = isset($address['country_id']) ? (int) $address['country_id'] : 0;
            $zoneId    = isset($address['zone_id']) ? (int) $address['zone_id'] : 0;

            $query = $this->db->query(sprintf(
                "SELECT * FROM `%szone_to_geo_zone` WHERE `geo_zone_id` = '%d' AND `country_id` = '%d' AND (`zone_id` = '%d' OR `zone_id` = '0')",
                DB_PREFIX,
                $geoZoneId,
                $countryId,
                $zoneId
            ));

            if (empty($query->num_rows)) {
                return [];
            }
        }

        $title = $settings->title();
        if ($title === '') {
            $title = $this->language->get('text_title');
        }

        return [
            'code'       => Settings::CODE,
            'title'      => $title,
            'terms'      => '',
            'sort_order' => $settings->sortOrder(),
        ];
    }
}
