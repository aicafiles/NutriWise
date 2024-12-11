import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _gender = "Male";
  bool _isEditable = false;
  File? _profileImage;
  File? _coverImage;
  String? _profileImageUrl;
  String? _coverImageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc =
      await _firestore.collection('Users').doc(user.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        print("Retrieved user data: $data");
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? user.email ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _notesController.text = data['notes'] ?? '';
          _gender = data['gender'] ?? 'Male';
          _profileImageUrl = data['profileImage'];
          _coverImageUrl = data['coverImage'];
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<String?> _uploadImageToImgur(File imageFile) async {
    const String clientId = '78f4063bd410e97';
    try {
      final url = Uri.parse("https://api.imgur.com/3/image");
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Client-ID $clientId'
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['data']['link'];
      } else {
        print("Failed to upload image. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading to Imgur: $e");
      return null;
    }
  }

  Future<void> _pickImage(bool isProfileImage) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
      await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        String? uploadedImageUrl = await _uploadImageToImgur(imageFile);

        if (uploadedImageUrl != null) {
          setState(() {
            if (isProfileImage) {
              _profileImage = imageFile;
              _profileImageUrl = uploadedImageUrl;
            } else {
              _coverImage = imageFile;
              _coverImageUrl = uploadedImageUrl;
            }
          });

          final user = _auth.currentUser;
          if (user != null) {
            await _firestore.collection('Users').doc(user.uid).update({
              if (isProfileImage) 'profileImage': _profileImageUrl,
              if (!isProfileImage) 'coverImage': _coverImageUrl,
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image.")),
          );
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error picking image.")),
      );
    }
  }

  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('Users').doc(user.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'notes': _notesController.text,
        'gender': _gender,
        'profileImage': _profileImageUrl,
        'coverImage': _coverImageUrl,
      }, SetOptions(merge: true));

      setState(() {
        _isEditable = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontFamily: 'YesevaOne',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _isEditable ? () => _pickImage(false) : null,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: DecorationImage(
                        image: _coverImageUrl != null
                            ? NetworkImage(_coverImageUrl!)
                            : const AssetImage("assets/banner.jpg")
                        as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  child: GestureDetector(
                    onTap: _isEditable ? () => _pickImage(true) : null,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : const AssetImage("assets/profile.jpg")
                      as ImageProvider,
                      backgroundColor: Colors.grey.shade200,
                      child: _profileImageUrl == null && _isEditable
                          ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Center(
              child: _isEditable
                  ? TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              )
                  : Text(
                _nameController.text.isNotEmpty ? _nameController.text : "Name",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ..._buildProfileFields(),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isEditable ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    child: const Text("Save"),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditable = !_isEditable;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    child: Text(_isEditable ? "Cancel" : "Edit"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProfileFields() {
    return [
      _buildField("Email Address", _emailController, _isEditable),
      _buildField("Phone Number", _phoneController, _isEditable),
      const SizedBox(height: 10),
      const Text(
        "Notes",
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      const SizedBox(height: 10),
      _isEditable
          ? TextField(
        controller: _notesController,
        maxLines: 6,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.green, 
              width: 2, 
            ),
          ),
          hintText: "Enter your notes here",
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black87,
        ),
      )
          : Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green, 
            width: 2, 
          ),
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFF7F8FA),
        ),
        child: Text(
          _notesController.text.isNotEmpty
              ? _notesController.text
              : "No notes added.",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        value: _gender,
        onChanged: _isEditable ? (value) => setState(() => _gender = value!) : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFE8F5E9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        items: ["Male", "Female", "Other"]
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(
                    gender,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ))
            .toList(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black87,
        ),
        dropdownColor: const Color(0xFFF1F8E9),
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.green,
        ),
        isExpanded: true,
      ),
    ];
  }

  Widget _buildField(String label, TextEditingController controller, bool editable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 10),
        editable
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.green, 
                      width: 2,
                    ),
                  ),
                  hintText: "Enter your $label",
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black87,
                ),
              )
            : Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFFF7F8FA),
                ),
                child: Text(
                  controller.text.isNotEmpty
                      ? controller.text
                      : "No $label added.",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
        const SizedBox(height: 10),
      ],
    );
  }
}