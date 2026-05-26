import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        "question": "How do I book a flight?",
        "answer":
            "You can book a flight by navigating to the 'Flights' tab, entering your origin, destination, and travel dates, and selecting from the available options. Follow the prompts to complete your payment securely.",
      },
      {
        "question": "What is the cancellation policy?",
        "answer":
            "Cancellation policies vary depending on the service provider (airline, hotel, or tour operator). Please check the specific terms and conditions displayed during the booking process or on your booking details page.",
      },
      {
        "question": "How can I contact a live agent?",
        "answer":
            "If you need immediate assistance, please use the 'My Support Tickets' section to create a new ticket. Our agents will respond to you via the built-in chat as soon as possible.",
      },
      {
        "question": "Are there any hidden fees?",
        "answer":
            "No, we believe in full transparency. The price you see at checkout includes all applicable taxes and fees, unless otherwise specified by local regulations at your destination.",
      },
      {
        "question": "Can I modify an existing booking?",
        "answer":
            "Modifications are subject to availability and the specific provider's policy. Please raise a support ticket with your booking reference to request changes.",
      },
      {
        "question": "What payment methods are accepted?",
        "answer":
            "We accept local cards and mobile banking through SSLCommerz.",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Premium background
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    faqs[index]["question"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1A1F36), // Premium dark text
                    ),
                  ),
                  iconColor: const Color(0xFF3F51B5),
                  collapsedIconColor: Colors.grey.shade400,
                  childrenPadding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        faqs[index]["answer"]!,
                        style: const TextStyle(
                          color: Color(0xFF4F566B),
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
