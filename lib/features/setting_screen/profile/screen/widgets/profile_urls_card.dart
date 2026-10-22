import 'package:eazotel/utils/res/t_responsive.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_setting_controller.dart';
import '../../../screen/widgets/setting_section_card.dart';

/// Links of landing pages + websites
class SettingUrlsCard extends StatelessWidget {
  const SettingUrlsCard({super.key, required this.controller, required this.r});

  final ProfileSettingController controller;
  final TResponsive r;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Obx(() {
      // Read the profile's URLs once it is available.
      final profile = controller.profile?.urls;

      if (profile != null) {
        // Sync the URLs from the API into the reactive lists.
        final landingUrls = profile.landingPages;
        final websiteUrls = profile.websites;

        if (controller.landingPages.toList().toString() !=
            landingUrls.toString()) {
          controller.landingPages.assignAll(landingUrls);
        }

        if (controller.websites.toList().toString() != websiteUrls.toString()) {
          controller.websites.assignAll(websiteUrls);
        }
      }

      final landing = _LinkList(
        title: 'Landing Pages',
        hint: 'yourhotel.com/offer',
        links: controller.landingPages,
        controller: controller,
      );

      final websites = _LinkList(
        title: 'Websites',
        hint: 'yourhotel.com',
        links: controller.websites,
        controller: controller,
      );

      final count = controller.landingPages.length + controller.websites.length;

      return SettingSectionCard(
        icon: Icons.link_rounded,
        title: 'URLs',
        trailing: '$count link${count == 1 ? '' : 's'}',
        subtitle:
            'Links you add here are used across SEO tracking and ad reporting.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.isPhone) ...[
              landing,
              const SizedBox(height: 18),
              websites,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: landing),
                  const SizedBox(width: 20),
                  Expanded(child: websites),
                ],
              ),
            Divider(height: 32, color: p.border),
            ElevatedButton(
              style: settingSmallButton(),
              onPressed: controller.saveLinks,
              child: const Text('Save'),
            ),
          ],
        ),
      );
    });
  }
}

class _LinkList extends StatefulWidget {
  const _LinkList({
    required this.title,
    required this.hint,
    required this.links,
    required this.controller,
  });

  final String title;
  final String hint;
  final RxList<String> links;
  final ProfileSettingController controller;

  @override
  State<_LinkList> createState() => _LinkListState();
}

class _LinkListState extends State<_LinkList> {
  final TextEditingController _input = TextEditingController();

  bool _adding = false;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.controller.addLink(widget.links, _input.text);

    setState(() {
      _error = error;

      if (error == null) {
        _input.clear();
        _adding = false;
      }
    });
  }

  /// Put an existing URL into the input to edit it.
  void _edit(String link) {
    widget.links.remove(link);

    setState(() {
      _input.text = link;
      _adding = true;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: p.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        Obx(
          () => Column(
            children: [
              for (final link in widget.links.toList())
                Container(
                  key: ValueKey(link),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: p.inner,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          link,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.primary, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _edit(link),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 17,
                          color: p.subText,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          widget.links.remove(link);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 17,
                          color: TAppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        if (_adding) ...[
          TextField(
            controller: _input,
            autofocus: true,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            style: TextStyle(color: p.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: widget.hint,
              isDense: true,
              errorText: _error,
              suffixIcon: IconButton(
                tooltip: 'Add',
                onPressed: _submit,
                icon: Icon(Icons.check, size: 18, color: p.primary),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 8),
        ],

        OutlinedButton.icon(
          onPressed: _adding
              ? _submit
              : () {
                  setState(() {
                    _adding = true;
                    _error = null;
                  });
                },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 36),
            foregroundColor: p.subText,
            side: BorderSide(color: p.subText),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add link', style: TextStyle(fontSize: 12.5)),
        ),
      ],
    );
  }
}
