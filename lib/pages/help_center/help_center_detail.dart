import 'package:flutter/material.dart';
import 'package:gokid/utils/showSnackbar.dart';
import 'package:gokid/widgets/custom_button.dart';

class HelpCenterDetail extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showAction;
  final VoidCallback? onPressedCallback;
  final String buttonText;

  const HelpCenterDetail({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.showAction,
    required this.buttonText,
    this.onPressedCallback,
  }) : super(key: key);

  @override
  _HelpCenterDetailState createState() => _HelpCenterDetailState();
}

class _HelpCenterDetailState extends State<HelpCenterDetail> {
  bool isLiked = false;
  bool isDisliked = false;

  void _handleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        isDisliked = false;
      }
      showSnackBar(context, 'Geri bildiriminiz için teşekkürler.');
    });
  }

  void _handleDislike() {
    setState(() {
      isDisliked = !isDisliked;
      if (isDisliked) {
        isLiked = false;
      }
      showSnackBar(context, 'Geri bildiriminiz için teşekkürler.');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Text(
                widget.subtitle,
                style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.grey),
              ),
              const SizedBox(height: 30.0),
                Visibility(
                  visible: widget.buttonText.isNotEmpty && widget.showAction,
                  child: CustomButton(
                    onTap: widget.onPressedCallback!,
                    text: widget.buttonText,
                  ),
                ),
              const SizedBox(height: 40.0),
              Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bu işinize yaradı mı ?',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Kendimizi geliştirebilmemiz için geri bildiriminize ihtiyacımız var.',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: _handleLike,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLiked ? Colors.blue.shade100 : Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.thumb_up_alt_sharp,
                              size: 20,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleDislike,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDisliked ? Colors.blue.shade100 : Colors.grey.shade200,
                            ),
                            child: Icon(
                              Icons.thumb_down_alt_sharp,
                              size: 20,
                              color: isDisliked ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
