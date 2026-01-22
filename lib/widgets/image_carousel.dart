import 'package:flutter/material.dart';
import '../ImageItem/image_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int currentIndex = 0;
  PageController controller = PageController(initialPage: 0);
  List<ImageItem>? images = [];
  bool isLoading = true;
  bool showDetails = false;
  String? error;
  CollectionReference<Map<String, dynamic>>? firestore;

  Future<bool> askForAdminPassword(BuildContext context) async {
    String localError = "";
    TextEditingController passController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Admin Login"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "enter Password",
                      errorText: localError.isNotEmpty ? localError : null,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    const adminPassword = "Pass123";
                    if (passController.text == adminPassword) {
                      Navigator.pop(context, true);
                    } else {
                      setState(() {
                        error = "Incorrect Password";
                      });
                    }
                  },
                  child: Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  Future<void> loadImagesFromFireBaseServer() async {
    isLoading = true;
    error = null;
    try {
      firestore = FirebaseFirestore.instance.collection('Gallery');

      QuerySnapshot snapshot = await firestore!.get();
      final loadedImages = snapshot.docs
          .map(
            (doc) => ImageItem(
              id: doc.id,
              caption: doc['caption'],
              title: doc['title'],
              url: doc['downloadUrl'],
              pageNo: doc['pageNo'],
            ),
          )
          .toList();
      loadedImages.sort((a, b) => a.pageNo!.compareTo(b.pageNo!));
      setState(() {
        images = loadedImages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadImagesFromFireBaseServer();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Column(
          children: [
            Text("Loading"),
            Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (images == null || images!.isEmpty) {
      return Scaffold(body: Center(child: Text("Empty Database")));
    }

    try {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                    showDetails = false;
                  });
                },
                itemCount: images!.length,
                itemBuilder: (context, index) {
                  final item = images![index];
                  return SafeArea(
                    minimum: EdgeInsets.all(8.0),
                    child: Column(
                      spacing: 8.0,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showDetails = !showDetails;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: showDetails
                                ? MediaQuery.of(context).size.height * 0.35
                                : MediaQuery.of(context).size.height * 0.65,
                            width: double.infinity,
                            child: Image.network(
                              item.url!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, size: 40),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                            ),
                          ),
                        ),

                        AnimatedSwitcher(
  duration: const Duration(milliseconds: 250),
  child: showDetails
      ? Column(
          key: const ValueKey('details'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120, // ✅ finite height
              child: SingleChildScrollView(
                child: Text(
                  item.caption!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        )
      : const SizedBox.shrink(key: ValueKey('empty')),
),

                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //if (currentIndex < images!.length - 1)
                  ElevatedButton(
                    onPressed: currentIndex == 0
                        ? null
                        : () {
                            controller.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    child: Text("Previous"),
                  ),

                  ElevatedButton(
                    onPressed: currentIndex == images!.length - 1
                        ? null
                        : () {
                            controller.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                    child: Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return ErrorWidget(e);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
