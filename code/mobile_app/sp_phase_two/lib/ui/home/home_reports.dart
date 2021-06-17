import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/scheduler.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spphasetwo/utils/session_services.dart';
import '../../blocs/weather_data/bloc.dart';

import '../../blocs/report_data/bloc.dart';

import 'components/report_post.dart';

import '../global_widgets.dart';


// temporary
import '../../utils/cache_services.dart';
import '../../models/report_model.dart';
import '../../utils/session_services.dart';

class HomeReports extends StatefulWidget {
  @override
  State<HomeReports> createState() => _HomeReportsState();
}

class _HomeReportsState extends State<HomeReports> {
  final _scrollController = ScrollController();
  ReportDataBloc _reportBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _reportBloc = BlocProvider.of<ReportDataBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportDataBloc, ReportDataState>(
      buildWhen: (ReportDataState prev, ReportDataState curr) {
        if (curr is ReportEmpty) {
          _reportBloc.add(FetchNewerReport(location: SessionServices().currCityRaw));
        } else if (curr is ReportLoading) {
          GlobalWidgets.loadingOverlay(context);
          return false;
        } else if (curr is ReportFetched) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.pop(context, 'dialog');
          });
        }

        return true;
      },
      // ignore: missing_return
      builder: (context, state) {
        print(state);
        if (state is ReportEmpty || state is ReportLoading) {
          if (state is ReportEmpty) {
            _reportBloc.add(FetchNewerReport(location: SessionServices().currCityRaw));
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(),
          );
        }
        else if (state is ReportFetched) {
          if (state.reports.isEmpty) {
            return Center(child: Text('No posts'));
          }
          return RefreshIndicator(
            // ignore: missing_return
            onRefresh: _onRefresh,
            child: ListView.builder(
              //physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return index >= state.reports.length
                    ? BottomLoader()
                    : ReportPost(imagePath: state.reports[index].reportId);
              },
              itemCount: state.hasReachedMax
                  ? state.reports.length
                  : state.reports.length + 1,
              controller: _scrollController,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      _reportBloc.add(FetchOlderReport(location: SessionServices().currCityRaw));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    if (!_reportBloc.isFetching)
      _reportBloc.add(FetchNewerReport(location: SessionServices().currCityRaw));
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
