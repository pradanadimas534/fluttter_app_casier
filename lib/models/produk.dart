class Produk {

  final String id;
  final String nama;
  final int harga;
  final int stok;

  Produk({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'].toString(),
      nama: json['nama'],
      harga: int.parse(json['harga'].toString()),
      stok: int.parse(json['stok'].toString()),
    );
  }

}