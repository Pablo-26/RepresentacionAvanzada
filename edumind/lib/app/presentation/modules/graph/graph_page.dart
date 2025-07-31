// lib/presentation/modules/graph/graph_page.dart
import 'package:edumind/app/data/models/graphnodemodel .dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SimpleGraphView extends StatelessWidget {
  final List<Node> nodes;
  final List<Edge> edges;
  
  const SimpleGraphView({required this.nodes, required this.edges, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si no hay nodos, mostrar mensaje
    if (nodes.isEmpty) {
      return Container(
        color: Color.fromARGB(255, 245, 247, 250),
        child: Center(
          child: Text(
            'No hay datos para mostrar en el grafo',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Calcular posiciones en diseño de telaraña
    final positionedNodes = _calculateSpiderLayout(nodes, edges);
    
    return Container(
      color: Color.fromARGB(255, 245, 247, 250),
      child: InteractiveViewer(
        constrained: false,
        boundaryMargin: EdgeInsets.all(300),
        minScale: 0.05,
        maxScale: 5.0,
        panEnabled: true,
        scaleEnabled: true,
        child: CustomPaint(
          size: Size(3000, 3000), // Tamaño más grande para grafos con muchos nodos
          painter: _GraphPainter(positionedNodes, edges),
        ),
      ),
    );
  }

  List<Node> _calculateSpiderLayout(List<Node> originalNodes, List<Edge> edges) {
    if (originalNodes.isEmpty) return originalNodes;

    final center = Offset(1500, 1500); // Centro del canvas más grande
    final List<Node> positionedNodes = [];
    const double nodeRadius = 50.0; // Radio del nodo para cálculos de colisión
    const double minDistance = 120.0; // Distancia mínima entre nodos

    // Encontrar el nodo central
    Node centralNode = _findCentralNode(originalNodes, edges);
    positionedNodes.add(Node(centralNode.id, centralNode.label, center));

    // Obtener nodos conectados directamente al central
    final connectedToCenter = _getConnectedNodes(centralNode.id, edges, originalNodes);
    
    // Distribuir nodos conectados en múltiples anillos concéntricos
    _distributeNodesInRings(connectedToCenter, center, positionedNodes, minDistance);

    // Posicionar nodos restantes
    final processedIds = positionedNodes.map((n) => n.id).toSet();
    final remainingNodes = originalNodes.where((n) => !processedIds.contains(n.id)).toList();

    for (final remainingNode in remainingNodes) {
      final position = _findAvailablePosition(positionedNodes, center, minDistance);
      positionedNodes.add(Node(remainingNode.id, remainingNode.label, position));
    }

    return positionedNodes;
  }

  void _distributeNodesInRings(List<Node> nodes, Offset center, List<Node> positionedNodes, double minDistance) {
    if (nodes.isEmpty) return;

    // Calcular cuántos nodos caben en cada anillo
    const double baseRadius = 200.0;
    const double ringSpacing = 150.0;
    int currentRing = 1;
    int nodesPlaced = 0;

    while (nodesPlaced < nodes.length) {
      final currentRadius = baseRadius + (currentRing - 1) * ringSpacing;
      final circumference = 2 * math.pi * currentRadius;
      final maxNodesInRing = math.max(1, (circumference / minDistance).floor());
      final nodesToPlaceInRing = math.min(maxNodesInRing, nodes.length - nodesPlaced);
      
      final angleStep = (2 * math.pi) / nodesToPlaceInRing;
      final startAngle = (currentRing % 2 == 0) ? angleStep / 2 : 0; // Alternar para mejor distribución

      for (int i = 0; i < nodesToPlaceInRing; i++) {
        final angle = startAngle + i * angleStep;
        final x = center.dx + currentRadius * math.cos(angle);
        final y = center.dy + currentRadius * math.sin(angle);
        
        final nodeToPlace = nodes[nodesPlaced + i];
        positionedNodes.add(Node(nodeToPlace.id, nodeToPlace.label, Offset(x, y)));
      }

      nodesPlaced += nodesToPlaceInRing;
      currentRing++;
    }
  }

  Offset _findAvailablePosition(List<Node> existingNodes, Offset center, double minDistance) {
    // Buscar una posición disponible usando un patrón espiral
    const double maxRadius = 800.0;
    const double radiusStep = 30.0;
    const double angleStep = 0.5;

    for (double radius = 200.0; radius <= maxRadius; radius += radiusStep) {
      for (double angle = 0; angle < 2 * math.pi; angle += angleStep) {
        final candidate = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );

        bool hasCollision = false;
        for (final existingNode in existingNodes) {
          final distance = _calculateDistance(candidate, existingNode.position);
          if (distance < minDistance) {
            hasCollision = true;
            break;
          }
        }

        if (!hasCollision) {
          return candidate;
        }
      }
    }

    // Si no encuentra posición, usar una posición aleatoria alejada
    final randomAngle = math.Random().nextDouble() * 2 * math.pi;
    final randomRadius = 400.0 + math.Random().nextDouble() * 400.0;
    return Offset(
      center.dx + randomRadius * math.cos(randomAngle),
      center.dy + randomRadius * math.sin(randomAngle),
    );
  }

  double _calculateDistance(Offset pos1, Offset pos2) {
    return math.sqrt(math.pow(pos1.dx - pos2.dx, 2) + math.pow(pos1.dy - pos2.dy, 2));
  }

  Node _findCentralNode(List<Node> nodes, List<Edge> edges) {
    // Contar conexiones por nodo
    final Map<String, int> connectionCount = {};
    
    for (final node in nodes) {
      connectionCount[node.id] = 0;
    }
    
    for (final edge in edges) {
      connectionCount[edge.sourceId] = (connectionCount[edge.sourceId] ?? 0) + 1;
      connectionCount[edge.targetId] = (connectionCount[edge.targetId] ?? 0) + 1;
    }
    
    // Encontrar el nodo con más conexiones
    String centralId = nodes.first.id;
    int maxConnections = 0;
    
    connectionCount.forEach((id, count) {
      if (count > maxConnections) {
        maxConnections = count;
        centralId = id;
      }
    });
    
    return nodes.firstWhere((n) => n.id == centralId);
  }

  List<Node> _getConnectedNodes(String centralId, List<Edge> edges, List<Node> allNodes) {
    final connectedIds = <String>{};
    
    for (final edge in edges) {
      if (edge.sourceId == centralId) {
        connectedIds.add(edge.targetId);
      } else if (edge.targetId == centralId) {
        connectedIds.add(edge.sourceId);
      }
    }
    
    return allNodes.where((n) => connectedIds.contains(n.id)).toList();
  }

  Node? _findClosestPositionedNode(Node targetNode, List<Node> positionedNodes, List<Edge> edges) {
    // Buscar nodos posicionados que estén conectados al nodo objetivo
    for (final edge in edges) {
      if (edge.sourceId == targetNode.id) {
        final connectedNode = positionedNodes.where((n) => n.id == edge.targetId).firstOrNull;
        if (connectedNode != null) return connectedNode;
      } else if (edge.targetId == targetNode.id) {
        final connectedNode = positionedNodes.where((n) => n.id == edge.sourceId).firstOrNull;
        if (connectedNode != null) return connectedNode;
      }
    }
    
    // Si no hay conexión directa, devolver el primer nodo posicionado
    return positionedNodes.isNotEmpty ? positionedNodes.first : null;
  }
}

class _GraphPainter extends CustomPainter {
  final List<Node> nodes;
  final List<Edge> edges;

  _GraphPainter(this.nodes, this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill;

    final centralNodePaint = Paint()
      ..color = Color.fromRGBO(5, 150, 105, 1) // Color verde de tu app
      ..style = PaintingStyle.fill;

    final edgePaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Dibuja aristas primero (para que queden detrás de los nodos)
    for (var edge in edges) {
      final sourceNode = nodes.where((n) => n.id == edge.sourceId).firstOrNull;
      final targetNode = nodes.where((n) => n.id == edge.targetId).firstOrNull;
      
      if (sourceNode != null && targetNode != null) {
        // Dibuja línea de conexión
        canvas.drawLine(sourceNode.position, targetNode.position, edgePaint);

        // Dibuja etiqueta de la arista si no está vacía
        if (edge.label.isNotEmpty && edge.label != 'relación') {
          final middle = Offset(
            (sourceNode.position.dx + targetNode.position.dx) / 2,
            (sourceNode.position.dy + targetNode.position.dy) / 2,
          );

          // Fondo semitransparente para la etiqueta
          final bgPaint = Paint()
            ..color = Colors.white.withOpacity(0.9)
            ..style = PaintingStyle.fill;

          final textSpan = TextSpan(
            text: _truncateText(edge.label, 15), // Truncar texto largo
            style: TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            )
          );
          
          textPainter.text = textSpan;
          textPainter.layout();
          
          // Dibuja fondo redondeado para la etiqueta
          final rect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: middle,
              width: textPainter.width + 8,
              height: textPainter.height + 4,
            ),
            Radius.circular(4),
          );
          canvas.drawRRect(rect, bgPaint);
          
          // Dibuja el texto
          textPainter.paint(
            canvas,
            middle - Offset(textPainter.width / 2, textPainter.height / 2)
          );
        }
      }
    }

    // Dibuja nodos
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final isCenter = i == 0; // Asumiendo que el primer nodo es el central
      
      // Radio del nodo variable según su importancia
      final nodeRadius = isCenter ? 50.0 : 30.0;
      final paint = isCenter ? centralNodePaint : nodePaint;
      
      // Dibuja círculo del nodo
      canvas.drawCircle(node.position, nodeRadius, paint);
      
      // Dibuja borde del nodo
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(node.position, nodeRadius, borderPaint);

      // Dibuja etiqueta del nodo
      final truncatedLabel = _truncateText(node.label, isCenter ? 20 : 15);
      final textSpan = TextSpan(
        text: truncatedLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: isCenter ? 12 : 10,
          fontWeight: isCenter ? FontWeight.bold : FontWeight.w500,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        )
      );
      textPainter.text = textSpan;
      textPainter.layout(maxWidth: nodeRadius * 1.8);
      
      // Centra el texto en el nodo
      textPainter.paint(
        canvas,
        node.position - Offset(textPainter.width / 2, textPainter.height / 2)
      );
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}