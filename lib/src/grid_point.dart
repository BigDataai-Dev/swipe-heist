class GridPoint {
  const GridPoint(this.row, this.column);

  final int row;
  final int column;

  GridPoint move(int rowDelta, int columnDelta) {
    return GridPoint(row + rowDelta, column + columnDelta);
  }

  @override
  bool operator ==(Object other) {
    return other is GridPoint && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}
