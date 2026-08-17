import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_provider.dart';
import '../../core/utils/totp_utils.dart';
import '../../data/models/account.dart';
import '../manual_add/manual_add_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late MobileScannerController _cameraController;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isDetecting) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null) return;

    _isDetecting = true;
    _handleScannedData(rawValue);
  }

  void _handleScannedData(String data) {
    final otpData = TotpUtils.parseOtpAuthUri(data);
    if (otpData != null) {
      _showAddConfirmDialog(
        issuer: otpData.issuer,
        label: otpData.label,
        secret: otpData.secret,
      );
    } else if (_isValidSecret(data)) {
      _showAddConfirmDialog(
        issuer: '手动添加',
        label: '账户',
        secret: data,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法识别的二维码，请尝试手动输入'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() => _isDetecting = false);
    }
  }

  bool _isValidSecret(String secret) {
    final cleaned = secret.replaceAll(' ', '').toUpperCase();
    final validChars = RegExp(r'^[A-Z2-7]+$');
    return cleaned.length >= 16 && validChars.hasMatch(cleaned);
  }

  void _showAddConfirmDialog({
    required String issuer,
    required String label,
    required String secret,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('添加验证码账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('发行方', issuer),
            const SizedBox(height: 8),
            _infoRow('账户名', label),
            const SizedBox(height: 8),
            _infoRow('密钥', '${secret.substring(0, 6)}...${secret.substring(secret.length - 4)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isDetecting = false);
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AppProvider>().addAccount(Account(
                issuer: issuer,
                label: label,
                secret: secret,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('确认添加'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(child: Text(value, style: AppTextStyles.body)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),
          _buildScanOverlay(context),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const Spacer(),
                const Text(
                  '扫码二维码',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _cameraController.toggleTorch(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flash_off, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManualAddPage()),
                        );
                        if (result == true && mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.photo_outlined),
                      label: const Text('从照片导入'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManualAddPage()),
                        );
                        if (result == true && mounted) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('手动输入'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.65;
    final scanAreaTop = (size.height - scanAreaSize) / 2 - 40;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Positioned(
                top: scanAreaTop,
                left: scanAreaLeft,
                child: Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: scanAreaTop,
          left: scanAreaLeft,
          child: SizedBox(
            width: scanAreaSize,
            height: scanAreaSize,
            child: CustomPaint(
              painter: _ScanCornerPainter(
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ),
          ),
        ),
        Positioned(
          top: scanAreaTop + scanAreaSize + 16,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '将二维码放入框内',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanCornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ScanCornerPainter({this.color = AppColors.primary, this.strokeWidth = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLength = size.width * 0.15;
    final radius = 12.0;

    final path = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(cornerLength, 0);
    canvas.drawPath(path, paint);

    path
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(path, paint);

    path
      ..moveTo(size.width, size.height - cornerLength)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(size.width, size.height, size.width - radius, size.height)
      ..lineTo(size.width - cornerLength, size.height);
    canvas.drawPath(path, paint);

    path
      ..moveTo(cornerLength, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, size.height - cornerLength);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
