import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../ImageItem/image_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  State<ImageCarousel> createState() => _ImageCarousel();
}

class _ImageCarousel extends State<ImageCarousel> {
  Future<void> loadImagesFromFireBaseServer() async {
    isLoading = true;
    error = null;
    try {
      firestore = FirebaseFirestore.instance.collection('Gallery');

      QuerySnapshot snapshot = await firestore!.get();
      final imagesData = snapshot.docs
          .map(
            (doc) => ImageItem(
              id: doc.id,
              url: doc['downloadUrl'],
              pageNo: doc['pageNo'],
            ),
          )
          .toList();
      imagesData.sort((a, b) => a.pageNo!.compareTo(b.pageNo!));
      setState(() {
        images = imagesData;
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

  int currentIndex = 0;
  PageController controller = PageController(initialPage: 0, keepPage: true);
  List<ImageItem>? images = [];
  bool isLoading = true;
  String? error;
  CollectionReference<Map<String, dynamic>>? firestore;
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (images == null || images!.isEmpty) {
      return const Center(child: Text("Empty Database"));
    }
    return Scaffold(
      body: Stack(
        children: [
          /// IMAGES
          PageView.builder(
            controller: controller,
            onPageChanged: (index) {
              setState(() => currentIndex = index);

              if (index + 1 < images!.length) {
                precacheImage(
                  CachedNetworkImageProvider(
                    images![index + 1].url!,
                    cacheKey: images![index + 1].url!,
                  ),
                  context,
                );
              }

              if (index - 1 >= 0) {

                precacheImage(
                  CachedNetworkImageProvider(
                    images![index - 1].url!,
                    cacheKey: images![index - 1].url!,
                  ),
                  context,
                );
              }
            },
            itemCount: images!.length,

            itemBuilder: (context, index) {
              final item = images![index];
              return Container(
                color: const Color.fromARGB(255, 252, 232, 179),
                child: CachedNetworkImage(
                  imageUrl: item.url!,

                  memCacheWidth: MediaQuery.of(context).size.width.toInt(),
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const SizedBox(),
                  fadeInDuration: Duration.zero,

                  errorWidget: (_, __, ___) =>
                      const Center(child: Icon(Icons.error, size: 40)),
                ),
              );
            },
          ),

          /// PREVIOUS BUTTON
          if (currentIndex > 0)
            Positioned(
              left: 16,
              bottom: 32,
              child: FloatingActionButton(
                heroTag: 'prev',
                onPressed: () => controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: const Icon(Icons.arrow_back),
              ),
            ),

          /// NEXT BUTTON
          if (currentIndex < images!.length - 1)
            Positioned(
              right: 16,
              bottom: 32,
              child: FloatingActionButton(
                heroTag: 'next',
                onPressed: () => controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
