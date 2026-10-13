// ============================================================
// LOCATION OPTION (model)
//
// User form ke "Select Location" dropdown ka ek item.
//   hid  -> API ko jata hai
//   name -> screen par dikhta hai (hotel ki city)
// ============================================================

class LocationOption {
  const LocationOption({required this.hid, required this.name});

  final String hid;
  final String name;
}
