import 'package:flutter/material.dart';

class TimerControls extends StatefulWidget {
  final bool isTiming;
  final String elapsedTime;
  final VoidCallback? onStart;
  final VoidCallback onStop;
  final bool fillAllRows;
  final ValueChanged<bool?> onFillAllRowsChanged;

  TimerControls({
    required this.isTiming,
    required this.elapsedTime,
    this.onStart,
    required this.onStop,
    required this.fillAllRows,
    required this.onFillAllRowsChanged,
  });

  @override
  _TimerControlsState createState() => _TimerControlsState();
}

class _TimerControlsState extends State<TimerControls> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  checkColor: Colors.white,
                  activeColor: Colors.brown.shade400,
                  value: widget.fillAllRows,
                  onChanged: widget.onFillAllRowsChanged,
                ),
              ),
              SizedBox(width: 5),
              Text(
                "Preencher todas as linhas",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 10),
          widget.isTiming
              ? _buildStopButton(context)
              : _buildStartButton(context),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => widget.onStart?.call(),
      child: Text('Cronometrar'),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.onStart != null ? Colors.brown.shade400 : Colors.grey,
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
          widget.elapsedTime,
          style: TextStyle(
            color: Colors.brown.shade800,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => widget.onStop(),
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
