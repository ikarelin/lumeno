enum PatientContactChannel {
  phone('phone'),
  email('email'),
  telegram('telegram'),
  whatsapp('whatsapp');

  const PatientContactChannel(this.storageValue);

  final String storageValue;

  static PatientContactChannel? tryParse(String value) {
    for (final channel in values) {
      if (channel.storageValue == value) {
        return channel;
      }
    }

    return null;
  }
}
