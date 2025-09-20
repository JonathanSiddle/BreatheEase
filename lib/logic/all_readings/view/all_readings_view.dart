import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zensoku/logic/all_readings/bloc/all_readings_bloc.dart';
import 'package:zensoku/repositories/peak_flow_readings_repository.dart';
import 'package:zensoku/widgets/day_summary_tile.dart';

///Main class for how this widget will be accessed
///handles displaying view and wrapping widget in required
///bloc, passing through repositories as needed
class AllReadingsPage extends StatelessWidget {
  const AllReadingsPage({super.key});

  static Page<void> page() =>
      const MaterialPage<void>(child: AllReadingsPage());

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const AllReadingsPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllReadingsBloc(
        peakFlowReadingsRepository: context.read<PeakFlowReadingsRepository>(),
      )..add(const AllReadingSubscriptionRequested()),
      child: const _AllReadingsView(),
    );
  }
}

class _AllReadingsView extends StatelessWidget {
  const _AllReadingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AllReadingsBloc, AllReadingsState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('All Readings'),
          ),
          body: CustomScrollView(
            slivers: [
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
            ],
          ),
        );
      },
    );
  }

  Widget getLoadingOrEmptyView(AllReadingsStatus status) {
    if (status == AllReadingsStatus.loading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (status == AllReadingsStatus.success) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('uh oh, no readings, something may have gone wrong!'),
        ),
      );
    } else {
      return const SliverToBoxAdapter(child: Text('Error getting readings'));
    }
  }
}
