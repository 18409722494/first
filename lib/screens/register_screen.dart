import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'login_screen.dart';

/// 全国机场列表
class Airport {
  final String code;
  final String name;
  final String city;

  const Airport({required this.code, required this.name, required this.city});

  @override
  String toString() => '$name ($code)';
}

const List<Airport> allAirports = [
  // 华北地区
  Airport(code: 'PEK', name: '首都国际机场', city: '北京'),
  Airport(code: 'PKX', name: '大兴国际机场', city: '北京'),
  Airport(code: 'TSN', name: '滨海国际机场', city: '天津'),
  Airport(code: 'SJW', name: '正定国际机场', city: '石家庄'),
  Airport(code: 'TYN', name: '武宿国际机场', city: '太原'),
  Airport(code: 'HET', name: '白塔国际机场', city: '呼和浩特'),
  Airport(code: 'DLC', name: '周水子国际机场', city: '大连'),
  Airport(code: 'CGQ', name: '龙嘉国际机场', city: '长春'),
  Airport(code: 'HRB', name: '太平国际机场', city: '哈尔滨'),
  // 华东地区
  Airport(code: 'PVG', name: '浦东国际机场', city: '上海'),
  Airport(code: 'SHA', name: '虹桥国际机场', city: '上海'),
  Airport(code: 'NKG', name: '禄口国际机场', city: '南京'),
  Airport(code: 'NGB', name: '栎社国际机场', city: '宁波'),
  Airport(code: 'HGH', name: '萧山国际机场', city: '杭州'),
  Airport(code: 'WNZ', name: '龙湾国际机场', city: '温州'),
  Airport(code: 'CZX', name: '奔牛国际机场', city: '常州'),
  Airport(code: 'NTG', name: '兴东国际机场', city: '南通'),
  Airport(code: 'YIZ', name: '花果山国际机场', city: '连云港'),
  Airport(code: 'YNZ', name: '南洋国际机场', city: '盐城'),
  Airport(code: 'WUX', name: '苏南硕放国际机场', city: '无锡'),
  Airport(code: 'XUZ', name: '观音国际机场', city: '徐州'),
  Airport(code: 'LYG', name: '花果山国际机场', city: '连云港'),
  Airport(code: 'NJS', name: '南通机场', city: '南通'),
  Airport(code: 'HFE', name: '新桥国际机场', city: '合肥'),
  Airport(code: 'JJN', name: '晋江国际机场', city: '泉州'),
  Airport(code: 'XMN', name: '高崎国际机场', city: '厦门'),
  Airport(code: 'FOC', name: '长乐国际机场', city: '福州'),
  Airport(code: 'JNA', name: '泉州晋江国际机场', city: '泉州'),
  Airport(code: 'KHN', name: '昌北国际机场', city: '南昌'),
  Airport(code: 'TNA', name: '遥墙国际机场', city: '济南'),
  Airport(code: 'TAO', name: '胶东国际机场', city: '青岛'),
  Airport(code: 'YNT', name: '蓬莱国际机场', city: '烟台'),
  Airport(code: 'WEH', name: '大水泊国际机场', city: '威海'),
  Airport(code: 'WUS', name: '武夷山机场', city: '南平'),
  // 中南地区
  Airport(code: 'CAN', name: '白云国际机场', city: '广州'),
  Airport(code: 'SZX', name: '宝安国际机场', city: '深圳'),
  Airport(code: 'ZUH', name: '金湾国际机场', city: '珠海'),
  Airport(code: 'ZXY', name: '珠三角枢纽机场', city: '佛山'),
  Airport(code: 'JZH', name: '金湾机场', city: '珠海'),
  Airport(code: 'HAK', name: '美兰国际机场', city: '海口'),
  Airport(code: 'SYX', name: '凤凰国际机场', city: '三亚'),
  Airport(code: 'CSX', name: '黄花国际机场', city: '长沙'),
  Airport(code: 'HGH', name: '黄花机场', city: '长沙'),
  Airport(code: 'WUH', name: '天河国际机场', city: '武汉'),
  Airport(code: 'CGD', name: '桃花源机场', city: '常德'),
  Airport(code: 'NGB', name: '张家界荷花机场', city: '张家界'),
  Airport(code: 'ENH', name: '许家坪机场', city: '恩施'),
  Airport(code: 'KWE', name: '龙洞堡国际机场', city: '贵阳'),
  Airport(code: 'KWE', name: '龙堡机场', city: '贵阳'),
  Airport(code: 'HRB', name: '龙洞堡机场', city: '贵阳'),
  Airport(code: 'LHW', name: '中川国际机场', city: '兰州'),
  Airport(code: 'XNT', name: '中川机场', city: '兰州'),
  Airport(code: 'ZHY', name: '沙坡头机场', city: '中卫'),
  Airport(code: 'INC', name: '河东国际机场', city: '银川'),
  Airport(code: 'XNN', name: '曹家堡国际机场', city: '西宁'),
  Airport(code: 'SIA', name: '咸阳国际机场', city: '西安'),
  Airport(code: 'XIY', name: '西安咸阳国际机场', city: '西安'),
  // 西南地区
  Airport(code: 'CTU', name: '双流国际机场', city: '成都'),
  Airport(code: 'TFU', name: '天府国际机场', city: '成都'),
  Airport(code: 'CKG', name: '江北国际机场', city: '重庆'),
  Airport(code: 'KMG', name: '长水国际机场', city: '昆明'),
  Airport(code: 'KMG', name: '昆明长水机场', city: '昆明'),
  Airport(code: 'LPT', name: '长水机场', city: '昆明'),
  Airport(code: 'KWE', name: '龙洞堡机场', city: '贵阳'),
  Airport(code: 'LJG', name: '三义国际机场', city: '丽江'),
  Airport(code: 'DLU', name: '荒草坝机场', city: '大理'),
  Airport(code: 'JHG', name: '嘎洒国际机场', city: '西双版纳'),
  Airport(code: 'LZY', name: '林芝米林机场', city: '林芝'),
  Airport(code: 'RKZ', name: '和平机场', city: '日喀则'),
  Airport(code: 'BPX', name: '邦达机场', city: '昌都'),
  Airport(code: 'LXA', name: '贡嘎国际机场', city: '拉萨'),
  Airport(code: 'CTU', name: '双流机场', city: '成都'),
  // 东北地区
  Airport(code: 'SHE', name: '桃仙国际机场', city: '沈阳'),
  Airport(code: 'DLC', name: '周水子机场', city: '大连'),
  Airport(code: 'CGQ', name: '龙嘉机场', city: '长春'),
  Airport(code: 'HRB', name: '太平机场', city: '哈尔滨'),
  Airport(code: 'MDG', name: '海浪国际机场', city: '牡丹江'),
  Airport(code: 'JNZ', name: '浪头机场', city: '丹东'),
  Airport(code: 'CHG', name: '朝阳机场', city: '朝阳'),
  // 新疆地区
  Airport(code: 'URC', name: '地窝堡国际机场', city: '乌鲁木齐'),
  Airport(code: 'KCA', name: '龟兹机场', city: '库车'),
  Airport(code: 'HTN', name: '天合机场', city: '和田'),
  Airport(code: 'FNH', name: '梨城机场', city: '库尔勒'),
  Airport(code: 'AKU', name: '天山机场', city: '阿克苏'),
  Airport(code: 'YIN', name: '银犁机场', city: '伊宁'),
  Airport(code: 'KRL', name: '胜利机场', city: '克拉玛依'),
  Airport(code: 'KRY', name: '博乐机场', city: '博乐'),
  Airport(code: 'TCZ', name: '塔城机场', city: '塔城'),
  Airport(code: 'NLT', name: '那拉提机场', city: '新源'),
  // 其他
  Airport(code: 'WUA', name: '乌兰浩特机场', city: '乌兰浩特'),
  Airport(code: 'HLD', name: '海拉尔机场', city: '呼伦贝尔'),
  Airport(code: 'ACX', name: '兴义机场', city: '兴义'),
  Airport(code: 'ZYI', name: '茅台机场', city: '遵义'),
  Airport(code: 'KJJ', name: '黄果树机场', city: '安顺'),
  Airport(code: 'LLB', name: '荔波机场', city: '黔南'),
  Airport(code: 'WGN', name: '铜仁凤凰机场', city: '铜仁'),
  Airport(code: 'JUH', name: '九华山机场', city: '池州'),
  Airport(code: 'TXN', name: '屯溪国际机场', city: '黄山'),
  Airport(code: 'JDZ', name: '罗家机场', city: '景德镇'),
  Airport(code: 'JGS', name: '井冈山机场', city: '吉安'),
  Airport(code: 'YYG', name: '宜春机场', city: '宜春'),
  Airport(code: 'KOW', name: '黄金机场', city: '赣州'),
  Airport(code: 'SCM', name: '三清山机场', city: '上饶'),
  Airport(code: 'LCX', name: '冠豸山机场', city: '龙岩'),
  Airport(code: 'FOC', name: '长乐机场', city: '福州'),
  Airport(code: 'WUS', name: '武夷山机场', city: '南平'),
  Airport(code: 'PZI', name: '保安机场', city: '攀枝花'),
  Airport(code: 'GNI', name: '青山机场', city: '广元'),
  Airport(code: 'NAO', name: '南充高坪机场', city: '南充'),
  Airport(code: 'MIG', name: '盘龙机场', city: '绵阳'),
  Airport(code: 'LZO', name: '蓝田机场', city: '泸州'),
  Airport(code: 'ZYI', name: '新舟机场', city: '遵义'),
  Airport(code: 'GYD', name: '富乐机场', city: '广安'),
  Airport(code: 'LZS', name: '南郊机场', city: '宜宾'),
  Airport(code: 'YBP', name: '五粮液机场', city: '宜宾'),
  Airport(code: 'DZH', name: '梁平机场', city: '重庆'),
  Airport(code: 'JIQ', name: '武陵山机场', city: '重庆'),
  Airport(code: 'DAX', name: '达州河市机场', city: '达州'),
  Airport(code: 'LDS', name: '阆中机场', city: '南充'),
  Airport(code: 'DCY', name: '甘孜康定机场', city: '甘孜'),
  Airport(code: 'RHT', name: '红原机场', city: '阿坝'),
  Airport(code: 'AHJ', name: '马尔康机场', city: '阿坝'),
  Airport(code: 'XIC', name: '青山机场', city: '西昌'),
  Airport(code: 'BSD', name: '保山云瑞机场', city: '保山'),
  Airport(code: 'LUM', name: '芒市机场', city: '德宏'),
  Airport(code: 'XMN', name: '高崎机场', city: '厦门'),
  Airport(code: 'JJN', name: '晋江机场', city: '泉州'),
  Airport(code: 'WUS', name: '武夷山机场', city: '武夷山'),
  Airport(code: 'ZHY', name: '中卫沙坡头机场', city: '中卫'),
  Airport(code: 'HXD', name: '敦煌机场', city: '敦煌'),
  Airport(code: 'JIC', name: '酒泉机场', city: '酒泉'),
  Airport(code: 'GZI', name: '张掖甘州机场', city: '张掖'),
  Airport(code: 'JGN', name: '金昌金川机场', city: '金昌'),
  Airport(code: 'IQM', name: '柴达木机场', city: '海西'),
  Airport(code: 'HTT', name: '花土沟机场', city: '海西'),
];

/// 注册页面 - 基于 UI 设计 (Frame228)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Airport? _selectedAirport;

  @override
  void dispose() {
    _usernameController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final l10n = AppLocalizations.of(context)!;
      final success = await authProvider.register(
        _employeeIdController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text,
        _selectedAirport?.name ?? '',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.registerSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? l10n.registerFail),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padMd = Responsive.padding(context, AppSpacing.md);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '注册 / 激活账号',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              Text(
                '填写员工信息',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              // 用户名
              _buildInputField(
                controller: _usernameController,
                label: '用户名',
                hint: '请输入用户名',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  if (value.length < 2) {
                    return '用户名至少2个字符';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 员工工号
              _buildInputField(
                controller: _employeeIdController,
                label: '员工工号',
                hint: '请输入员工工号',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入员工工号';
                  }
                  if (value.trim().length < 4) {
                    return '工号格式不正确';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 机场选择
              _buildAirportDropdown(),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 设置密码
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 设置密码
              _buildInputField(
                controller: _passwordController,
                label: '设置密码（6-20位）',
                hint: '请设置登录密码',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondaryDark,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请设置密码';
                  }
                  if (value.length < 6) {
                    return '密码至少6位';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 确认密码
              _buildInputField(
                controller: _confirmPasswordController,
                label: '确认密码',
                hint: '请再次输入密码',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondaryDark,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请确认密码';
                  }
                  if (value != _passwordController.text) {
                    return '两次密码不一致';
                  }
                  return null;
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

              // 提交按钮
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              '提交注册',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

              // 提示
              Center(
                child: Text(
                  '提交后需等待管理员审核激活',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.8),
                  ),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

              // 已有账号登录
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '已有账号？',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      '立即登录',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 机场下拉选择器
  Widget _buildAirportDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '所属机场',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 8)),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark, width: 1),
          ),
          child: DropdownButtonFormField<Airport>(
            initialValue: _selectedAirport,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.flight_outlined, color: AppColors.textSecondaryDark, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text(
              '请选择所属机场',
              style: TextStyle(color: AppColors.textHintDark, fontSize: 15),
            ),
            dropdownColor: AppColors.surfaceDark,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondaryDark),
            validator: (value) {
              if (value == null) {
                return '请选择所属机场';
              }
              return null;
            },
            onChanged: (Airport? newValue) {
              setState(() {
                _selectedAirport = newValue;
              });
            },
            items: allAirports.map((airport) {
              return DropdownMenuItem<Airport>(
                value: airport,
                child: Text(
                  '${airport.city} ${airport.name} (${airport.code})',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryDark,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 8)),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: AppColors.textHintDark),
                    prefixIcon: Icon(icon, color: AppColors.textSecondaryDark, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon,
            ],
          ),
        ),
      ],
    );
  }
}
