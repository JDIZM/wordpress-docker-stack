<?php
/**
 * Plugin Name: Local mail catcher
 * Description: Sends all WordPress mail to the Mailpit container. Local development only.
 */

defined('ABSPATH') || exit;

// Runs last, so a mail plugin that sets its own server on this hook does not win.
add_action('phpmailer_init', function ($phpmailer) {
    $phpmailer->isSMTP();
    $phpmailer->Host = 'mailpit';
    $phpmailer->Port = 1025;
    $phpmailer->SMTPAuth = false;
    $phpmailer->SMTPAutoTLS = false;
    $phpmailer->SMTPSecure = '';
}, PHP_INT_MAX);

// WordPress builds its default sender from the host name. "wordpress@localhost" is not a valid
// address, so the mail would fail before it reaches Mailpit.
add_filter('wp_mail_from', function ($from) {
    return is_email($from) ? $from : 'wordpress@example.test';
});
