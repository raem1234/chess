import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(ChessApp());

class ChessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajedrez para Dos Jugadores',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: ChessBoardWidget(),
    );
  }
}

class ChessBoard {
  final int size = 8;
  final List<Map<String, String>> pieces = [];
  final Color lightSquareColor = const Color.fromARGB(255, 248, 248, 248)!;
  final Color darkSquareColor = const Color.fromARGB(255, 153, 79, 56)!;

  ChessBoard() {
    _initializePieces();
  }

  void _initializePieces() {
    // Piezas negras
    addPiece('♜', 'a8');
    addPiece('♞', 'b8');
    addPiece('♝', 'c8');
    addPiece('♛', 'd8');
    addPiece('♚', 'e8');
    addPiece('♝', 'f8');
    addPiece('♞', 'g8');
    addPiece('♜', 'h8');

    // Peones negros
    for (int i = 0; i < 8; i++) {
      addPiece('♟', '${String.fromCharCode(97 + i)}7');
    }

    // Piezas blancas
    addPiece('♖', 'a1');
    addPiece('♘', 'b1');
    addPiece('♗', 'c1');
    addPiece('♕', 'd1');
    addPiece('♔', 'e1');
    addPiece('♗', 'f1');
    addPiece('♘', 'g1');
    addPiece('♖', 'h1');

    // Peones blancos
    for (int i = 0; i < 8; i++) {
      addPiece('♙', '${String.fromCharCode(97 + i)}2');
    }
  }

  void addPiece(String piece, String position) {
    pieces.add({'piece': piece, 'position': position});
  }

  void removePiece(String position) {
    pieces.removeWhere((element) => element['position'] == position);
  }

  String? getPieceAt(String position) {
    return pieces.firstWhere(
      (element) => element['position'] == position,
      orElse: () => {'piece': ''},
    )['piece'];
  }

  bool isValidMove(String from, String to) {
    String? piece = getPieceAt(from);
    if (piece == null || piece.isEmpty) return false;

    int fromCol = from.codeUnitAt(0);
    int fromRow = int.parse(from[1]);
    int toCol = to.codeUnitAt(0);
    int toRow = int.parse(to[1]);

    switch (piece) {
      case '♙': // Peón blanco (avanza hacia arriba)
        return (fromCol == toCol &&
            (toRow == fromRow + 1 || (fromRow == 2 && toRow == 4)));
      case '♟': // Peón negro (avanza hacia abajo)
        return (fromCol == toCol &&
            (toRow == fromRow - 1 || (fromRow == 7 && toRow == 5)));
      default:
        return false;
    }
  }

  void movePiece(String from, String to) {
    if (isValidMove(from, to)) {
      removePiece(to); // Captura si hay una pieza en la posición destino
      String? piece = getPieceAt(from);
      if (piece != null && piece.isNotEmpty) {
        removePiece(from);
        addPiece(piece, to);
      }
    }
  }
}

class ChessBoardWidget extends StatefulWidget {
  @override
  _ChessBoardWidgetState createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  final ChessBoard chessBoard = ChessBoard();
  String? selectedPosition;
  bool isWhiteTurn = true;
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _handleTap(String position) {
    setState(() {
      String? piece = chessBoard.getPieceAt(position);

      if (selectedPosition == null) {
        // Seleccionar una pieza del color correcto
        if (piece != null &&
            piece.isNotEmpty &&
            ((isWhiteTurn && piece.contains(RegExp(r'[\u2654-\u2659]'))) ||
                (!isWhiteTurn && piece.contains(RegExp(r'[\u265A-\u265F]'))))) {
          selectedPosition = position;
        }
      } else {
        // Intentar mover la pieza seleccionada
        if (chessBoard.isValidMove(selectedPosition!, position)) {
          chessBoard.movePiece(selectedPosition!, position);
          isWhiteTurn =
              !isWhiteTurn; // Cambiar de turno si el movimiento es válido
        }
        selectedPosition = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajedrez para Dos Jugadores')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Tiempo: ${_formatTime(_secondsElapsed)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            isWhiteTurn ? 'Turno: Blancas' : 'Turno: Negras',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                bool isDark = (row + col) % 2 == 1;
                String position = '${String.fromCharCode(97 + col)}${8 - row}';
                String? pieceSymbol = chessBoard.getPieceAt(position);

                return GestureDetector(
                  onTap: () => _handleTap(position),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? chessBoard.darkSquareColor
                          : chessBoard.lightSquareColor,
                      border: selectedPosition == position
                          ? Border.all(color: Colors.red, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        pieceSymbol ?? '',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
