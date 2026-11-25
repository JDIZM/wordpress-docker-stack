<?php
// Theme setup. Presentation only: data and API routes belong in the plugin.

add_action('after_setup_theme', function () {
    add_theme_support('title-tag');
});

add_action('wp_enqueue_scripts', function () {
    wp_enqueue_style('starter-theme', get_stylesheet_uri(), [], wp_get_theme()->get('Version'));
});
