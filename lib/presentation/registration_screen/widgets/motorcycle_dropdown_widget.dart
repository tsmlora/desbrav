import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MotorcycleDropdownWidget extends StatefulWidget {
  final List<Map<String, dynamic>> brands;
  final String? selectedBrand;
  final Function(String?) onBrandChanged;
  final TextEditingController modelController;
  final Function(String) onModelChanged;
  final bool isValid;

  const MotorcycleDropdownWidget({
    Key? key,
    required this.brands,
    required this.selectedBrand,
    required this.onBrandChanged,
    required this.modelController,
    required this.onModelChanged,
    required this.isValid,
  }) : super(key: key);

  @override
  State<MotorcycleDropdownWidget> createState() =>
      _MotorcycleDropdownWidgetState();
}

class _MotorcycleDropdownWidgetState extends State<MotorcycleDropdownWidget> {
  bool _isLoadingModels = false;
  List<String> _availableModels = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedBrand != null) {
      _loadModelsForBrand(widget.selectedBrand!);
    }
  }

  void _loadModelsForBrand(String brandName) async {
    setState(() => _isLoadingModels = true);

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final brand = widget.brands.firstWhere(
      (b) => b['name'] == brandName,
      orElse: () => {'models': <String>[]},
    );

    setState(() {
      _availableModels = List<String>.from(brand['models'] ?? []);
      _isLoadingModels = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Brand dropdown
        DropdownButtonFormField<String>(
          value: widget.selectedBrand,
          decoration: InputDecoration(
            labelText: 'Marca da Moto',
            hintText: 'Selecione a marca',
            suffixIcon: widget.isValid
                ? Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.successLight,
                      size: 20,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isValid
                    ? AppTheme.successLight
                    : AppTheme.dividerLight,
                width: widget.isValid ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isValid
                    ? AppTheme.successLight
                    : AppTheme.dividerLight,
                width: widget.isValid ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isValid
                    ? AppTheme.successLight
                    : AppTheme.primaryLight,
                width: 2,
              ),
            ),
          ),
          items: widget.brands.map<DropdownMenuItem<String>>((brand) {
            return DropdownMenuItem<String>(
              value: brand['name'],
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    brand['name'],
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            widget.onBrandChanged(newValue);
            if (newValue != null) {
              _loadModelsForBrand(newValue);
            } else {
              setState(() {
                _availableModels = [];
                widget.modelController.clear();
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Marca é obrigatória';
            }
            return null;
          },
          dropdownColor: AppTheme.lightTheme.colorScheme.surface,
          icon: CustomIconWidget(
            iconName: 'keyboard_arrow_down',
            color: AppTheme.textSecondaryLight,
            size: 24,
          ),
        ),
        SizedBox(height: 2.h),

        // Model field with autocomplete
        if (widget.selectedBrand != null) ...[
          _isLoadingModels
              ? Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerLight),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryLight,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Carregando modelos...',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight),
                        ),
                      ],
                    ),
                  ),
                )
              : Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _availableModels;
                    }
                    return _availableModels.where((String option) {
                      return option.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                    });
                  },
                  onSelected: (String selection) {
                    widget.modelController.text = selection;
                    widget.onModelChanged(selection);
                  },
                  fieldViewBuilder: (
                    context,
                    controller,
                    focusNode,
                    onEditingComplete,
                  ) {
                    // Sync with the external controller
                    if (widget.modelController.text != controller.text) {
                      controller.text = widget.modelController.text;
                    }

                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      onChanged: (value) {
                        widget.modelController.text = value;
                        widget.onModelChanged(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Modelo',
                        hintText: 'Digite ou selecione o modelo',
                        suffixIcon: widget.modelController.text.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(right: 3.w),
                                child: CustomIconWidget(
                                  iconName: 'check_circle',
                                  color: AppTheme.successLight,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Modelo é obrigatório';
                        }
                        return null;
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 30.h,
                            maxWidth: 85.w,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(
                                  option,
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                                leading: CustomIconWidget(
                                  iconName: 'motorcycle',
                                  color: AppTheme.primaryLight,
                                  size: 18,
                                ),
                                onTap: () => onSelected(option),
                                hoverColor: AppTheme.primaryLight.withValues(
                                  alpha: 0.1,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ],
    );
  }
}
