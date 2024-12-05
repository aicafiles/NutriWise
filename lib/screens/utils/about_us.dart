import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'About Us',
          style: TextStyle(
            fontFamily: 'YesevaOne',
            fontSize: 20,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome to NutriWise!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'At NutriWise, we are dedicated to bringing you the best food recommendations tailored to your needs. Our mission is to make healthy eating easy, accessible, and enjoyable for everyone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'nutriwisee@gmail.com',
                      iconColor: Colors.green,
                    ),
                    const Divider(height: 30, thickness: 1, color: Colors.green),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: '0976 125 2854',
                      iconColor: Colors.green,
                    ),
                    const Divider(height: 30, thickness: 1, color: Colors.green),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      label:
                      'Golden Country Homes, Alangilan Batangas City, Philippines',
                      iconColor: Colors.green,
                      isAddress: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Our team is committed to innovation and excellence. We are constantly working to improve your experience and ensure that you receive the best recommendations for a healthier, happier lifestyle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Color iconColor,
    bool isAddress = false,
  }) {
    return Row(
      crossAxisAlignment:
      isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: isAddress ? TextOverflow.visible : TextOverflow.ellipsis,
            maxLines: isAddress ? null : 1,
          ),
        ),
      ],
    );
  }
}
