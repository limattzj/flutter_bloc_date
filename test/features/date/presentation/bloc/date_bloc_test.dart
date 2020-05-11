import 'package:date_bloc/features/date/data/data_sources/local_data_source.dart';
import 'package:date_bloc/features/date/data/model/date_model.dart';
import 'package:date_bloc/features/date/data/repository/date_repository_impl.dart';
import 'package:date_bloc/features/date/domain/entity/date.dart';
import 'package:date_bloc/features/date/presentation/bloc/date_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  DateBloc dateBloc;
  DateRepositoryImpl dateRepositoryImpl;
  DateLocalDataSourceImpl dateLocalDataSource;
  SharedPreferences sharedPreferences;

  final List<Date> emptyDate = [];
  setUp(() async {
    // shared preference
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    // local data source
    dateLocalDataSource = DateLocalDataSourceImpl(sharedPreferences);
    // repo
    dateRepositoryImpl = DateRepositoryImpl(dateLocalDataSource);
    // use case
    // bloc
    dateBloc = DateBloc(repo: dateRepositoryImpl);
  });

  group('GetDatesEvent', () {
    final List<Date> resultDate = [
      Date(
        message: 'upcoming birthday',
        targetDate: DateTime.parse('2021-01-24'),
      )
    ];
    test('initialState should be DateInitial', () async {
      // assert
      expect(dateBloc.initialState, const DateInitial());
    });

    blocTest(
      'should get an empty list',
      build: () async => dateBloc,
      act: (bloc) async => dateBloc.add(const GetDates()),
      skip: 0,
      expect: [
        const DateInitial(),
        const DateLoading(),
        DateLoaded([]),
      ],
    );

    blocTest(
      'should get a list of Date objects',
      build: () async {
        // cache the data using local data source
        final DateModel birthday = DateModel(
          message: 'upcoming birthday',
          targetDate: DateTime.parse('2021-01-24'),
        );
        final listToCache = [birthday];
        // calling local data source to store data
        dateLocalDataSource.cacheDates(listToCache);
        return dateBloc;
      },
      act: (bloc) async => dateBloc.add(const GetDates()),
      skip: 0,
      expect: [
        const DateInitial(),
        const DateLoading(),
        DateLoaded(resultDate),
      ],
    );
  });

  group('AddDateEvent', () {
    final firstBday = Date(
      message: 'my first birthday',
      targetDate: DateTime.parse('1994-01-24'),
    );
    final result = [firstBday];

    blocTest(
      'should add A list of items to SharedPreference when event is AddDateEvent',
      build: () async {
        return dateBloc;
      },
      act: (bloc) async {
        dateBloc.add(CreateDate(
          message: 'my first birthday',
          date: DateTime.parse('1994-01-24'),
        ));
      },
      skip: 0,
      expect: [
        const DateInitial(),
        const DateLoading(),
        DateLoaded(result),
      ],
    );

    blocTest(
      'should return DateError is input is null',
      build: () async => dateBloc,
      act: (bloc) async => dateBloc.add(CreateDate(message: '', date: null)),
      skip: 0,
      expect: [
        const DateInitial(),
        const DateLoading(),
        DateError(message: 'date cannot be null'),
      ],
    );
  });

  group('DeleteDateEvent', () {
    final List<Date> resultDate = [
      Date(
        message: 'upcoming birthday',
        targetDate: DateTime.parse('2021-01-24'),
      )
    ];
    blocTest(
      'should return DateInitial, DateLoading, DateLoaded, DateLoading, DateLoaded',
      build: () async {
        final DateModel birthday = DateModel(
          message: 'upcoming birthday',
          targetDate: DateTime.parse('2021-01-24'),
        );
        final listToCache = [birthday];
        dateLocalDataSource.cacheDates(listToCache);
        return dateBloc;
      },
      act: (bloc) async {
        dateBloc.add(const GetDates());
        return dateBloc.add(const DeleteDate(index: 0));
      },
      skip: 0,
      expect: [
        DateInitial(),
        DateLoading(),
        DateLoaded(resultDate),
        DateLoading(),
        DateLoaded(emptyDate),
      ],
    );
  });

  group('UpdateDate', () {
    final DateModel birthday = DateModel(
      message: 'upcoming birthday',
      targetDate: DateTime.parse('2021-01-24'),
    );
    final DateModel newYear = DateModel(
      message: 'new year',
      targetDate: DateTime.parse('2021-01-01'),
    );

    final DateModel oldYear = DateModel(
      message: 'old year',
      targetDate: DateTime.parse('1000-01-01'),
    );

    blocTest(
      'should update items at index 1',
      build: () async {
        final listToCache = [birthday, newYear];
        // save listToCache to shared preference
        dateLocalDataSource.cacheDates(listToCache);
        return dateBloc;
      },
      act: (bloc) async {
        dateBloc.add(const GetDates());
        return dateBloc.add(UpdateDate(
          index: 1,
          message: 'old year',
          date: DateTime.parse('1000-01-01'),
        ));
      },
      skip: 0,
      expect: [
        DateInitial(),
        DateLoading(),
        DateLoaded([birthday, newYear]),
        DateLoading(),
        DateLoaded([birthday, oldYear]),
      ],
    );
  });
}
