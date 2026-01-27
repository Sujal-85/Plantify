import 'dart:io';
import 'package:flutter/material.dart';

Widget displayImage(String path, {BoxFit fit = BoxFit.cover, Color? color, BlendMode? colorBlendMode}) {
  return Image.file(
    File(path),
    fit: fit,
    color: color,
    colorBlendMode: colorBlendMode ?? BlendMode.srcIn, // Default unused if color null
  );
}
