// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '行李管理系统';

  @override
  String get homeTitle => '行李管理工作台';

  @override
  String get searchLuggage => '查询行李';

  @override
  String get scanQRCode => '扫描行李二维码';

  @override
  String get welcomeBack => '欢迎回来，航司工作人员';

  @override
  String get employee => '员工';

  @override
  String get quickActions => '快捷操作';

  @override
  String get scanProcess => '扫码处理';

  @override
  String get scanProcessDesc => '扫描行李二维码';

  @override
  String get searchLuggageDesc => '搜索行李信息';

  @override
  String get damageRegistration => '破损登记';

  @override
  String get damageRegistrationDesc => '登记破损行李';

  @override
  String get evidenceQuery => '证据查询';

  @override
  String get evidenceQueryDesc => '查询破损证据';

  @override
  String get homeTab => '首页';

  @override
  String get luggageTab => '行李';

  @override
  String get todoTab => '待办';

  @override
  String get myTab => '我的';

  @override
  String get profileTitle => '员工中心';

  @override
  String get accountInfo => '账户信息';

  @override
  String get accountSecurity => '账户安全';

  @override
  String get personalization => '个性化设置';

  @override
  String get systemSettings => '系统设置';

  @override
  String get quickFunctions => '快捷功能';

  @override
  String get helpSupport => '帮助与支持';

  @override
  String get confirmLogout => '确认退出';

  @override
  String get logoutConfirmMsg => '确定要退出登录吗？';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get logout => '退出';

  @override
  String get logoutBtn => '退出登录';

  @override
  String get employeeId => '员工工号';

  @override
  String get workEmail => '工作邮箱';

  @override
  String get notSet => '未设置';

  @override
  String get employeeName => '员工姓名';

  @override
  String get unknownUser => '未知用户';

  @override
  String get accountInfoNote => '账户信息说明';

  @override
  String get accountInfoNoteContent =>
      '• 员工工号是您在系统中的唯一标识\n• 工作邮箱用于系统通知和重要信息发送\n• 员工姓名将显示在您的个人资料中';

  @override
  String get changePassword => '修改密码';

  @override
  String get oldPassword => '旧密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmNewPassword => '确认新密码';

  @override
  String get passwordMismatch => '两次输入的密码不一致';

  @override
  String get passwordChangedSuccess => '密码修改成功';

  @override
  String get bindPhone => '绑定手机';

  @override
  String get phoneNumber => '手机号码';

  @override
  String get verifyCode => '验证码';

  @override
  String get verifyCodeSent => '验证码已发送';

  @override
  String get getVerifyCode => '获取验证码';

  @override
  String get fillAllFields => '请填写完整信息';

  @override
  String get phoneBindSuccess => '手机绑定成功';

  @override
  String get accountSecurityTitle => '账户安全';

  @override
  String get passwordChange => '修改密码';

  @override
  String get phoneBind => '绑定手机';

  @override
  String get notBound => '未绑定';

  @override
  String get twoFactorAuth => '两步验证';

  @override
  String get twoFactorEnabled => '两步验证已开启';

  @override
  String get securityTips => '安全提示';

  @override
  String get securityTipsContent =>
      '• 请定期修改密码，使用强密码\n• 绑定手机可以提高账户安全性\n• 开启两步验证可以防止账户被非法登录';

  @override
  String get changeAvatar => '修改头像';

  @override
  String get selectAvatarSource => '请选择头像来源';

  @override
  String avatarSelected(String name) {
    return '头像选择成功: $name';
  }

  @override
  String get avatarCancelled => '已取消选择';

  @override
  String get album => '相册';

  @override
  String get camera => '拍照';

  @override
  String avatarCaptureSuccess(String name) {
    return '头像拍摄成功: $name';
  }

  @override
  String get changeNickname => '修改昵称';

  @override
  String get newNickname => '新昵称';

  @override
  String get nicknameEmpty => '昵称不能为空';

  @override
  String get nicknameChangedSuccess => '昵称修改成功';

  @override
  String get personalizationTitle => '个性化设置';

  @override
  String get personalizationNote => '个性化设置说明';

  @override
  String get personalizationNoteContent =>
      '• 修改头像可以让您的个人资料更加个性化\n• 修改昵称可以更改您在系统中的显示名称\n• 这些设置仅影响您的个人资料显示，不会影响您的账户安全';

  @override
  String get languageSettings => '语言设置';

  @override
  String get themeSettings => '主题设置';

  @override
  String get lightMode => '浅色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get systemMode => '跟随系统';

  @override
  String get clearCache => '清理缓存';

  @override
  String get clearCacheConfirm => '确定要清理应用缓存吗？这将删除应用的临时数据，但不会影响您的个人数据。';

  @override
  String get cacheClearedSuccess => '缓存清理成功';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get luggageStatusUpdate => '行李状态更新';

  @override
  String get systemNotification => '系统通知';

  @override
  String get abnormalAlert => '异常提醒';

  @override
  String get systemSettingsTitle => '系统设置';

  @override
  String get systemSettingsNote => '系统设置说明';

  @override
  String get systemSettingsNoteContent =>
      '• 通知设置可以控制应用的通知类型\n• 语言设置可以更改应用的显示语言\n• 主题设置可以切换深色/浅色模式\n• 清理缓存可以释放应用占用的存储空间';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get feedback => '意见反馈';

  @override
  String get feedbackHint => '请输入您的意见或建议';

  @override
  String get feedbackEmpty => '请输入反馈内容';

  @override
  String get feedbackSuccess => '反馈提交成功，感谢您的建议';

  @override
  String get submit => '提交';

  @override
  String get appName => '行李管理系统';

  @override
  String get appDesc => '行李管理系统是一款专为航空地勤人员设计的行李追踪和管理工具。';

  @override
  String get copyright => '© 2026 行李管理系统 版权所有';

  @override
  String get contactUsEnabled => '联系我们功能已启用';

  @override
  String get helpSupportTitle => '帮助与支持';

  @override
  String get usageHelp => '使用帮助';

  @override
  String get about => '关于';

  @override
  String get contactUs => '联系我们';

  @override
  String get contactPhone => '400-123-4567';

  @override
  String get helpSupportNote => '帮助与支持说明';

  @override
  String get helpSupportNoteContent =>
      '• 使用帮助：查看应用的使用指南和常见问题\n• 意见反馈：提交您对应用的意见和建议\n• 关于：查看应用的版本信息和版权声明\n• 联系我们：获取客服支持';

  @override
  String get quickScanEnabled => '快速扫描功能已启用';

  @override
  String get quickFunctionsTitle => '快捷功能';

  @override
  String get luggageMap => '行李地图';

  @override
  String get luggageMapDesc => '查看行李位置分布';

  @override
  String get quickScan => '快速扫描';

  @override
  String get quickScanDesc => '直接进入扫描界面';

  @override
  String get quickFunctionsNote => '快捷功能说明';

  @override
  String get quickFunctionsNoteContent =>
      '• 行李地图：查看行李的实时位置分布\n• 快速扫描：直接进入二维码扫描界面，方便快速处理行李';

  @override
  String get queryLuggage => '查询行李';

  @override
  String get searchLuggageHint => '搜索行李';

  @override
  String get searchPlaceholder => '标签号、航班号、乘客姓名或目的地';

  @override
  String get scanBarcode => '扫描条形码';

  @override
  String get statusFilter => '状态过滤';

  @override
  String get allStatuses => '全部状态';

  @override
  String get executeSearch => '执行搜索';

  @override
  String get enterSearchCondition => '请输入搜索条件并点击搜索按钮';

  @override
  String luggageTagNo(String tag) {
    return '行李标签号: $tag';
  }

  @override
  String remark(String note) {
    return '备注: $note';
  }

  @override
  String get filterConditions => '筛选条件';

  @override
  String get clearFilter => '清除筛选';

  @override
  String get status => '状态';

  @override
  String get all => '全部';

  @override
  String get checkIn => '已办理托运';

  @override
  String get inTransit => '运输中';

  @override
  String get arrived => '已到达';

  @override
  String get delivered => '已交付';

  @override
  String get damaged => '已损坏';

  @override
  String get lost => '已丢失';

  @override
  String get unknownStatus => '未知状态';

  @override
  String get changeStatus => '修改状态';

  @override
  String get markDamaged => '标记破损';

  @override
  String get viewHistoryLog => '查看历史日志';

  @override
  String get luggageManagement => '行李管理';

  @override
  String get filter => '筛选';

  @override
  String get refresh => '刷新';

  @override
  String get searchLuggageTag => '搜索行李标签、所有者、位置...';

  @override
  String totalLuggage(int count) {
    return '共 $count 个行李';
  }

  @override
  String get loadMore => '（下拉加载更多）';

  @override
  String allLoaded(int count) {
    return '— 已加载全部 $count 条 —';
  }

  @override
  String get enterLocationFirst => '请先输入位置信息';

  @override
  String get locationSynced => '位置与状态已同步到后端';

  @override
  String updateLocationFailed(int code) {
    return '更新行李位置失败($code)';
  }

  @override
  String get unknownLocation => '未知位置';

  @override
  String get updateSuccess => '更新成功';

  @override
  String get uploadCreateSuccess => '上传/创建成功';

  @override
  String get luggageInfo => '行李信息';

  @override
  String get basicInfo => '基本信息';

  @override
  String get historyLog => '历史日志';

  @override
  String get qrCodeResult => '二维码解析结果';

  @override
  String get luggageDetail => '行李详情';

  @override
  String get location => '位置';

  @override
  String get note => '备注';

  @override
  String get update => '更新(PUT)';

  @override
  String get uploadCreate => '上传/创建(POST)';

  @override
  String get viewOnMap => '在地图上查看';

  @override
  String get updateLocationBackend => '更新位置到后端';

  @override
  String get operationHistoryLog => '操作历史日志';

  @override
  String operator(String name) {
    return '操作人: $name';
  }

  @override
  String get evidenceDetail => '证据详情';

  @override
  String get copyHashValue => '复制哈希值';

  @override
  String baggageNo(String no) {
    return '行李号: $no';
  }

  @override
  String get damagedBaggage => '破损行李';

  @override
  String get loading => '加载中...';

  @override
  String get imageLoadFailed => '图片加载失败';

  @override
  String get recordTime => '记录时间';

  @override
  String get recordLocation => '记录地点';

  @override
  String get hashValue => '哈希值';

  @override
  String get damageDesc => '破损描述';

  @override
  String get hashVerification => '证据哈希验证';

  @override
  String get hashVerificationNote => '哈希值用于验证图片证据的完整性和真实性';

  @override
  String get hashVerified => '哈希验证通过：证据未被篡改';

  @override
  String get hashFailed => '哈希验证失败：证据可能被修改';

  @override
  String get verifyHash => '验证哈希';

  @override
  String get noImageToVerify => '无图片可验证';

  @override
  String get hashVerifySuccess => '哈希验证成功，证据未被篡改';

  @override
  String verifyFailed(String error) {
    return '验证失败: $error';
  }

  @override
  String get hashCopied => '哈希值已复制到剪贴板';

  @override
  String get maxPhotosHint => '最多只能上传3张照片';

  @override
  String get photoUploadSuccess => '照片上传成功';

  @override
  String uploadFailed(String error) {
    return '上传失败: $error';
  }

  @override
  String get hint => '提示';

  @override
  String get noPhotoHint => '您还没有上传行李照片，这是定责的重要依据。确定要继续吗？';

  @override
  String get continueAction => '继续';

  @override
  String get addLuggageSuccess => '行李信息添加成功！';

  @override
  String addFailed(String error) {
    return '添加失败: $error';
  }

  @override
  String get addLuggageInfo => '添加行李信息';

  @override
  String get luggageTagNoLabel => '行李标签号';

  @override
  String get enterLuggageTagNo => '请输入行李标签号';

  @override
  String get flightNo => '航班号';

  @override
  String get enterFlightNo => '请输入航班号';

  @override
  String get passengerName => '乘客姓名';

  @override
  String get enterPassengerName => '请输入乘客姓名';

  @override
  String get luggageWeight => '行李重量 (kg)';

  @override
  String get enterWeight => '请输入行李重量';

  @override
  String get invalidWeight => '请输入有效的重量';

  @override
  String get destination => '目的地';

  @override
  String get enterDestination => '请输入目的地';

  @override
  String get luggageStatus => '行李状态';

  @override
  String get remarkOptional => '备注';

  @override
  String get enterRemark => '请输入备注信息（可选）';

  @override
  String get operatorEmployee => '操作员工';

  @override
  String get latitude => '纬度';

  @override
  String get longitude => '经度';

  @override
  String get autoLocation => '位置信息将自动获取';

  @override
  String get uploadPhoto => '上传照片';

  @override
  String get uploadPhotoHint => '请上传行李外观照片，作为定责依据';

  @override
  String get tapUploadPhoto => '点击上传照片';

  @override
  String get max3Photos => '最多上传3张';

  @override
  String get addLuggage => '添加行李';

  @override
  String get processSuccess => '处理成功';

  @override
  String processFailed(String error) {
    return '处理失败: $error';
  }

  @override
  String get overweightTitle => '超重费用/称重';

  @override
  String get weighingInfo => '称重信息';

  @override
  String get actualWeight => '行李重量';

  @override
  String get enterActualWeight => '请输入实际重量';

  @override
  String get feeInfo => '费用信息';

  @override
  String get confirmProcess => '确认处理';

  @override
  String get luggageInfoLabel => '行李信息';

  @override
  String get tagNo => '标签号';

  @override
  String get flightNoLabel => '航班号';

  @override
  String get passenger => '乘客';

  @override
  String get overweightFee => '超重费用';

  @override
  String get autoCalc => '自动计算';

  @override
  String get additionalFee => '需补缴费用';

  @override
  String get overweightNote => '超重费用将自动计算，确认后将通知旅客补缴。';

  @override
  String get passengerContact => '旅客联系/认领';

  @override
  String get passengerInfo => '旅客信息';

  @override
  String get name => '姓名';

  @override
  String get phone => '手机号';

  @override
  String get email => '邮箱';

  @override
  String get callRecord => '通话记录';

  @override
  String get calling => '正在拨打...';

  @override
  String get callPhone => '拨打电话';

  @override
  String get sendSms => '发送短信';

  @override
  String get claimConfirm => '认领确认';

  @override
  String get confirmClaimNote => '请确认旅客身份后，点击下方按钮完成认领流程。';

  @override
  String get confirmClaim => '确认认领';

  @override
  String get claimSuccess => '认领成功';

  @override
  String get scanOperation => '扫码操作';

  @override
  String get scanOperationGuide =>
      '在底部导航栏点击「扫码」进入扫码界面，点击扫描按钮对准行李上的二维码即可识别。识别成功后会自动跳转到行李详情页，您可以在此更新行李位置或状态。';

  @override
  String get luggageListGuide =>
      '在底部导航栏点击「行李」进入行李列表页。您可以通过搜索框按行李标签号或旅客姓名进行搜索，也可以通过筛选按钮按行李状态进行筛选。';

  @override
  String get damageRegistrationGuide =>
      '发现行李破损时，在扫码结果页面点击「破损登记」按钮，或在行李详情页点击「登记破损」按钮。上传破损照片并填写描述后提交，系统会自动生成破损记录并通知相关人员。';

  @override
  String get overweightGuide =>
      '当待办事项中出现超重行李提示时，点击该条进入超重处理页面。核对行李重量，确认超重后选择收费方式（现金/电子支付），完成后更新行李状态。';

  @override
  String get contactPassengerGuide =>
      '当待办事项中出现无人认领行李提示时，点击该条进入联系旅客页面。系统会显示旅客的联系方式，点击呼叫按钮可直接拨打电话。联系成功后更新行李状态为「已交付」。';

  @override
  String get submitFeedbackGuide =>
      '如果您在使用过程中遇到问题或有改进建议，可以在「我的 → 帮助与支持 → 意见反馈」中填写并提交。我们会认真处理每一条反馈。';

  @override
  String get themeLanguageGuide =>
      '在「我的 → 系统设置 → 主题设置」中可切换浅色/深色/跟随系统三种模式。在「语言设置」中可切换简体中文或 English。设置会自动保存。';

  @override
  String get notificationGuide =>
      '应用会在出现待办事项时推送通知，包括超重行李、无人认领行李、破损登记等。在「系统设置 → 通知设置」中可以分别开启或关闭各类型的通知。';

  @override
  String get usageHelpTitle => '使用帮助';

  @override
  String loadFailed(String error) {
    return '加载失败: $error';
  }

  @override
  String get todoTitle => '待办事项';

  @override
  String get reload => '重新加载';

  @override
  String get noTodoItems => '暂无待办事项';

  @override
  String get abnormalLuggage => '需要处理的异常行李';

  @override
  String luggageNotFound(String tag) {
    return '未找到行李: $tag';
  }

  @override
  String loadLuggageFailed(String error) {
    return '加载行李失败: $error';
  }

  @override
  String get qrCodeNoLuggageId =>
      '二维码中未包含行李标识（需 JSON/链接参数 luggageId，或多行文本中的「行李号」「行李编号」）';

  @override
  String getLuggageFailed(String error) {
    return '获取行李信息失败: $error';
  }

  @override
  String get cannotSyncMissingNo => '无法同步：缺少行李号 baggageNumber';

  @override
  String get statusUpdatedArrived => '状态已更新为：已到达（已同步后端）';

  @override
  String updateStatusFailed(String error) {
    return '更新状态失败: $error';
  }

  @override
  String get scan => '扫码';

  @override
  String get toggleFlash => '切换闪光灯';

  @override
  String get switchCamera => '切换摄像头';

  @override
  String get processing => '正在处理...';

  @override
  String get alignQRCode => '对准二维码进行识别';

  @override
  String identified(String content) {
    return '已识别：$content';
  }

  @override
  String get scanTip => '提示：扫码后将弹出操作选项。';

  @override
  String get evidenceQueryTitle => '证据查询';

  @override
  String get searchBaggageNo => '搜索行李号、地点、描述...';

  @override
  String get selectDateRange => '选择日期范围';

  @override
  String get clearDateFilter => '清除日期筛选';

  @override
  String totalRecords(int count) {
    return '共 $count 条记录';
  }

  @override
  String get noMatchingRecords => '未找到匹配的记录';

  @override
  String get noEvidenceRecords => '暂无破损证据记录';

  @override
  String get scanDamagedSubmit => '请扫描破损行李并提交报告';

  @override
  String get enableLocationService => '请打开手机「定位服务」后重试，或点右上角定位图标';

  @override
  String get enableGpsHint => '无法获取位置：请开启定位/GPS，或到空旷处后点右上角「重新定位」';

  @override
  String get selectImageSource => '选择图片来源';

  @override
  String get imageSelectFailed => '选择图片失败';

  @override
  String get selectOneImage => '请选择一张图片';

  @override
  String get noLocationHint => '未获取到位置：请打开手机定位与 GPS，或到窗边/室外后点右上角「重新定位」再提交';

  @override
  String get damageReportSuccess => '报告提交成功，行李状态已同步为已损坏';

  @override
  String submitReportFailed(String error) {
    return '提交报告失败: $error';
  }

  @override
  String networkError(String stage, String error) {
    return '[$stage] 网络异常: $error';
  }

  @override
  String serverNotConnected(String stage, String body) {
    return '[$stage] 无法连接服务器（HTTP 0）: $body';
  }

  @override
  String apiNotFound(String stage) {
    return '[$stage] 接口不存在（404）：请确认后端已启动并部署';
  }

  @override
  String authFailed(String stage, String status) {
    return '[$stage] 权限/认证失败（$status）：请检查后端接口权限';
  }

  @override
  String unknownError(String stage) {
    return '[$stage] 未知错误';
  }

  @override
  String get detail => '详情';

  @override
  String get baggageNotExist => '行李号在系统中不存在';

  @override
  String get duplicateReport => '该行李已存在破损报告（重复提交）';

  @override
  String get hashCheckFailed => '哈希校验失败';

  @override
  String stageDetail(String stage) {
    return '[$stage] 详细信息';
  }

  @override
  String get stage => '阶段';

  @override
  String get httpStatusCode => 'HTTP 状态码';

  @override
  String get exceptionInfo => '异常信息';

  @override
  String get responseBody => '响应正文';

  @override
  String get close => '关闭';

  @override
  String get damageReportTitle => '行李破损报告';

  @override
  String get reloadLocation => '重新获取位置';

  @override
  String get tapSelectPhoto => '点击选择破损照片';

  @override
  String get luggageId => '行李ID';

  @override
  String get enterLuggageId => '请输入行李ID';

  @override
  String get damageDescription => '破损描述';

  @override
  String get enterDamageDesc => '请描述行李破损情况';

  @override
  String locationCoords(String lat, String lng) {
    return '位置: $lat, $lng';
  }

  @override
  String get noLocationYet => '尚未获取到位置。请开启定位/GPS；提交时会自动再试，也可点右上角或下方按钮刷新。';

  @override
  String get getLocation => '获取位置';

  @override
  String get submitReport => '提交报告';

  @override
  String get statusCheckIn => '已办理托运';

  @override
  String get statusInTransit => '运输中';

  @override
  String get statusArrived => '已到达';

  @override
  String get statusDelivered => '已交付';

  @override
  String get statusDamaged => '已损坏';

  @override
  String get statusLost => '已丢失';

  @override
  String daysAgo(int days) {
    return '$days天前';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours小时前';
  }

  @override
  String minutesAgo(int minutes) {
    return '$minutes分钟前';
  }

  @override
  String get justNow => '刚刚';

  @override
  String getLuggageListFailed(int code) {
    return '获取行李列表失败($code)';
  }

  @override
  String get missingId => '缺少行李标识';

  @override
  String luggageNotFoundById(String key) {
    return '未找到行李（已按ID与行李号尝试）: $key';
  }

  @override
  String queryLuggageFailed(int code) {
    return '查询行李失败($code)';
  }

  @override
  String luggageNotFoundByNo(String id) {
    return '未找到行李: $id';
  }

  @override
  String updateLuggageFailed(int code) {
    return '更新行李失败($code)';
  }

  @override
  String uploadLuggageFailed(int code) {
    return '上传行李失败($code)';
  }

  @override
  String addLuggageFailed(int code) {
    return '添加行李失败($code)';
  }

  @override
  String requestFailed(int code) {
    return '请求失败（HTTP $code）';
  }

  @override
  String get requestTimeout => '请求超时，请检查网络连接';

  @override
  String get loginFailed => '登录失败，请重试';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get wrongPassword => '用户名或密码错误';

  @override
  String get registerFailed => '注册失败，请重试';

  @override
  String get registerSuccess => '注册成功，请使用用户名和密码登录';

  @override
  String get usernamePasswordEmpty => '用户名或密码不能为空';

  @override
  String get employeeIdNotExist => '工号不存在或未在系统中登记';

  @override
  String get employeeIdAlreadyRegistered => '该工号已注册';

  @override
  String get usernameTaken => '用户名已被占用';

  @override
  String get logoutFailed => '注销失败，请重试';

  @override
  String get logoutSuccess => '已注销';

  @override
  String get logoutFailedNoEmployeeId => '工号不存在，无法完成服务端注销';

  @override
  String networkErrorPrefix(String error) {
    return '网络错误: $error';
  }

  @override
  String unsupportedHttpMethod(String method) {
    return '不支持的HTTP方法: $method';
  }

  @override
  String get permissionDenied => '权限被拒绝';

  @override
  String get goToSettings => '去设置';

  @override
  String get getLocationFailed => '获取位置信息失败，请稍后重试';

  @override
  String get evidenceRequestTimeout => '请求超时';

  @override
  String getDataFailed(int code) {
    return '获取数据失败（$code）';
  }

  @override
  String get verifyRequestTimeout => '验证请求超时';

  @override
  String initFailed(String error) {
    return '初始化失败: $error';
  }

  @override
  String loginError(String error) {
    return '登录失败: $error';
  }

  @override
  String registerError(String error) {
    return '注册失败: $error';
  }

  @override
  String get cameraPermission => '相机';

  @override
  String get cameraPermissionDesc => '用于拍照和扫描二维码';

  @override
  String get albumPermission => '相册';

  @override
  String get albumPermissionDesc => '用于从相册选择照片';

  @override
  String get locationPermission => '位置';

  @override
  String get locationPermissionDesc => '用于获取当前位置信息';

  @override
  String get phonePermission => '电话';

  @override
  String get phonePermissionDesc => '用于拨打客服电话';

  @override
  String get needCameraPermission => '需要相机权限才能使用此功能';

  @override
  String get needAlbumPermission => '需要相册权限才能选择照片';

  @override
  String get needLocationPermission => '需要位置权限才能获取当前位置';

  @override
  String get needPhonePermission => '需要电话权限才能拨打电话';

  @override
  String get cameraPermanentlyDenied => '相机权限已被永久拒绝，请在系统设置中开启';

  @override
  String get albumPermanentlyDenied => '相册权限已被永久拒绝，请在系统设置中开启';

  @override
  String get locationPermanentlyDenied => '位置权限已被永久拒绝，请在系统设置中开启';

  @override
  String get phonePermanentlyDenied => '电话权限已被永久拒绝，请在系统设置中开启';

  @override
  String needPermission(String permission, String desc) {
    return '需要$permission权限，$desc';
  }

  @override
  String get search => '搜索...';

  @override
  String get allOption => '全部';

  @override
  String get searchLuggageTagHint => '搜索行李标签号、航班号...';

  @override
  String get noLuggage => '暂无行李';

  @override
  String get scanOrAddLuggage => '扫码或手动添加行李';

  @override
  String get noSearchResults => '未找到相关结果';

  @override
  String noLuggageWithKeyword(String keyword) {
    return '未找到包含 \"$keyword\" 的行李';
  }

  @override
  String get tryOtherCondition => '尝试更换搜索条件';

  @override
  String get networkFailed => '网络连接失败';

  @override
  String get checkNetworkRetry => '请检查网络设置后重试';

  @override
  String get loadFailedRetry => '加载失败，请重试';

  @override
  String get retry => '重试';

  @override
  String get scanSuccess => '扫码成功';

  @override
  String get selectOperation => '请选择操作';

  @override
  String get baggageNoLabel => '行李号';

  @override
  String get passengerLabel => '乘客';

  @override
  String get weightLabel => '重量';

  @override
  String get confirmArrived => '确认到达';

  @override
  String get handleOverweight => '超重处理';

  @override
  String get contactPassenger => '联系旅客';

  @override
  String get flight => '航班';

  @override
  String get weight => '重量';

  @override
  String get confirmDelete => '确认删除';

  @override
  String deleteConfirmMsg(String item) {
    return '确定要删除 \"$item\" 吗？此操作无法撤销。';
  }

  @override
  String get delete => '删除';

  @override
  String get operationSuccess => '操作已成功完成';

  @override
  String get gotIt => '知道了';

  @override
  String permissionRequest(String name) {
    return '$name权限请求';
  }

  @override
  String get authorizePrompt => '是否授权此权限？';

  @override
  String get noPlaceFound => '未找到相关地点';

  @override
  String get searchFailedCheckNetwork => '搜索失败，请检查网络';

  @override
  String get searchLocation => '输入地名开始搜索...';

  @override
  String get searchLocationHint => '搜索地名、地址...';

  @override
  String get login => '登录';

  @override
  String get userLogin => '用户登录';

  @override
  String get loginHint => '请使用用户名和密码登录账户';

  @override
  String get username => '用户名';

  @override
  String get enterUsername => '请输入用户名';

  @override
  String get password => '密码';

  @override
  String get enterPassword => '请输入密码';

  @override
  String get passwordMinLength => '密码长度至少6位';

  @override
  String get noAccount => '还没有员工账号？';

  @override
  String get goToRegister => '前往员工注册/激活';

  @override
  String get loginFail => '登录失败';

  @override
  String get registerFail => '注册失败';

  @override
  String get registerTitle => '用户账号注册/激活';

  @override
  String get registerHint => '工号须已由航司预置；填写工号与账号信息以激活账户';

  @override
  String get employeeIdLabel => '工号';

  @override
  String get enterEmployeeId => '请输入员工工号';

  @override
  String get enterEmployeeIdAgain => '请输入工号';

  @override
  String get employeeIdFormatWrong => '工号格式不正确';

  @override
  String get usernameLabel => '用户名';

  @override
  String get enterUsernameLabel => '请输入用户名';

  @override
  String get enterUsernameLabelAgain => '请输入用户名';

  @override
  String get usernameMinLength => '用户名长度至少3位';

  @override
  String get enterPasswordLabel => '请输入密码（至少6位）';

  @override
  String get enterPasswordAgain => '请输入密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get enterConfirmPassword => '请再次输入密码';

  @override
  String get passwordsMismatch => '两次输入的密码不一致';

  @override
  String get register => '注册';

  @override
  String get hasAccount => '已有账户？';

  @override
  String get loginNow => '立即登录';
}
