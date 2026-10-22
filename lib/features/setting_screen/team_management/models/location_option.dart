// ============================================================
// LOCATION OPTION (model)
//
// One item of the user form's "Select Location" dropdown.
//   hid  -> sent to the API
//   name -> shown on screen (the hotel's city)
// ============================================================

class LocationOption {
  const LocationOption({required this.hid, required this.name});

  final String hid;
  final String name;
}
