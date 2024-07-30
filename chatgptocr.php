<?php

require_once 'chatgptocr.civix.php';

use CRM_Chatgptocr_ExtensionUtil as E;

/**
 * Implements hook_civicrm_config().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_config/
 */
function chatgptocr_civicrm_config(&$config): void {
  _chatgptocr_civix_civicrm_config($config);
}

/**
 * Implements hook_civicrm_install().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_install
 */
function chatgptocr_civicrm_install(): void {
  _chatgptocr_civix_civicrm_install();
}

/**
 * Implements hook_civicrm_enable().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_enable
 */
function chatgptocr_civicrm_enable(): void {
  _chatgptocr_civix_civicrm_enable();
}

function chatgptocr_civicrm_navigationMenu(&$menu) {
  _chatgptocr_civix_insert_navigation_menu($menu, 'Administer/System Settings', array(
    'label' => ts('Add Physical Form to System'),
    'name' => 'OctoCR',
    'url' => 'civicrm/octocr',
    'permission' => 'administer CiviCRM',
    'operator' => 'OR',
    'separator' => 0,
  ));

  // _chatgptocr_civix_insert_navigation_menu($menu, 'Administer/System Settings', array(
  //   'label' => ts('Upload Micro Jobber Application'),
  //   'name' => 'ApplicationForm',
  //   'url' => 'civicrm/mj-app',
  //   'permission' => 'administer CiviCRM',
  //   'operator' => 'OR',
  //   'separator' => 0,
  // ));

  _chatgptocr_civix_insert_navigation_menu($menu, 'Administer', array(
    'label' => ts('Referral Form OCR'),
    'name' => 'ReferralForm',
    'url' => 'civicrm/referral-form',
    'permission' => 'administer CiviCRM',
    'operator' => 'OR',
    'separator' => 0,
  ));
  _chatgptocr_civix_navigationMenu($menu);
}