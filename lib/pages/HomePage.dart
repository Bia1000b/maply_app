import 'package:flutter/material.dart';

import '../widgets/PlaceCard.dart';
import 'NewPlacePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
//aq eh so exemplo pra fazer o layout
  final List<Map<String, String>> places = [
    {
      'name': 'Torre Eiffel',
      'location': 'Paris, França',
      'date': '15/08/2023',
    },
    {
      'name': 'Coliseu',
      'location': 'Roma, Itália',
      'date': '22/07/2023',
    },
    {
      'name': 'Estátua da Liberdade',
      'location': 'Nova Iorque, EUA',
      'date': '10/05/2023',
    },
    {
      'name': 'Estátua da Liberdade',
      'location': 'Nova Iorque, EUA',
      'date': '10/05/2023',
    },{
      'name': 'Estátua da Liberdade',
      'location': 'Nova Iorque, EUA',
      'date': '10/05/2023',
    },{
      'name': 'Estátua da Liberdade',
      'location': 'Nova Iorque, EUA',
      'date': '10/05/2023',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            print('Adicionar novo lugar');
          },
        ),
        title: Center(child: Text('Meus Lugares', style: Theme.of(context).textTheme.headlineSmall)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewPlacePage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16, left: 16, top: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.black), // Ícone escuro para contraste
                    onPressed: () {
                      print('Abrir filtros');
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return PlaceCard(
                  name: place['name']!,
                  location: place['location']!,
                  date: place['date']!,
                  imagePath: place['image'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}