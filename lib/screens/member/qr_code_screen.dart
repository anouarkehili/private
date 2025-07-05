import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code الخاص بي'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<UserModel?>(
        future: authService.getUserData(authService.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('حدث خطأ في تحميل البيانات'));
          }

          final user = snapshot.data!;
          final qrData = user.qrCodeData;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (qrData != null && qrData.isNotEmpty)
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 250.0,
                    backgroundColor: Colors.white,
                  )
                else
                  const Text(
                    'لا يوجد QR Code متاح حالياً.',
                    style: TextStyle(fontSize: 18),
                  ),
                const SizedBox(height: 20),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'قم بإظهار هذا الكود لمسؤول الصالة لتسجيل حضورك',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
