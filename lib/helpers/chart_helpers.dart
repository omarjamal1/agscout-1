class TotalCountPerPlotClassData {
//  String type;
  String year;
  double averageCount;

//  final Color dataColor;

  TotalCountPerPlotClassData({this.year, this.averageCount});

  @override
  String toString() {
    return "$year $averageCount";
  }
}
