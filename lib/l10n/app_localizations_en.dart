// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Luggage Management System';

  @override
  String get homeTitle => 'Luggage Management Console';

  @override
  String get searchLuggage => 'Search Luggage';

  @override
  String get scanQRCode => 'Scan Luggage QR Code';

  @override
  String get welcomeBack => 'Welcome back, airline staff';

  @override
  String get employee => 'Employee';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get scanProcess => 'Scan Processing';

  @override
  String get scanProcessDesc => 'Scan luggage QR codes';

  @override
  String get searchLuggageDesc => 'Search luggage information';

  @override
  String get damageRegistration => 'Damage Registration';

  @override
  String get damageRegistrationDesc => 'Register damaged luggage';

  @override
  String get evidenceQuery => 'Evidence Query';

  @override
  String get evidenceQueryDesc => 'Query damage evidence';

  @override
  String get homeTab => 'Home';

  @override
  String get luggageTab => 'Luggage';

  @override
  String get todoTab => 'To-Do';

  @override
  String get myTab => 'Me';

  @override
  String get profileTitle => 'Employee Center';

  @override
  String get accountInfo => 'Account Info';

  @override
  String get accountSecurity => 'Account Security';

  @override
  String get personalization => 'Personalization';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get quickFunctions => 'Quick Functions';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get logoutConfirmMsg => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get logout => 'Exit';

  @override
  String get logoutBtn => 'Log Out';

  @override
  String get employeeId => 'Employee ID';

  @override
  String get workEmail => 'Work Email';

  @override
  String get notSet => 'Not Set';

  @override
  String get employeeName => 'Employee Name';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get accountInfoNote => 'Account Info Notice';

  @override
  String get accountInfoNoteContent =>
      '• Your employee ID is your unique identifier in the system\n• Work email is used for system notifications and important messages\n• Your employee name will be displayed in your profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get bindPhone => 'Bind Phone';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get verifyCode => 'Verification Code';

  @override
  String get verifyCodeSent => 'Verification code sent';

  @override
  String get getVerifyCode => 'Get Code';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get phoneBindSuccess => 'Phone bound successfully';

  @override
  String get accountSecurityTitle => 'Account Security';

  @override
  String get passwordChange => 'Change Password';

  @override
  String get phoneBind => 'Bind Phone';

  @override
  String get notBound => 'Not Bound';

  @override
  String get twoFactorAuth => 'Two-Factor Auth';

  @override
  String get twoFactorEnabled => 'Two-factor auth enabled';

  @override
  String get securityTips => 'Security Tips';

  @override
  String get securityTipsContent =>
      '• Change your password regularly and use a strong password\n• Binding your phone improves account security\n• Enabling two-factor auth prevents unauthorized login';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get selectAvatarSource => 'Select Avatar Source';

  @override
  String avatarSelected(String name) {
    return 'Avatar selected: $name';
  }

  @override
  String get avatarCancelled => 'Selection cancelled';

  @override
  String get album => 'Photo Album';

  @override
  String get camera => 'Camera';

  @override
  String avatarCaptureSuccess(String name) {
    return 'Avatar captured: $name';
  }

  @override
  String get changeNickname => 'Change Nickname';

  @override
  String get newNickname => 'New Nickname';

  @override
  String get nicknameEmpty => 'Nickname cannot be empty';

  @override
  String get nicknameChangedSuccess => 'Nickname changed successfully';

  @override
  String get personalizationTitle => 'Personalization';

  @override
  String get personalizationNote => 'Personalization Notice';

  @override
  String get personalizationNoteContent =>
      '• Changing your avatar personalizes your profile\n• Changing your nickname updates your display name\n• These settings only affect how your profile is displayed, not account security';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemMode => 'Follow System';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheConfirm =>
      'Clear app cache? This will delete temporary data but not your personal data.';

  @override
  String get cacheClearedSuccess => 'Cache cleared successfully';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get luggageStatusUpdate => 'Luggage Status Update';

  @override
  String get systemNotification => 'System Notifications';

  @override
  String get abnormalAlert => 'Abnormal Alerts';

  @override
  String get systemSettingsTitle => 'System Settings';

  @override
  String get systemSettingsNote => 'System Settings Notice';

  @override
  String get systemSettingsNoteContent =>
      '• Notification settings control which alerts you receive\n• Language settings change the app display language\n• Theme settings switch between light/dark/system mode\n• Clear cache frees up storage space';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackHint => 'Enter your feedback or suggestions';

  @override
  String get feedbackEmpty => 'Please enter feedback content';

  @override
  String get feedbackSuccess =>
      'Feedback submitted, thank you for your suggestions';

  @override
  String get submit => 'Submit';

  @override
  String get appName => 'Luggage Management System';

  @override
  String get appDesc =>
      'A luggage tracking and management tool designed for airline ground staff.';

  @override
  String get copyright =>
      '© 2026 Luggage Management System. All Rights Reserved.';

  @override
  String get contactUsEnabled => 'Contact Us is enabled';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get usageHelp => 'User Guide';

  @override
  String get about => 'About';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactPhone => '400-123-4567';

  @override
  String get helpSupportNote => 'Help & Support Notice';

  @override
  String get helpSupportNoteContent =>
      '• User Guide: View app tutorials and FAQs\n• Feedback: Submit your suggestions\n• About: View version info and copyright\n• Contact Us: Get customer support';

  @override
  String get quickScanEnabled => 'Quick scan is enabled';

  @override
  String get quickFunctionsTitle => 'Quick Functions';

  @override
  String get luggageMap => 'Luggage Map';

  @override
  String get luggageMapDesc => 'View luggage location distribution';

  @override
  String get quickScan => 'Quick Scan';

  @override
  String get quickScanDesc => 'Enter scan interface directly';

  @override
  String get quickFunctionsNote => 'Quick Functions Notice';

  @override
  String get quickFunctionsNoteContent =>
      '• Luggage Map: View real-time luggage location distribution\n• Quick Scan: Enter QR scan interface for fast luggage handling';

  @override
  String get queryLuggage => 'Query Luggage';

  @override
  String get searchLuggageHint => 'Search Luggage';

  @override
  String get searchPlaceholder =>
      'Tag No., Flight No., Passenger Name or Destination';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get statusFilter => 'Status Filter';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get executeSearch => 'Search';

  @override
  String get enterSearchCondition => 'Enter search criteria and tap Search';

  @override
  String luggageTagNo(String tag) {
    return 'Luggage Tag: $tag';
  }

  @override
  String remark(String note) {
    return 'Remark: $note';
  }

  @override
  String get filterConditions => 'Filter Conditions';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get status => 'Status';

  @override
  String get all => 'All';

  @override
  String get checkIn => 'Checked In';

  @override
  String get inTransit => 'In Transit';

  @override
  String get arrived => 'Arrived';

  @override
  String get delivered => 'Delivered';

  @override
  String get damaged => 'Damaged';

  @override
  String get lost => 'Lost';

  @override
  String get unknownStatus => 'Unknown Status';

  @override
  String get changeStatus => 'Change Status';

  @override
  String get markDamaged => 'Mark Damaged';

  @override
  String get viewHistoryLog => 'View History';

  @override
  String get luggageManagement => 'Luggage Management';

  @override
  String get filter => 'Filter';

  @override
  String get refresh => 'Refresh';

  @override
  String get searchLuggageTag => 'Search tag, owner, location...';

  @override
  String totalLuggage(int count) {
    return '$count luggage items';
  }

  @override
  String get loadMore => '(Pull to load more)';

  @override
  String allLoaded(int count) {
    return '— All $count items loaded —';
  }

  @override
  String get enterLocationFirst => 'Please enter location info first';

  @override
  String get locationSynced => 'Location and status synced to server';

  @override
  String updateLocationFailed(int code) {
    return 'Location update failed ($code)';
  }

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get updateSuccess => 'Update successful';

  @override
  String get uploadCreateSuccess => 'Upload/Create successful';

  @override
  String get luggageInfo => 'Luggage Info';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get historyLog => 'History';

  @override
  String get qrCodeResult => 'QR Code Result';

  @override
  String get luggageDetail => 'Luggage Detail';

  @override
  String get location => 'Location';

  @override
  String get note => 'Note';

  @override
  String get update => 'Update (PUT)';

  @override
  String get uploadCreate => 'Upload/Create (POST)';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get updateLocationBackend => 'Update location to server';

  @override
  String get operationHistoryLog => 'Operation History';

  @override
  String operator(String name) {
    return 'Operator: $name';
  }

  @override
  String get evidenceDetail => 'Evidence Detail';

  @override
  String get copyHashValue => 'Copy Hash';

  @override
  String baggageNo(String no) {
    return 'Baggage No.: $no';
  }

  @override
  String get damagedBaggage => 'Damaged Luggage';

  @override
  String get loading => 'Loading...';

  @override
  String get imageLoadFailed => 'Image failed to load';

  @override
  String get recordTime => 'Record Time';

  @override
  String get recordLocation => 'Record Location';

  @override
  String get hashValue => 'Hash Value';

  @override
  String get damageDesc => 'Damage Description';

  @override
  String get hashVerification => 'Evidence Hash Verification';

  @override
  String get hashVerificationNote =>
      'Hash verifies image evidence integrity and authenticity';

  @override
  String get hashVerified => 'Hash verified: evidence not tampered';

  @override
  String get hashFailed => 'Hash failed: evidence may have been modified';

  @override
  String get verifyHash => 'Verify Hash';

  @override
  String get noImageToVerify => 'No image to verify';

  @override
  String get hashVerifySuccess => 'Hash verified, evidence intact';

  @override
  String verifyFailed(String error) {
    return 'Verification failed: $error';
  }

  @override
  String get hashCopied => 'Hash copied to clipboard';

  @override
  String get maxPhotosHint => 'Maximum 3 photos allowed';

  @override
  String get photoUploadSuccess => 'Photo uploaded successfully';

  @override
  String uploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get hint => 'Hint';

  @override
  String get noPhotoHint =>
      'No luggage photo uploaded. Photos are important for liability. Continue anyway?';

  @override
  String get continueAction => 'Continue';

  @override
  String get addLuggageSuccess => 'Luggage info added successfully!';

  @override
  String addFailed(String error) {
    return 'Add failed: $error';
  }

  @override
  String get addLuggageInfo => 'Add Luggage Info';

  @override
  String get luggageTagNoLabel => 'Luggage Tag';

  @override
  String get enterLuggageTagNo => 'Enter luggage tag';

  @override
  String get flightNo => 'Flight No.';

  @override
  String get enterFlightNo => 'Enter flight number';

  @override
  String get passengerName => 'Passenger Name';

  @override
  String get enterPassengerName => 'Enter passenger name';

  @override
  String get luggageWeight => 'Weight (kg)';

  @override
  String get enterWeight => 'Enter weight';

  @override
  String get invalidWeight => 'Please enter a valid weight';

  @override
  String get destination => 'Destination';

  @override
  String get enterDestination => 'Enter destination';

  @override
  String get luggageStatus => 'Luggage Status';

  @override
  String get remarkOptional => 'Remark';

  @override
  String get enterRemark => 'Enter remark (optional)';

  @override
  String get operatorEmployee => 'Operator';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get autoLocation => 'Location will be auto-fetched';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get uploadPhotoHint => 'Upload luggage photos as liability evidence';

  @override
  String get tapUploadPhoto => 'Tap to upload photos';

  @override
  String get max3Photos => 'Max 3 photos';

  @override
  String get addLuggage => 'Add Luggage';

  @override
  String get processSuccess => 'Processed successfully';

  @override
  String processFailed(String error) {
    return 'Process failed: $error';
  }

  @override
  String get overweightTitle => 'Overweight Fee / Weighing';

  @override
  String get weighingInfo => 'Weight Info';

  @override
  String get actualWeight => 'Luggage Weight';

  @override
  String get enterActualWeight => 'Enter actual weight';

  @override
  String get feeInfo => 'Fee Info';

  @override
  String get confirmProcess => 'Confirm';

  @override
  String get luggageInfoLabel => 'Luggage Info';

  @override
  String get tagNo => 'Tag No.';

  @override
  String get flightNoLabel => 'Flight';

  @override
  String get passenger => 'Passenger';

  @override
  String get overweightFee => 'Overweight Fee';

  @override
  String get autoCalc => 'Auto Calculate';

  @override
  String get additionalFee => 'Additional Fee Due';

  @override
  String get overweightNote =>
      'Fee will be auto-calculated. Passenger will be notified after confirmation.';

  @override
  String get passengerContact => 'Passenger Contact / Claim';

  @override
  String get passengerInfo => 'Passenger Info';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get callRecord => 'Call Log';

  @override
  String get calling => 'Calling...';

  @override
  String get callPhone => 'Call';

  @override
  String get sendSms => 'Send SMS';

  @override
  String get claimConfirm => 'Confirm Claim';

  @override
  String get confirmClaimNote =>
      'Verify passenger identity and tap below to complete the claim.';

  @override
  String get confirmClaim => 'Confirm Claim';

  @override
  String get claimSuccess => 'Claim successful';

  @override
  String get scanOperation => 'Scan Operation';

  @override
  String get scanOperationGuide =>
      'Tap Scan at the bottom nav to enter scan mode. Point at luggage QR code to scan. After successful scan, you\'ll be redirected to the luggage detail page.';

  @override
  String get luggageListGuide =>
      'Tap Luggage at the bottom nav to view the luggage list. Use the search bar to search by tag number or passenger name, or use the filter button to filter by status.';

  @override
  String get damageRegistrationGuide =>
      'When you find damaged luggage, tap \'Register Damage\' on the scan result page or luggage detail page. Upload damage photos and submit. The system will generate a damage record and notify relevant staff.';

  @override
  String get overweightGuide =>
      'When an overweight luggage item appears in To-Do, tap it to enter the overweight handling page. Verify weight, choose payment method (cash/e-payment), then update status.';

  @override
  String get contactPassengerGuide =>
      'When an unclaimed luggage item appears in To-Do, tap it to enter the contact passenger page. System shows passenger contact info. Tap call to dial directly. Update status to \'Delivered\' after successful contact.';

  @override
  String get submitFeedbackGuide =>
      'If you have issues or suggestions, submit feedback at \'Me → Help & Support → Feedback\'. We value every piece of feedback.';

  @override
  String get themeLanguageGuide =>
      'Switch between Light/Dark/System theme at \'Me → System Settings → Theme Settings\'. Change language at \'Language Settings\'. Settings are saved automatically.';

  @override
  String get notificationGuide =>
      'The app pushes notifications for To-Do items including overweight luggage, unclaimed luggage, and damage registration. Enable or disable each notification type at \'System Settings → Notification Settings\'.';

  @override
  String get usageHelpTitle => 'User Guide';

  @override
  String loadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get todoTitle => 'To-Do';

  @override
  String get reload => 'Reload';

  @override
  String get noTodoItems => 'No To-Do items';

  @override
  String get abnormalLuggage => 'Abnormal luggage requiring action';

  @override
  String luggageNotFound(String tag) {
    return 'Luggage not found: $tag';
  }

  @override
  String loadLuggageFailed(String error) {
    return 'Failed to load luggage: $error';
  }

  @override
  String get qrCodeNoLuggageId =>
      'QR code contains no luggage ID (requires JSON/link param \'luggageId\', or text containing \'baggage number\')';

  @override
  String getLuggageFailed(String error) {
    return 'Failed to get luggage info: $error';
  }

  @override
  String get cannotSyncMissingNo => 'Cannot sync: missing baggage number';

  @override
  String get statusUpdatedArrived => 'Status updated to Arrived (synced)';

  @override
  String updateStatusFailed(String error) {
    return 'Failed to update status: $error';
  }

  @override
  String get scan => 'Scan';

  @override
  String get toggleFlash => 'Toggle Flash';

  @override
  String get switchCamera => 'Switch Camera';

  @override
  String get processing => 'Processing...';

  @override
  String get alignQRCode => 'Align QR code to scan';

  @override
  String identified(String content) {
    return 'Identified: $content';
  }

  @override
  String get scanTip => 'Tip: Options will appear after scanning.';

  @override
  String get evidenceQueryTitle => 'Evidence Query';

  @override
  String get searchBaggageNo => 'Search bag no., location, description...';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get clearDateFilter => 'Clear date filter';

  @override
  String totalRecords(int count) {
    return '$count records';
  }

  @override
  String get noMatchingRecords => 'No matching records found';

  @override
  String get noEvidenceRecords => 'No damage evidence records';

  @override
  String get scanDamagedSubmit => 'Scan damaged luggage and submit a report';

  @override
  String get enableLocationService =>
      'Enable Location Services and retry, or tap the location icon';

  @override
  String get enableGpsHint =>
      'Cannot get location: Enable GPS or go outdoors, then tap \'Relocate\'';

  @override
  String get selectImageSource => 'Select image source';

  @override
  String get imageSelectFailed => 'Image selection failed';

  @override
  String get selectOneImage => 'Please select one image';

  @override
  String get noLocationHint =>
      'No location: Enable GPS or go outdoors. Tap \'Relocate\' or the button below to retry.';

  @override
  String get damageReportSuccess =>
      'Report submitted, luggage status updated to Damaged';

  @override
  String submitReportFailed(String error) {
    return 'Report submission failed: $error';
  }

  @override
  String networkError(String stage, String error) {
    return '[$stage] Network error: $error';
  }

  @override
  String serverNotConnected(String stage, String body) {
    return '[$stage] Cannot connect to server (HTTP 0): $body';
  }

  @override
  String apiNotFound(String stage) {
    return '[$stage] API not found (404): Check if backend is deployed';
  }

  @override
  String authFailed(String stage, String status) {
    return '[$stage] Auth failed ($status): Check backend permissions';
  }

  @override
  String unknownError(String stage) {
    return '[$stage] Unknown error';
  }

  @override
  String get detail => 'Details';

  @override
  String get baggageNotExist => 'Baggage number does not exist in the system';

  @override
  String get duplicateReport =>
      'Damage report already exists for this baggage (duplicate submission)';

  @override
  String get hashCheckFailed => 'Hash verification failed';

  @override
  String stageDetail(String stage) {
    return '[$stage] Details';
  }

  @override
  String get stage => 'Stage';

  @override
  String get httpStatusCode => 'HTTP Status';

  @override
  String get exceptionInfo => 'Exception';

  @override
  String get responseBody => 'Response';

  @override
  String get close => 'Close';

  @override
  String get damageReportTitle => 'Luggage Damage Report';

  @override
  String get reloadLocation => 'Relocate';

  @override
  String get tapSelectPhoto => 'Tap to select damage photo';

  @override
  String get luggageId => 'Luggage ID';

  @override
  String get enterLuggageId => 'Enter luggage ID';

  @override
  String get damageDescription => 'Damage Description';

  @override
  String get enterDamageDesc => 'Describe the damage';

  @override
  String locationCoords(String lat, String lng) {
    return 'Location: $lat, $lng';
  }

  @override
  String get noLocationYet =>
      'No location yet. Enable GPS; the app will retry on submit, or tap \'Get Location\'.';

  @override
  String get getLocation => 'Get Location';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get statusCheckIn => 'Checked In';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusArrived => 'Arrived';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusDamaged => 'Damaged';

  @override
  String get statusLost => 'Lost';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String getLuggageListFailed(int code) {
    return 'Failed to get luggage list ($code)';
  }

  @override
  String get missingId => 'Missing luggage identifier';

  @override
  String luggageNotFoundById(String key) {
    return 'Luggage not found (tried by ID and tag): $key';
  }

  @override
  String queryLuggageFailed(int code) {
    return 'Query failed ($code)';
  }

  @override
  String luggageNotFoundByNo(String id) {
    return 'Luggage not found: $id';
  }

  @override
  String updateLuggageFailed(int code) {
    return 'Update failed ($code)';
  }

  @override
  String uploadLuggageFailed(int code) {
    return 'Upload failed ($code)';
  }

  @override
  String addLuggageFailed(int code) {
    return 'Add failed ($code)';
  }

  @override
  String requestFailed(int code) {
    return 'Request failed (HTTP $code)';
  }

  @override
  String get requestTimeout => 'Request timeout, check your network';

  @override
  String get loginFailed => 'Login failed, please retry';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get wrongPassword => 'Incorrect username or password';

  @override
  String get registerFailed => 'Registration failed, please retry';

  @override
  String get registerSuccess =>
      'Registration successful. Please log in with your username and password.';

  @override
  String get usernamePasswordEmpty => 'Username or password cannot be empty';

  @override
  String get employeeIdNotExist =>
      'Employee ID does not exist or not registered in the system';

  @override
  String get employeeIdAlreadyRegistered =>
      'This employee ID is already registered';

  @override
  String get usernameTaken => 'Username is taken';

  @override
  String get logoutFailed => 'Logout failed, please retry';

  @override
  String get logoutSuccess => 'Logged out';

  @override
  String get logoutFailedNoEmployeeId =>
      'Employee ID does not exist, cannot logout from server';

  @override
  String networkErrorPrefix(String error) {
    return 'Network error: $error';
  }

  @override
  String unsupportedHttpMethod(String method) {
    return 'Unsupported HTTP method: $method';
  }

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get getLocationFailed => 'Failed to get location, please retry';

  @override
  String get evidenceRequestTimeout => 'Request timeout';

  @override
  String getDataFailed(int code) {
    return 'Failed to get data ($code)';
  }

  @override
  String get verifyRequestTimeout => 'Verification request timeout';

  @override
  String initFailed(String error) {
    return 'Init failed: $error';
  }

  @override
  String loginError(String error) {
    return 'Login failed: $error';
  }

  @override
  String registerError(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get cameraPermission => 'Camera';

  @override
  String get cameraPermissionDesc =>
      'Used for taking photos and scanning QR codes';

  @override
  String get albumPermission => 'Photo Album';

  @override
  String get albumPermissionDesc => 'Used for selecting photos from album';

  @override
  String get locationPermission => 'Location';

  @override
  String get locationPermissionDesc => 'Used for getting current location';

  @override
  String get phonePermission => 'Phone';

  @override
  String get phonePermissionDesc => 'Used for making calls';

  @override
  String get needCameraPermission =>
      'Camera permission required for this feature';

  @override
  String get needAlbumPermission =>
      'Album permission required to select photos';

  @override
  String get needLocationPermission =>
      'Location permission required to get current location';

  @override
  String get needPhonePermission => 'Phone permission required to make calls';

  @override
  String get cameraPermanentlyDenied =>
      'Camera permission permanently denied. Please enable in system settings.';

  @override
  String get albumPermanentlyDenied =>
      'Album permission permanently denied. Please enable in system settings.';

  @override
  String get locationPermanentlyDenied =>
      'Location permission permanently denied. Please enable in system settings.';

  @override
  String get phonePermanentlyDenied =>
      'Phone permission permanently denied. Please enable in system settings.';

  @override
  String needPermission(String permission, String desc) {
    return '$permission permission required: $desc';
  }

  @override
  String get search => 'Search...';

  @override
  String get allOption => 'All';

  @override
  String get searchLuggageTagHint => 'Search luggage tag, flight...';

  @override
  String get noLuggage => 'No luggage';

  @override
  String get scanOrAddLuggage => 'Scan or add luggage';

  @override
  String get noSearchResults => 'No results found';

  @override
  String noLuggageWithKeyword(String keyword) {
    return 'No luggage containing \"$keyword\"';
  }

  @override
  String get tryOtherCondition => 'Try changing search criteria';

  @override
  String get networkFailed => 'Network connection failed';

  @override
  String get checkNetworkRetry => 'Check your network settings and retry';

  @override
  String get loadFailedRetry => 'Failed to load, please retry';

  @override
  String get retry => 'Retry';

  @override
  String get scanSuccess => 'Scan successful';

  @override
  String get selectOperation => 'Select operation';

  @override
  String get baggageNoLabel => 'Baggage No.';

  @override
  String get passengerLabel => 'Passenger';

  @override
  String get weightLabel => 'Weight';

  @override
  String get confirmArrived => 'Confirm Arrived';

  @override
  String get handleOverweight => 'Handle Overweight';

  @override
  String get contactPassenger => 'Contact Passenger';

  @override
  String get flight => 'Flight';

  @override
  String get weight => 'Weight';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String deleteConfirmMsg(String item) {
    return 'Delete \"$item\"? This cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get operationSuccess => 'Operation successful';

  @override
  String get gotIt => 'Got It';

  @override
  String permissionRequest(String name) {
    return '$name Permission Request';
  }

  @override
  String get authorizePrompt => 'Authorize this permission?';

  @override
  String get noPlaceFound => 'No matching places found';

  @override
  String get searchFailedCheckNetwork => 'Search failed, check your network';

  @override
  String get searchLocation => 'Search place name...';

  @override
  String get searchLocationHint => 'Search place, address...';

  @override
  String get login => 'Login';

  @override
  String get userLogin => 'User Login';

  @override
  String get loginHint => 'Log in with your username and password';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get noAccount => 'No employee account?';

  @override
  String get goToRegister => 'Register / Activate Account';

  @override
  String get loginFail => 'Login failed';

  @override
  String get registerFail => 'Registration failed';

  @override
  String get registerTitle => 'Employee Account Registration / Activation';

  @override
  String get registerHint =>
      'Employee ID must be pre-registered by the airline. Fill in ID and account info to activate.';

  @override
  String get employeeIdLabel => 'Employee ID';

  @override
  String get enterEmployeeId => 'Enter employee ID';

  @override
  String get enterEmployeeIdAgain => 'Enter employee ID';

  @override
  String get employeeIdFormatWrong => 'Invalid employee ID format';

  @override
  String get usernameLabel => 'Username';

  @override
  String get enterUsernameLabel => 'Enter username';

  @override
  String get enterUsernameLabelAgain => 'Enter username';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters';

  @override
  String get enterPasswordLabel => 'Enter password (min 6 characters)';

  @override
  String get enterPasswordAgain => 'Enter password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterConfirmPassword => 'Re-enter password';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get register => 'Register';

  @override
  String get hasAccount => 'Have an account?';

  @override
  String get loginNow => 'Log in now';
}
