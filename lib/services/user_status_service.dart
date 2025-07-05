import '../models/user_model.dart';

class UserStatusService {
  /// Returns true if the user is activated and has a valid subscription
  static bool isUserActive(UserModel user) {
    if (!user.isActivated) return false;
    if (user.subscriptionEnd == null) return false;
    return user.subscriptionEnd!.isAfter(DateTime.now());
  }

  /// Returns true if the user's subscription is expired
  static bool isSubscriptionExpired(UserModel user) {
    if (user.subscriptionEnd == null) return true;
    return user.subscriptionEnd!.isBefore(DateTime.now());
  }

  /// Returns the number of days remaining for the subscription
  static int daysRemaining(UserModel user) {
    if (user.subscriptionEnd == null) return 0;
    return user.subscriptionEnd!.difference(DateTime.now()).inDays;
  }
}
