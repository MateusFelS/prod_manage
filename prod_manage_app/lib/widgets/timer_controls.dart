import 'package:flutter/material.dart';

class TimerControls extends StatelessWidget {
  final bool isTiming;
  final String elapsedTime;
  final VoidCallback onStart;
  final VoidCallback onStop;

  TimerControls({
    required this.isTiming,
    required this.elapsedTime,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isTiming ? _buildStopButton(context) : _buildStartButton(context),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onStart,
      child: Text('Cronometrar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown.shade400,
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        fixedSize: Size(MediaQuery.of(context).size.width * .8, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildStopButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          elapsedTime,
          style: TextStyle(
            color: Colors.brown.shade800,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: onStop,
          child: Text('Parar Cronômetro'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade400,
            foregroundColor: Colors.white,
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            fixedSize: Size(MediaQuery.of(context).size.width * .8, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
