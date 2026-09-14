// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'सहकार सेवा';

  @override
  String get tagline => 'सहकारी सेवा, सर्वांसाठी न्याय्य';

  @override
  String get phone => 'फोन';

  @override
  String get password => 'पासवर्ड';

  @override
  String get name => 'नाव';

  @override
  String get signIn => 'साइन इन';

  @override
  String get createAccount => 'खाते तयार करा';

  @override
  String get iAmCustomer => 'मला सेवा हवी आहे';

  @override
  String get iAmWorker => 'मी सहकारी कामगार आहे';

  @override
  String get society => 'सहकारी संस्था';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get services => 'सेवा';

  @override
  String get emergency => 'आपत्कालीन';

  @override
  String get emergencyHint =>
      'सर्वोत्तम उपलब्ध कामगार आपोआप नियुक्त. 1.5x किंमत';

  @override
  String get myBookings => 'माझ्या बुकिंग';

  @override
  String get noBookings => 'अजून बुकिंग नाही';

  @override
  String bookService(String service) {
    return '$service बुक करा';
  }

  @override
  String get address => 'पत्ता';

  @override
  String get pinLocation => 'स्थान सेट करण्यासाठी नकाशावर टॅप करा';

  @override
  String get when => 'केव्हा';

  @override
  String get isEmergency => 'आपत्कालीन (तत्काळ, 1.5× किंमत)';

  @override
  String get youPay => 'तुम्ही द्याल';

  @override
  String get workerGets => 'कामगाराला';

  @override
  String get cooperativeGets => 'सहकारी निधी';

  @override
  String get findWorkers => 'कामगार शोधा';

  @override
  String get matchedWorkers => 'जुळलेले कामगार';

  @override
  String get noWorkers => '10 किमी मध्ये कामगार उपलब्ध नाही';

  @override
  String get choose => 'निवडा';

  @override
  String kmAway(String km) {
    return '$km किमी दूर';
  }

  @override
  String jobsThisWeek(int n) {
    return 'या आठवड्यात $n कामे';
  }

  @override
  String get matchScore => 'मॅच स्कोअर';

  @override
  String get insured => 'विमाधारक';

  @override
  String get accidentCover => 'अपघात कवच';

  @override
  String get coopMember => 'सहकारी सदस्य';

  @override
  String booking(int id) {
    return 'बुकिंग #$id';
  }

  @override
  String get status_requested => 'विनंती केली';

  @override
  String get status_assigned => 'कामगार नियुक्त';

  @override
  String get status_accepted => 'स्वीकारले';

  @override
  String get status_in_progress => 'सुरू आहे';

  @override
  String get status_completed => 'पूर्ण';

  @override
  String get status_paid => 'पैसे दिले';

  @override
  String get status_rated => 'रेटिंग दिली';

  @override
  String get status_cancelled => 'रद्द';

  @override
  String pay(String amount) {
    return '$amount भरा';
  }

  @override
  String get paymentDemo => 'डेमो पेमेंट (Razorpay टेस्ट मोड)';

  @override
  String get rate => 'सेवेला रेट करा';

  @override
  String get submit => 'सबमिट करा';

  @override
  String get cancelBooking => 'बुकिंग रद्द करा';

  @override
  String get viewInvoice => 'बिल पहा';

  @override
  String get jobs => 'कामे';

  @override
  String get bookings => 'बुकिंग';

  @override
  String get earnings => 'कमाई';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get available => 'उपलब्ध';

  @override
  String get newRequests => 'नवीन कामाच्या विनंत्या';

  @override
  String get noRequests => 'नवीन विनंती नाही. उपलब्ध रहा!';

  @override
  String get estimatedEarnings => 'अंदाजे कमाई';

  @override
  String get accept => 'स्वीकारा';

  @override
  String get start => 'काम सुरू करा';

  @override
  String get complete => 'पूर्ण करा';

  @override
  String get thisMonth => 'या महिन्यात';

  @override
  String jobsDone(int n) {
    return '$n कामे';
  }

  @override
  String get welfare => 'कल्याण आणि सदस्यत्व';

  @override
  String get skills => 'कौशल्ये';

  @override
  String get certifications => 'प्रमाणपत्रे';

  @override
  String get addCertification => 'प्रमाणपत्र जोडा';

  @override
  String get verified => 'सत्यापित';

  @override
  String get pendingVerification => 'सत्यापन प्रलंबित';

  @override
  String experience(int n) {
    return '$n वर्षांचा अनुभव';
  }

  @override
  String get language => 'भाषा';

  @override
  String get save => 'जतन करा';

  @override
  String get error => 'काहीतरी चूक झाली';
}
