import 'package:flutter/material.dart';
import 'package:virtual_marketplace_app/models/art_model/art_model.dart';

class DisplayArtPage extends StatelessWidget {
  ArtModel passedArtModel;

  DisplayArtPage({super.key, required this.passedArtModel});

  final bool isUserArt = true;

  @override
  Widget build(BuildContext context) {
    final artistName = passedArtModel.artWorkCreator.userName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Artwork Details"),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the artwork image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(passedArtModel.artWorkPictureUri),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Artwork name and artist
              Text(
                '${passedArtModel.artWorkName} by $artistName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Dimensions and price buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(passedArtModel.artDimensions),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('\$${passedArtModel.artPrice}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Buy button
              ElevatedButton(
                onPressed: () {
                  // TODO Navigate to payment page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Buy',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              // Change details button (only if it's the user's art)
              if (isUserArt)
                ElevatedButton(
                  onPressed: () {
                    // TODO Handle changing details
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Change Details',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
