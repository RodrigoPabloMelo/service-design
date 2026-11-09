abstract class UrlLauncher {
  Future<void> launchExternalAppUrl(String url);
  Future<void> sendWppMessage(String number, {String? message});
  Future<void> redirectToStore();
}
