import 'package:flutter/material.dart';

class PlaceCard extends StatelessWidget {
  final String name;
  final String location;
  final String date;
  final String? imagePath;

  const PlaceCard({
    Key? key,
    required this.name,
    required this.location,
    required this.date,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 5),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          print('Detalhes do local: $name');
        },
        borderRadius: BorderRadius.circular(12.0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              imagePath ?? 'assets/imagemPadrao.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),

          title: Text(
            name,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),

          subtitle: Text(
            '$location - $date',
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),

          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[600],
            size: 18,
          ),
        ),
      ),
    );
  }
}