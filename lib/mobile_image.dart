class ImageElement {
  dynamic src;
  dynamic width;
  dynamic height;
  dynamic style;
  dynamic onError;
  dynamic onLoad;
  dynamic alt;
  dynamic naturalWidth;
  dynamic naturalHeight;

  ImageElement({this.src, this.width, this.height});
}

// class ObjectElement {
//   dynamic data;
//   dynamic width;
//   dynamic height;
//   dynamic style;
//   dynamic onError;
//   dynamic onLoad;
//   dynamic onClick;
//   dynamic type;
//
//   ObjectElement();
// }

class DivElement {
  dynamic style;
  dynamic children;

  DivElement();
}

dynamic platformViewRegistry ;

// class PlatformViewRegistry {
//   registerViewFactory(String s, dynamic Function(int id) callback) {}
// }
