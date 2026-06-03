class ItemModel {
  final int id;
  String name;
  double price;
  double stock;
  double sold;
  final String type; // 'satuan' | 'timbang'
  final String unit; // 'pcs' | 'gram' | 'ons' | 'kg'

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.sold,
    required this.type,
    required this.unit,
  });

  // ── COPY WITH ────────────────────────────────────────────────────
  ItemModel copyWith({
    int? id,
    String? name,
    double? price,
    double? stock,
    double? sold,
    String? type,
    String? unit,
  }) =>
      ItemModel(
        id:    id    ?? this.id,
        name:  name  ?? this.name,
        price: price ?? this.price,
        stock: stock ?? this.stock,
        sold:  sold  ?? this.sold,
        type:  type  ?? this.type,
        unit:  unit  ?? this.unit,
      );

  // ── CSV HEADER ───────────────────────────────────────────────────
  static String csvHeader() => 'id,name,price,stock,sold,type,unit';

  // ── TO CSV ROW ───────────────────────────────────────────────────
  String toCsvRow() {
    // Nama di-wrap tanda kutip agar koma di dalam nama tidak merusak CSV
    final safeName = name.replaceAll('"', '""');
    return '$id,"$safeName",$price,$stock,$sold,$type,$unit';
  }

  // ── FROM CSV ROW ─────────────────────────────────────────────────
  factory ItemModel.fromCsvRow(String row) {
    final cols = _parseCsvRow(row);
    if (cols.length < 7) {
      throw FormatException('Format CSV tidak valid: $row');
    }
    return ItemModel(
      id:    int.parse(cols[0]),
      name:  cols[1],
      price: double.parse(cols[2]),
      stock: double.parse(cols[3]),
      sold:  double.parse(cols[4]),
      type:  cols[5],
      unit:  cols[6],
    );
  }

  // ── CSV PARSER ───────────────────────────────────────────────────
  // Handle quoted fields dengan benar (misal nama yang mengandung koma)
  static List<String> _parseCsvRow(String row) {
    final result  = <String>[];
    var   inQuote = false;
    var   buf     = StringBuffer();

    for (var i = 0; i < row.length; i++) {
      final ch = row[i];

      if (ch == '"') {
        // Escaped quote ("")
        if (inQuote && i + 1 < row.length && row[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuote = !inQuote;
        }
      } else if (ch == ',' && !inQuote) {
        result.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    result.add(buf.toString());
    return result;
  }
}