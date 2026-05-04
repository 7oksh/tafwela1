import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatelessWidget {

  EditProfileScreen({super.key});

  // Firebase Image
  final String networkImage =
      "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=687&auto=format&fit=crop&auto=format";

  // Controllers
  final firstNameController =
  TextEditingController();

  final lastNameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  // Image Picker
  final ImagePicker picker =
  ImagePicker();

  // Local Image
  final Rx<Uint8List?> selectedImage =
  Rx<Uint8List?>(null);

  // Pick Image
  Future<void> pickImage(
      ImageSource source,
      ) async {

    final pickedFile =
    await picker.pickImage(
      source: source,
    );

    if (pickedFile != null) {

      final bytes =
      await pickedFile.readAsBytes();

      selectedImage.value = bytes;
    }
  }

  // Bottom Sheet
  void showImagePicker(
      BuildContext context,
      ) {

    showModalBottomSheet(

      context: context,

      builder: (context) {

        return SafeArea(

          child: Wrap(

            children: [

              ListTile(

                leading: const Icon(
                  Icons.camera_alt,
                ),

                title: const Text(
                  "الكاميرا",
                ),

                onTap: () {

                  Navigator.pop(context);

                  pickImage(
                    ImageSource.camera,
                  );
                },
              ),

              ListTile(

                leading: const Icon(
                  Icons.photo_library,
                ),

                title: const Text(
                  "المعرض",
                ),

                onTap: () {

                  Navigator.pop(context);

                  pickImage(
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F7FA),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF0B245B),

        elevation: 0,

        centerTitle: true,

        title: Text(

          "تعديل البيانات",

          style: GoogleFonts.cairo(

            color: Colors.white,

            fontSize: 22,

            fontWeight:
            FontWeight.bold,
          ),
        ),

        leading: IconButton(

          onPressed: () {
            Get.back();
          },

          icon: const Icon(

            Icons.arrow_back_ios,

            color: Colors.white,
          ),
        ),
      ),

      body: Column(

        children: [

          const SizedBox(height: 20),

          // Profile Image
          GestureDetector(

            onTap: () {
              showImagePicker(context);
            },

            child: Obx(() => Stack(

              alignment:
              Alignment.bottomLeft,

              children: [

                CircleAvatar(

                  radius: 55,

                  backgroundColor:
                  Colors.orange.shade200,

                  backgroundImage:

                  selectedImage.value != null

                      ? MemoryImage(
                    selectedImage.value!,
                  )

                      : NetworkImage(
                    networkImage,
                  ) as ImageProvider,
                ),

                GestureDetector(

                  onTap: () {
                    showImagePicker(
                      context,
                    );
                  },

                  child: Container(

                    padding:
                    const EdgeInsets.all(6),

                    decoration:
                    const BoxDecoration(

                      color:
                      Color(0xFF0B245B),

                      shape:
                      BoxShape.circle,
                    ),

                    child: const Icon(

                      Icons.camera_alt,

                      color: Colors.white,

                      size: 18,
                    ),
                  ),
                ),
              ],
            )),
          ),

          const SizedBox(height: 30),

          Expanded(

            child: Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: Column(

                children: [

                  buildField(

                    "الاسم الأول",

                    "أدخل الاسم الأول",

                    firstNameController,
                  ),

                  buildField(

                    "اسم العائلة",

                    "أدخل اسم العائلة",

                    lastNameController,
                  ),

                  buildField(

                    "البريد الإلكتروني",

                    "example@mail.com",

                    emailController,

                    keyboardType:
                    TextInputType
                        .emailAddress,
                  ),

                  buildField(

                    "رقم الهاتف",

                    "+966xxxxxxxxx",

                    phoneController,

                    keyboardType:
                    TextInputType.phone,
                  ),

                  const Spacer(),

                  SizedBox(

                    width: double.infinity,

                    height: 60,

                    child: ElevatedButton(

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        const Color(
                          0xFF0B245B,
                        ),

                        shape:
                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),

                      onPressed: () async {

                        // Firebase upload later
                        if (selectedImage.value !=
                            null) {

                          print(
                            "Upload image to Firebase",
                          );
                        }

                        Get.snackbar(

                          "تم الحفظ",

                          "تم تحديث البيانات بنجاح",

                          backgroundColor:
                          Colors.green,

                          colorText:
                          Colors.white,
                        );
                      },

                      child: Text(

                        "حفظ التغييرات",

                        style:
                        GoogleFonts.cairo(

                          fontSize: 18,

                          fontWeight:
                          FontWeight.bold,

                          color:
                          Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildField(
      String label,
      String hint,
      TextEditingController controller, {

        TextInputType keyboardType =
            TextInputType.text,
      }) {

    return SizedBox(

      width: double.infinity,

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.end,

        children: [

          Align(

            alignment:
            Alignment.centerRight,

            child: Text(

              label,

              textAlign:
              TextAlign.right,

              style: GoogleFonts.cairo(

                fontSize: 16,

                fontWeight:
                FontWeight.w600,

                color:
                Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 8),

          TextField(

            controller: controller,

            keyboardType: keyboardType,

            textAlign: TextAlign.right,

            textDirection:
            TextDirection.rtl,

            decoration: InputDecoration(

              hintText: hint,

              hintTextDirection:
              TextDirection.rtl,

              hintStyle:
              GoogleFonts.cairo(

                color: Colors.grey,
              ),

              filled: true,

              fillColor: Colors.white,

              contentPadding:
              const EdgeInsets.symmetric(

                horizontal: 16,

                vertical: 18,
              ),

              border:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(14),

                borderSide:
                BorderSide.none,
              ),
            ),

            onChanged: (value) {

              // Names only
              if (label.contains("الاسم")) {

                controller.text =
                    value.replaceAll(

                      RegExp(
                        r'[^a-zA-Zأ-ي ]',
                      ),

                      '',
                    );

                controller.selection =
                    TextSelection.fromPosition(

                      TextPosition(
                        offset:
                        controller.text.length,
                      ),
                    );
              }

              // Phone only
              if (label.contains("الهاتف")) {

                controller.text =
                    value.replaceAll(

                      RegExp(r'[^0-9+]'),

                      '',
                    );

                controller.selection =
                    TextSelection.fromPosition(

                      TextPosition(
                        offset:
                        controller.text.length,
                      ),
                    );
              }
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}