import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
            fontSize: 22,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find the best food recommendations tailored for you.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),

              // Contact Information Box
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactRow(
                      icon: Icons.email,
                      label: 'nutriwisee@gmail.com',
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildContactRow(
                      icon: Icons.phone,
                      label: '09761252854',
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildContactRow(
                      icon: Icons.location_on,
                      label: 'Golden Country Homes, Alangilan Batangas City',
                      iconColor: Colors.green,
                      isAddress: true,  // Flag for address row
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each contact row
  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required Color iconColor,
    bool isAddress = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 12),
        // For address, make sure it wraps properly
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            overflow: isAddress ? TextOverflow.visible : TextOverflow.ellipsis,  // Allow address to wrap
            maxLines: isAddress ? null : 1,  // Allow address to use multiple lines
          ),
        ),
      ],
    );
  }
}
