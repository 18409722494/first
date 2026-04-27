import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'行李管理系统'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'行李管理工作台'**
  String get homeTitle;

  /// No description provided for @searchLuggage.
  ///
  /// In zh, this message translates to:
  /// **'查询行李'**
  String get searchLuggage;

  /// No description provided for @scanQRCode.
  ///
  /// In zh, this message translates to:
  /// **'扫描行李二维码'**
  String get scanQRCode;

  /// No description provided for @welcomeBack.
  ///
  /// In zh, this message translates to:
  /// **'欢迎回来，航司工作人员'**
  String get welcomeBack;

  /// No description provided for @employee.
  ///
  /// In zh, this message translates to:
  /// **'员工'**
  String get employee;

  /// No description provided for @quickActions.
  ///
  /// In zh, this message translates to:
  /// **'快捷操作'**
  String get quickActions;

  /// No description provided for @scanProcess.
  ///
  /// In zh, this message translates to:
  /// **'扫码处理'**
  String get scanProcess;

  /// No description provided for @scanProcessDesc.
  ///
  /// In zh, this message translates to:
  /// **'扫描行李二维码'**
  String get scanProcessDesc;

  /// No description provided for @searchLuggageDesc.
  ///
  /// In zh, this message translates to:
  /// **'搜索行李信息'**
  String get searchLuggageDesc;

  /// No description provided for @damageRegistration.
  ///
  /// In zh, this message translates to:
  /// **'破损登记'**
  String get damageRegistration;

  /// No description provided for @damageRegistrationDesc.
  ///
  /// In zh, this message translates to:
  /// **'登记破损行李'**
  String get damageRegistrationDesc;

  /// No description provided for @evidenceQuery.
  ///
  /// In zh, this message translates to:
  /// **'证据查询'**
  String get evidenceQuery;

  /// No description provided for @evidenceQueryDesc.
  ///
  /// In zh, this message translates to:
  /// **'查询破损证据'**
  String get evidenceQueryDesc;

  /// No description provided for @homeTab.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homeTab;

  /// No description provided for @luggageTab.
  ///
  /// In zh, this message translates to:
  /// **'行李'**
  String get luggageTab;

  /// No description provided for @todoTab.
  ///
  /// In zh, this message translates to:
  /// **'待办'**
  String get todoTab;

  /// No description provided for @myTab.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get myTab;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'员工中心'**
  String get profileTitle;

  /// No description provided for @accountInfo.
  ///
  /// In zh, this message translates to:
  /// **'账户信息'**
  String get accountInfo;

  /// No description provided for @accountSecurity.
  ///
  /// In zh, this message translates to:
  /// **'账户安全'**
  String get accountSecurity;

  /// No description provided for @personalization.
  ///
  /// In zh, this message translates to:
  /// **'个性化设置'**
  String get personalization;

  /// No description provided for @systemSettings.
  ///
  /// In zh, this message translates to:
  /// **'系统设置'**
  String get systemSettings;

  /// No description provided for @quickFunctions.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get quickFunctions;

  /// No description provided for @helpSupport.
  ///
  /// In zh, this message translates to:
  /// **'帮助与支持'**
  String get helpSupport;

  /// No description provided for @confirmLogout.
  ///
  /// In zh, this message translates to:
  /// **'确认退出'**
  String get confirmLogout;

  /// No description provided for @logoutConfirmMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出登录吗？'**
  String get logoutConfirmMsg;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get logout;

  /// No description provided for @logoutBtn.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logoutBtn;

  /// No description provided for @employeeId.
  ///
  /// In zh, this message translates to:
  /// **'员工工号'**
  String get employeeId;

  /// No description provided for @workEmail.
  ///
  /// In zh, this message translates to:
  /// **'工作邮箱'**
  String get workEmail;

  /// No description provided for @notSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet;

  /// No description provided for @employeeName.
  ///
  /// In zh, this message translates to:
  /// **'员工姓名'**
  String get employeeName;

  /// No description provided for @unknownUser.
  ///
  /// In zh, this message translates to:
  /// **'未知用户'**
  String get unknownUser;

  /// No description provided for @accountInfoNote.
  ///
  /// In zh, this message translates to:
  /// **'账户信息说明'**
  String get accountInfoNote;

  /// No description provided for @accountInfoNoteContent.
  ///
  /// In zh, this message translates to:
  /// **'• 员工工号是您在系统中的唯一标识\n• 您可以在此修改个人相关信息'**
  String get accountInfoNoteContent;

  /// No description provided for @changePassword.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In zh, this message translates to:
  /// **'旧密码'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In zh, this message translates to:
  /// **'新密码'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In zh, this message translates to:
  /// **'确认新密码'**
  String get confirmNewPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致'**
  String get passwordMismatch;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密码修改成功'**
  String get passwordChangedSuccess;

  /// No description provided for @bindPhone.
  ///
  /// In zh, this message translates to:
  /// **'绑定手机'**
  String get bindPhone;

  /// No description provided for @phoneNumber.
  ///
  /// In zh, this message translates to:
  /// **'手机号码'**
  String get phoneNumber;

  /// No description provided for @verifyCode.
  ///
  /// In zh, this message translates to:
  /// **'验证码'**
  String get verifyCode;

  /// No description provided for @verifyCodeSent.
  ///
  /// In zh, this message translates to:
  /// **'验证码已发送'**
  String get verifyCodeSent;

  /// No description provided for @getVerifyCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get getVerifyCode;

  /// No description provided for @fillAllFields.
  ///
  /// In zh, this message translates to:
  /// **'请填写完整信息'**
  String get fillAllFields;

  /// No description provided for @phoneBindSuccess.
  ///
  /// In zh, this message translates to:
  /// **'手机绑定成功'**
  String get phoneBindSuccess;

  /// No description provided for @accountSecurityTitle.
  ///
  /// In zh, this message translates to:
  /// **'账户安全'**
  String get accountSecurityTitle;

  /// No description provided for @passwordChange.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get passwordChange;

  /// No description provided for @phoneBind.
  ///
  /// In zh, this message translates to:
  /// **'绑定手机'**
  String get phoneBind;

  /// No description provided for @notBound.
  ///
  /// In zh, this message translates to:
  /// **'未绑定'**
  String get notBound;

  /// No description provided for @twoFactorAuth.
  ///
  /// In zh, this message translates to:
  /// **'两步验证'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorEnabled.
  ///
  /// In zh, this message translates to:
  /// **'两步验证已开启'**
  String get twoFactorEnabled;

  /// No description provided for @securityTips.
  ///
  /// In zh, this message translates to:
  /// **'安全提示'**
  String get securityTips;

  /// No description provided for @securityTipsContent.
  ///
  /// In zh, this message translates to:
  /// **'• 请定期修改密码，使用强密码\n• 绑定手机可以提高账户安全性\n• 开启两步验证可以防止账户被非法登录'**
  String get securityTipsContent;

  /// No description provided for @changeAvatar.
  ///
  /// In zh, this message translates to:
  /// **'修改头像'**
  String get changeAvatar;

  /// No description provided for @selectAvatarSource.
  ///
  /// In zh, this message translates to:
  /// **'请选择头像来源'**
  String get selectAvatarSource;

  /// No description provided for @avatarSelected.
  ///
  /// In zh, this message translates to:
  /// **'头像选择成功: {name}'**
  String avatarSelected(String name);

  /// No description provided for @avatarCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消选择'**
  String get avatarCancelled;

  /// No description provided for @album.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get album;

  /// No description provided for @camera.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get camera;

  /// No description provided for @avatarCaptureSuccess.
  ///
  /// In zh, this message translates to:
  /// **'头像拍摄成功: {name}'**
  String avatarCaptureSuccess(String name);

  /// No description provided for @changeNickname.
  ///
  /// In zh, this message translates to:
  /// **'修改昵称'**
  String get changeNickname;

  /// No description provided for @newNickname.
  ///
  /// In zh, this message translates to:
  /// **'新昵称'**
  String get newNickname;

  /// No description provided for @nicknameEmpty.
  ///
  /// In zh, this message translates to:
  /// **'昵称不能为空'**
  String get nicknameEmpty;

  /// No description provided for @nicknameChangedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'昵称修改成功'**
  String get nicknameChangedSuccess;

  /// No description provided for @personalizationTitle.
  ///
  /// In zh, this message translates to:
  /// **'个性化设置'**
  String get personalizationTitle;

  /// No description provided for @personalizationNote.
  ///
  /// In zh, this message translates to:
  /// **'个性化设置说明'**
  String get personalizationNote;

  /// No description provided for @personalizationNoteContent.
  ///
  /// In zh, this message translates to:
  /// **'• 修改头像可以让您的个人资料更加个性化\n• 修改昵称可以更改您在系统中的显示名称\n• 这些设置仅影响您的个人资料显示，不会影响您的账户安全'**
  String get personalizationNoteContent;

  /// No description provided for @languageSettings.
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get languageSettings;

  /// No description provided for @themeSettings.
  ///
  /// In zh, this message translates to:
  /// **'主题设置'**
  String get themeSettings;

  /// No description provided for @lightMode.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get systemMode;

  /// No description provided for @clearCache.
  ///
  /// In zh, this message translates to:
  /// **'清理缓存'**
  String get clearCache;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清理应用缓存吗？这将删除应用的临时数据，但不会影响您的个人数据。'**
  String get clearCacheConfirm;

  /// No description provided for @cacheClearedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'缓存清理成功'**
  String get cacheClearedSuccess;

  /// No description provided for @notificationSettings.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// No description provided for @luggageStatusUpdate.
  ///
  /// In zh, this message translates to:
  /// **'行李状态更新'**
  String get luggageStatusUpdate;

  /// No description provided for @systemNotification.
  ///
  /// In zh, this message translates to:
  /// **'系统通知'**
  String get systemNotification;

  /// No description provided for @abnormalAlert.
  ///
  /// In zh, this message translates to:
  /// **'异常提醒'**
  String get abnormalAlert;

  /// No description provided for @systemSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'系统设置'**
  String get systemSettingsTitle;

  /// No description provided for @systemSettingsNote.
  ///
  /// In zh, this message translates to:
  /// **'系统设置说明'**
  String get systemSettingsNote;

  /// No description provided for @systemSettingsNoteContent.
  ///
  /// In zh, this message translates to:
  /// **'• 通知设置可以控制应用的通知类型\n• 语言设置可以更改应用的显示语言\n• 主题设置可以切换深色/浅色模式\n• 清理缓存可以释放应用占用的存储空间'**
  String get systemSettingsNoteContent;

  /// No description provided for @simplifiedChinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @feedback.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedback;

  /// No description provided for @feedbackHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的意见或建议'**
  String get feedbackHint;

  /// No description provided for @feedbackEmpty.
  ///
  /// In zh, this message translates to:
  /// **'请输入反馈内容'**
  String get feedbackEmpty;

  /// No description provided for @feedbackSuccess.
  ///
  /// In zh, this message translates to:
  /// **'反馈提交成功，感谢您的建议'**
  String get feedbackSuccess;

  /// No description provided for @submit.
  ///
  /// In zh, this message translates to:
  /// **'提交'**
  String get submit;

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'行李管理系统'**
  String get appName;

  /// No description provided for @appDesc.
  ///
  /// In zh, this message translates to:
  /// **'行李管理系统是一款专为航空地勤人员设计的行李追踪和管理工具。'**
  String get appDesc;

  /// No description provided for @copyright.
  ///
  /// In zh, this message translates to:
  /// **'© 2026 行李管理系统 版权所有'**
  String get copyright;

  /// No description provided for @contactUsEnabled.
  ///
  /// In zh, this message translates to:
  /// **'联系我们功能已启用'**
  String get contactUsEnabled;

  /// No description provided for @helpSupportTitle.
  ///
  /// In zh, this message translates to:
  /// **'帮助与支持'**
  String get helpSupportTitle;

  /// No description provided for @usageHelp.
  ///
  /// In zh, this message translates to:
  /// **'使用帮助'**
  String get usageHelp;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @contactUs.
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get contactUs;

  /// No description provided for @contactPhone.
  ///
  /// In zh, this message translates to:
  /// **'400-123-4567'**
  String get contactPhone;

  /// No description provided for @helpSupportNote.
  ///
  /// In zh, this message translates to:
  /// **'帮助与支持说明'**
  String get helpSupportNote;

  /// No description provided for @helpSupportNoteContent.
  ///
  /// In zh, this message translates to:
  /// **'• 使用帮助：查看应用的使用指南和常见问题\n• 意见反馈：提交您对应用的意见和建议\n• 关于：查看应用的版本信息和版权声明\n• 联系我们：获取客服支持'**
  String get helpSupportNoteContent;

  /// No description provided for @quickScanEnabled.
  ///
  /// In zh, this message translates to:
  /// **'快速扫描功能已启用'**
  String get quickScanEnabled;

  /// No description provided for @quickFunctionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get quickFunctionsTitle;

  /// No description provided for @luggageMap.
  ///
  /// In zh, this message translates to:
  /// **'行李地图'**
  String get luggageMap;

  /// No description provided for @luggageMapDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看行李位置分布'**
  String get luggageMapDesc;

  /// No description provided for @quickScan.
  ///
  /// In zh, this message translates to:
  /// **'快速扫描'**
  String get quickScan;

  /// No description provided for @quickScanDesc.
  ///
  /// In zh, this message translates to:
  /// **'直接进入扫描界面'**
  String get quickScanDesc;

  /// No description provided for @quickFunctionsNote.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能说明'**
  String get quickFunctionsNote;

  /// No description provided for @quickFunctionsNoteContent.
  ///
  /// In zh, this message translates to:
  /// **'• 行李地图：查看行李的实时位置分布\n• 快速扫描：直接进入二维码扫描界面，方便快速处理行李'**
  String get quickFunctionsNoteContent;

  /// No description provided for @queryLuggage.
  ///
  /// In zh, this message translates to:
  /// **'查询行李'**
  String get queryLuggage;

  /// No description provided for @searchLuggageHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索行李'**
  String get searchLuggageHint;

  /// No description provided for @searchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'标签号、航班号、乘客姓名或目的地'**
  String get searchPlaceholder;

  /// No description provided for @scanBarcode.
  ///
  /// In zh, this message translates to:
  /// **'扫描条形码'**
  String get scanBarcode;

  /// No description provided for @statusFilter.
  ///
  /// In zh, this message translates to:
  /// **'状态过滤'**
  String get statusFilter;

  /// No description provided for @allStatuses.
  ///
  /// In zh, this message translates to:
  /// **'全部状态'**
  String get allStatuses;

  /// No description provided for @executeSearch.
  ///
  /// In zh, this message translates to:
  /// **'执行搜索'**
  String get executeSearch;

  /// No description provided for @enterSearchCondition.
  ///
  /// In zh, this message translates to:
  /// **'请输入搜索条件并点击搜索按钮'**
  String get enterSearchCondition;

  /// No description provided for @luggageTagNo.
  ///
  /// In zh, this message translates to:
  /// **'行李标签号: {tag}'**
  String luggageTagNo(String tag);

  /// No description provided for @remark.
  ///
  /// In zh, this message translates to:
  /// **'备注: {note}'**
  String remark(String note);

  /// No description provided for @filterConditions.
  ///
  /// In zh, this message translates to:
  /// **'筛选条件'**
  String get filterConditions;

  /// No description provided for @clearFilter.
  ///
  /// In zh, this message translates to:
  /// **'清除筛选'**
  String get clearFilter;

  /// No description provided for @status.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get status;

  /// No description provided for @all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @checkIn.
  ///
  /// In zh, this message translates to:
  /// **'已办理托运'**
  String get checkIn;

  /// No description provided for @inTransit.
  ///
  /// In zh, this message translates to:
  /// **'运输中'**
  String get inTransit;

  /// No description provided for @arrived.
  ///
  /// In zh, this message translates to:
  /// **'已到达'**
  String get arrived;

  /// No description provided for @delivered.
  ///
  /// In zh, this message translates to:
  /// **'已交付'**
  String get delivered;

  /// No description provided for @damaged.
  ///
  /// In zh, this message translates to:
  /// **'已损坏'**
  String get damaged;

  /// No description provided for @lost.
  ///
  /// In zh, this message translates to:
  /// **'已丢失'**
  String get lost;

  /// No description provided for @unknownStatus.
  ///
  /// In zh, this message translates to:
  /// **'未知状态'**
  String get unknownStatus;

  /// No description provided for @changeStatus.
  ///
  /// In zh, this message translates to:
  /// **'修改状态'**
  String get changeStatus;

  /// No description provided for @markDamaged.
  ///
  /// In zh, this message translates to:
  /// **'标记破损'**
  String get markDamaged;

  /// No description provided for @viewHistoryLog.
  ///
  /// In zh, this message translates to:
  /// **'查看历史日志'**
  String get viewHistoryLog;

  /// No description provided for @luggageManagement.
  ///
  /// In zh, this message translates to:
  /// **'行李管理'**
  String get luggageManagement;

  /// No description provided for @filter.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @searchLuggageTag.
  ///
  /// In zh, this message translates to:
  /// **'搜索行李标签、所有者、位置...'**
  String get searchLuggageTag;

  /// No description provided for @totalLuggage.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 个行李'**
  String totalLuggage(int count);

  /// No description provided for @loadMore.
  ///
  /// In zh, this message translates to:
  /// **'（下拉加载更多）'**
  String get loadMore;

  /// No description provided for @allLoaded.
  ///
  /// In zh, this message translates to:
  /// **'— 已加载全部 {count} 条 —'**
  String allLoaded(int count);

  /// No description provided for @enterLocationFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先输入位置信息'**
  String get enterLocationFirst;

  /// No description provided for @locationSynced.
  ///
  /// In zh, this message translates to:
  /// **'位置与状态已同步到后端'**
  String get locationSynced;

  /// No description provided for @updateLocationFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新行李位置失败({code})'**
  String updateLocationFailed(int code);

  /// No description provided for @unknownLocation.
  ///
  /// In zh, this message translates to:
  /// **'未知位置'**
  String get unknownLocation;

  /// No description provided for @updateSuccess.
  ///
  /// In zh, this message translates to:
  /// **'更新成功'**
  String get updateSuccess;

  /// No description provided for @uploadCreateSuccess.
  ///
  /// In zh, this message translates to:
  /// **'上传/创建成功'**
  String get uploadCreateSuccess;

  /// No description provided for @luggageInfo.
  ///
  /// In zh, this message translates to:
  /// **'行李信息'**
  String get luggageInfo;

  /// No description provided for @basicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get basicInfo;

  /// No description provided for @historyLog.
  ///
  /// In zh, this message translates to:
  /// **'历史日志'**
  String get historyLog;

  /// No description provided for @qrCodeResult.
  ///
  /// In zh, this message translates to:
  /// **'二维码解析结果'**
  String get qrCodeResult;

  /// No description provided for @luggageDetail.
  ///
  /// In zh, this message translates to:
  /// **'行李详情'**
  String get luggageDetail;

  /// No description provided for @location.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get location;

  /// No description provided for @note.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get note;

  /// No description provided for @update.
  ///
  /// In zh, this message translates to:
  /// **'更新(PUT)'**
  String get update;

  /// No description provided for @uploadCreate.
  ///
  /// In zh, this message translates to:
  /// **'上传/创建(POST)'**
  String get uploadCreate;

  /// No description provided for @viewOnMap.
  ///
  /// In zh, this message translates to:
  /// **'在地图上查看'**
  String get viewOnMap;

  /// No description provided for @updateLocationBackend.
  ///
  /// In zh, this message translates to:
  /// **'更新位置到后端'**
  String get updateLocationBackend;

  /// No description provided for @operationHistoryLog.
  ///
  /// In zh, this message translates to:
  /// **'操作历史日志'**
  String get operationHistoryLog;

  /// No description provided for @operator.
  ///
  /// In zh, this message translates to:
  /// **'操作人: {name}'**
  String operator(String name);

  /// No description provided for @evidenceDetail.
  ///
  /// In zh, this message translates to:
  /// **'证据详情'**
  String get evidenceDetail;

  /// No description provided for @copyHashValue.
  ///
  /// In zh, this message translates to:
  /// **'复制哈希值'**
  String get copyHashValue;

  /// No description provided for @baggageNo.
  ///
  /// In zh, this message translates to:
  /// **'行李号: {no}'**
  String baggageNo(String no);

  /// No description provided for @damagedBaggage.
  ///
  /// In zh, this message translates to:
  /// **'破损行李'**
  String get damagedBaggage;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// No description provided for @imageLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片加载失败'**
  String get imageLoadFailed;

  /// No description provided for @recordTime.
  ///
  /// In zh, this message translates to:
  /// **'记录时间'**
  String get recordTime;

  /// No description provided for @recordLocation.
  ///
  /// In zh, this message translates to:
  /// **'记录地点'**
  String get recordLocation;

  /// No description provided for @hashValue.
  ///
  /// In zh, this message translates to:
  /// **'哈希值'**
  String get hashValue;

  /// No description provided for @damageDesc.
  ///
  /// In zh, this message translates to:
  /// **'破损描述'**
  String get damageDesc;

  /// No description provided for @hashVerification.
  ///
  /// In zh, this message translates to:
  /// **'证据哈希验证'**
  String get hashVerification;

  /// No description provided for @hashVerificationNote.
  ///
  /// In zh, this message translates to:
  /// **'哈希值用于验证图片证据的完整性和真实性'**
  String get hashVerificationNote;

  /// No description provided for @hashVerified.
  ///
  /// In zh, this message translates to:
  /// **'哈希验证通过：证据未被篡改'**
  String get hashVerified;

  /// No description provided for @hashFailed.
  ///
  /// In zh, this message translates to:
  /// **'哈希验证失败：证据可能被修改'**
  String get hashFailed;

  /// No description provided for @verifyHash.
  ///
  /// In zh, this message translates to:
  /// **'验证哈希'**
  String get verifyHash;

  /// No description provided for @noImageToVerify.
  ///
  /// In zh, this message translates to:
  /// **'无图片可验证'**
  String get noImageToVerify;

  /// No description provided for @hashVerifySuccess.
  ///
  /// In zh, this message translates to:
  /// **'哈希验证成功，证据未被篡改'**
  String get hashVerifySuccess;

  /// No description provided for @verifyFailed.
  ///
  /// In zh, this message translates to:
  /// **'验证失败: {error}'**
  String verifyFailed(String error);

  /// No description provided for @hashCopied.
  ///
  /// In zh, this message translates to:
  /// **'哈希值已复制到剪贴板'**
  String get hashCopied;

  /// No description provided for @maxPhotosHint.
  ///
  /// In zh, this message translates to:
  /// **'最多只能上传3张照片'**
  String get maxPhotosHint;

  /// No description provided for @photoUploadSuccess.
  ///
  /// In zh, this message translates to:
  /// **'照片上传成功'**
  String get photoUploadSuccess;

  /// No description provided for @uploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'上传失败: {error}'**
  String uploadFailed(String error);

  /// No description provided for @hint.
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get hint;

  /// No description provided for @noPhotoHint.
  ///
  /// In zh, this message translates to:
  /// **'您还没有上传行李照片，这是定责的重要依据。确定要继续吗？'**
  String get noPhotoHint;

  /// No description provided for @continueAction.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get continueAction;

  /// No description provided for @addLuggageSuccess.
  ///
  /// In zh, this message translates to:
  /// **'行李信息添加成功！'**
  String get addLuggageSuccess;

  /// No description provided for @addFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加失败: {error}'**
  String addFailed(String error);

  /// No description provided for @addLuggageInfo.
  ///
  /// In zh, this message translates to:
  /// **'添加行李信息'**
  String get addLuggageInfo;

  /// No description provided for @luggageTagNoLabel.
  ///
  /// In zh, this message translates to:
  /// **'行李标签号'**
  String get luggageTagNoLabel;

  /// No description provided for @enterLuggageTagNo.
  ///
  /// In zh, this message translates to:
  /// **'请输入行李标签号'**
  String get enterLuggageTagNo;

  /// No description provided for @flightNo.
  ///
  /// In zh, this message translates to:
  /// **'航班号'**
  String get flightNo;

  /// No description provided for @enterFlightNo.
  ///
  /// In zh, this message translates to:
  /// **'请输入航班号'**
  String get enterFlightNo;

  /// No description provided for @passengerName.
  ///
  /// In zh, this message translates to:
  /// **'乘客姓名'**
  String get passengerName;

  /// No description provided for @enterPassengerName.
  ///
  /// In zh, this message translates to:
  /// **'请输入乘客姓名'**
  String get enterPassengerName;

  /// No description provided for @luggageWeight.
  ///
  /// In zh, this message translates to:
  /// **'行李重量 (kg)'**
  String get luggageWeight;

  /// No description provided for @enterWeight.
  ///
  /// In zh, this message translates to:
  /// **'请输入行李重量'**
  String get enterWeight;

  /// No description provided for @invalidWeight.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的重量'**
  String get invalidWeight;

  /// No description provided for @destination.
  ///
  /// In zh, this message translates to:
  /// **'目的地'**
  String get destination;

  /// No description provided for @enterDestination.
  ///
  /// In zh, this message translates to:
  /// **'请输入目的地'**
  String get enterDestination;

  /// No description provided for @luggageStatus.
  ///
  /// In zh, this message translates to:
  /// **'行李状态'**
  String get luggageStatus;

  /// No description provided for @remarkOptional.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get remarkOptional;

  /// No description provided for @enterRemark.
  ///
  /// In zh, this message translates to:
  /// **'请输入备注信息（可选）'**
  String get enterRemark;

  /// No description provided for @operatorEmployee.
  ///
  /// In zh, this message translates to:
  /// **'操作员工'**
  String get operatorEmployee;

  /// No description provided for @latitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get longitude;

  /// No description provided for @autoLocation.
  ///
  /// In zh, this message translates to:
  /// **'位置信息将自动获取'**
  String get autoLocation;

  /// No description provided for @uploadPhoto.
  ///
  /// In zh, this message translates to:
  /// **'上传照片'**
  String get uploadPhoto;

  /// No description provided for @uploadPhotoHint.
  ///
  /// In zh, this message translates to:
  /// **'请上传行李外观照片，作为定责依据'**
  String get uploadPhotoHint;

  /// No description provided for @tapUploadPhoto.
  ///
  /// In zh, this message translates to:
  /// **'点击上传照片'**
  String get tapUploadPhoto;

  /// No description provided for @max3Photos.
  ///
  /// In zh, this message translates to:
  /// **'最多上传3张'**
  String get max3Photos;

  /// No description provided for @addLuggage.
  ///
  /// In zh, this message translates to:
  /// **'添加行李'**
  String get addLuggage;

  /// No description provided for @processSuccess.
  ///
  /// In zh, this message translates to:
  /// **'处理成功'**
  String get processSuccess;

  /// No description provided for @processFailed.
  ///
  /// In zh, this message translates to:
  /// **'处理失败: {error}'**
  String processFailed(String error);

  /// No description provided for @overweightTitle.
  ///
  /// In zh, this message translates to:
  /// **'超重费用/称重'**
  String get overweightTitle;

  /// No description provided for @weighingInfo.
  ///
  /// In zh, this message translates to:
  /// **'称重信息'**
  String get weighingInfo;

  /// No description provided for @actualWeight.
  ///
  /// In zh, this message translates to:
  /// **'行李重量'**
  String get actualWeight;

  /// No description provided for @enterActualWeight.
  ///
  /// In zh, this message translates to:
  /// **'请输入实际重量'**
  String get enterActualWeight;

  /// No description provided for @feeInfo.
  ///
  /// In zh, this message translates to:
  /// **'费用信息'**
  String get feeInfo;

  /// No description provided for @confirmProcess.
  ///
  /// In zh, this message translates to:
  /// **'确认处理'**
  String get confirmProcess;

  /// No description provided for @luggageInfoLabel.
  ///
  /// In zh, this message translates to:
  /// **'行李信息'**
  String get luggageInfoLabel;

  /// No description provided for @tagNo.
  ///
  /// In zh, this message translates to:
  /// **'标签号'**
  String get tagNo;

  /// No description provided for @flightNoLabel.
  ///
  /// In zh, this message translates to:
  /// **'航班号'**
  String get flightNoLabel;

  /// No description provided for @passenger.
  ///
  /// In zh, this message translates to:
  /// **'乘客'**
  String get passenger;

  /// No description provided for @overweightFee.
  ///
  /// In zh, this message translates to:
  /// **'超重费用'**
  String get overweightFee;

  /// No description provided for @autoCalc.
  ///
  /// In zh, this message translates to:
  /// **'自动计算'**
  String get autoCalc;

  /// No description provided for @additionalFee.
  ///
  /// In zh, this message translates to:
  /// **'需补缴费用'**
  String get additionalFee;

  /// No description provided for @overweightNote.
  ///
  /// In zh, this message translates to:
  /// **'超重费用将自动计算，确认后将通知旅客补缴。'**
  String get overweightNote;

  /// No description provided for @passengerContact.
  ///
  /// In zh, this message translates to:
  /// **'旅客联系/认领'**
  String get passengerContact;

  /// No description provided for @passengerInfo.
  ///
  /// In zh, this message translates to:
  /// **'旅客信息'**
  String get passengerInfo;

  /// No description provided for @name.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get email;

  /// No description provided for @callRecord.
  ///
  /// In zh, this message translates to:
  /// **'通话记录'**
  String get callRecord;

  /// No description provided for @calling.
  ///
  /// In zh, this message translates to:
  /// **'正在拨打...'**
  String get calling;

  /// No description provided for @callPhone.
  ///
  /// In zh, this message translates to:
  /// **'拨打电话'**
  String get callPhone;

  /// No description provided for @sendSms.
  ///
  /// In zh, this message translates to:
  /// **'发送短信'**
  String get sendSms;

  /// No description provided for @claimConfirm.
  ///
  /// In zh, this message translates to:
  /// **'认领确认'**
  String get claimConfirm;

  /// No description provided for @confirmClaimNote.
  ///
  /// In zh, this message translates to:
  /// **'请确认旅客身份后，点击下方按钮完成认领流程。'**
  String get confirmClaimNote;

  /// No description provided for @confirmClaim.
  ///
  /// In zh, this message translates to:
  /// **'确认认领'**
  String get confirmClaim;

  /// No description provided for @claimSuccess.
  ///
  /// In zh, this message translates to:
  /// **'认领成功'**
  String get claimSuccess;

  /// No description provided for @scanOperation.
  ///
  /// In zh, this message translates to:
  /// **'扫码操作'**
  String get scanOperation;

  /// No description provided for @scanOperationGuide.
  ///
  /// In zh, this message translates to:
  /// **'在底部导航栏点击「扫码」进入扫码界面，点击扫描按钮对准行李上的二维码即可识别。识别成功后会自动跳转到行李详情页，您可以在此更新行李位置或状态。'**
  String get scanOperationGuide;

  /// No description provided for @luggageListGuide.
  ///
  /// In zh, this message translates to:
  /// **'在底部导航栏点击「行李」进入行李列表页。您可以通过搜索框按行李标签号或旅客姓名进行搜索，也可以通过筛选按钮按行李状态进行筛选。'**
  String get luggageListGuide;

  /// No description provided for @damageRegistrationGuide.
  ///
  /// In zh, this message translates to:
  /// **'发现行李破损时，在扫码结果页面点击「破损登记」按钮，或在行李详情页点击「登记破损」按钮。上传破损照片并填写描述后提交，系统会自动生成破损记录并通知相关人员。'**
  String get damageRegistrationGuide;

  /// No description provided for @overweightGuide.
  ///
  /// In zh, this message translates to:
  /// **'当待办事项中出现超重行李提示时，点击该条进入超重处理页面。核对行李重量，确认超重后选择收费方式（现金/电子支付），完成后更新行李状态。'**
  String get overweightGuide;

  /// No description provided for @contactPassengerGuide.
  ///
  /// In zh, this message translates to:
  /// **'当待办事项中出现无人认领行李提示时，点击该条进入联系旅客页面。系统会显示旅客的联系方式，点击呼叫按钮可直接拨打电话。联系成功后更新行李状态为「已交付」。'**
  String get contactPassengerGuide;

  /// No description provided for @submitFeedbackGuide.
  ///
  /// In zh, this message translates to:
  /// **'如果您在使用过程中遇到问题或有改进建议，可以在「我的 → 帮助与支持 → 意见反馈」中填写并提交。我们会认真处理每一条反馈。'**
  String get submitFeedbackGuide;

  /// No description provided for @themeLanguageGuide.
  ///
  /// In zh, this message translates to:
  /// **'在「我的 → 系统设置 → 主题设置」中可切换浅色/深色/跟随系统三种模式。在「语言设置」中可切换简体中文或 English。设置会自动保存。'**
  String get themeLanguageGuide;

  /// No description provided for @notificationGuide.
  ///
  /// In zh, this message translates to:
  /// **'应用会在出现待办事项时推送通知，包括超重行李、无人认领行李、破损登记等。在「系统设置 → 通知设置」中可以分别开启或关闭各类型的通知。'**
  String get notificationGuide;

  /// No description provided for @usageHelpTitle.
  ///
  /// In zh, this message translates to:
  /// **'使用帮助'**
  String get usageHelpTitle;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败: {error}'**
  String loadFailed(String error);

  /// No description provided for @todoTitle.
  ///
  /// In zh, this message translates to:
  /// **'待办事项'**
  String get todoTitle;

  /// No description provided for @reload.
  ///
  /// In zh, this message translates to:
  /// **'重新加载'**
  String get reload;

  /// No description provided for @noTodoItems.
  ///
  /// In zh, this message translates to:
  /// **'暂无待办事项'**
  String get noTodoItems;

  /// No description provided for @abnormalLuggage.
  ///
  /// In zh, this message translates to:
  /// **'需要处理的异常行李'**
  String get abnormalLuggage;

  /// No description provided for @luggageNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到行李: {tag}'**
  String luggageNotFound(String tag);

  /// No description provided for @loadLuggageFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载行李失败: {error}'**
  String loadLuggageFailed(String error);

  /// No description provided for @qrCodeNoLuggageId.
  ///
  /// In zh, this message translates to:
  /// **'二维码中未包含行李标识（需 JSON/链接参数 luggageId，或多行文本中的「行李号」「行李编号」）'**
  String get qrCodeNoLuggageId;

  /// No description provided for @getLuggageFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取行李信息失败: {error}'**
  String getLuggageFailed(String error);

  /// No description provided for @cannotSyncMissingNo.
  ///
  /// In zh, this message translates to:
  /// **'无法同步：缺少行李号 baggageNumber'**
  String get cannotSyncMissingNo;

  /// No description provided for @statusUpdatedArrived.
  ///
  /// In zh, this message translates to:
  /// **'状态已更新为：已到达（已同步后端）'**
  String get statusUpdatedArrived;

  /// No description provided for @updateStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新状态失败: {error}'**
  String updateStatusFailed(String error);

  /// No description provided for @scan.
  ///
  /// In zh, this message translates to:
  /// **'扫码'**
  String get scan;

  /// No description provided for @toggleFlash.
  ///
  /// In zh, this message translates to:
  /// **'切换闪光灯'**
  String get toggleFlash;

  /// No description provided for @switchCamera.
  ///
  /// In zh, this message translates to:
  /// **'切换摄像头'**
  String get switchCamera;

  /// No description provided for @processing.
  ///
  /// In zh, this message translates to:
  /// **'正在处理...'**
  String get processing;

  /// No description provided for @alignQRCode.
  ///
  /// In zh, this message translates to:
  /// **'对准二维码进行识别'**
  String get alignQRCode;

  /// No description provided for @identified.
  ///
  /// In zh, this message translates to:
  /// **'已识别：{content}'**
  String identified(String content);

  /// No description provided for @scanTip.
  ///
  /// In zh, this message translates to:
  /// **'提示：扫码后将弹出操作选项。'**
  String get scanTip;

  /// No description provided for @evidenceQueryTitle.
  ///
  /// In zh, this message translates to:
  /// **'证据查询'**
  String get evidenceQueryTitle;

  /// No description provided for @searchBaggageNo.
  ///
  /// In zh, this message translates to:
  /// **'搜索行李号、地点、描述...'**
  String get searchBaggageNo;

  /// No description provided for @selectDateRange.
  ///
  /// In zh, this message translates to:
  /// **'选择日期范围'**
  String get selectDateRange;

  /// No description provided for @clearDateFilter.
  ///
  /// In zh, this message translates to:
  /// **'清除日期筛选'**
  String get clearDateFilter;

  /// No description provided for @totalRecords.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 条记录'**
  String totalRecords(int count);

  /// No description provided for @noMatchingRecords.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的记录'**
  String get noMatchingRecords;

  /// No description provided for @noEvidenceRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无破损证据记录'**
  String get noEvidenceRecords;

  /// No description provided for @scanDamagedSubmit.
  ///
  /// In zh, this message translates to:
  /// **'请扫描破损行李并提交报告'**
  String get scanDamagedSubmit;

  /// No description provided for @enableLocationService.
  ///
  /// In zh, this message translates to:
  /// **'请打开手机「定位服务」后重试，或点右上角定位图标'**
  String get enableLocationService;

  /// No description provided for @enableGpsHint.
  ///
  /// In zh, this message translates to:
  /// **'无法获取位置：请开启定位/GPS，或到空旷处后点右上角「重新定位」'**
  String get enableGpsHint;

  /// No description provided for @selectImageSource.
  ///
  /// In zh, this message translates to:
  /// **'选择图片来源'**
  String get selectImageSource;

  /// No description provided for @imageSelectFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败'**
  String get imageSelectFailed;

  /// No description provided for @selectOneImage.
  ///
  /// In zh, this message translates to:
  /// **'请选择一张图片'**
  String get selectOneImage;

  /// No description provided for @noLocationHint.
  ///
  /// In zh, this message translates to:
  /// **'未获取到位置：请打开手机定位与 GPS，或到窗边/室外后点右上角「重新定位」再提交'**
  String get noLocationHint;

  /// No description provided for @damageReportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'报告提交成功，行李状态已同步为已损坏'**
  String get damageReportSuccess;

  /// No description provided for @submitReportFailed.
  ///
  /// In zh, this message translates to:
  /// **'提交报告失败: {error}'**
  String submitReportFailed(String error);

  /// No description provided for @networkError.
  ///
  /// In zh, this message translates to:
  /// **'[{stage}] 网络异常: {error}'**
  String networkError(String stage, String error);

  /// No description provided for @serverNotConnected.
  ///
  /// In zh, this message translates to:
  /// **'[{stage}] 无法连接服务器（HTTP 0）: {body}'**
  String serverNotConnected(String stage, String body);

  /// No description provided for @apiNotFound.
  ///
  /// In zh, this message translates to:
  /// **'[{stage}] 接口不存在（404）：请确认后端已启动并部署'**
  String apiNotFound(String stage);

  /// No description provided for @authFailed.
  ///
  /// In zh, this message translates to:
  /// **'[{stage}] 权限/认证失败（{status}）：请检查后端接口权限'**
  String authFailed(String stage, String status);

  /// No description provided for @unknownError.
  ///
  /// In zh, this message translates to:
  /// **'[{stage}] 未知错误'**
  String unknownError(String stage);

  /// No description provided for @detail.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get detail;

  /// No description provided for @baggageNotExist.
  ///
  /// In zh, this message translates to:
  /// **'行李号在系统中不存在'**
  String get baggageNotExist;

  /// No description provided for @duplicateReport.
  ///
  /// In zh, this message translates to:
  /// **'该行李已存在破损报告（重复提交）'**
  String get duplicateReport;

  /// No description provided for @hashCheckFailed.
  ///
  /// In zh, this message translates to:
  /// **'哈希校验失败'**
  String get hashCheckFailed;

  /// No description provided for @stageDetail.
  ///
  /// In zh, this message translates to:
  /// **'[{stage}] 详细信息'**
  String stageDetail(String stage);

  /// No description provided for @stage.
  ///
  /// In zh, this message translates to:
  /// **'阶段'**
  String get stage;

  /// No description provided for @httpStatusCode.
  ///
  /// In zh, this message translates to:
  /// **'HTTP 状态码'**
  String get httpStatusCode;

  /// No description provided for @exceptionInfo.
  ///
  /// In zh, this message translates to:
  /// **'异常信息'**
  String get exceptionInfo;

  /// No description provided for @responseBody.
  ///
  /// In zh, this message translates to:
  /// **'响应正文'**
  String get responseBody;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @damageReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'行李破损报告'**
  String get damageReportTitle;

  /// No description provided for @reloadLocation.
  ///
  /// In zh, this message translates to:
  /// **'重新获取位置'**
  String get reloadLocation;

  /// No description provided for @tapSelectPhoto.
  ///
  /// In zh, this message translates to:
  /// **'点击选择破损照片'**
  String get tapSelectPhoto;

  /// No description provided for @luggageId.
  ///
  /// In zh, this message translates to:
  /// **'行李ID'**
  String get luggageId;

  /// No description provided for @enterLuggageId.
  ///
  /// In zh, this message translates to:
  /// **'请输入行李ID'**
  String get enterLuggageId;

  /// No description provided for @damageDescription.
  ///
  /// In zh, this message translates to:
  /// **'破损描述'**
  String get damageDescription;

  /// No description provided for @enterDamageDesc.
  ///
  /// In zh, this message translates to:
  /// **'请描述行李破损情况'**
  String get enterDamageDesc;

  /// No description provided for @locationCoords.
  ///
  /// In zh, this message translates to:
  /// **'位置: {lat}, {lng}'**
  String locationCoords(String lat, String lng);

  /// No description provided for @noLocationYet.
  ///
  /// In zh, this message translates to:
  /// **'尚未获取到位置。请开启定位/GPS；提交时会自动再试，也可点右上角或下方按钮刷新。'**
  String get noLocationYet;

  /// No description provided for @getLocation.
  ///
  /// In zh, this message translates to:
  /// **'获取位置'**
  String get getLocation;

  /// No description provided for @submitReport.
  ///
  /// In zh, this message translates to:
  /// **'提交报告'**
  String get submitReport;

  /// No description provided for @statusCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'已办理托运'**
  String get statusCheckIn;

  /// No description provided for @statusInTransit.
  ///
  /// In zh, this message translates to:
  /// **'运输中'**
  String get statusInTransit;

  /// No description provided for @statusArrived.
  ///
  /// In zh, this message translates to:
  /// **'已到达'**
  String get statusArrived;

  /// No description provided for @statusDelivered.
  ///
  /// In zh, this message translates to:
  /// **'已交付'**
  String get statusDelivered;

  /// No description provided for @statusDamaged.
  ///
  /// In zh, this message translates to:
  /// **'已损坏'**
  String get statusDamaged;

  /// No description provided for @statusLost.
  ///
  /// In zh, this message translates to:
  /// **'已丢失'**
  String get statusLost;

  /// No description provided for @daysAgo.
  ///
  /// In zh, this message translates to:
  /// **'{days}天前'**
  String daysAgo(int days);

  /// No description provided for @hoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{hours}小时前'**
  String hoursAgo(int hours);

  /// No description provided for @minutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{minutes}分钟前'**
  String minutesAgo(int minutes);

  /// No description provided for @justNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get justNow;

  /// No description provided for @getLuggageListFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取行李列表失败({code})'**
  String getLuggageListFailed(int code);

  /// No description provided for @missingId.
  ///
  /// In zh, this message translates to:
  /// **'缺少行李标识'**
  String get missingId;

  /// No description provided for @luggageNotFoundById.
  ///
  /// In zh, this message translates to:
  /// **'未找到行李（已按ID与行李号尝试）: {key}'**
  String luggageNotFoundById(String key);

  /// No description provided for @queryLuggageFailed.
  ///
  /// In zh, this message translates to:
  /// **'查询行李失败({code})'**
  String queryLuggageFailed(int code);

  /// No description provided for @luggageNotFoundByNo.
  ///
  /// In zh, this message translates to:
  /// **'未找到行李: {id}'**
  String luggageNotFoundByNo(String id);

  /// No description provided for @updateLuggageFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新行李失败({code})'**
  String updateLuggageFailed(int code);

  /// No description provided for @uploadLuggageFailed.
  ///
  /// In zh, this message translates to:
  /// **'上传行李失败({code})'**
  String uploadLuggageFailed(int code);

  /// No description provided for @addLuggageFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加行李失败({code})'**
  String addLuggageFailed(int code);

  /// No description provided for @requestFailed.
  ///
  /// In zh, this message translates to:
  /// **'请求失败（HTTP {code}）'**
  String requestFailed(int code);

  /// No description provided for @requestTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请检查网络连接'**
  String get requestTimeout;

  /// No description provided for @loginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请重试'**
  String get loginFailed;

  /// No description provided for @loginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get loginSuccess;

  /// No description provided for @wrongPassword.
  ///
  /// In zh, this message translates to:
  /// **'用户名或密码错误'**
  String get wrongPassword;

  /// No description provided for @registerFailed.
  ///
  /// In zh, this message translates to:
  /// **'注册失败，请重试'**
  String get registerFailed;

  /// No description provided for @registerSuccess.
  ///
  /// In zh, this message translates to:
  /// **'注册成功，请使用用户名和密码登录'**
  String get registerSuccess;

  /// No description provided for @usernamePasswordEmpty.
  ///
  /// In zh, this message translates to:
  /// **'用户名或密码不能为空'**
  String get usernamePasswordEmpty;

  /// No description provided for @employeeIdNotExist.
  ///
  /// In zh, this message translates to:
  /// **'工号不存在或未在系统中登记'**
  String get employeeIdNotExist;

  /// No description provided for @employeeIdAlreadyRegistered.
  ///
  /// In zh, this message translates to:
  /// **'该工号已注册'**
  String get employeeIdAlreadyRegistered;

  /// No description provided for @usernameTaken.
  ///
  /// In zh, this message translates to:
  /// **'用户名已被占用'**
  String get usernameTaken;

  /// No description provided for @logoutFailed.
  ///
  /// In zh, this message translates to:
  /// **'注销失败，请重试'**
  String get logoutFailed;

  /// No description provided for @logoutSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已注销'**
  String get logoutSuccess;

  /// No description provided for @logoutFailedNoEmployeeId.
  ///
  /// In zh, this message translates to:
  /// **'工号不存在，无法完成服务端注销'**
  String get logoutFailedNoEmployeeId;

  /// No description provided for @networkErrorPrefix.
  ///
  /// In zh, this message translates to:
  /// **'网络错误: {error}'**
  String networkErrorPrefix(String error);

  /// No description provided for @unsupportedHttpMethod.
  ///
  /// In zh, this message translates to:
  /// **'不支持的HTTP方法: {method}'**
  String unsupportedHttpMethod(String method);

  /// No description provided for @permissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'权限被拒绝'**
  String get permissionDenied;

  /// No description provided for @goToSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get goToSettings;

  /// No description provided for @getLocationFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取位置信息失败，请稍后重试'**
  String get getLocationFailed;

  /// No description provided for @evidenceRequestTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时'**
  String get evidenceRequestTimeout;

  /// No description provided for @getDataFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取数据失败（{code}）'**
  String getDataFailed(int code);

  /// No description provided for @verifyRequestTimeout.
  ///
  /// In zh, this message translates to:
  /// **'验证请求超时'**
  String get verifyRequestTimeout;

  /// No description provided for @initFailed.
  ///
  /// In zh, this message translates to:
  /// **'初始化失败: {error}'**
  String initFailed(String error);

  /// No description provided for @loginError.
  ///
  /// In zh, this message translates to:
  /// **'登录失败: {error}'**
  String loginError(String error);

  /// No description provided for @registerError.
  ///
  /// In zh, this message translates to:
  /// **'注册失败: {error}'**
  String registerError(String error);

  /// No description provided for @cameraPermission.
  ///
  /// In zh, this message translates to:
  /// **'相机'**
  String get cameraPermission;

  /// No description provided for @cameraPermissionDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于拍照和扫描二维码'**
  String get cameraPermissionDesc;

  /// No description provided for @albumPermission.
  ///
  /// In zh, this message translates to:
  /// **'相册'**
  String get albumPermission;

  /// No description provided for @albumPermissionDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于从相册选择照片'**
  String get albumPermissionDesc;

  /// No description provided for @locationPermission.
  ///
  /// In zh, this message translates to:
  /// **'位置'**
  String get locationPermission;

  /// No description provided for @locationPermissionDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于获取当前位置信息'**
  String get locationPermissionDesc;

  /// No description provided for @phonePermission.
  ///
  /// In zh, this message translates to:
  /// **'电话'**
  String get phonePermission;

  /// No description provided for @phonePermissionDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于拨打客服电话'**
  String get phonePermissionDesc;

  /// No description provided for @needCameraPermission.
  ///
  /// In zh, this message translates to:
  /// **'需要相机权限才能使用此功能'**
  String get needCameraPermission;

  /// No description provided for @needAlbumPermission.
  ///
  /// In zh, this message translates to:
  /// **'需要相册权限才能选择照片'**
  String get needAlbumPermission;

  /// No description provided for @needLocationPermission.
  ///
  /// In zh, this message translates to:
  /// **'需要位置权限才能获取当前位置'**
  String get needLocationPermission;

  /// No description provided for @needPhonePermission.
  ///
  /// In zh, this message translates to:
  /// **'需要电话权限才能拨打电话'**
  String get needPhonePermission;

  /// No description provided for @cameraPermanentlyDenied.
  ///
  /// In zh, this message translates to:
  /// **'相机权限已被永久拒绝，请在系统设置中开启'**
  String get cameraPermanentlyDenied;

  /// No description provided for @albumPermanentlyDenied.
  ///
  /// In zh, this message translates to:
  /// **'相册权限已被永久拒绝，请在系统设置中开启'**
  String get albumPermanentlyDenied;

  /// No description provided for @locationPermanentlyDenied.
  ///
  /// In zh, this message translates to:
  /// **'位置权限已被永久拒绝，请在系统设置中开启'**
  String get locationPermanentlyDenied;

  /// No description provided for @phonePermanentlyDenied.
  ///
  /// In zh, this message translates to:
  /// **'电话权限已被永久拒绝，请在系统设置中开启'**
  String get phonePermanentlyDenied;

  /// No description provided for @needPermission.
  ///
  /// In zh, this message translates to:
  /// **'需要{permission}权限，{desc}'**
  String needPermission(String permission, String desc);

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索...'**
  String get search;

  /// No description provided for @allOption.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get allOption;

  /// No description provided for @searchLuggageTagHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索行李标签号、航班号...'**
  String get searchLuggageTagHint;

  /// No description provided for @noLuggage.
  ///
  /// In zh, this message translates to:
  /// **'暂无行李'**
  String get noLuggage;

  /// No description provided for @scanOrAddLuggage.
  ///
  /// In zh, this message translates to:
  /// **'扫码或手动添加行李'**
  String get scanOrAddLuggage;

  /// No description provided for @noSearchResults.
  ///
  /// In zh, this message translates to:
  /// **'未找到相关结果'**
  String get noSearchResults;

  /// No description provided for @noLuggageWithKeyword.
  ///
  /// In zh, this message translates to:
  /// **'未找到包含 \"{keyword}\" 的行李'**
  String noLuggageWithKeyword(String keyword);

  /// No description provided for @tryOtherCondition.
  ///
  /// In zh, this message translates to:
  /// **'尝试更换搜索条件'**
  String get tryOtherCondition;

  /// No description provided for @networkFailed.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败'**
  String get networkFailed;

  /// No description provided for @checkNetworkRetry.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络设置后重试'**
  String get checkNetworkRetry;

  /// No description provided for @loadFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请重试'**
  String get loadFailedRetry;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @scanSuccess.
  ///
  /// In zh, this message translates to:
  /// **'扫码成功'**
  String get scanSuccess;

  /// No description provided for @selectOperation.
  ///
  /// In zh, this message translates to:
  /// **'请选择操作'**
  String get selectOperation;

  /// No description provided for @baggageNoLabel.
  ///
  /// In zh, this message translates to:
  /// **'行李号'**
  String get baggageNoLabel;

  /// No description provided for @passengerLabel.
  ///
  /// In zh, this message translates to:
  /// **'乘客'**
  String get passengerLabel;

  /// No description provided for @weightLabel.
  ///
  /// In zh, this message translates to:
  /// **'重量'**
  String get weightLabel;

  /// No description provided for @confirmArrived.
  ///
  /// In zh, this message translates to:
  /// **'确认到达'**
  String get confirmArrived;

  /// No description provided for @handleOverweight.
  ///
  /// In zh, this message translates to:
  /// **'超重处理'**
  String get handleOverweight;

  /// No description provided for @contactPassenger.
  ///
  /// In zh, this message translates to:
  /// **'联系旅客'**
  String get contactPassenger;

  /// No description provided for @flight.
  ///
  /// In zh, this message translates to:
  /// **'航班'**
  String get flight;

  /// No description provided for @weight.
  ///
  /// In zh, this message translates to:
  /// **'重量'**
  String get weight;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除 \"{item}\" 吗？此操作无法撤销。'**
  String deleteConfirmMsg(String item);

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @operationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'操作已成功完成'**
  String get operationSuccess;

  /// No description provided for @gotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get gotIt;

  /// No description provided for @permissionRequest.
  ///
  /// In zh, this message translates to:
  /// **'{name}权限请求'**
  String permissionRequest(String name);

  /// No description provided for @authorizePrompt.
  ///
  /// In zh, this message translates to:
  /// **'是否授权此权限？'**
  String get authorizePrompt;

  /// No description provided for @noPlaceFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到相关地点'**
  String get noPlaceFound;

  /// No description provided for @searchFailedCheckNetwork.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败，请检查网络'**
  String get searchFailedCheckNetwork;

  /// No description provided for @searchLocation.
  ///
  /// In zh, this message translates to:
  /// **'输入地名开始搜索...'**
  String get searchLocation;

  /// No description provided for @searchLocationHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索地名、地址...'**
  String get searchLocationHint;

  /// No description provided for @login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get login;

  /// No description provided for @userLogin.
  ///
  /// In zh, this message translates to:
  /// **'用户登录'**
  String get userLogin;

  /// No description provided for @loginHint.
  ///
  /// In zh, this message translates to:
  /// **'请使用用户名和密码登录账户'**
  String get loginHint;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名'**
  String get enterUsername;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In zh, this message translates to:
  /// **'密码长度至少6位'**
  String get passwordMinLength;

  /// No description provided for @noAccount.
  ///
  /// In zh, this message translates to:
  /// **'还没有员工账号？'**
  String get noAccount;

  /// No description provided for @goToRegister.
  ///
  /// In zh, this message translates to:
  /// **'前往员工注册/激活'**
  String get goToRegister;

  /// No description provided for @loginFail.
  ///
  /// In zh, this message translates to:
  /// **'登录失败'**
  String get loginFail;

  /// No description provided for @registerFail.
  ///
  /// In zh, this message translates to:
  /// **'注册失败'**
  String get registerFail;

  /// No description provided for @registerTitle.
  ///
  /// In zh, this message translates to:
  /// **'用户账号注册/激活'**
  String get registerTitle;

  /// No description provided for @registerHint.
  ///
  /// In zh, this message translates to:
  /// **'工号须已由航司预置；填写工号与账号信息以激活账户'**
  String get registerHint;

  /// No description provided for @employeeIdLabel.
  ///
  /// In zh, this message translates to:
  /// **'工号'**
  String get employeeIdLabel;

  /// No description provided for @enterEmployeeId.
  ///
  /// In zh, this message translates to:
  /// **'请输入员工工号'**
  String get enterEmployeeId;

  /// No description provided for @enterEmployeeIdAgain.
  ///
  /// In zh, this message translates to:
  /// **'请输入工号'**
  String get enterEmployeeIdAgain;

  /// No description provided for @employeeIdFormatWrong.
  ///
  /// In zh, this message translates to:
  /// **'工号格式不正确'**
  String get employeeIdFormatWrong;

  /// No description provided for @usernameLabel.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get usernameLabel;

  /// No description provided for @enterUsernameLabel.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名'**
  String get enterUsernameLabel;

  /// No description provided for @enterUsernameLabelAgain.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名'**
  String get enterUsernameLabelAgain;

  /// No description provided for @usernameMinLength.
  ///
  /// In zh, this message translates to:
  /// **'用户名长度至少3位'**
  String get usernameMinLength;

  /// No description provided for @enterPasswordLabel.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码（至少6位）'**
  String get enterPasswordLabel;

  /// No description provided for @enterPasswordAgain.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get enterPasswordAgain;

  /// No description provided for @confirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'请再次输入密码'**
  String get enterConfirmPassword;

  /// No description provided for @passwordsMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致'**
  String get passwordsMismatch;

  /// No description provided for @register.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get register;

  /// No description provided for @hasAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有账户？'**
  String get hasAccount;

  /// No description provided for @loginNow.
  ///
  /// In zh, this message translates to:
  /// **'立即登录'**
  String get loginNow;

  /// No description provided for @personalInfo.
  ///
  /// In zh, this message translates to:
  /// **'个人信息'**
  String get personalInfo;

  /// No description provided for @personalInfoChangedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'个人信息修改成功'**
  String get personalInfoChangedSuccess;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @gender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get gender;

  /// No description provided for @enterGender.
  ///
  /// In zh, this message translates to:
  /// **'请输入性别'**
  String get enterGender;

  /// No description provided for @hometown.
  ///
  /// In zh, this message translates to:
  /// **'籍贯'**
  String get hometown;

  /// No description provided for @enterHometown.
  ///
  /// In zh, this message translates to:
  /// **'请输入籍贯'**
  String get enterHometown;

  /// No description provided for @birthDate.
  ///
  /// In zh, this message translates to:
  /// **'出生日期'**
  String get birthDate;

  /// No description provided for @contact.
  ///
  /// In zh, this message translates to:
  /// **'联系方式'**
  String get contact;

  /// No description provided for @enterContact.
  ///
  /// In zh, this message translates to:
  /// **'请输入联系方式'**
  String get enterContact;

  /// No description provided for @hireDate.
  ///
  /// In zh, this message translates to:
  /// **'入职日期'**
  String get hireDate;

  /// No description provided for @selectDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get selectDate;

  /// No description provided for @unprocessedBaggage.
  ///
  /// In zh, this message translates to:
  /// **'未处理行李'**
  String get unprocessedBaggage;

  /// No description provided for @selectFlight.
  ///
  /// In zh, this message translates to:
  /// **'选择航班'**
  String get selectFlight;

  /// No description provided for @noAvailableFlights.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用航班'**
  String get noAvailableFlights;

  /// No description provided for @noUnprocessedBaggage.
  ///
  /// In zh, this message translates to:
  /// **'该航班暂无未处理行李'**
  String get noUnprocessedBaggage;

  /// No description provided for @markAsLost.
  ///
  /// In zh, this message translates to:
  /// **'标记丢失'**
  String get markAsLost;

  /// No description provided for @selectBaggageToMark.
  ///
  /// In zh, this message translates to:
  /// **'请先选择要标记为丢失的行李'**
  String get selectBaggageToMark;

  /// No description provided for @confirmMarkLost.
  ///
  /// In zh, this message translates to:
  /// **'确认标记'**
  String get confirmMarkLost;

  /// No description provided for @markLostSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功标记 {count} 件行李为丢失'**
  String markLostSuccess(int count);

  /// No description provided for @markLostFailed.
  ///
  /// In zh, this message translates to:
  /// **'部分失败：成功 {success} 件，失败 {fail} 件'**
  String markLostFailed(int success, int fail);

  /// No description provided for @selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 件'**
  String selectedCount(int count);

  /// No description provided for @totalUnprocessed.
  ///
  /// In zh, this message translates to:
  /// **'共 {total} 件未处理行李'**
  String totalUnprocessed(int total);

  /// No description provided for @unprocessed.
  ///
  /// In zh, this message translates to:
  /// **'待处理'**
  String get unprocessed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
