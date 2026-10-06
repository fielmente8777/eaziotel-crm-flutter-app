import 'package:eazotel/features/whatsapp/controller/whatsappTemplateController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappTemplateScreen extends StatefulWidget {
  WhatsappTemplateScreen({
    super.key,
    this.onTemplateSelected,
    this.onSend,
    this.controller,
    this.sendLabel = 'Send', // <-- NEW
  });

  final String sendLabel; // <-- NEW
  final ValueChanged<dynamic>? onTemplateSelected;

  /// Send dabane par selected template ke saath call hoga.
  /// true return karo to popup band ho jayega.
  final Future<bool> Function(dynamic template)? onSend;

  final Whatsapptemplatecontroller? controller;

  @override
  State<WhatsappTemplateScreen> createState() => _WhatsappTemplateScreenState();
}

class _WhatsappTemplateScreenState extends State<WhatsappTemplateScreen>
    with SingleTickerProviderStateMixin {
  late final Whatsapptemplatecontroller controller;

  final ScrollController _scrollController = ScrollController();

  final Map<int, GlobalKey> _templateKeys = {};

  int? selectedIndex;

  bool _isSending = false;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? Get.put(Whatsapptemplatecontroller());

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // ============================================================
  // KEY
  // ============================================================

  GlobalKey _getTemplateKey(int index) {
    return _templateKeys.putIfAbsent(index, () => GlobalKey());
  }

  // ============================================================
  // SCROLL TO SELECTED TEMPLATE
  // ============================================================

  void _scrollToTemplate(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _templateKeys[index];

      if (key == null) {
        return;
      }

      final targetContext = key.currentContext;

      if (targetContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        alignment: 0.08,
      );
    });
  }

  // ============================================================
  // SELECT TEMPLATE
  // ============================================================

  void _selectTemplate(int index, List<dynamic> templates) {
    if (index < 0 || index >= templates.length) {
      return;
    }

    setState(() {
      selectedIndex = index;
    });

    widget.onTemplateSelected?.call(templates[index]);

    _scrollToTemplate(index);
  }

  // ============================================================
  // SEND TEMPLATE
  // ============================================================

  Future<void> _handleSend(List<dynamic> templates) async {
    if (_isSending) return;

    if (selectedIndex == null ||
        selectedIndex! < 0 ||
        selectedIndex! >= templates.length) {
      return;
    }

    setState(() => _isSending = true);

    bool ok = false;

    try {
      ok = await widget.onSend?.call(templates[selectedIndex!]) ?? false;
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;

    setState(() => _isSending = false);

    if (ok) {
      Navigator.of(context).maybePop();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF15151D),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        final templates =
            controller.whatsappTemplateResponse.value?.result?.docs?.data
                ?.toList() ??
            [];

        return Column(
          children: [
            _buildHeader(templates.length),

            Expanded(
              child: templates.isEmpty
                  ? _buildEmptyState()
                  : _buildTemplateList(context, templates),
            ),

            _buildBottomBar(context, templates),
          ],
        );
      }),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 15, 12, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1C25),
        border: Border(bottom: BorderSide(color: Color(0xFF30313B))),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_outlined, color: Color(0xFFFF8A1F), size: 22),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'WhatsApp Templates',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF302016),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFFFF9A3D),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 5),

          IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIST VIEW
  // ============================================================

  Widget _buildTemplateList(BuildContext context, List<dynamic> templates) {
    return ListView.builder(
      controller: _scrollController,
      cacheExtent: 1200,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: KeyedSubtree(
            key: _getTemplateKey(index),
            child: _buildTemplateCard(
              context: context,
              template: templates[index],
              index: index,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TEMPLATE CARD
  // ============================================================

  Widget _buildTemplateCard({
    required BuildContext context,
    required dynamic template,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    final templateName = _getTemplateName(template);

    final components = _getComponents(template);

    final header = _findComponent(components, 'HEADER');

    final body = _findComponent(components, 'BODY');

    final footer = _findComponent(components, 'FOOTER');

    final buttons = _findComponent(components, 'BUTTONS');

    final headerText = _getString(header, 'text');

    final bodyText = _getString(body, 'text');

    final footerText = _getString(footer, 'text');

    final headerFormat = _getString(header, 'format');

    final isImageHeader = headerFormat.toUpperCase() == 'IMAGE';

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowValue = _glowController.value;

        return GestureDetector(
          onTap: () {
            _selectTemplate(
              index,
              controller.whatsappTemplateResponse.value?.result?.docs?.data
                      ?.toList() ??
                  [],
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF201A19)
                  : const Color(0xFF171820),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Color.lerp(
                        const Color(0xFFFF7200),
                        const Color(0xFFFFB15C),
                        glowValue,
                      )!
                    : const Color(0xFF42434D),
                width: isSelected ? 1.7 : 0.8,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(
                          0xFFFF7200,
                        ).withOpacity(0.15 + (glowValue * 0.18)),
                        blurRadius: 18 + (glowValue * 10),
                        spreadRadius: 1 + (glowValue * 2),
                      ),
                      BoxShadow(
                        color: const Color(
                          0xFFFF9A3D,
                        ).withOpacity(0.08 + (glowValue * 0.10)),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 5,
                      ),
                    ],
            ),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          _buildCardTitle(templateName, isSelected),

          Padding(
            padding: const EdgeInsets.all(13),
            child: _buildTemplatePreview(
              context: context,
              header: header,
              headerText: headerText,
              bodyText: bodyText,
              footerText: footerText,
              buttons: buttons,
              isImageHeader: isImageHeader,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildCardTitle(String name, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF472018) : const Color(0xFF381A15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name.isEmpty ? 'Unnamed Template' : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFF8A1F),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (isSelected)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7200),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7200).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Selected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _buildTemplatePreview({
    required BuildContext context,
    required dynamic header,
    required String headerText,
    required String bodyText,
    required String footerText,
    required dynamic buttons,
    required bool isImageHeader,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isImageHeader)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _buildImageHeader(header),
          ),

        if (!isImageHeader && headerText.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _buildMessageBox(text: headerText, isHeader: true),
          ),

        if (bodyText.trim().isNotEmpty)
          _buildMessageBox(text: bodyText, isHeader: false),

        if (footerText.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              footerText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9999A3),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        if (buttons != null)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: _buildButtons(buttons),
          ),
      ],
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  Widget _buildMessageBox({required String text, required bool isHeader}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF351A16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF4B4B55), width: 0.7),
      ),
      child: Text(
        _formatVariables(text),
        maxLines: isHeader ? 4 : 10,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFFF2F2F5),
          fontSize: isHeader ? 14 : 13,
          height: 1.35,
          fontWeight: isHeader ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE HEADER
  // ============================================================

  Widget _buildImageHeader(dynamic header) {
    try {
      final example = header?.example;

      final dynamic headerHandle = example?.headerHandle;

      String? imageUrl;

      if (headerHandle is List && headerHandle.isNotEmpty) {
        imageUrl = headerHandle.first?.toString();
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        return _buildImagePlaceholder();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 80,
          width: double.infinity,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            cacheWidth: 900,
            cacheHeight: 500,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder(broken: true);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                color: const Color(0xFF25252E),
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF7200),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (_) {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder({bool broken = false}) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF25252E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        broken ? Icons.broken_image_outlined : Icons.image_outlined,
        color: const Color(0xFF888894),
        size: 34,
      ),
    );
  }

  // ============================================================
  // BUTTONS
  // ============================================================

  Widget _buildButtons(dynamic buttonsComponent) {
    try {
      final dynamic buttons = buttonsComponent?.buttons;

      if (buttons == null || buttons is! List || buttons.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: buttons.map<Widget>((button) {
          final text = _getString(button, 'text');

          final type = _getString(button, 'type');

          if (text.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF20212A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _buttonIcon(type),
                  size: 14,
                  color: const Color(0xFF5BA5FF),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5BA5FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  IconData _buttonIcon(String type) {
    switch (type.toUpperCase()) {
      case 'URL':
        return Icons.open_in_new;

      case 'PHONE_NUMBER':
        return Icons.phone_outlined;

      case 'QUICK_REPLY':
        return Icons.reply_outlined;

      default:
        return Icons.touch_app_outlined;
    }
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar(BuildContext context, List<dynamic> templates) {
    final hasSelection =
        selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < templates.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF15151D),
        border: Border(top: BorderSide(color: Color(0xFF30313B))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;

          if (isSmall) {
            return Column(
              children: [
                _buildDropdown(context, templates),

                const SizedBox(height: 8),

                Row(
                  children: [
                    if (hasSelection) ...[
                      Expanded(child: _buildSendButton(templates)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildClearButton()),
                      const SizedBox(width: 8),
                    ],

                    Expanded(child: _buildBackButton(context)),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              SizedBox(width: 320, child: _buildDropdown(context, templates)),

              const SizedBox(width: 10),

              if (hasSelection) _buildClearButton(),

              const Spacer(),

              if (hasSelection) ...[
                _buildSendButton(templates),
                const SizedBox(width: 10),
              ],

              _buildBackButton(context),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown(BuildContext context, List<dynamic> templates) {
    final hasSelection =
        selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < templates.length;

    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF171820),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A4B55)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: hasSelection ? selectedIndex : null,

          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Select Template',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color(0xFFBDBDC6), fontSize: 13),
            ),
          ),

          isExpanded: true,

          dropdownColor: const Color(0xFF25252E),

          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.keyboard_arrow_down, color: Color(0xFFD5D5DD)),
          ),

          items: List.generate(templates.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _getTemplateName(templates[index]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            );
          }),

          onChanged: (index) {
            if (index == null) {
              return;
            }

            _selectTemplate(index, templates);
          },
        ),
      ),
    );
  }

  // ============================================================
  // SEND BUTTON
  // ============================================================

  Widget _buildSendButton(List<dynamic> templates) {
    return InkWell(
      onTap: _isSending ? null : () => _handleSend(templates),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: _isSending
              ? const Color(0xFFFF7200).withOpacity(0.5)
              : const Color(0xFFFF7200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSending)
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.send, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            const Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Widget _buildClearButton() {
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = null;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A315A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close, size: 15, color: Color(0xFF9CC7FF)),
            SizedBox(width: 5),
            Text(
              'Clear',
              style: TextStyle(color: Color(0xFF9CC7FF), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BACK
  // ============================================================

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).maybePop();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4A4B55)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Color(0xFFDADAE0), size: 17),
            SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(color: Color(0xFFDADAE0), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, color: Color(0xFF777783), size: 42),
          SizedBox(height: 12),
          Text(
            'No templates found',
            style: TextStyle(color: Color(0xFFBDBDC6), fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  List<dynamic> _getComponents(dynamic template) {
    try {
      final components = template?.components;

      if (components == null) {
        return [];
      }

      return List<dynamic>.from(components);
    } catch (_) {
      return [];
    }
  }

  dynamic _findComponent(List<dynamic> components, String type) {
    for (final component in components) {
      final componentType = _getString(component, 'type');

      if (componentType.toUpperCase() == type.toUpperCase()) {
        return component;
      }
    }

    return null;
  }

  String _getTemplateName(dynamic template) {
    return _getString(template, 'name');
  }

  String _getString(dynamic object, String field) {
    if (object == null) {
      return '';
    }

    try {
      switch (field) {
        case 'name':
          return object.name?.toString() ?? '';

        case 'type':
          return object.type?.toString() ?? '';

        case 'text':
          return object.text?.toString() ?? '';

        case 'format':
          return object.format?.toString() ?? '';

        case 'language':
          return object.language?.toString() ?? '';

        case 'category':
          return object.category?.toString() ?? '';

        default:
          return '';
      }
    } catch (_) {
      return '';
    }
  }

  String _formatVariables(String text) {
    return text.replaceAllMapped(RegExp(r'\{\{\s*(\d+)\s*\}\}'), (match) {
      return '{{${match.group(1)}}}';
    });
  }
}
