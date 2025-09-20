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
                    BlocBuilder<SettingsCubit, ZensokuThemeMode>(
                      builder: (context, state) {
                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButton<ZensokuThemeMode>(
                                isExpanded: true,
                                value: state,
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
