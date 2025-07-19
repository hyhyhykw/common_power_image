import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:power_image/power_image.dart';

import 'mobile_image.dart' if (dart.library.html) 'dart:html';
import 'mobile_image.dart' if (dart.library.html) 'dart:ui_web' as ui;

class PowerImageWidget extends StatelessWidget {
  static const defaultPlaceholderColor = Color(0xffEAEAEA);

  final String? renderingType;
  final String imageType;

  //load as drawable
  final bool drawable;
  final String? package;
  final String src;
  final double? width;
  final double? height;
  final Color placeholderColor;
  final BoxFit? fit;
  final Widget? placeholder;
  final bool needDefaultPlaceholder;
  final bool needDefaultError;
  final double? renderWidth;
  final double? renderHeight;
  final Color? imageColor;

  // final ImageFrameBuilder? frameBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;

  final AlignmentGeometry alignment;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  const PowerImageWidget.network(this.src,
      {super.key,
      this.drawable = false,
      this.package,
      this.renderingType,
      this.width,
      this.height,
      this.imageColor,
      // this.frameBuilder,
      this.errorBuilder,
      this.fit = BoxFit.cover,
      this.alignment = Alignment.center,
      this.semanticLabel,
      this.excludeFromSemantics = false,
      this.placeholder,
      this.needDefaultPlaceholder = true,
      this.needDefaultError = true,
      this.renderWidth,
      this.renderHeight,
      this.placeholderColor = defaultPlaceholderColor})
      : imageType = 'network';

  const PowerImageWidget.asset(
    this.src, {
    super.key,
    this.drawable = false,
    this.package,
    this.renderingType,
    this.width,
    this.imageColor,
    this.height,
    // this.frameBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.placeholder,
    this.placeholderColor = defaultPlaceholderColor,
    this.needDefaultPlaceholder = false,
    this.needDefaultError = true,
    this.renderWidth,
    this.renderHeight,
  }) : imageType = 'asset';

  const PowerImageWidget.nativeAsset(
    this.src, {
    super.key,
    this.drawable = false,
    this.package,
    this.imageColor,
    this.renderingType,
    this.width,
    this.height,
    // this.frameBuilder,
    this.errorBuilder,
    this.placeholderColor = defaultPlaceholderColor,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.placeholder,
    this.needDefaultPlaceholder = false,
    this.needDefaultError = true,
    this.renderWidth,
    this.renderHeight,
  }) : imageType = 'nativeAsset';

  const PowerImageWidget.file(
    this.src, {
    super.key,
    this.imageColor,
    this.drawable = false,
    this.package,
    this.renderingType,
    this.width,
    this.height,
    // this.frameBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.placeholderColor = defaultPlaceholderColor,
    this.excludeFromSemantics = false,
    this.placeholder,
    this.needDefaultPlaceholder = true,
    this.needDefaultError = true,
    this.renderWidth,
    this.renderHeight,
  }) : imageType = 'file';

  Widget? _generatePlaceholder() {
    var placeholder = this.placeholder;
    if (null == this.placeholder) {
      if (needDefaultPlaceholder) {
        placeholder = Container(
          color: placeholderColor,
          width: width,
          height: height,
        );
      }
    }
    return placeholder;
  }

  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  static String _toColorValue(double x) {
    final intValue = _floatToInt8(x);
    final hexValue = intValue.toRadixString(16);
    if (hexValue.length == 1) {
      return '0$hexValue';
    }
    return hexValue;
  }

  @override
  Widget build(BuildContext context) {
    var imageColor = this.imageColor;
    if (kIsWeb) {
      return _WebImage(
        src,
        imageType,
        package: package,
        width: width,
        height: height,
        fit: fit,
        imageColor: this.imageColor,
        placeholderColor: placeholderColor,
        placeholder: this.placeholder,
        needDefaultPlaceholder: needDefaultPlaceholder,
        needDefaultError: needDefaultPlaceholder,
        renderWidth: renderWidth,
        renderHeight: renderHeight,
        errorBuilder: this.errorBuilder,
        alignment: alignment,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
      );
    }

    final placeholder = _generatePlaceholder();

    ImageFrameBuilder? frameBuilder = placeholder == null
        ? null
        : (BuildContext _, Widget child, int? frame,
            bool wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }
            final loading = frame == null;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 50),
              child: Container(
                  key: ValueKey<bool>(loading),
                  child: loading ? placeholder : child),
            );
          };

    var errorBuilder = this.errorBuilder;

    if (null == this.errorBuilder) {
      if (needDefaultError) {
        errorBuilder = (BuildContext _, Object $, StackTrace? $_) {
          return Container(
            color: placeholderColor,
            width: width,
            height: height,
          );
        };
      }
    }

    if (imageType == 'asset') {
      return Image.asset(
        src,
        width: width,
        height: height,
        frameBuilder: frameBuilder,
        errorBuilder: errorBuilder,
        fit: fit,
        color: imageColor,
        alignment: alignment,
        excludeFromSemantics: excludeFromSemantics,
        semanticLabel: semanticLabel,
      );
    }

    String? color;
    if (imageColor != null) {
      color = '#'
          '${_toColorValue(imageColor.a)}'
          '${_toColorValue(imageColor.r)}'
          '${_toColorValue(imageColor.g)}'
          '${_toColorValue(imageColor.b)}';
    }

    final json = jsonEncode({
      'imageType': imageType,
      'drawable': drawable,
      'url': src,
      'renderWidth': renderWidth ?? -1,
      'renderHeight': renderHeight ?? -1,
      'color': color
    });

    final powerImage = PowerImage.options(
      PowerImageRequestOptions(
        src: PowerImageRequestOptionsSrcAsset(src: json, package: package),
        imageType: 'custom',
        renderingType: renderingType,
      ),
      width: width,
      height: height,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      fit: fit ?? (imageType == 'network' ? BoxFit.cover : BoxFit.contain),
      alignment: alignment,
      excludeFromSemantics: excludeFromSemantics,
      semanticLabel: semanticLabel,
    );
    return powerImage;
  }
}

// ignore: must_be_immutable
class _WebImage extends StatelessWidget {
  final String imageType;
  final String? package;
  final String src;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final bool needDefaultPlaceholder;
  final bool needDefaultError;
  final double? renderWidth;
  final double? renderHeight;
  final Color placeholderColor;

  // final ImageFrameBuilder? frameBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;

  final AlignmentGeometry alignment;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final Color? imageColor;

  _WebImage(
    this.src,
    this.imageType, {
    this.package,
    this.width,
    this.height,
    this.imageColor,
    this.fit = BoxFit.none,
    this.placeholder,
    this.needDefaultPlaceholder = false,
    this.needDefaultError = false,
    this.renderWidth,
    this.renderHeight,
    this.errorBuilder,
    this.alignment = Alignment.center,
    this.semanticLabel,
    required this.placeholderColor,
    this.excludeFromSemantics = false,
  });

  Widget? _generateError(context) {
    var errorBuilder = this.errorBuilder;

    if (null == errorBuilder) {
      if (needDefaultError) {
        errorBuilder = (BuildContext _, Object $, StackTrace? $_) {
          return Container(
            color: placeholderColor,
            width: width,
            height: height,
          );
        };
      }
    }
    return errorBuilder?.call(context, '', null);
  }

  var _webError = false;

  var _webComplete = false;

  Widget? _generatePlaceholder() {
    var placeholder = this.placeholder;
    if (null == placeholder) {
      if (needDefaultPlaceholder) {
        placeholder = Container(
          color: placeholderColor,
          width: width,
          height: height,
        );
      }
    }
    return placeholder;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (imageType == 'file' || imageType == 'nativeAsset') {
      var container = Container(
        color: placeholderColor,
        width: width,
        height: height ?? screenWidth,
        alignment: Alignment.center,
        child: const Text(
          'Format not support',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      );
      return container;
    }

    if (imageType == 'network') {
      var statefulBuilder = StatefulBuilder(
        builder: (context, setState) {
          String divId =
              "web_image_${src.hashCode}_${DateTime.now().toIso8601String()}";
          // ignore: undefined_prefixed_name
          ui.platformViewRegistry.registerViewFactory(
            divId,
            (int viewId) {
              String objectFit;
              switch (fit) {
                case BoxFit.fill:
                  objectFit = 'fill';
                  break;
                case BoxFit.contain:
                  objectFit = 'contain';
                  break;
                case BoxFit.cover:
                  objectFit = 'cover';
                  break;

                case BoxFit.none:
                  objectFit = 'unset';
                  break;
                case BoxFit.fitWidth:
                case BoxFit.fitHeight:
                case BoxFit.scaleDown:
                  objectFit = 'scale-down';
                  break;
                default:
                  objectFit = 'contain';
                  break;
              }

              var divElement = DivElement()
                ..style.width = '100%'
                ..style.height = '100%';

              final imageElement = ImageElement(
                src: src,
                width: width?.toInt(),
                height: height?.toInt(),
              );
              if (_webError) {
                imageElement.style.display = 'none';
              }
              imageElement
                ..style.objectFit = objectFit
                ..onError.listen((event) {
                  if (!_webError) {
                    setState(() {
                      _webError = true;
                      _webComplete = false;
                    });
                  }
                })
                ..onLoad.listen((event) {
                  if (!_webComplete) {
                    setState(() {
                      _webError = false;
                      _webComplete = true;
                    });
                  }
                });

              divElement.children.add(imageElement);
              return divElement;
            },
          );

          return SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                _generatePlaceholder() ?? const SizedBox.shrink(),
                if (_webError)
                  _generateError(context) ?? const SizedBox.shrink(),
                HtmlElementView(key: UniqueKey(), viewType: divId)
              ],
            ),
          );
        },
      );

      return Stack(
        children: [
          statefulBuilder,
          Container(
            color: Colors.transparent,
            width: width,
            height: height,
          )
        ],
      );
    }

    //asset image
    final assetUrl =
        'assets/${package == null ? '' : 'packages/$package/'}$src';
    var image = Image.network(
      assetUrl,
      width: width,
      height: height,
      fit: fit,
      color: imageColor,
      alignment: alignment,
      excludeFromSemantics: excludeFromSemantics,
      semanticLabel: semanticLabel,
    );
    return image;
  }
}
