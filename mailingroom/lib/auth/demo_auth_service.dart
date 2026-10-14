import '../models/office.dart';
import '../models/user.dart';
import 'auth_service.dart';

class DemoAuthService extends AuthService {
  MyUser? _demoCurrentUser;

  final List<Map<String, dynamic>> _demoAccounts = [
    {
      'email': 'demo@mailingroom.com',
      'password': '123456',
      'name': 'Ruth Diana',
      'officeId': 'office-bandung',
    },
  ];

  final List<Office> _offices = [
    Office(
      id: 'office-bandung',
      namaOffice: 'Kantor Pos Bandung',
      alamat: 'Jl. Asia Afrika No. 49',
      kota: 'Bandung',
      kodePos: '40111',
      noTelp: '022-4200000',
    ),
    Office(
      id: 'office-jakarta',
      namaOffice: 'Kantor Pos Jakarta',
      alamat: 'Jl. Lapangan Banteng Utara',
      kota: 'Jakarta',
      kodePos: '10710',
      noTelp: '021-3500000',
    ),
    Office(
      id: 'office-surabaya',
      namaOffice: 'Kantor Pos Surabaya',
      alamat: 'Jl. Kebon Rojo No. 10',
      kota: 'Surabaya',
      kodePos: '60175',
      noTelp: '031-5310000',
    ),
  ];

  @override
  MyUser? get currentUser => _demoCurrentUser;

  @override
  bool get isCheckingLogin => false;

  @override
  Future<void> login(
    String email,
    String password,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    final account = _demoAccounts.where(
      (account) =>
          account['email'] == email &&
          account['password'] == password,
    );

    if (account.isEmpty) {
      throw Exception(
        'Email atau password demo salah.',
      );
    }

    final selectedAccount = account.first;

    _demoCurrentUser = MyUser(
      uid: 'demo-user-001',
      email: selectedAccount['email'],
      role: 'pengirim',
      nama: selectedAccount['name'],
      officeId: selectedAccount['officeId'],
      departemenId: 'demo-departemen',
      divisiId: 'demo-divisi',
      jabatan: 'Pengirim',
      phone: '0800000000',
    );

    notifyListeners();
  }

  @override
  Future<List<Office>> getOffices() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return _offices;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? officeId,
    String? subDirektoratId,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    final alreadyExists = _demoAccounts.any(
      (account) => account['email'] == email,
    );

    if (alreadyExists) {
      throw Exception(
        'Email sudah terdaftar pada demo.',
      );
    }

    _demoAccounts.add({
      'email': email,
      'password': password,
      'name': name,
      'officeId': officeId ?? 'office-bandung',
    });
  }

  @override
  Future<void> signOut() async {
    _demoCurrentUser = null;

    notifyListeners();
  }
}