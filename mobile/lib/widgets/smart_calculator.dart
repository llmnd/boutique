import 'package:flutter/material.dart';

class SmartCalculator extends StatefulWidget {
  final Function(double) onResultSelected;
  final double? initialValue;
  final String title;
  final bool isDark;

  const SmartCalculator({
    super.key,
    required this.onResultSelected,
    this.initialValue,
    this.title = 'CALCULATRICE',
    required this.isDark,
  });

  @override
  State<SmartCalculator> createState() => _SmartCalculatorState();
}

class _SmartCalculatorState extends State<SmartCalculator> {
  String _display = '0';
  String _fullExpression = '';
  List<String> _expressionParts = [];
  double _result = 0;
  String _lastOperation = '';

  bool _newNumber = true;
  bool _justCalculated = false;
  bool _showHistory = false;
  bool _hasDecimal = false;

  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _display = _formatNumber(widget.initialValue!);
      _fullExpression = _display;
      _expressionParts = [_display];
    }
  }

  /* ================= FORMAT ================= */

  String _formatNumber(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    String formatted = v.toStringAsFixed(6);
    return formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /* ================= NUMBERS ================= */

  void _handleNumber(String n) {
    setState(() {
      if (_justCalculated) {
        _resetAfterCalculation();
      }

      if (_newNumber || _display == '0') {
        _display = n;
        _newNumber = false;
        _lastOperation = '';
        
        if (_expressionParts.isEmpty || 
            (_expressionParts.isNotEmpty && _isOperation(_expressionParts.last))) {
          _expressionParts.add(n);
        } else {
          _expressionParts[_expressionParts.length - 1] = n;
        }
      } else {
        if (_display.length < 12) {
          _display += n;
          if (_expressionParts.isNotEmpty && !_isOperation(_expressionParts.last)) {
            _expressionParts[_expressionParts.length - 1] = _display;
          }
        }
      }
      
      _updateFullExpression();
    });
  }

  /* ================= RÉINITIALISATION APRÈS CALCUL ================= */

  void _resetAfterCalculation() {
    _display = '0';
    _fullExpression = '';
    _expressionParts = [];
    _result = 0;
    _lastOperation = '';
    _justCalculated = false;
    _newNumber = true;
    _hasDecimal = false;
  }

  /* ================= POINT DÉCIMAL ================= */

  void _handleDecimal() {
    if (_justCalculated) {
      _resetAfterCalculation();
    }

    if (!_hasDecimal) {
      setState(() {
        if (_newNumber) {
          _display = '0.';
          _newNumber = false;
          _lastOperation = '';
          
          if (_expressionParts.isEmpty || 
              (_expressionParts.isNotEmpty && _isOperation(_expressionParts.last))) {
            _expressionParts.add('0.');
          } else {
            _expressionParts[_expressionParts.length - 1] = '0.';
          }
        } else {
          _display += '.';
          if (_expressionParts.isNotEmpty && !_isOperation(_expressionParts.last)) {
            _expressionParts[_expressionParts.length - 1] = _display;
          }
        }
        _hasDecimal = true;
        _updateFullExpression();
      });
    }
  }

  /* ================= OPÉRATIONS ================= */

  void _handleOperation(String op) {
    setState(() {
      if (_justCalculated) {
        // Après un calcul, on commence une nouvelle expression avec le résultat
        _expressionParts = [_display];
        _justCalculated = false;
        _newNumber = true;
        _hasDecimal = false;
        _lastOperation = op;
        _display = '0'; // CORRECTION : Réinitialiser l'affichage
      } else if (_newNumber && _expressionParts.isNotEmpty && 
                 _isOperation(_expressionParts.last)) {
        // Si on appuie sur une opération sans nouveau nombre, on change l'opération
        _expressionParts[_expressionParts.length - 1] = op;
        _lastOperation = op;
        _display = '0'; // CORRECTION : Réinitialiser l'affichage
      } else if (!_newNumber) {
        // Ajouter l'opération après un nombre
        _expressionParts.add(op);
        _newNumber = true;
        _hasDecimal = false;
        _lastOperation = op;
        _display = '0'; // CORRECTION : Réinitialiser l'affichage après opération
      } else if (_expressionParts.isNotEmpty && !_isOperation(_expressionParts.last)) {
        // Si on a un nombre mais _newNumber est vrai (après une opération)
        _expressionParts.add(op);
        _lastOperation = op;
        _display = '0'; // CORRECTION : Réinitialiser l'affichage
      }
      
      _updateFullExpression();
    });
  }

  /* ================= VÉRIFIER SI C'EST UNE OPÉRATION ================= */

  bool _isOperation(String token) {
    return token == '+' || token == '-' || token == '×' || token == '÷' || token == '%';
  }

  /* ================= METTRE À JOUR L'EXPRESSION COMPLÈTE ================= */

  void _updateFullExpression() {
    _fullExpression = _expressionParts.join(' ');
    
    while (_fullExpression.isNotEmpty && 
           _isOperation(_fullExpression.split(' ').last)) {
      final parts = _fullExpression.split(' ');
      parts.removeLast();
      _fullExpression = parts.join(' ');
    }
  }

  /* ================= CALCUL FINAL ================= */

  void _calculate() {
    if (_expressionParts.length < 3) return;
    
    try {
      List<dynamic> tokens = [..._expressionParts];
      
      // Traiter × ÷ %
      for (int i = 0; i < tokens.length; i++) {
        if (tokens[i] == '×' || tokens[i] == '÷' || tokens[i] == '%') {
          if (i > 0 && i < tokens.length - 1) {
            double left = double.parse(tokens[i - 1].toString());
            double right = double.parse(tokens[i + 1].toString());
            double result;
            
            switch (tokens[i]) {
              case '×':
                result = left * right;
                break;
              case '÷':
                result = right != 0 ? left / right : double.infinity;
                break;
              case '%':
                result = left * (right / 100);
                break;
              default:
                result = 0;
            }
            
            tokens[i - 1] = result.toString();
            tokens.removeAt(i);
            tokens.removeAt(i);
            i--;
          }
        }
      }
      
      // Traiter + -
      double total = double.parse(tokens[0].toString());
      
      for (int i = 1; i < tokens.length; i += 2) {
        if (i + 1 < tokens.length) {
          double nextNum = double.parse(tokens[i + 1].toString());
          
          switch (tokens[i]) {
            case '+':
              total += nextNum;
              break;
            case '-':
              total -= nextNum;
              break;
          }
        }
      }
      
      setState(() {
        _result = total;
        _display = _formatNumber(_result);
        _lastOperation = '';
        
        String historyExpression = _fullExpression;
        String historyResult = _display;
        
        _history.insert(0, {
          'expression': historyExpression,
          'result': historyResult
        });
        
        if (_history.length > 20) _history.removeLast();
        
        _fullExpression = _display;
        _expressionParts = [_display];
        _newNumber = true;
        _hasDecimal = false;
        _justCalculated = true;
      });
      
    } catch (e) {
      setState(() {
        _display = 'Erreur';
        _lastOperation = '';
        _justCalculated = true;
      });
    }
  }

  /* ================= ACTIONS ================= */

  void _clear() {
    setState(() {
      _display = '0';
      _fullExpression = '';
      _expressionParts = [];
      _result = 0;
      _lastOperation = '';
      _newNumber = true;
      _hasDecimal = false;
      _justCalculated = false;
    });
  }

  void _clearEntry() {
    setState(() {
      if (_justCalculated) {
        _clear();
      } else {
        _display = '0';
        _newNumber = true;
        _hasDecimal = false;
        _lastOperation = '';
        
        if (_expressionParts.isNotEmpty && !_isOperation(_expressionParts.last)) {
          _expressionParts[_expressionParts.length - 1] = '0';
          _updateFullExpression();
        }
      }
    });
  }

  void _backspace() {
    if (_display == '0' || _display.length == 1 || _justCalculated) {
      _clearEntry();
      return;
    }

    setState(() {
      final newDisplay = _display.substring(0, _display.length - 1);
      
      _display = newDisplay.isEmpty ? '0' : newDisplay;
      
      if (_expressionParts.isNotEmpty && !_isOperation(_expressionParts.last)) {
        _expressionParts[_expressionParts.length - 1] = _display;
        _updateFullExpression();
      }
      
      if (!_display.contains('.')) {
        _hasDecimal = false;
      }
    });
  }

  void _selectResult() {
    final value = double.tryParse(_display.replaceAll(',', '.')) ?? 0;
    
    double finalValue;
    if (value == value.toInt()) {
      finalValue = value.toInt().toDouble();
    } else {
      finalValue = value;
    }
    
    widget.onResultSelected(finalValue);
    Navigator.pop(context);
  }

  /* ================= BOUTONS AVEC EFFETS ================= */

  Widget _btn(
    String label,
    VoidCallback onTap, {
    Color? bg,
    Color? fg,
    double size = 24,
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isActive ? fg : bg,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.2),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w400,
                color: isActive ? bg : fg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ================= AFFICHAGE ================= */

  Widget _buildDisplay(Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_fullExpression.isNotEmpty && _fullExpression != _display)
            Flexible(
              child: SingleChildScrollView(
                reverse: true,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      _fullExpression,
                      style: TextStyle(
                        fontSize: 18,
                        color: txt.withOpacity(0.5),
                      ),
                    ),
                    // Afficher l'opération active à la fin si elle existe
                    if (_lastOperation.isNotEmpty)
                      Text(
                        ' $_lastOperation',
                        style: TextStyle(
                          fontSize: 18,
                          color: txt,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: txt,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ================= HISTORIQUE ================= */

  Widget _buildHistory(Color txt) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique',
                style: TextStyle(
                  color: txt,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                color: txt,
                onPressed: () => setState(() => _showHistory = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Text(
                      'Aucun historique',
                      style: TextStyle(color: txt.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final entry = _history[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              entry['expression']!,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: txt.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              entry['result']!,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: txt,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    final bg = isDark ? Colors.black : Colors.white;
    final btn = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5EA);
    final op = const Color(0xFFFF9500);
    final result = const Color(0xFF34C759);
    final action = const Color(0xFF007AFF);
    final txt = isDark ? Colors.white : Colors.black;

    bool isPlusActive = _lastOperation == '+';
    bool isMinusActive = _lastOperation == '-';
    bool isMultiplyActive = _lastOperation == '×';
    bool isDivideActive = _lastOperation == '÷';
    bool isPercentActive = _lastOperation == '%';

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 600,
          maxWidth: 380,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* ================= EN-TÊTE ================= */

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      _showHistory ? Icons.calculate : Icons.history,
                      size: 22,
                    ),
                    color: txt,
                    onPressed: () => setState(() => _showHistory = !_showHistory),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    color: txt,
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            /* ================= AFFICHAGE / HISTORIQUE ================= */

            Expanded(
              child: _showHistory ? _buildHistory(txt) : _buildDisplay(txt),
            ),

            /* ================= GRILLE DE BOUTONS ================= */

            if (!_showHistory)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Première ligne - Actions
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: _btn('CE', _clearEntry, bg: btn, fg: txt, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _btn('C', _clear, bg: btn, fg: Colors.red),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _btn('←', _backspace, bg: btn, fg: txt),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _btn(
                              '÷', 
                              () => _handleOperation('÷'), 
                              bg: op, 
                              fg: Colors.white,
                              isActive: isDivideActive,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Grille numérique
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.0,
                      children: [
                        // Ligne 1
                        _btn('7', () => _handleNumber('7'), bg: btn, fg: txt),
                        _btn('8', () => _handleNumber('8'), bg: btn, fg: txt),
                        _btn('9', () => _handleNumber('9'), bg: btn, fg: txt),
                        _btn(
                          '×', 
                          () => _handleOperation('×'), 
                          bg: op, 
                          fg: Colors.white,
                          isActive: isMultiplyActive,
                        ),

                        // Ligne 2
                        _btn('4', () => _handleNumber('4'), bg: btn, fg: txt),
                        _btn('5', () => _handleNumber('5'), bg: btn, fg: txt),
                        _btn('6', () => _handleNumber('6'), bg: btn, fg: txt),
                        _btn(
                          '-', 
                          () => _handleOperation('-'), 
                          bg: op, 
                          fg: Colors.white,
                          isActive: isMinusActive,
                        ),

                        // Ligne 3
                        _btn('1', () => _handleNumber('1'), bg: btn, fg: txt),
                        _btn('2', () => _handleNumber('2'), bg: btn, fg: txt),
                        _btn('3', () => _handleNumber('3'), bg: btn, fg: txt),
                        _btn(
                          '+', 
                          () => _handleOperation('+'), 
                          bg: op, 
                          fg: Colors.white,
                          isActive: isPlusActive,
                        ),

                        // Ligne 4
                        _btn('0', () => _handleNumber('0'), bg: btn, fg: txt),
                        _btn('.', _handleDecimal, bg: btn, fg: txt),
                        _btn(
                          '%', 
                          () => _handleOperation('%'), 
                          bg: btn, 
                          fg: txt,
                          isActive: isPercentActive,
                        ),
                        _btn('=', _calculate, bg: result, fg: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bouton OK
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _selectResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: action,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          splashFactory: InkRipple.splashFactory,
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}