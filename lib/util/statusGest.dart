enum statusGest {
  EmAndamento,
  Nasceu,
  Morreu,
}

statusGest getStatus(String id) {
  for (statusGest status in statusGest.values) {
    if (status.index == int.parse(id)) {
      return status;
    }
  }
  throw ArgumentError('Invalid enum id');
}
