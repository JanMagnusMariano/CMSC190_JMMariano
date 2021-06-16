import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:spphasetwo/utils/cache_services.dart';
import './bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:meta/meta.dart';

import '../../repository/rethink_weather.dart';

//temp
import '../../models/report_model.dart';
import '../../models/user_model.dart';
import '../../utils/session_services.dart';

class ReportDataBloc extends Bloc<ReportDataEvent, ReportDataState> {
  bool isFetching = false;

  ReportDataBloc() : super(ReportEmpty());

  @override
  Stream<Transition<ReportDataEvent, ReportDataState>> transformEvents(
      Stream<ReportDataEvent> events,
      TransitionFunction<ReportDataEvent, ReportDataState> transitionFn,
      ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<ReportDataState> mapEventToState(ReportDataEvent event) async* {
    if (event is SubmitReport) {
      yield* _mapSubmitReportToState(event);
    } else if (event is FetchOlderReport && !_hasReachedMax(state)) {
      yield* _mapFetchOlderReportToState(event, state);
    } else if (event is FetchNewerReport) {
      yield await _mapFetchNewerReportToState(event, state);
      isFetching = false;
    }
  }

  Stream<ReportDataState> _mapSubmitReportToState(SubmitReport event) async* {
    try {
      await RethinkWeather().submitReport(event.imageFile, event.location, event.description);
      print('Successfully submitted');
    } catch (_) {
      print('Error in submitting report');
    }
  }

  // ignore: missing_return
  Stream<ReportDataState> _mapFetchOlderReportToState(FetchOlderReport event, ReportDataState state) async* {
    if (state is ReportEmpty) {
      List<dynamic> posts = await _fetchReports(0, 10, event.location);
      yield ReportFetched(reports: posts, hasReachedMax: false, lastId: posts[posts.length - 1].id);
    }
    if (state is ReportFetched) {
      List<Report> posts = await _fetchReports(state.lastId, 3, event.location);
      List<Report> newPosts = state.reports + posts;

      int newId = (posts.length == 0) ? 0 : newPosts[newPosts.length - 1].id;
      ReportFetched newState = new ReportFetched(reports: newPosts, hasReachedMax: false, lastId: newId);
      yield (posts.length == 0) ? state.copyWith(hasReachedMax: true) : newState;
    }
  }

  // ignore: missing_return
  Future<ReportDataState> _mapFetchNewerReportToState(FetchNewerReport event, ReportDataState state) async {
    isFetching = true;
    String _fetchDate, _cityName = SessionServices().currCityRaw;
    CityCache currCityCache = SessionServices().currUser.findCityCached(_cityName);

    if (currCityCache == null) _fetchDate = SessionServices().currUser.lastOnline;
    else _fetchDate = currCityCache.newestFetch;

    Map<String, dynamic> _toReturn = await RethinkWeather().fetchLatestReports(_cityName, _fetchDate);

    if (currCityCache == null) {
      CityCache city = new CityCache(
          cityName: _cityName, newestFetch: _toReturn['last_fetch'],
          oldestFetch: _fetchDate, userEmail: SessionServices().currUser.email
      );

      SessionServices().currUser.citiesCache.add(city);
    } else {
      currCityCache.newestFetch = _toReturn['last_fetch'];
      SessionServices().currUser.updateCity(currCityCache);
    }

    if (_toReturn['reports'].length == 0) return state;

    int id = await CacheServices().getLatestId(_cityName);
    print('id $id');
    print('len ' + _toReturn['reports'].length.toString());

    for (var i = (_toReturn['reports'].length - 1); i >= 0; i--) {
      await CacheServices().upsertReport(_toReturn['reports'][i]);
    }

    print('city $_cityName');
    List<dynamic> _reports = _toReturn['reports'];


    List<Report> newReports = await CacheServices().fetchReportBatch(id, _cityName, 10);
    List<Report> reportAppend = new List<Report>();

    if (state is ReportFetched) reportAppend = newReports + state.reports;
    else reportAppend = newReports;

    print('new reps : ' + newReports.length.toString());
    print(reportAppend);

    ReportFetched newState = new ReportFetched(lastId: reportAppend[0].id, reports: reportAppend, hasReachedMax: false);
    return (newReports.length == 0) ? state : newState;
  }

  Future<List<Report>> _fetchReports(int start, int limit, String loc) async {
    // Fetch from cache
    String _cityName = SessionServices().currCityRaw;

    // Check if cache is empty
    //  if empty, fetch new reports, treat as fetchNewerReports
    //  if not empty, fetch up until limit if enough
    //    if not enough, fetch more from server or until very first post is reached
    //    if enough, return

    //delete next line
    if (start == 0) {
      await RethinkWeather().fetchLatestReports(_cityName, '');
      start = await CacheServices().getLatestId(_cityName);
    }

    var result = await CacheServices().fetchReportBatch(start, _cityName, limit);
    return result;
  }

  bool _hasReachedMax(ReportDataState state) =>
      state is ReportFetched && state.hasReachedMax;
}
