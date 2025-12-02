import 'package:flutter/material.dart';
import 'dart:io';
import '../models/visit.dart';
import '../models/picture.dart';
import '../main.dart';
import 'package:intl/intl.dart';


class DetailPage extends StatefulWidget {
  final int visitId;

  const DetailPage({super.key, required this.visitId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Visit? visit;
  List<Picture> pictures = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadVisitData();
  }

  Future<void> _loadVisitData() async {
    final db = database;

    final visits = await db.visitDao.findAllVisits();
    visit = visits.firstWhere((v) => v.id == widget.visitId);

    pictures = await db.pictureDao.findPicturesByVisitId(widget.visitId);

    setState(() => loading = false);
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.photo_library, color: Colors.grey, size: 40)),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.red,
        child: const Center(child: Icon(Icons.error)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (visit == null) {
      return const Scaffold(
        body: Center(child: Text("Visita não encontrada")),
      );
    }

    final DateTime data = DateFormat('dd/MM/yyyy').parse(visit!.date);
    final String? firstImagePath = pictures.isNotEmpty ? pictures.first.filePath : null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          visit!.placeName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------------- IMAGEM DE CAPA COM BADGES ----------------
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: _buildImage(firstImagePath),
                  ),

                  // Badge de Nota (canto inferior esquerdo)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Nota: ${visit!.rating.toInt()}/5",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Data (canto inferior direito)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${data.day.toString().padLeft(2, '0')}/"
                        "${data.month.toString().padLeft(2, '0')}/"
                        "${data.year}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ---------------- CONTEÚDO ROLÁVEL ----------------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Descrição
                      const Text(
                        "Descrição:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        visit!.description ?? "Nenhuma descrição.",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Imagens
                      const Text(
                        "Imagens:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pictures.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.2,
                        ),
                        itemBuilder: (_, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildImage(pictures[index].filePath),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Endereço
                      const Text(
                        "Endereço:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        visit!.placeLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
