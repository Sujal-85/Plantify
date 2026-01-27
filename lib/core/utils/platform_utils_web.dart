import 'package:flutter/material.dart';

Widget displayImage(String path, {BoxFit fit = BoxFit.cover, Color? color, BlendMode? colorBlendMode}) {
  return Image.network(
    path,
    fit: fit,
    color: color,
    colorBlendMode: colorBlendMode ?? BlendMode.srcIn,
  );
}
