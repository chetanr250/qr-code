// ignore_for_file: use_build_context_synchronously
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

class QR extends StatefulWidget {
  const QR({Key? key}) : super(key: key);

  @override
  State<QR> createState() => _QRState();
}

class _QRState extends State<QR> {
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  bool isProcessingScan = false;
  bool isFlashOn = false;
  bool isBackCamera = true;

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (isProcessingScan) {
        return;
      }
      isProcessingScan = true;
      controller.pauseCamera();
      Vibration.vibrate(duration: 100);
      bool isUrl = await canLaunchUrl(
        Uri.parse(scanData.code!),
      );
      if (isUrl ||
          scanData.code!.startsWith('upi') ||
          scanData.code!.startsWith('http') ||
          scanData.code!.startsWith('https') ||
          scanData.code!.startsWith('tel') ||
          scanData.code!.startsWith('mailto') ||
          scanData.code!.startsWith('sms') ||
          scanData.code!.startsWith('geo') ||
          scanData.code!.startsWith('smsto') ||
          scanData.code!.startsWith('mms') ||
          scanData.code!.startsWith('nfc')) {
        launchUrl(Uri.parse(scanData.code!),
            mode: LaunchMode.externalApplication);
        isProcessingScan = false;
        return;
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            scrollable: true,
            content: SingleChildScrollView(
              child: Text(
                scanData.code ?? '',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Clipboard.setData(ClipboardData(text: scanData.code!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Text copied to clipboard'),
                    ),
                  );
                  await controller.resumeCamera();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Copy text'),
              ),
              TextButton(
                onPressed: () async {
                  await controller.resumeCamera();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      isProcessingScan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    void firstRun() async {
      await controller?.resumeCamera();
      isBackCamera = await controller?.getCameraInfo() == CameraFacing.back;
    }

    @override
    void initState() {
      super.initState();
      firstRun();
    }

    Color blur = const Color.fromARGB(99, 0, 0, 0);
    var width = MediaQuery.of(context).size.width * 0.80;
    var appBarHeight = AppBar().preferredSize.height;
    var bottomNavigationBarHeight = kBottomNavigationBarHeight;
    var safearea = MediaQuery.of(context).padding.top;
    var safeareaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: const Row(
            children: [
              Icon(Icons.qr_code_scanner),
              SizedBox(width: 8),
              Text('Scan QR'),
              // ]),
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                if (isFlashOn && isBackCamera) {
                  await controller?.toggleFlash();
                  setState(() {
                    isFlashOn = !isFlashOn;
                  });
                  isBackCamera = !isBackCamera;
                  controller?.flipCamera();
                  return;
                }
                isBackCamera = !isBackCamera;
                controller?.flipCamera();
              },
              icon: const Icon(Icons.flip_camera_ios_outlined)),
          IconButton(
              onPressed: () async {
                if (isBackCamera) {
                  controller?.toggleFlash();
                  setState(() {
                    isFlashOn = !isFlashOn;
                  });
                } else {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Flash not available'),
                    ),
                  );
                  return;
                }
              },
              icon: Icon(isFlashOn || !isBackCamera
                  ? Icons.flash_off_outlined
                  : Icons.flash_on_rounded)),
          IconButton(
              onPressed: () async {
                await controller?.resumeCamera();
                controller?.resumeCamera();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: GestureDetector(
        onTap: () async {
          await controller?.resumeCamera();
          controller?.resumeCamera();
        },
        onDoubleTap: () {
          if (isFlashOn && isBackCamera) {
            controller?.toggleFlash();
            setState(() {
              isFlashOn = !isFlashOn;
            });
            isBackCamera = !isBackCamera;
            controller?.flipCamera();
            return;
          }
          isBackCamera = !isBackCamera;
          controller?.flipCamera();
        },
        child: Stack(
          children: <Widget>[
            QRView(
              key: qrKey,
              onQRViewCreated: onQRViewCreated,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: (MediaQuery.of(context).size.height - width) / 2 -
                    appBarHeight -
                    safearea,
                width: width,
                decoration: BoxDecoration(
                  color: blur,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: (MediaQuery.of(context).size.height - width) / 2 -
                    bottomNavigationBarHeight -
                    safeareaBottom,
                width: width,
                decoration: BoxDecoration(color: blur),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 0.1,
                decoration: BoxDecoration(color: blur),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 0.1,
                decoration: BoxDecoration(color: blur),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    widthFactor: double.minPositive,
                    heightFactor: double.minPositive,
                    child: (result != null)
                        ? Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                reverse: true,
                                child: Text(
                                  result!.code.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'american typewriter',
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          )
                        : const Text('Scan a code'),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
