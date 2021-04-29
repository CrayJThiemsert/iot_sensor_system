library ftiotsystem.globals;

String g_internet_ssid = "";
String g_internet_password = "";

String g_device_name = "";

String formatNumber(double n) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
}