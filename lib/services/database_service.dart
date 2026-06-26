import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_version/models/fuel_type_model.dart';
import 'package:new_version/models/station_model.dart';
import 'package:new_version/models/user_model.dart';

class DatabaseService {
  DatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<StationModel>> fetchStations() async {
    try {
      final snapshot = await _firestore.collection('stations').get();
      if (snapshot.docs.isEmpty) return _mockStations;
      return snapshot.docs
          .map((doc) => StationModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (_) {
      return _mockStations;
    }
  }

  Future<UserModel?> fetchUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(uid, doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  static final List<StationModel> _mockStations = [
    StationModel(
      id: '1',
      name: 'محطة توتال إنرجي - المعادي',
      address: 'شارع النصر، المعادي، القاهرة',
      latitude: 29.9602,
      longitude: 31.2569,
      distanceKm: 2.5,
      rating: 4.5,
      crowdStatus: CrowdStatus.low,
      imageUrl:
          'https://images.unsplash.com/photo-1574263867128-2b67e3b586b8?w=400',
      fuelTypes: const [
        FuelTypeModel(id: '92', name: 'بنزين 92', price: 17.25),
        FuelTypeModel(id: '95', name: 'بنزين 95', price: 19.50),
        FuelTypeModel(id: 'diesel', name: 'سولار', price: 14.75),
      ],
      services: const ['مغسلة', 'كافتيريا', 'ATM'],
      isOpen: true,
    ),
    StationModel(
      id: '2',
      name: 'محطة شل - التجمع الخامس',
      address: 'التجمع الخامس، القاهرة',
      latitude: 30.0131,
      longitude: 31.4913,
      distanceKm: 4.2,
      rating: 4.2,
      crowdStatus: CrowdStatus.medium,
      imageUrl:
          'https://images.unsplash.com/photo-1548269792-6c3be2a72a7d?w=400',
      fuelTypes: const [
        FuelTypeModel(id: '92', name: 'بنزين 92', price: 17.25),
        FuelTypeModel(id: '95', name: 'بنزين 95', price: 19.50),
      ],
      services: const ['سوبر ماركت', 'إطارات'],
      isOpen: true,
    ),
    StationModel(
      id: '3',
      name: 'محطة مصر - مدينة نصر',
      address: 'عباس العقاد، مدينة نصر',
      latitude: 30.0511,
      longitude: 31.3656,
      distanceKm: 6.8,
      rating: 3.9,
      crowdStatus: CrowdStatus.high,
      imageUrl:
          'https://images.unsplash.com/photo-1598032895826-30482a443a5d?w=400',
      fuelTypes: const [
        FuelTypeModel(id: '92', name: 'بنزين 92', price: 17.25, isAvailable: false),
        FuelTypeModel(id: '95', name: 'بنزين 95', price: 19.50),
      ],
      services: const ['كافتيريا'],
      isOpen: true,
    ),
    StationModel(
      id: '4',
      name: 'محطة أدنوك - الزمالك',
      address: 'شارع 26 يوليو، الزمالك',
      latitude: 30.0626,
      longitude: 31.2197,
      distanceKm: 8.1,
      rating: 4.7,
      crowdStatus: CrowdStatus.low,
      imageUrl:
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400',
      fuelTypes: const [
        FuelTypeModel(id: '95', name: 'بنزين 95', price: 19.50),
        FuelTypeModel(id: 'diesel', name: 'سولار', price: 14.75),
      ],
      services: const ['مغسلة', 'ATM', 'ورشة'],
      isOpen: true,
    ),
  ];
}
