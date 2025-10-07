import 'package:cloud_firestore/cloud_firestore.dart';

class Surat {
  final String? id;
  final String nomor;
  final String perihal;
  final String pengirimAsal;
  final String? penerimaTujuan;
  final String jenisSurat;
  final String status;
  final String tanggal;

  Surat({
    this.id,
    required this.nomor,
    required this.perihal,
    required this.pengirimAsal,
    this.penerimaTujuan,
    required this.jenisSurat,
    required this.status,
    required this.tanggal,
  });

  factory Surat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Surat(
      id: doc.id,
      nomor: data['nomor'],
      perihal: data['perihal'],
      pengirimAsal: data['pengirimAsal'],
      penerimaTujuan: data['penerimaTujuan'],
      jenisSurat: data['jenisSurat'],
      status: data['status'],
      tanggal: data['tanggal'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomor': nomor,
      'perihal': perihal,
      'pengirimAsal': pengirimAsal,
      'penerimaTujuan': penerimaTujuan,
      'jenisSurat': jenisSurat,
      'status': status,
      'tanggal': tanggal,
    };
  }
}