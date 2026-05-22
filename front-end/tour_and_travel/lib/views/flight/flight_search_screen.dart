import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/flight_view_model.dart';
import '../../core/constant/app_colors.dart';
import 'flight_list_screen.dart';

class FlightSearchScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const FlightSearchScreen({super.key, this.scaffoldKey});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final FlightViewModel _flightViewModel = Get.put(FlightViewModel());
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  int _selectedTripType = 1; // 0=OneWay, 1=RoundTrip
  DateTime _departureDate = DateTime.now();
  DateTime _returnDate = DateTime.now();
  int _adults = 1;
  int _children = 0;
  String _cabinClass = 'Economy';

  final List<String> _tripTypes = ['One Way', 'Round Trip'];
  final List<String> _cabinOptions = ['Economy', 'Business', 'First Class'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image + Header
            _buildHeroHeader(context),

            // Trip Type Tabs
            _buildTripTypeTabs(),

            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Leaving From
                  _buildInputField(
                    controller: _fromController,
                    icon: Icons.flight_takeoff,
                    hint: "Leaving From",
                  ),
                  const SizedBox(height: 14),

                  // Going To
                  _buildInputField(
                    controller: _toController,
                    icon: Icons.flight_land,
                    hint: "Going To",
                  ),
                  const SizedBox(height: 14),

                  // Departure Date
                  _buildDateField(
                    label: "Departure Date",
                    date: _departureDate,
                    onTap: () => _pickDate(true),
                  ),
                  const SizedBox(height: 14),

                  // Return Date
                  if (_selectedTripType == 1) ...[
                    _buildDateField(
                      label: "Return Date",
                      date: _returnDate,
                      onTap: () => _pickDate(false),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Passengers Row
                  Row(
                    children: [
                      Expanded(child: _buildCounter("Adults", _adults, (v) => setState(() => _adults = v), min: 1)),
                      const SizedBox(width: 14),
                      Expanded(child: _buildCounter("Child", _children, (v) => setState(() => _children = v))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Cabin Class
                  _buildCabinClassDropdown(),
                  const SizedBox(height: 24),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                        shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                      onPressed: () {
                        if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
                          _flightViewModel.searchFlights(_fromController.text, _toController.text);
                          Get.back();
                        } else {
                          Get.snackbar("Validation", "Please enter both cities",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        }
                      },
                      child: const Text(
                        "Search Flights",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Clear All Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _fromController.clear();
                          _toController.clear();
                          _selectedTripType = 1;
                          _departureDate = DateTime.now();
                          _returnDate = DateTime.now();
                          _adults = 1;
                          _children = 0;
                          _cabinClass = 'Economy';
                        });
                        _flightViewModel.searchFlights('', '');
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Clear All", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Stack(
      children: [
        // Hero Image
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Icon(Icons.flight, size: 120, color: Colors.white.withOpacity(0.15)),
              ),
              // Gradient Overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.scaffoldBg],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // AppBar overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Search Flight",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing space for the back button
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(_tripTypes.length, (index) {
          bool isSelected = _selectedTripType == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTripType = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _tripTypes[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: Icon(icon, color: AppColors.primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                     'July', 'August', 'September', 'October', 'November', 'December'];
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: AppColors.primaryBlue, size: 24),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}",
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged, {int min = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _counterButton(Icons.remove, () {
                if (value > min) onChanged(value - 1);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _counterButton(Icons.add, () => onChanged(value + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.accentGold,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildCabinClassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _cabinClass,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'Cabin Class',
          labelStyle: TextStyle(color: AppColors.textSecondary),
        ),
        items: _cabinOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _cabinClass = v!),
      ),
    );
  }

  Future<void> _pickDate(bool isDeparture) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureDate : _returnDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }
}
