import 'package:flutter/material.dart';
import '../models/abnormal_baggage.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 证据详情页面
class EvidenceDetailScreen extends StatefulWidget {
  final AbnormalBaggage baggage;

  const EvidenceDetailScreen({super.key, required this.baggage});

  @override
  State<EvidenceDetailScreen> createState() => _EvidenceDetailScreenState();
}

class _EvidenceDetailScreenState extends State<EvidenceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final padMd = Responsive.padding(context, AppSpacing.md);
    final padSm = Responsive.padding(context, AppSpacing.sm);
    final spSm = Responsive.spacing(context, AppSpacing.sm);
    final spXs = Responsive.spacing(context, AppSpacing.xs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('证据详情'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            Padding(
              padding: EdgeInsets.all(padMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '行李号: ${widget.baggage.baggageNumber}',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.spacing(context, 12),
                          vertical: Responsive.spacing(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '破损行李',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: Responsive.fontSize(context, 13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spSm),
                  _buildInfoCard(context, padSm, spSm, spXs),
                  SizedBox(height: spSm),
                  _buildDescriptionCard(context, spSm, spXs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Container(
        width: double.infinity,
        height: screenWidth * 0.75,
        color: AppColors.backgroundLight,
        child: widget.baggage.imageUrl.isNotEmpty
            ? Image.network(
                widget.baggage.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                        SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                        Text(
                          '加载中...',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 12),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: Responsive.iconSize(context, 64),
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                        Text(
                          '图片加载失败',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: Responsive.iconSize(context, 64),
                  color: Colors.grey[400],
                ),
              ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    if (widget.baggage.imageUrl.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              '行李号: ${widget.baggage.baggageNumber}',
              style: const TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.baggage.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, double padSm, double spSm, double spXs) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Padding(
        padding: EdgeInsets.all(padSm),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              Icons.confirmation_number_outlined,
              '行李号',
              widget.baggage.baggageNumber,
              spSm,
              spXs,
            ),
            Divider(color: Colors.grey[200], height: spSm * 2),
            _buildInfoRow(
              context,
              Icons.access_time,
              '记录时间',
              widget.baggage.formattedTime,
              spSm,
              spXs,
            ),
            Divider(color: Colors.grey[200], height: spSm * 2),
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              '记录地点',
              widget.baggage.location,
              spSm,
              spXs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    double spSm,
    double spXs, {
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: Responsive.iconSize(context, 18), color: AppColors.primary),
        SizedBox(width: spSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: spXs),
              SelectableText(
                value,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(BuildContext context, double spSm, double spXs) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  size: Responsive.iconSize(context, 18),
                  color: AppColors.error,
                ),
                SizedBox(width: spSm),
                Text(
                  '破损描述',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 13),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: spSm),
            Text(
              widget.baggage.damageDescription,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}