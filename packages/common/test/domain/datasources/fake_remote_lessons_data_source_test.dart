import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeRemoteLessonsDataSource dataSource;

  setUp(() => dataSource = FakeRemoteLessonsDataSource());

  group('FakeRemoteLessonsDataSource', () {
    group('fetchLessons', () {
      test('returns empty list when no lessons have been saved', () async {
        final lessons = await dataSource.fetchLessons();
        expect(lessons, isEmpty);
      });

      test('returns all saved lessons', () async {
        await dataSource.saveLesson(_lesson('1'));
        await dataSource.saveLesson(_lesson('2'));

        final lessons = await dataSource.fetchLessons();

        expect(lessons, hasLength(2));
        expect(lessons.map((l) => l.id), containsAll(['1', '2']));
      });
    });

    group('saveLesson', () {
      test('adds a new lesson', () async {
        await dataSource.saveLesson(_lesson('1', name: 'Intro'));

        final lessons = await dataSource.fetchLessons();

        expect(lessons, hasLength(1));
        expect(lessons.first.id, '1');
        expect(lessons.first.name, 'Intro');
      });

      test('replaces lesson with the same id', () async {
        await dataSource.saveLesson(_lesson('1', name: 'Original'));
        await dataSource.saveLesson(_lesson('1', name: 'Updated'));

        final lessons = await dataSource.fetchLessons();

        expect(lessons, hasLength(1));
        expect(lessons.first.name, 'Updated');
      });

      test('keeps distinct lessons with different ids', () async {
        await dataSource.saveLesson(_lesson('1'));
        await dataSource.saveLesson(_lesson('2'));
        await dataSource.saveLesson(_lesson('3'));

        expect(await dataSource.fetchLessons(), hasLength(3));
      });
    });

    group('deleteLesson', () {
      test('removes the lesson with the given id', () async {
        await dataSource.saveLesson(_lesson('1'));
        await dataSource.saveLesson(_lesson('2'));

        await dataSource.deleteLesson('1');

        final lessons = await dataSource.fetchLessons();
        expect(lessons, hasLength(1));
        expect(lessons.first.id, '2');
      });

      test('does nothing when id does not exist', () async {
        await dataSource.saveLesson(_lesson('1'));

        await dataSource.deleteLesson('999');

        expect(await dataSource.fetchLessons(), hasLength(1));
      });
    });
  });
}

Lesson _lesson(String id, {String name = 'Test Lesson'}) => Lesson(
      id: id,
      name: name,
      description: 'A description',
      exercises: [],
    );
