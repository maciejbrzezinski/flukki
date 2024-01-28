import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () =>
              launchUrlString('https://github.com/maciejbrzezinski/flukki'),
          style: TextButton.styleFrom(
            primary: Colors.grey,
            padding: EdgeInsets.zero,
          ),
          child: const Text('https://github.com/maciejbrzezinski/flukki'),
        ),
        TextButton(
          onPressed: () => launchUrlString('https://flukki.com'),
          style: TextButton.styleFrom(
            primary: Colors.grey,
            padding: EdgeInsets.zero,
          ),
          child: const Text('https://flukki.com'),
        )
      ],
    );
  }
}
