abstract class TextManager{
  /// Validation messages - signup
  static const String emailRequired = "email_required";
  static const String emailInvalid = "email_invalid";
  static const String phoneRequired = "phone_required";
  static const String phoneInvalid = "phone_invalid";
  static const String passwordRequired = "password_required";
  static const String passwordTooShort = "password_too_short";
  static const String firstNameRequired = "first_name_required";
  static const String lastNameRequired = "last_name_required";

  /// UI Texts - signup
  static const String createAccount = "create_account";
  static const String registrationSuccess = "registration_success";
  static const String nameHint = "name_hint";
  static const String firstNameHint = "first_name_hint";
  static const String lastNameHint = "last_name_hint";
  static const String emailHint = "email_hint";
  static const String phoneHint = "phone_hint";
  static const String passwordHint = "password_hint";
  static const String nationalIdHint = "national_id_hint";
  static const String registerButton = "register_button";
  static const String registrationFailed = "registration_failed";
  static const String alreadyHaveAccount = "already_have_account";
  static const String loginText = "login_text";

  /// UI Texts - login
  static const String loginNow = "login_now";
  static const String loginIntroMessage = "login_intro_message";
  static const String noAccountQuestion = "no_account_question";
  static const String signUpText = "sign_up_text";

  static const String fieldIsRequired = "fieldIsRequired";

  /// UI Texts - upload id
  static const String upload = "upload";
  static const String uploadYourId = "upload_your_id";
  static const String instructionPlaceId = "instruction_place_id";
  static const String instructionPositionId = "instruction_position_id";
  static const String instructionClearDetails = "instruction_clear_details";
  static const String uploadPhoto = "upload_photo";
  static const String imageUploadedSuccessfully = "image_uploaded_successfully";
  static const String pleaseTakePhotoFirst = "please_take_photo_first";
  static const String personalInformation = "personalInformation";
  static const String edit = "edit";

  static var nationalIdInvalid = "national_id_invalid";
  static var editProfileText = "edit_profile_text";
  static var rentCarText = "rentCarText";
  static var searchBarHint = "searchBarHint";
  static var home = "home";
  static var profile = "profile";
  static var notification = "notification";
  static var more = "more";
  static var topBrands = "topBrands";
  static var all = "all";
  static var toyotaCar = "toyotaCar" ;
  static var bmwCar= "BMWCar";
  static var fordCar= "fordCar";
  static var hondaCar= "hondaCar";
  static var teslaCar= "teslaCar";
  static var volkswagenCar= "volkswagenCar";
  static var audiCar= "audiCar";
  static var kiaCar= "kiaCar";
  static var mazdaCar= " mazdaCar";
  static var mercedesBenzCar= "mercedesBenzCar";
  static var subaruCar= "subaruCar";
  static var lexusCar= "lexusCar";
  static var nissanCar= "nissanCar";
  static var hyundaiCar= "hyundaiCar";
  static var chevroletCar= "chevroletCar";
  static var porscheCar= "porscheCar";
  static var buickCar= "buickCar";
  static var jeepCar= "jeepCar";
  static var renaultCar= "renaultCar";
  static var volvoCar= "volvoCar";
  static var location = "location";
  static var capacity = "capacity";
  static var brand = "brand";
  static var price = "price";
  static var model = "model";
  static var carType = "carType";
  static var availability = "availability";
  static var filter = "filter";
  static var applyButton = "Show offers";
  static var carCategory = "carCategory";
  static var driverOption = "driverOption";
  static var withDriver = "withDriver";
  static var withoutDriver = "withoutDriver";
  static var availableCarTypes = "availableCarTypes";
  static var allCars = "allCars";
  static var available = "available";
  static var unAvailable = "unAvailable";
  static var seats = "seats";
  static var fuelType = "fuelType";
  static var transmissionTypes = "transmissionTypes";
  static var clear = "clear";
  static var showOffers = "showOffers";
  static var bookingHistory = "booking_history";
  static var renterNotification = "renter_notification";

  /// UI Texts - Add Car
  static const String addCarTitle = "add_car_title";
  static const String editCarTitle = "edit_car_title";
  // static const String viewCarsTitle = "view_cars_title";
  static const String addCarButton = "add_car_button";
  static const String carAddedSuccess = "car_added_success";
  static const String carUpdatedSuccess = "car_updated_success";
  static const String carDeletedSuccess = "car_deleted_success";
  static const String carAddedError = "car_added_error";
  static const String deleteCarTitle = "delete_car_title";
  static const String deleteCarConfirmation = "delete_car_confirmation";
  // static const String noCarsMessage = "no_cars_message";
  static const String cancel = "cancel";
  static const String delete = "delete";

  /// Car Form Labels
  static const String brandLabel = "brand_label";
  static const String modelLabel = "model_label";
  static const String carTypeLabel = "car_type_label";
  static const String carCategoryLabel = "car_category_label";
  static const String plateNumberLabel = "plate_number_label";
  static const String yearLabel = "year_label";
  static const String colorLabel = "color_label";
  static const String seatingCapacityLabel = "seating_capacity_label";
  static const String transmissionTypeLabel = "transmission_type_label";
  static const String fuelTypeLabel = "fuel_type_label";
  static const String odometerLabel = "odometer_label";

  /// Car Form Hints
  static const String brandHint = "brand_hint";
  static const String modelHint = "model_hint";
  static const String carTypeHint = "car_type_hint";
  static const String carCategoryHint = "car_category_hint";
  static const String plateNumberHint = "plate_number_hint";
  static const String yearHint = "year_hint";
  static const String colorHint = "color_hint";
  static const String seatingCapacityHint = "seating_capacity_hint";
  static const String transmissionTypeHint = "transmission_type_hint";
  static const String fuelTypeHint = "fuel_type_hint";
  static const String odometerHint = "odometer_hint";

  /// Car Form Validation Messages
  static const String brandRequired = "brand_required";
  static const String modelRequired = "model_required";
  static const String carTypeRequired = "car_type_required";
  static const String carCategoryRequired = "car_category_required";
  static const String plateNumberRequired = "plate_number_required";
  static const String plateNumberInvalid = "plate_number_invalid";
  static const String yearRequired = "year_required";
  static const String yearInvalid = "year_invalid";
  static const String yearRangeInvalid = "year_range_invalid";
  static const String colorRequired = "color_required";
  static const String seatingCapacityRequired = "seating_capacity_required";
  static const String seatingCapacityInvalid = "seating_capacity_invalid";
  static const String seatingCapacityRange = "seating_capacity_range";
  static const String transmissionTypeRequired = "transmission_type_required";
  static const String fuelTypeRequired = "fuel_type_required";
  static const String odometerRequired = "odometer_required";
  static const String odometerInvalid = "odometer_invalid";

  static const String ownerNavigation = "owner_navigation";
  static const String ownerHome = "owner_home";
  static const String ownerProfile = "owner_profile";
  static const String ownerNotification = "owner_notification";

  /// Document Labels
  static const String idFront = "document.id_front";
  static const String idBack = "document.id_back";
  static const String driverLicense = "document.driver_license";
  static const String drugsTest = "document.drugs_test";
  static const String criminalRecord = "document.criminal_record";
  static const String drivingViolations = "document.driving_violations";
  static const String profilePhoto = "document.profile_photo";
  static const String carPhoto = "document.car_photo";
  static const String carLicense = "document.car_license";
  static const String vehicleViolations = "document.vehicle_violations";
  static const String insurance = "document.insurance";
  static const String carTest = "document.car_test";

  // Document Instructions
  static const String instructionIdFront = "instructions.id_front";
  static const String instructionIdBack = "instructions.id_back";
  static const String instructionDriverLicense = "instructions.driver_license";
  static const String instructionDrugsTest = "instructions.drugs_test";
  static const String instructionCriminalRecord = "instructions.criminal_record";
  static const String instructionDrivingViolations = "instructions.driving_violations";
  static const String instructionProfilePhoto = "instructions.profile_photo";
  static const String instructionCarPhoto = "instructions.car_photo";
  static const String instructionCarLicense = "instructions.car_license";
  static const String instructionVehicleViolations = "instructions.vehicle_violations";
  static const String instructionInsurance = "instructions.insurance";
  static const String instructionCarTest = "instructions.car_test";

  static const String uploadButton = "button.upload";
  static const String uploading = "button.uploading";

  // Document messages
  static const String uploadSuccess = "upload_success";
  static const String removeSuccess = "remove_success";
  static const String uploadFailed = "upload_failed";

  static const String skipNow = "skip_now";

}
