import 'package:flutter/material.dart';

class TimerControls extends StatefulWidget {
  final bool isTiming;
  final String elapsedTime;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final bool fillAllRows;
  final ValueChanged<bool?> onFillAllRowsChanged;
  final VoidCallback? onSave;

  const TimerControls({
    Key? key,
    required this.isTiming,
    required this.elapsedTime,
    this.onStart,
    this.onStop,
    required this.fillAllRows,
    required this.onFillAllRowsChanged,
    this.onSave,
  }) : super(key: key);

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
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  icon: Icons.timer,
                  onPressed: widget.onStart,
                  isEnabled: !widget.isTiming,
                ),
                _buildIconButton(
                  icon: Icons.stop,
                  onPressed: widget.onStop,
                  isEnabled: widget.isTiming,
                ),
                _buildSaveButton(),
              ],
            ),
          ),
          SizedBox(height: 10),
          widget.isTiming
              ? Text(
                  widget.elapsedTime,
                  style: TextStyle(
                    color: Colors.brown.shade800,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled ? Colors.brown.shade400 : Colors.grey.shade400,
            padding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(50, 50),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: widget.onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade400,
            padding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(50, 50),
          ),
          child: Icon(
            Icons.save,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }
}
