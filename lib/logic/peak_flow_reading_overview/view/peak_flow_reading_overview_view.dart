import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:zensoku/logic/all_readings/view/all_readings_view.dart';
import 'package:zensoku/logic/peak_flow_reading_overview/bloc/peak_flow_reading_overview_bloc.dart';
import 'package:zensoku/logic/settings/settings_page.dart';
import 'package:zensoku/models/day_data.dart';
import 'package:zensoku/models/features/app_feature.dart';
import 'package:zensoku/repositories/date_time_repository.dart';
import 'package:zensoku/repositories/guid_id_repository.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/util/log_util.dart';
import 'package:zensoku/widgets/day_summary_tile.dart';
import 'package:zensoku/widgets/dialog_util.dart';
import 'package:zensoku/widgets/week_overview_graph.dart';
import 'package:zensoku/zensoku_theme.dart';

class PeakFlowReadingOverviewPage extends StatelessWidget {
  PeakFlowReadingOverviewPage({super.key, Logger? logger})
      : _logger = logger ?? Logger();

  static Page<void> page({Logger? logger}) => MaterialPage<void>(
          child: PeakFlowReadingOverviewPage(
        logger: logger ?? Logger(),
      ));

  static MaterialPageRoute<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => PeakFlowReadingOverviewPage());
  }

  final Logger _logger;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PeakFlowReadingOverviewBloc(
          featureRegistory: context.read<FeatureRegistory>(),
          guidRepository: context.read<GuidRepository>(),
          dateTimeRepository: context.read<DateTimeRepository>(),
          peakFlowReadingsRepository:
              context.read<PeakFlowReadingsRepository>())
        ..add(const PeakFlowReadingOverviewSubscriptionRequested()),
      child: PeakFlowReadingsOverviewView(logger: _logger),
    );
  }
}

class PeakFlowReadingsOverviewView extends StatelessWidget {
  PeakFlowReadingsOverviewView({super.key, required Logger? logger})
      : _logger = logger ?? Logger();

  final _key = GlobalKey<ExpandableFabState>();
  final Logger _logger;

  Widget getLoadingOrEmptyView(PeakFlowReadingOverviewStatus status) {
    if (status == PeakFlowReadingOverviewStatus.loading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (status == PeakFlowReadingOverviewStatus.success) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('Start Adding Readings'),
        ),
      );
    } else {
      return const SliverToBoxAdapter(child: Text('Error getting readings'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: MultiBlocListener(
            listeners: [
              BlocListener<PeakFlowReadingOverviewBloc,
                  PeakFlowReadingOverviewState>(listener: (context, state) {
                _logger.d(state.status);
                if (state.status ==
                    PeakFlowReadingOverviewStatus.showAllReadingsPage) {
                  _logger.d('Showing readings page');
                  //show all readings page
                  Navigator.of(context).push(AllReadingsPage.route());
                } else {
                  _logger.d('user is not premium');
                }
              })
            ],
            child: BlocBuilder<PeakFlowReadingOverviewBloc,
                PeakFlowReadingOverviewState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              children: [
                                Text(
                                  'Overview',
                                  style: TextStyle(fontSize: 48),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(SettingsPage.route());
                              },
                              icon: const Icon(FontAwesomeIcons.gear),
                              iconSize: 32,
                            )
                          ],
                        ),
                      ),
                      //---Graph View Section
                      SliverToBoxAdapter(
                        child: WeekOverviewGraph(
                          daysAndSummary:
                              DayData.toDisplayDatesAndValues(state.dayData),
                          logger: _logger,
                        ),
                      ),
                      if (state.dayData.isEmpty)
                        getLoadingOrEmptyView(state.status)
                      else
                        SliverList.builder(
                            itemBuilder: (context, index) {
                              final day = state.dayData[index];

                              return DaySummaryTile(
                                dayData: day,
                              );
                            },
                            itemCount: state.dayData.length),
                      SliverToBoxAdapter(
                        child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
                            child: TextButton(
                                child: const Text('More'),
                                onPressed: () async {
                                  context.read<PeakFlowReadingOverviewBloc>().add(
                                      const PeakFlowReadingOverviewRequestShowAllReadings());
                                })),
                      )
                    ],
                  ),
                );
              },
            ),
          )),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(FontAwesomeIcons.plus),
          foregroundColor: Colors.white,
          backgroundColor: ZensokuTheme.primaryColor,
          angle: 3.14 * 2,
        ),
        closeButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(FontAwesomeIcons.x),
          foregroundColor: Colors.white,
          backgroundColor: ZensokuTheme.primaryColor,
        ),
        type: ExpandableFabType.up, // FAB expands upwards
        children: [
          FloatingActionButton.large(
            heroTag: 'add peak flow',
            onPressed: () async {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              await showPeakFlowReadingInputDialog(context,
                  logger: context
                      .read<LoggingFactory>()
                      .getLogger('showPeakFlowInputDialog'));
            },
            tooltip: 'peak flow',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/lungs.svg',
                  width: 40,
                  height: 40,
                ),
                const Text(
                  'Peak Flow',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          FloatingActionButton.large(
            heroTag: 'Preventer',
            onPressed: () async {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              context
                  .read<PeakFlowReadingOverviewBloc>()
                  .add(const PeakFlowReadingOverviewIncrementPreventerUse());
            },
            tooltip: 'Preventer',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/preventer.svg',
                ),
                const Text(
                  'Preventer',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          FloatingActionButton.large(
            heroTag: 'reliever',
            onPressed: () async {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              context
                  .read<PeakFlowReadingOverviewBloc>()
                  .add(const PeakFlowReadingOverviewIncrementRelieverUse());
            },
            tooltip: 'reliever',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/reliever.svg',
                ),
                const Text(
                  'Reliever',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
