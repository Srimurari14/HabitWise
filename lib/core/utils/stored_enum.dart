/// Reading an enum back out of stored data.
///
/// `Enum.values.byName` throws an `ArgumentError` on a name it does not
/// recognise, and the names in the database were written by whichever version
/// of the app the person ran before this one. Rename or retire a value and
/// every old row becomes a crash on the screen that reads it. A name nobody
/// recognises any more has to read as "not known", which the screens already
/// handle, because they have always had to cope with a check-in that never
/// recorded one.
T? storedEnum<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}
