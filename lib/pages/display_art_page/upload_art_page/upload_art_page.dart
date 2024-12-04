import 'package:flutter/material.dart';

class UploadArtPage extends StatefulWidget {
  const UploadArtPage({Key? key}) : super(key: key);

  @override
  _UploadArtPageState createState() => _UploadArtPageState();
}

class _UploadArtPageState extends State<UploadArtPage> {
  String? uploadedArtUri;

  final TextEditingController artworkNameController = TextEditingController();
  final TextEditingController artistNameController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController artTypeController = TextEditingController();

  @override
  void dispose() {
    artworkNameController.dispose();
    artistNameController.dispose();
    widthController.dispose();
    heightController.dispose();
    priceController.dispose();
    artTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Upload Artwork"),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                // Container to show uploaded artwork
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: uploadedArtUri == null
                      ? const Center(
                          child: Text(
                            'No Artwork Uploaded',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            uploadedArtUri!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                // Upload image button
                ElevatedButton(
                  onPressed: () {
                    // TODO add actual image upload logic
                    setState(() {
                      uploadedArtUri = '...';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                  ),
                  child: const Text(
                    'Upload Art Picture',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                // Artwork Name input
                TextField(
                  controller: artworkNameController,
                  decoration: const InputDecoration(
                    labelText: 'Artwork Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Artist Name input
                TextField(
                  controller: artistNameController,
                  decoration: const InputDecoration(
                    labelText: 'Artist Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Dimensions input with units
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Width input
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widthController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Width',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'cm',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Height input
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: heightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Height',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'cm',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Price input
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Art Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Art Type input
                TextField(
                  controller: artTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Art Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // TODO add submit button logic
                ElevatedButton(
                  onPressed: () {
                    if (uploadedArtUri == null ||
                        artworkNameController.text.isEmpty ||
                        artistNameController.text.isEmpty ||
                        widthController.text.isEmpty ||
                        heightController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        artTypeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please fill out all fields and upload an image.'),
                        ),
                      );
                      return;
                    }
                    // Print entered details
                    print('Uploaded Art URI: $uploadedArtUri');
                    print('Artwork Name: ${artworkNameController.text}');
                    print('Artist Name: ${artistNameController.text}');
                    print('Width: ${widthController.text} cm');
                    print('Height: ${heightController.text} cm');
                    print('Price: ${priceController.text}');
                    print('Art Type: ${artTypeController.text}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
