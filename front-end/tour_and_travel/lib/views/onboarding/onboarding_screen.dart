import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  List<Map<String, String>> data = [
    {
      "image": "assets/images/onbroading_screen1.png",
      "title": "Seamless Flight Bookings",
      "desc":
          "Book domestic and international flights at the best prices—quick, easy, and reliable."
    },
    {
      "image": "assets/images/onbroading_screen2.png",
      "title": "Customized Tour Planning",
      "desc":
          "Plan your dream getaway with expert-curated tours tailored to your preferences and budget."
    },
    {
      "image": "assets/images/onbroading_screen3.png",
      "title": "Comfortable Hotel Stays",
      "desc":
          "Find and book top-rated hotels worldwide with exclusive deals and hassle-free reservations."
    },
  ];
void finishOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('seenOnboarding', true);
  Get.offAllNamed(Routes.LOGIN); 
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: data.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(data[i]["image"]!, height: 300),
                      SizedBox(height: 30),
                      Text(
                        data[i]["title"]!,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                      Text(
                        data[i]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// DOT INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              data.length,
              (index) => Container(
                margin: EdgeInsets.all(4),
                width: currentIndex == index ? 10 : 8,
                height: currentIndex == index ? 10 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.blue
                      : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          /// BUTTON
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                if (currentIndex == data.length - 1) {
                  finishOnboarding();
                } else {
                  _controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                }
              },
              child: Text(
                currentIndex == data.length - 1
                    ? "Get Started"
                    : "Next",
              ),
            ),
          ),
        ],
      ),
    );
  }
}