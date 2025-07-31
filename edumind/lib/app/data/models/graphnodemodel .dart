import 'package:flutter/material.dart';

class Node {
  final String id;
  final String label;
  final Offset position;

  Node(this.id, this.label, this.position);
}

class Edge {
  final String sourceId;
  final String targetId;
  final String label;

  Edge(this.sourceId, this.targetId, this.label);
}
