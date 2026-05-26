class HotelModel {
  int? id;
  String? name;
  String? location;
  String? description;
  double? rating;
  String? imageUrl;
  String? galleryImages;
  String? amenities;
  double? pricePerNight;
  int? availableRooms;
  bool? isFeatured;
  String? contactInfo;
  List<dynamic> rooms = [];

  HotelModel({
    this.id,
    this.name,
    this.location,
    this.description,
    this.rating,
    this.imageUrl,
    this.galleryImages,
    this.amenities,
    this.pricePerNight,
    this.availableRooms,
    this.isFeatured,
    this.contactInfo,
    this.rooms = const [],
  });

  HotelModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    location = json['location'];
    description = json['description'];
    rating = (json['rating'] as num?)?.toDouble();
    imageUrl = json['imageUrl'];
    galleryImages = json['galleryImages'];
    amenities = json['amenities'];
    pricePerNight = (json['pricePerNight'] as num?)?.toDouble();
    availableRooms = json['availableRooms'];
    isFeatured = json['isFeatured'];
    contactInfo = json['contactInfo'];
    rooms = json['rooms'] is List ? json['rooms'] : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['location'] = location;
    data['description'] = description;
    data['rating'] = rating;
    data['imageUrl'] = imageUrl;
    data['galleryImages'] = galleryImages;
    data['amenities'] = amenities;
    data['pricePerNight'] = pricePerNight;
    data['availableRooms'] = availableRooms;
    data['isFeatured'] = isFeatured;
    data['contactInfo'] = contactInfo;
    data['rooms'] = rooms;
    return data;
  }

  List<String> get galleryList {
    if (galleryImages == null || galleryImages!.isEmpty) {
      return imageUrl != null ? [imageUrl!] : [];
    }
    return galleryImages!.split(',').map((e) => e.trim()).toList();
  }

  List<String> get amenitiesList {
    if (amenities == null || amenities!.isEmpty) {
      return [];
    }
    return amenities!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Map<String, dynamic>? get primaryRoom {
    if (rooms.isEmpty) return null;
    final room = rooms.first;
    return room is Map<String, dynamic>
        ? room
        : Map<String, dynamic>.from(room as Map);
  }

  String get roomSummary {
    final room = primaryRoom;
    if (room == null) return "Single Room • King Bed • City View • AC";
    final acLabel = room['isAc'] == false ? 'Non AC' : 'AC';
    return "${room['type'] ?? 'Single Room'} • ${room['bedType'] ?? 'King Bed'} • ${room['viewType'] ?? 'City View'} • $acLabel";
  }
}
