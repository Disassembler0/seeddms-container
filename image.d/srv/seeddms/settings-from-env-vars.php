<?php
define("SEEDDMS_CONFIG_FILE", "/srv/seeddms/conf/settings.xml");
require("/srv/seeddms/seeddms/inc/inc.Settings.php");

$dbHostname = getenv("POSTGRES_HOST");
if ($dbHostname) {
    $settings->_dbHostname = $dbHostname;
}
$dbDatabase = getenv("POSTGRES_DB");
if ($dbDatabase) {
    $settings->_dbDatabase = $dbDatabase;
}
$dbUser = getenv("POSTGRES_USER");
if ($dbUser) {
    $settings->_dbUser = $dbUser;
}
$dbPass = getenv("POSTGRES_PASSWORD");
if ($dbPass) {
    $settings->_dbPass = $dbPass;
}

$smtpServer = getenv("SMTP_HOST");
if ($smtpServer) {
    $settings->_smtpServer = $smtpServer;
}
$smtpPort = getenv("SMTP_PORT");
if ($smtpPort) {
    $settings->_smtpPort = $smtpPort;
}
$smtpSendFrom = getenv("SMTP_SENDER");
if ($smtpSendFrom) {
    $settings->_smtpSendFrom = $smtpSendFrom;
}
$smtpUser = getenv("SMTP_USERNAME");
if ($smtpUser) {
    $settings->_smtpUser = $smtpUser;
}
$smtpPassword = getenv("SMTP_PASSWORD");
if ($smtpPassword) {
    $settings->_smtpPassword = $smtpPassword;
}

$settings->save();
