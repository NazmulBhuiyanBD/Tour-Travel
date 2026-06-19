import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../view_models/auth_view_model.dart';
import '../../view_models/user_view_model.dart';
import '../../view_models/review_view_model.dart';
import '../../core/constant/app_colors.dart';
import '../../core/constant/api_constants.dart';
import '../../routes/app_routes.dart';
import '../../data/api/network_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserViewModel _userViewModel = Get.put(UserViewModel());
  final AuthViewModel _authViewModel = Get.find<AuthViewModel>();
  final ReviewViewModel _reviewViewModel = Get.put(ReviewViewModel());

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  String? _selectedGender;
  String? _profilePicUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final user = _authViewModel.user.value;
    _nameController = TextEditingController(text: user.name ?? '');
    _phoneController = TextEditingController(text: user.phone ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _dobController = TextEditingController(text: _formatDate(user.dateOfBirth));
    _addressController = TextEditingController(text: user.address ?? '');
    _selectedGender = user.gender;
    _profilePicUrl = user.profilePicture;

    // Fetch user reviews
    _reviewViewModel.fetchUserReviews();
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "";
    try {
      final date = DateTime.parse(isoDate);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return isoDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email (Read Only)',
                      icon: Icons.email_outlined,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty
                          ? 'Please enter your phone number'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(),
                    const SizedBox(height: 20),
                    _buildDatePickerField(context),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home_outlined,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your address' : null,
                    ),
                    const SizedBox(height: 40),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _userViewModel.isLoading.value
                              ? null
                              : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                          ),
                          child: _userViewModel.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildReviewsSummary(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSummary() {
    return Obx(() {
      final reviewsCount = _reviewViewModel.userReviews.length;
      if (reviewsCount == 0) return const SizedBox.shrink();

      double avgRating = 0;
      for (var review in _reviewViewModel.userReviews) {
        avgRating += review['rating'] ?? 0;
      }
      avgRating = avgRating / reviewsCount;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Reviews",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      reviewsCount.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Reviews",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Avg Rating",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () {
                  Get.toNamed(Routes.MY_REVIEWS);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "View All Reviews",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _selectAndUploadImage,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage:
                        _profilePicUrl != null && _profilePicUrl!.isNotEmpty
                        ? NetworkImage(
                            "${ApiConstants.mediaBaseUrl}$_profilePicUrl",
                          )
                        : null,
                    child: _isUploading
                        ? const CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          )
                        : (_profilePicUrl == null || _profilePicUrl!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.textSecondary,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _authViewModel.user.value.name ?? 'User',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _authViewModel.user.value.email ?? '',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF8F9FA) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: readOnly ? Colors.grey.shade400 : AppColors.primaryBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        items: ['Male', 'Female', 'Other'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) =>
            value == null ? 'Please select your gender' : null,
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return _buildTextField(
      controller: _dobController,
      label: 'Date of Birth',
      icon: Icons.cake_outlined,
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dobController.text =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          });
        }
      },
      validator: (value) =>
          value!.isEmpty ? 'Please enter your date of birth' : null,
    );
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      _userViewModel.updateProfile(
        _nameController.text,
        _phoneController.text,
        _selectedGender ?? '',
        _dobController.text,
        _addressController.text,
        _profilePicUrl,
      );
    }
  }

  Future<void> _selectAndUploadImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryBlue,
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _isUploading = true;
      });

      final NetworkApiService apiService = NetworkApiService();
      final response = await apiService.getMultipartApiResponse(
        ApiConstants.baseUrl + ApiConstants.supportUpload,
        file,
      );

      if (response != null && response['path'] != null) {
        setState(() {
          _profilePicUrl = response['path'];
          _isUploading = false;
        });
        Get.snackbar(
          "Success",
          "Profile picture uploaded successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        setState(() {
          _isUploading = false;
        });
        Get.snackbar(
          "Upload Failed",
          "Failed to upload image. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
