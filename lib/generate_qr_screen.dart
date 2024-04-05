import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrcode_scanner/generate_qr.dart';
import 'package:image_picker/image_picker.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _textController = TextEditingController();

  bool isCustomised = false;
  bool isImageUploaded = false;
  String uploadingStatus = 'Embed an Image in QR Code';
  List<bool> selectedShape = [true, false];
  var imagePath = '';

  Map<String, Color> colors = {
    'Black': Colors.black,
    'Red': Color.fromARGB(255, 255, 43, 28),
    'Blue': const Color.fromARGB(255, 0, 140, 255),
    'Green': const Color.fromARGB(255, 98, 239, 103),
    'Yellow': Colors.yellow,
    'Orange': const Color.fromARGB(255, 252, 170, 47),
    'Purple': const Color.fromARGB(255, 183, 75, 202),
    'Deep Blue': const Color.fromARGB(255, 0, 0, 255),
  };
  List<bool> selectedColor1 = [true, false, false, false];
  List<bool> selectedColor2 = [false, false, false, false];
  int? shape;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<Object?>>[
                PopupMenuItem<String>(
                  value: 'Basic',
                  child: Row(
                    children: [
                      Icon(!isCustomised
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank),
                      const SizedBox(width: 8),
                      const Text('Basic QR Code'),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      isCustomised = false;
                    });
                  },
                ),
                PopupMenuItem<String>(
                  padding: const EdgeInsets.all(10),
                  value: 'Customised',
                  child: Row(
                    children: [
                      Icon(isCustomised
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank),
                      const SizedBox(width: 8),
                      const Text('Customised QR Code'),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      isCustomised = true;
                    });
                  },
                ),
              ];
            },
          ),
        ],
        title: Container(
          alignment: Alignment.center,
          child: const Row(
            children: [
              Icon(Icons.qr_code),
              SizedBox(width: 8),
              Text('Generate QR'),
              // ]),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                // scrollPadding: EdgeInsets.all(20),
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter text to generate QR',
                ),
              ),
              // customised QR code
              if (isCustomised)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    // const SizedBox(height: 12),
                    const Text(
                      'QR Shape',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Shape Toggle Buttons
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(10),
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width / 2 - 20,
                        minHeight: 40,
                      ),
                      isSelected: selectedShape,
                      onPressed: (index) {
                        setState(() {
                          for (int i = 0; i < selectedShape.length; i++) {
                            if (i == index) {
                              selectedShape[i] = true;
                            } else {
                              selectedShape[i] = false;
                            }
                          }
                        });
                      },
                      children: const [
                        Text('Square'),
                        Text('Circle'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Color Toggle Buttons
                    const Text(
                      'QR Colour',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Wrap(alignment: WrapAlignment.center, children: [
                      // 1st half of colors
                      ToggleButtons(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        isSelected: selectedColor1,
                        onPressed: (index) {
                          setState(() {
                            selectedColor2 =
                                List.filled(colors.length ~/ 2, false);
                            for (int i = 0; i < selectedColor1.length; i++) {
                              if (i == index) {
                                selectedColor1[i] = true;
                              } else {
                                selectedColor1[i] = false;
                              }
                            }
                          });
                        },
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width /
                                  (colors.length / 2) -
                              10,
                          minHeight: 40,
                        ),
                        children: [
                          for (int i = 0; i < selectedColor1.length; i++)
                            Text(
                              colors.keys.elementAt(i),
                            ),
                        ],
                      ),

                      // 2nd half of colors
                      ToggleButtons(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        onPressed: (index) {
                          setState(() {
                            selectedColor1 =
                                List.filled(colors.length ~/ 2, false);
                            for (int i = 0; i < selectedColor2.length; i++) {
                              if (i == index) {
                                selectedColor2[i] = true;
                              } else {
                                selectedColor2[i] = false;
                              }
                            }
                          });
                        },
                        isSelected: selectedColor2,
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width /
                                  (colors.length / 2) -
                              10,
                          minHeight: 40,
                        ),
                        children: [
                          for (int i = 0; i < colors.length / 2; i++)
                            Text(
                              colors.keys.elementAt(i + colors.length ~/ 2),
                            ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: isImageUploaded
                                ? MaterialStateProperty.all(
                                    const Color.fromARGB(255, 0, 253, 21))
                                : MaterialStateProperty.all(
                                    const Color.fromARGB(85, 0, 168, 253)),
                            side: MaterialStateProperty.all(
                              const BorderSide(
                                color: Color.fromARGB(85, 0, 168, 253),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              uploadingStatus = 'Uploading Image...';
                            });
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedFile == null) {
                              setState(() {
                                uploadingStatus = 'Upload Image';
                              });
                              return;
                            }
                            setState(() {
                              isImageUploaded = true;
                            });
                            final tempDir = await getTemporaryDirectory();
                            final tempPath =
                                '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';

                            final File tempFile = File(tempPath);
                            await tempFile
                                .writeAsBytes(await pickedFile.readAsBytes());
                            imagePath = tempPath;
                            setState(() {
                              uploadingStatus = 'Image loaded';
                            });
                          },
                          icon: Icon(
                              isImageUploaded ? Icons.done : Icons.upload,
                              color: isImageUploaded
                                  ? Colors.black
                                  : Colors.white),
                          label: Text(
                            uploadingStatus,
                            style: isImageUploaded
                                ? const TextStyle(color: Colors.black)
                                : const TextStyle(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        isImageUploaded
                            ? IconButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color.fromARGB(
                                            44, 162, 162, 162)),
                                    iconColor: MaterialStateColor.resolveWith(
                                        (states) => isImageUploaded
                                            ? Colors.red
                                            : Colors.black)),
                                onPressed: () {
                                  setState(() {
                                    isImageUploaded = false;
                                    uploadingStatus =
                                        'Embed an Image in QR Code';
                                  });

                                  imagePath = '';
                                },
                                icon: const Icon(Icons.delete_outlined),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                      color: Color.fromARGB(85, 0, 168, 253), width: 1),
                  // backgroundColor: Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () {
                  if (_textController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter some text'),
                      ),
                    );
                    return;
                  }
                  String data = _textController.text;
                  showModalBottomSheet(
                    useSafeArea: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => GenerateQR(
                      data: data,
                      dataModuleColor: isCustomised
                          ? colors.values.elementAt(
                              [...selectedColor1, ...selectedColor2]
                                  .indexOf(true),
                            )
                          : Colors.black,
                      eyeShape: isCustomised ? selectedShape.indexOf(true) : 0,
                      imagePath: imagePath,
                    ),
                  );
                  // _textController.clear();
                },
                child: const Text('Generate QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
