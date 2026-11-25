<?php
/**
 * Plugin Name: Starter Plugin
 * Description: The smallest plugin that works: one REST route. Replace it with yours.
 * Version: 0.1.0
 * Requires at least: 6.5
 * Requires PHP: 8.1
 */

if (!defined('ABSPATH')) {
    exit;
}

// GET /wp-json/starter/v1/ping
add_action('rest_api_init', function () {
    register_rest_route('starter/v1', '/ping', [
        'methods' => 'GET',
        // Open to everyone, which is fine for a route that returns no data. Check the user for anything else.
        'permission_callback' => '__return_true',
        'callback' => fn() => ['ok' => true, 'time' => gmdate('c')],
    ]);
});
