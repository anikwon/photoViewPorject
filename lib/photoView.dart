import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class PhotoViewPage extends StatefulWidget {
  List<String> imagePaths;
  int currentIndex;
  PhotoViewPage(
      {super.key, required this.imagePaths, required this.currentIndex});

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  late PageController _controller;
  bool _isDownloading = false;

  void downloadImage(String imageUrl) async {
    setState(
      () {
        _isDownloading = true;
      },
    );

    // 바이트 형태로 imageUrl을 받아옵니다.
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));

    // saveImage 메소드 호출
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));

    if (result['isSuccess']) {
      print("다운로드가 완료되었습니다");
    } else {
      print("오류가 발생했습니다. $result");
    }

    setState(() {
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _controller = PageController(initialPage: widget.currentIndex);
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(widget.imagePaths[index]),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.only(top: 45, right: 20),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    "${index + 1} / ${widget.imagePaths.length}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              //! 다운로드 버튼
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 25, right: 25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      //! 다운로드 중에는 버튼 disable 위함
                      if (!_isDownloading) {
                        downloadImage(widget.imagePaths[index]);
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
