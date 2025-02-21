import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:semesta_gym/components/mainButton.dart';
import 'package:semesta_gym/components/myTextFormField.dart';
import 'package:semesta_gym/components/passwordTextFormField.dart';
import 'package:semesta_gym/models/trainingFocus.dart';
import 'package:semesta_gym/screens/auth/personalTrainer/loginScreen.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class RegisterScreenTrainer extends StatefulWidget {
  const RegisterScreenTrainer({super.key});

  @override
  State<RegisterScreenTrainer> createState() => _RegisterScreenTrainerState();
}

class _RegisterScreenTrainerState extends State<RegisterScreenTrainer> {
  List<TrainingFocus> _trainingFocusList = [];
  List<TrainingFocus> _selectedTrainingFocus = [];
  bool _isLoading = true;
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController workoutHoursController = TextEditingController();
  final TextEditingController pricePerSessionController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;

  Future<void> fetchTrainingFocus() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:3000/api/training-focus'));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        if (jsonData.isEmpty) {
          print('API returned an empty list.');
        } else {
          print('First item in JSON: ${jsonData[0]}');
        }

        setState(() {
          _trainingFocusList = jsonData
              .map((data) {
                try {
                  return TrainingFocus.fromJson(data);
                } catch (e) {
                  print('Error parsing JSON: $e, Data: $data');
                  return null;
                }
              })
              .whereType<TrainingFocus>()
              .toList(); // Remove any null values

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load training focus data');
      }
    } catch (error) {
      print('Error fetching training focus: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final tempDir = await getApplicationDocumentsDirectory();
      final newPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = await imageFile.copy(newPath);

      String fileName = path.basename(newImage.path);
      print("✅ Extracted File Name: $fileName");

      setState(() {
        _selectedImage = newImage;
      });
    }
  }

  void _showPickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> registerTrainer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:3000/api/trainers/register/'),
      );

      // Add fields
      request.fields['email'] = emailController.text;
      request.fields['password'] = passwordController.text;
      request.fields['name'] = nameController.text;
      request.fields['phone'] = phoneNumberController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['hoursOfPractice'] = workoutHoursController.text;
      request.fields['price'] = pricePerSessionController.text;

      // Send trainingFocus as separate fields
      _selectedTrainingFocus.asMap().forEach((index, focus) {
        request.fields['trainingFocus[$index]'] = focus.id.toString();
      });

      print("Request Fields: ${request.fields}");

      if (_selectedImage != null) {
        String fileExtension =
            path.extension(_selectedImage!.path).toLowerCase();
        String mimeType = 'image/jpeg';

        if (fileExtension == '.png') {
          mimeType = 'image/png';
        } else if (fileExtension == '.jpg' || fileExtension == '.jpeg') {
          mimeType = 'image/jpeg';
        }

        var picture = await http.MultipartFile.fromPath(
          'picture',
          _selectedImage!.path,
          contentType: MediaType('image', mimeType.split('/')[1]),
        );

        request.files.add(picture);
        print("File Path: ${_selectedImage!.path}");
        print("MIME Type: $mimeType");
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Registration successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAll(() => LoginScreenTrainer());
      } else {
        final responseData = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseData);
        print("Response Body: $responseData");
        Get.snackbar(
          "Error",
          responseJson["message"] ?? "Registration failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      Get.snackbar(
        "Error",
        "Something went wrong. Try again later.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /*  Future<void> registerTrainer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/trainers/register/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
          "name": nameController.text,
          "phone": phoneNumberController.text,
          "trainingFocus": _selectedTrainingFocus.map((focus) => focus.id).toList(),
          "description": descriptionController.text,
          "hoursOfPractice": workoutHoursController.text,
          "price": pricePerSessionController.text,
          "picture": _selectedImage.toString()
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Registration successful!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        Get.offAll(() => LoginScreenTrainer());
      } else {
        Get.snackbar("Error", responseData["message"] ?? "Registration failed",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (error) {
      Get.snackbar("Error", "Something went wrong. Try again later.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  } */

  @override
  void initState() {
    super.initState();
    fetchTrainingFocus();
  }

  String getDisplayText() {
    String text = _selectedTrainingFocus.isEmpty
        ? "Pilih Fokus Pelatihan"
        : _selectedTrainingFocus.map((e) => e.name).join(", ");

    return text.length > 30 ? "${text.substring(0, 30)}..." : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(left: 32, right: 32, bottom: 32),
            child: Column(
              children: [
                Center(
                    child: Text(
                  "Register\nPersonal Trainer",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
                SizedBox(
                  height: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      "Nama Personal Trainer",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: nameController,
                      name: "Nama",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name/username";
                        }
                        if (value.length < 3) {
                          return "Name must be at least 3 characters long ";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        nameController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    // email
                    Text(
                      "Email",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: emailController,
                      name: "Email",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Please Enter Your Email");
                        }
                        if (!RegExp("^[a-zA-z0-9+_.-]+@[[a-zA-z0-9.-]+.[a-z]")
                            .hasMatch(value)) {
                          return ("Please Enter a valid email");
                        }
                        return null;
                      },
                      onSaved: (value) {
                        emailController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    // upload image
                    Text(
                      "Photo",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    FormField<File>(
                      validator: (value) {
                        if (_selectedImage == null) {
                          return "Please select an image";
                        }
                        return null;
                      },
                      builder: (FormFieldState<File> field) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _showPickerDialog,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: field.hasError
                                          ? Colors.red
                                          : Colors.grey),
                                ),
                                child: _selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(_selectedImage!.path),
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error,
                                                    size: 40,
                                                    color: Colors.red),
                                                SizedBox(height: 5),
                                                Text("Failed to load image",
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt,
                                              size: 40,
                                              color: Colors.grey[700]),
                                          SizedBox(height: 5),
                                          Text("Tap to upload photo",
                                              style: TextStyle(
                                                  color: Colors.grey[700])),
                                        ],
                                      ),
                              ),
                            ),
                            if (_selectedImage != null) ...[
                              SizedBox(height: 10),

                              // Image File Name
                              Text(
                                "Selected Image: ${_selectedImage!.path.split('/').last}",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),

                              SizedBox(height: 5),

                              // Delete Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                icon: Icon(Icons.delete, color: Colors.white),
                                label: Text("Remove Image"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                            if (field.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  field.errorText ?? "",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    // Fokus Pelatihan dropdown
                    Text(
                      "Fokus Pelatihan",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MultiSelectBottomSheetField(
                      initialChildSize: 0.4,
                      listType: MultiSelectListType.CHIP,
                      searchable: true,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      buttonIcon:
                          Icon(Icons.arrow_drop_down, color: Colors.black54),
                      buttonText: Text(
                        getDisplayText(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow
                            .ellipsis,
                        maxLines: 1,
                      ),
                      title: Text(
                        "Fokus Pelatihan",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      items: _trainingFocusList.isNotEmpty
                          ? _trainingFocusList
                              .map((focus) => MultiSelectItem<TrainingFocus>(
                                  focus, focus.name))
                              .toList()
                          : [],
                      initialValue: _selectedTrainingFocus,
                      validator: (values) {
                        if (values == null || values.isEmpty) {
                          return "Pilih setidaknya satu fokus pelatihan";
                        }
                        return null;
                      },
                      onConfirm: (values) {
                        setState(() {
                          _selectedTrainingFocus = values.cast<TrainingFocus>();
                        });
                      },
                      onSaved: (values) {
                        _selectedTrainingFocus =
                            values?.cast<TrainingFocus>() ?? [];
                      },
                      chipDisplay: MultiSelectChipDisplay.none(),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    // Descriptiona
                    Text(
                      "Deskripsi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: descriptionController,
                      name: "Deskripsi",
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your description";
                        }
                        if (value.length < 3) {
                          return "description must be at least 3 characters long ";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        descriptionController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    // no. hp
                    Text(
                      "No. Handphone",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: phoneNumberController,
                      name: "No. Handphone (Contoh: 0857xxxxxxxx)",
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Please Enter Your Phone Number");
                        }
                        if (value.length < 12) {
                          return "Phone Number must be at least 12 characters long ";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        phoneNumberController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    // Jam latihan
                    Text(
                      "Jam Latihan",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: workoutHoursController,
                      name: "Jam Latihan (Contoh: 12:00-14:00)",
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9:-]')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a time range";
                        }
                        final timeRangeRegex = RegExp(
                            r'^(?:[01]\d|2[0-3]):[0-5]\d-(?:[01]\d|2[0-3]):[0-5]\d$');
                        if (!timeRangeRegex.hasMatch(value)) {
                          return "Enter a valid time range (HH:mm-HH:mm)";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        workoutHoursController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    // Harga Perbulan
                    Text(
                      "Harga Perbulan/Sesi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    MyTextFormField(
                      controller: pricePerSessionController,
                      name: "Harga Perbulan/Sesi",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the price";
                        }
                        String numericValue =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (numericValue.isEmpty ||
                            int.tryParse(numericValue) == null) {
                          return "Invalid price format";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        pricePerSessionController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    // Password
                    Text(
                      "Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    PasswordTextFormField(
                      controller: passwordController,
                      name: "Password",
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return ("Password is required for Register");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Enter Valid Password(Min. 6 Character)");
                        }
                        return null;
                      },
                      onSaved: (value) {
                        passwordController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),

                    // Confirm Password
                    Text(
                      "Confirm Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    PasswordTextFormField(
                      controller: confirmPasswordController,
                      name: "Confirm Password",
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return ("Password is required for Register");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Enter Valid Password(Min. 6 Character)");
                        }
                        if (value != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        confirmPasswordController.text = value!;
                      },
                    ),
                    SizedBox(
                      height: 32,
                    ),
                  ],
                ),
                MainButton(
                  onPressed: () {
                    registerTrainer();
                  },
                  text: "Register",
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah Punya Akun? "),
                    InkWell(
                        onTap: () {
                          Get.offAll(() => LoginScreenTrainer());
                        },
                        child: Text(
                          "Login PT",
                          style: TextStyle(color: Color(0xFFF68989)),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
