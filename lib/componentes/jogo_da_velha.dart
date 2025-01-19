import 'package:flutter/material.dart';
import 'dart:math';

class JogoDaVelha extends StatefulWidget {
  const JogoDaVelha({super.key});

  @override
  State<JogoDaVelha> createState() => _JogoDaVelhaState();
}

class _JogoDaVelhaState extends State<JogoDaVelha> {
  List<String> _tabuleiro = List.filled(9, '');
  String _jogador = 'x';
  bool _contraMaquina = false;
  final Random _randomico = Random();
  String _mensagem = '';
  bool _pensando = false;

  void _iniciarJogo() {
    setState(() {
      _tabuleiro = List.filled(9, '');
      _jogador = 'x';
      _mensagem = '';
      _pensando = false;
    });
  }

  void _trocaJogador() {
    setState(() {
      _jogador = _jogador == 'x' ? 'o' : 'x';
    });
  }

  void _mostreDialogoVencedor(String vencedor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vencedor == 'Empate' ? 'Empate!' : 'Vencedor: $vencedor'),
          actions: [
            ElevatedButton(
              child: const Text('Reiniciar jogo'),
              onPressed: () {
                Navigator.of(context).pop();
                _iniciarJogo();
              },
            ),
          ],
        );
      },
    );
  }

  bool _verificaVencedor(String jogador) {
    const posicoesVencedoras = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var posicoes in posicoesVencedoras) {
      if (_tabuleiro[posicoes[0]] == jogador &&
          _tabuleiro[posicoes[1]] == jogador &&
          _tabuleiro[posicoes[2]] == jogador) {
        _mostreDialogoVencedor(jogador);
        return true;
      }
    }
    if (!_tabuleiro.contains('')) {
      _mostreDialogoVencedor('Empate');
      return true;
    }
    return false;
  }

  void _jogadaComputador() {
    setState(() {
      _pensando = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      int movimento;
      do {
        movimento = _randomico.nextInt(9);
      } while (_tabuleiro[movimento] != '');
      setState(() {
        _tabuleiro[movimento] = 'o';
        if (!_verificaVencedor('o')) {
          _trocaJogador();
        }
        _pensando = false;
      });
    });
  }

  void jogada(int index) {
    if (_tabuleiro[index] == '' && _mensagem == '') {
      setState(() {
        _tabuleiro[index] = _jogador;
        if (!_verificaVencedor(_jogador)) {
          _trocaJogador();
          if (_contraMaquina && _jogador == 'o') {
            _jogadaComputador();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double altura = MediaQuery.of(context).size.height * 0.5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: _contraMaquina,
                  onChanged: (value) {
                    setState(() {
                      _contraMaquina = value;
                      _iniciarJogo();
                    });
                  },
                ),
              ),
              Text(_contraMaquina ? 'Computador' : 'Humano'),
              const SizedBox(width: 30.0),
              if (_pensando)
                SizedBox(
                  height: 15.0,
                  width: 15.0,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        SizedBox(
          width: altura,
          height: altura,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  jogada(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.pink.shade700,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      _tabuleiro[index],
                      style: const TextStyle(fontSize: 40.0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20), // Espaçamento entre o tabuleiro e o botão
        ElevatedButton(
          onPressed: _iniciarJogo,
          child: const Text('Reiniciar jogo'),
        ),
      ],
    );
  }
}
