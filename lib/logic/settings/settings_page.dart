import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zensoku/logic/settings/settings_cubit.dart';
import 'package:zensoku/static/global_strings.dart';
import 'package:zensoku/zensoku_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SettingsPage());
  }

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //top section
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Text(
                        'Theme',
                        style:
                            TextStyle(fontSize: ZensokuTheme.baseHeading1Size),
                      ),
                    ),
                    BlocBuilder<SettingsCubit, BreatheEaseSettings>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<ZensokuThemeMode>(
                                    isExpanded: true,
                                    value: state.mode,
                                    onChanged: (ZensokuThemeMode? themeVal) {
                                      final newThemeVal =
                                          themeVal ?? ZensokuThemeMode.system;
                                      settingsCubit.updateTheme(newThemeVal);
                                    },
                                    items: const <DropdownMenuItem<
                                        ZensokuThemeMode>>[
                                      DropdownMenuItem<ZensokuThemeMode>(
                                        value: ZensokuThemeMode.light,
                                        child: Text('Light'),
                                      ),
                                      DropdownMenuItem<ZensokuThemeMode>(
                                        value: ZensokuThemeMode.dark,
                                        child: Text('Dark'),
                                      ),
                                      DropdownMenuItem<ZensokuThemeMode>(
                                        value: ZensokuThemeMode.system,
                                        child: Text('System'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Text(
                                'Features',
                                style: TextStyle(
                                    fontSize: ZensokuTheme.baseHeading1Size),
                              ),
                            ),
                            //feature toggles
                            ...state.features.map((f) => ReusableToggleSwitch(
                                key: Key(f.type.key),
                                value: f.isEnabled,
                                title: f.type.displayName,
                                onChanged: (v) =>
                                    settingsCubit.updateFeature(f.type.key, v)))
                          ],
                        );
                      },
                    ),
                  ],
                ),
                // const Spacer(),
                //bottom column
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: TextButton(
                        onPressed: () async {
                          if (!await launchUrl(Uri.parse(CONTACT_URL))) {
                            // throw Exception('Could not launch $_contactUrl');
                          }
                        },
                        child: const Text(
                          'SUPPPORT',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: TextButton(
                        onPressed: () async {
                          if (!await launchUrl(Uri.parse(TERMS_URL))) {
                            // throw Exception('Could not launch $_termsUrl');
                          }
                        },
                        child: const Text(
                          'TERMS AND CONDITIONS',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: TextButton(
                        onPressed: () async {
                          if (!await launchUrl(Uri.parse(PRIVACY_URL))) {
                            // throw Exception('Could not launch $_privacyUrl');
                          }
                        },
                        child: const Text(
                          'PRIVACY POLICY',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (BuildContext context) => LicensePage(
                                    applicationName: 'BreatheEase',
                                    applicationVersion:
                                        settingsCubit.pubspecVersion,
                                    applicationIcon:
                                        SvgPicture.asset('lung.svg'),
                                    applicationLegalese: '',
                                  )));
                        },
                        child: const Text(
                          'OPEN SOURCE',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        settingsCubit.pubspecVersion,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReusableToggleSwitch extends StatelessWidget {
  const ReusableToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor,
    this.inactiveColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? title;
  final String? subtitle;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
          inactiveThumbColor: inactiveColor,
        ),
      ],
    );
  }
}
