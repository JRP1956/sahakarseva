// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SahakarSeva';

  @override
  String get tagline => 'Cooperative services, fair for everyone';

  @override
  String get phone => 'Phone';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get iAmCustomer => 'I need a service';

  @override
  String get iAmWorker => 'I am a cooperative worker';

  @override
  String get society => 'Cooperative society';

  @override
  String get signOut => 'Sign out';

  @override
  String get services => 'Services';

  @override
  String get emergency => 'Emergency';

  @override
  String get emergencyHint =>
      'Auto-assigns the best available worker. 1.5x price';

  @override
  String get myBookings => 'My bookings';

  @override
  String get noBookings => 'No bookings yet';

  @override
  String bookService(String service) {
    return 'Book $service';
  }

  @override
  String get address => 'Address';

  @override
  String get pinLocation => 'Tap the map to set your location';

  @override
  String get when => 'When';

  @override
  String get isEmergency => 'Emergency (on-demand, 1.5× price)';

  @override
  String get youPay => 'You pay';

  @override
  String get workerGets => 'Worker gets';

  @override
  String get cooperativeGets => 'Cooperative fund';

  @override
  String get findWorkers => 'Find workers';

  @override
  String get matchedWorkers => 'Matched workers';

  @override
  String get noWorkers => 'No available workers within 10 km';

  @override
  String get choose => 'Choose';

  @override
  String kmAway(String km) {
    return '$km km away';
  }

  @override
  String jobsThisWeek(int n) {
    return '$n jobs this week';
  }

  @override
  String get matchScore => 'Match score';

  @override
  String get insured => 'Insured';

  @override
  String get accidentCover => 'Accident cover';

  @override
  String get coopMember => 'Co-op member';

  @override
  String booking(int id) {
    return 'Booking #$id';
  }

  @override
  String get status_requested => 'Requested';

  @override
  String get status_assigned => 'Worker assigned';

  @override
  String get status_accepted => 'Accepted';

  @override
  String get status_in_progress => 'In progress';

  @override
  String get status_completed => 'Completed';

  @override
  String get status_paid => 'Paid';

  @override
  String get status_rated => 'Rated';

  @override
  String get status_cancelled => 'Cancelled';

  @override
  String pay(String amount) {
    return 'Pay $amount';
  }

  @override
  String get paymentDemo => 'Demo payment (Razorpay test mode)';

  @override
  String get rate => 'Rate this service';

  @override
  String get submit => 'Submit';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get viewInvoice => 'View invoice';

  @override
  String get jobs => 'Jobs';

  @override
  String get bookings => 'Bookings';

  @override
  String get earnings => 'Earnings';

  @override
  String get profile => 'Profile';

  @override
  String get available => 'Available';

  @override
  String get newRequests => 'New job requests';

  @override
  String get noRequests => 'No new requests. Stay available!';

  @override
  String get estimatedEarnings => 'Estimated earnings';

  @override
  String get accept => 'Accept';

  @override
  String get start => 'Start job';

  @override
  String get complete => 'Mark complete';

  @override
  String get thisMonth => 'This month';

  @override
  String jobsDone(int n) {
    return '$n jobs';
  }

  @override
  String get welfare => 'Welfare & membership';

  @override
  String get skills => 'Skills';

  @override
  String get certifications => 'Certifications';

  @override
  String get addCertification => 'Add certification';

  @override
  String get verified => 'Verified';

  @override
  String get pendingVerification => 'Pending verification';

  @override
  String experience(int n) {
    return '$n years experience';
  }

  @override
  String get language => 'Language';

  @override
  String get save => 'Save';

  @override
  String get error => 'Something went wrong';
}
