import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isEditable = false;
  File? _profileImage;
  File? _coverImage;

  Future<void> _checkPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _pickImage(bool isProfileImage) async {
    await _checkPermissions();
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfileImage) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
      });
    }
  }

  void _showImageOptions(bool isProfileImage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Upload New Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(isProfileImage);
                },
              ),
              if ((isProfileImage ? _profileImage : _coverImage) != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Remove Photo"),
                  onTap: () {
                    setState(() {
                      if (isProfileImage) {
                        _profileImage = null;
                      } else {
                        _coverImage = null;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = "Coco Martin"; // Default name
    _emailController.text = "coco.martin@example.com";
    _phoneController.text = "+63 912 345 6789";
    _genderController.text = "Male";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'Smart Swap',
              style: TextStyle(
                fontFamily: 'YesevaOne',
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditable ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditable = !_isEditable;
              });
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3F3F3),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => _showImageOptions(false),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: _coverImage != null
                            ? DecorationImage(
                          image: FileImage(_coverImage!),
                          fit: BoxFit.cover,
                        )
                            : const DecorationImage(
                          image: AssetImage("assets/cover-placeholder.jpg"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 140,
                    child: GestureDetector(
                      onTap: () => _showImageOptions(true),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage("assets/profile-placeholder.jpg")
                        as ImageProvider,
                        backgroundColor: Colors.grey.shade200,
                        child: _profileImage == null && _isEditable
                            ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 150,
                    top: 210, // Adjusted lower for better alignment
                    child: Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Adjusted spacing
              if (_isEditable)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditableField("Email Address", _emailController),
                    const SizedBox(height: 15),
                    _buildEditableField("Phone Number", _phoneController),
                    const SizedBox(height: 15),
                    _buildEditableField("Gender", _genderController),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDisplayField("Email Address", _emailController.text),
                    const SizedBox(height: 10),
                    _buildDisplayField("Phone Number", _phoneController.text),
                    const SizedBox(height: 10),
                    _buildDisplayField("Gender", _genderController.text),
                  ],
                ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE), // Light pastel blue
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _notesController,
                  enabled: _isEditable,
                  decoration: const InputDecoration(
                    hintText: "Enter your notes here...",
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter $label",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayField(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
