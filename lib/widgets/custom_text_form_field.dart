import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Icon? leadingIcon;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextFormField({
    super.key,
    this.labelText = '',
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.leadingIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: widget.readOnly 
              ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5)  // darker when readonly
              : Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          obscureText: _isObscure,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            prefixIcon: widget.leadingIcon,
            suffixIcon: widget.suffixIcon ?? (widget.obscureText ? 
              IconButton(
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                }, 
                icon: Icon(!_isObscure ?
                  Icons.visibility : Icons.visibility_off
                ),
              ) : null
            ),
          ),
        ),
      ),
    );
  }
}
