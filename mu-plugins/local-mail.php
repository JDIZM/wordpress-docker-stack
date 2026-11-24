<?php
/**
 * Plugin Name: Local mail catcher
 * Description: Sends all WordPress mail to the Mailpit container. Local development only.
 */

add_action('phpmailer_init', function ($phpmailer) {
    $phpmailer->isSMTP();
    $phpmailer->Host = 'mailpit';
    $phpmailer->Port = 1025;
    $phpmailer->SMTPAuth = false;
    $phpmailer->SMTPAutoTLS = false;
});

// WordPress builds its default sender from the host name. "wordpress@localhost" is not a valid
// address, so the mail would fail before it reaches Mailpit.
add_filter('wp_mail_from', function ($from) {
    return is_email($from) ? $from : 'wordpress@example.test';
});
