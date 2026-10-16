<?php
/**
 * ZeroKYC Pay for OpenCart 2.3 — Library Bootstrap & PSR-4 Autoloader.
 *
 * Loads the vendored ZeroKYC PHP SDK and the OpenCart integration classes
 * without requiring Composer at runtime.
 */

declare(strict_types=1);

if (!defined('ZEROKYC_OC_VERSION')) {
    define('ZEROKYC_OC_VERSION', '0.1.0');
}

spl_autoload_register(static function (string $class): void {
    // 1. Vendored ZeroKYC PHP SDK (namespace: ZeroKYC\)
    $sdkPrefix = 'ZeroKYC\\';
    if (strncmp($sdkPrefix, $class, strlen($sdkPrefix)) === 0) {
        $relative = substr($class, strlen($sdkPrefix));
        $file     = __DIR__ . '/vendor/zerokyc/zkp-sdk-php/src/' . str_replace('\\', '/', $relative) . '.php';
        if (is_file($file)) {
            require_once $file;
        }
        return;
    }

    // 2. OpenCart plugin integration classes (namespace: ZeroKyc\OpenCart\)
    $pluginPrefix = 'ZeroKyc\\OpenCart\\';
    if (strncmp($pluginPrefix, $class, strlen($pluginPrefix)) === 0) {
        $relative = substr($class, strlen($pluginPrefix));
        $file     = __DIR__ . '/' . str_replace('\\', '/', $relative) . '.php';
        if (is_file($file)) {
            require_once $file;
        }
    }
});
