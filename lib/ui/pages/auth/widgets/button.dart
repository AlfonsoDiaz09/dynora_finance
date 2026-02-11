import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Button extends StatefulWidget {
  const Button({super.key, required this.loading, required this.text});

  final String text;
  final bool loading;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool loading = false;

  @override
  void initState() {
    loading = widget.loading;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 52.h,
      decoration: BoxDecoration(
        color: Color(0xFFB14CFF),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB14CFF).withValues(alpha: 0.4),
            blurRadius: 16.r,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() => loading = true);
          },
          child: Center(
            child: loading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
