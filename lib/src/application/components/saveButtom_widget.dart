import 'package:docInHand/src/application/constants/colors.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  const SaveButton({required this.onPressed, super.key});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool _isLoading = false;

  void _handlePressed() async {
    setState(() {
      _isLoading = true;
    });

     widget.onPressed();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors["green"],
          shape: const CircleBorder(),
          minimumSize: const Size(140, 65),
        ),
        onPressed: _isLoading ? null : _handlePressed,
        child: _isLoading
            ? SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(
                  color: customColors['white'],
                  strokeWidth: 3,
                ),
              )
            : Icon(
                Icons.save_as_rounded,
                size: 35,
                color: customColors['white'],
              ),
      ),
    );
  }
}
