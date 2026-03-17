import 'package:flutter/material.dart';

class GoodsKindRadio extends StatefulWidget {
  final String? selectedValue;
  final Function(String?) onChanged;

  const GoodsKindRadio({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<GoodsKindRadio> createState() => _GoodsKindRadioState();
}

class _GoodsKindRadioState extends State<GoodsKindRadio> {

  final List<String> items = [
    "Peralatan Kantor",
    "Perangkat Teknologi",
    "Perlengkapan Kerja",
    "Elektronik Kantor",
    "Peralatan Presentasi",
    "Barang Kecil",
    "Buku dan Dokumen",
    "Pakaian dan Perlengkapan Pribadi",
    "Komponen IT",
    "AQMS LCS 2023",
    "WQMS ONLIMO 2023",
    "WQMS ONLIMO 2024",
    "AQMS LCS 2024",
    "AQMS REFERENCE 2024",
    "AQMS FIX SYSTEM 2024",
    "SPARING",
    "HVAS",
    "AQMS KSP",
    "AQMS 2024",
    "Alat Lab",
    "Pameran",
    "Produk Khusus atau Barang Spesifik",
    "Lainnya"
  ];

  String search = "";

  @override
  Widget build(BuildContext context) {

    final filtered = items
        .where((item) => item.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Card(
      
      color: const Color(0xFF1f2937),
      // margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Color(0xFF2d4a7c)
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            /// SEARCH FILTER
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Cari jenis barang...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF131927),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            /// LIST RADIO
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {

                  final item = filtered[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: const Color(0xFF131927),
                    child: ListTile(
                      title: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      leading: Radio<String>(
                        value: item,
                        groupValue: widget.selectedValue,
                        activeColor: const Color(0xFF4a9eff),
                        onChanged: widget.onChanged,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}