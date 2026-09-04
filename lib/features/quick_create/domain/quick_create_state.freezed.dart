// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_create_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuickCreateState {

 QuickCreateIntent get intent; QuickCreateSource get source; Patient? get selectedPatient; Clinic? get selectedClinic; DateTime? get selectedStartsAt; int get durationMinutes; PatientDraft get patientDraft; ClinicDraft get clinicDraft; String get patientSearchQuery; List<Patient> get patientResults; List<Clinic> get clinics; List<AvailabilitySlot> get suggestedSlots; String get visitNoteDraft; bool get isSchedulingPatient; bool get isCreatingPatient; bool get isCreatingClinic; bool get isSearchingPatients; bool get isLoadingClinics; bool get isLoadingSlots; bool get isSavingPatient; bool get isSavingClinic; bool get isSavingVisit; Object? get submitError;
/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuickCreateStateCopyWith<QuickCreateState> get copyWith => _$QuickCreateStateCopyWithImpl<QuickCreateState>(this as QuickCreateState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QuickCreateState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuickCreateState&&(identical(other.intent, _this.intent) || other.intent == _this.intent)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.selectedPatient, _this.selectedPatient) || other.selectedPatient == _this.selectedPatient)&&(identical(other.selectedClinic, _this.selectedClinic) || other.selectedClinic == _this.selectedClinic)&&(identical(other.selectedStartsAt, _this.selectedStartsAt) || other.selectedStartsAt == _this.selectedStartsAt)&&(identical(other.durationMinutes, _this.durationMinutes) || other.durationMinutes == _this.durationMinutes)&&(identical(other.patientDraft, _this.patientDraft) || other.patientDraft == _this.patientDraft)&&(identical(other.clinicDraft, _this.clinicDraft) || other.clinicDraft == _this.clinicDraft)&&(identical(other.patientSearchQuery, _this.patientSearchQuery) || other.patientSearchQuery == _this.patientSearchQuery)&&const DeepCollectionEquality().equals(other.patientResults, _this.patientResults)&&const DeepCollectionEquality().equals(other.clinics, _this.clinics)&&const DeepCollectionEquality().equals(other.suggestedSlots, _this.suggestedSlots)&&(identical(other.visitNoteDraft, _this.visitNoteDraft) || other.visitNoteDraft == _this.visitNoteDraft)&&(identical(other.isSchedulingPatient, _this.isSchedulingPatient) || other.isSchedulingPatient == _this.isSchedulingPatient)&&(identical(other.isCreatingPatient, _this.isCreatingPatient) || other.isCreatingPatient == _this.isCreatingPatient)&&(identical(other.isCreatingClinic, _this.isCreatingClinic) || other.isCreatingClinic == _this.isCreatingClinic)&&(identical(other.isSearchingPatients, _this.isSearchingPatients) || other.isSearchingPatients == _this.isSearchingPatients)&&(identical(other.isLoadingClinics, _this.isLoadingClinics) || other.isLoadingClinics == _this.isLoadingClinics)&&(identical(other.isLoadingSlots, _this.isLoadingSlots) || other.isLoadingSlots == _this.isLoadingSlots)&&(identical(other.isSavingPatient, _this.isSavingPatient) || other.isSavingPatient == _this.isSavingPatient)&&(identical(other.isSavingClinic, _this.isSavingClinic) || other.isSavingClinic == _this.isSavingClinic)&&(identical(other.isSavingVisit, _this.isSavingVisit) || other.isSavingVisit == _this.isSavingVisit)&&const DeepCollectionEquality().equals(other.submitError, _this.submitError));
}


@override
int get hashCode {
  final _this = this as QuickCreateState;
  return Object.hashAll([runtimeType,_this.intent,_this.source,_this.selectedPatient,_this.selectedClinic,_this.selectedStartsAt,_this.durationMinutes,_this.patientDraft,_this.clinicDraft,_this.patientSearchQuery,const DeepCollectionEquality().hash(_this.patientResults),const DeepCollectionEquality().hash(_this.clinics),const DeepCollectionEquality().hash(_this.suggestedSlots),_this.visitNoteDraft,_this.isSchedulingPatient,_this.isCreatingPatient,_this.isCreatingClinic,_this.isSearchingPatients,_this.isLoadingClinics,_this.isLoadingSlots,_this.isSavingPatient,_this.isSavingClinic,_this.isSavingVisit,const DeepCollectionEquality().hash(_this.submitError)]);
}

@override
String toString() {
  final _this = this as QuickCreateState;
  return 'QuickCreateState(intent: ${_this.intent}, source: ${_this.source}, selectedPatient: ${_this.selectedPatient}, selectedClinic: ${_this.selectedClinic}, selectedStartsAt: ${_this.selectedStartsAt}, durationMinutes: ${_this.durationMinutes}, patientDraft: ${_this.patientDraft}, clinicDraft: ${_this.clinicDraft}, patientSearchQuery: ${_this.patientSearchQuery}, patientResults: ${_this.patientResults}, clinics: ${_this.clinics}, suggestedSlots: ${_this.suggestedSlots}, visitNoteDraft: ${_this.visitNoteDraft}, isSchedulingPatient: ${_this.isSchedulingPatient}, isCreatingPatient: ${_this.isCreatingPatient}, isCreatingClinic: ${_this.isCreatingClinic}, isSearchingPatients: ${_this.isSearchingPatients}, isLoadingClinics: ${_this.isLoadingClinics}, isLoadingSlots: ${_this.isLoadingSlots}, isSavingPatient: ${_this.isSavingPatient}, isSavingClinic: ${_this.isSavingClinic}, isSavingVisit: ${_this.isSavingVisit}, submitError: ${_this.submitError})';
}


}

/// @nodoc
abstract mixin class $QuickCreateStateCopyWith<$Res>  {
  factory $QuickCreateStateCopyWith(QuickCreateState value, $Res Function(QuickCreateState) _then) = _$QuickCreateStateCopyWithImpl;
@useResult
$Res call({
 QuickCreateIntent intent, QuickCreateSource source, Patient? selectedPatient, Clinic? selectedClinic, DateTime? selectedStartsAt, int durationMinutes, PatientDraft patientDraft, ClinicDraft clinicDraft, String patientSearchQuery, List<Patient> patientResults, List<Clinic> clinics, List<AvailabilitySlot> suggestedSlots, String visitNoteDraft, bool isSchedulingPatient, bool isCreatingPatient, bool isCreatingClinic, bool isSearchingPatients, bool isLoadingClinics, bool isLoadingSlots, bool isSavingPatient, bool isSavingClinic, bool isSavingVisit, Object? submitError
});


$PatientCopyWith<$Res>? get selectedPatient;$ClinicCopyWith<$Res>? get selectedClinic;$PatientDraftCopyWith<$Res> get patientDraft;$ClinicDraftCopyWith<$Res> get clinicDraft;

}
/// @nodoc
class _$QuickCreateStateCopyWithImpl<$Res>
    implements $QuickCreateStateCopyWith<$Res> {
  _$QuickCreateStateCopyWithImpl(this._self, this._then);

  final QuickCreateState _self;
  final $Res Function(QuickCreateState) _then;

/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intent = null,Object? source = null,Object? selectedPatient = freezed,Object? selectedClinic = freezed,Object? selectedStartsAt = freezed,Object? durationMinutes = null,Object? patientDraft = null,Object? clinicDraft = null,Object? patientSearchQuery = null,Object? patientResults = null,Object? clinics = null,Object? suggestedSlots = null,Object? visitNoteDraft = null,Object? isSchedulingPatient = null,Object? isCreatingPatient = null,Object? isCreatingClinic = null,Object? isSearchingPatients = null,Object? isLoadingClinics = null,Object? isLoadingSlots = null,Object? isSavingPatient = null,Object? isSavingClinic = null,Object? isSavingVisit = null,Object? submitError = freezed,}) {
  return _then(QuickCreateState(
intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as QuickCreateIntent,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as QuickCreateSource,selectedPatient: freezed == selectedPatient ? _self.selectedPatient : selectedPatient // ignore: cast_nullable_to_non_nullable
as Patient?,selectedClinic: freezed == selectedClinic ? _self.selectedClinic : selectedClinic // ignore: cast_nullable_to_non_nullable
as Clinic?,selectedStartsAt: freezed == selectedStartsAt ? _self.selectedStartsAt : selectedStartsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,patientDraft: null == patientDraft ? _self.patientDraft : patientDraft // ignore: cast_nullable_to_non_nullable
as PatientDraft,clinicDraft: null == clinicDraft ? _self.clinicDraft : clinicDraft // ignore: cast_nullable_to_non_nullable
as ClinicDraft,patientSearchQuery: null == patientSearchQuery ? _self.patientSearchQuery : patientSearchQuery // ignore: cast_nullable_to_non_nullable
as String,patientResults: null == patientResults ? _self.patientResults : patientResults // ignore: cast_nullable_to_non_nullable
as List<Patient>,clinics: null == clinics ? _self.clinics : clinics // ignore: cast_nullable_to_non_nullable
as List<Clinic>,suggestedSlots: null == suggestedSlots ? _self.suggestedSlots : suggestedSlots // ignore: cast_nullable_to_non_nullable
as List<AvailabilitySlot>,visitNoteDraft: null == visitNoteDraft ? _self.visitNoteDraft : visitNoteDraft // ignore: cast_nullable_to_non_nullable
as String,isSchedulingPatient: null == isSchedulingPatient ? _self.isSchedulingPatient : isSchedulingPatient // ignore: cast_nullable_to_non_nullable
as bool,isCreatingPatient: null == isCreatingPatient ? _self.isCreatingPatient : isCreatingPatient // ignore: cast_nullable_to_non_nullable
as bool,isCreatingClinic: null == isCreatingClinic ? _self.isCreatingClinic : isCreatingClinic // ignore: cast_nullable_to_non_nullable
as bool,isSearchingPatients: null == isSearchingPatients ? _self.isSearchingPatients : isSearchingPatients // ignore: cast_nullable_to_non_nullable
as bool,isLoadingClinics: null == isLoadingClinics ? _self.isLoadingClinics : isLoadingClinics // ignore: cast_nullable_to_non_nullable
as bool,isLoadingSlots: null == isLoadingSlots ? _self.isLoadingSlots : isLoadingSlots // ignore: cast_nullable_to_non_nullable
as bool,isSavingPatient: null == isSavingPatient ? _self.isSavingPatient : isSavingPatient // ignore: cast_nullable_to_non_nullable
as bool,isSavingClinic: null == isSavingClinic ? _self.isSavingClinic : isSavingClinic // ignore: cast_nullable_to_non_nullable
as bool,isSavingVisit: null == isSavingVisit ? _self.isSavingVisit : isSavingVisit // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError ,
  ));
}
/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientCopyWith<$Res>? get selectedPatient {
    if (_self.selectedPatient == null) {
    return null;
  }

  return $PatientCopyWith<$Res>(_self.selectedPatient!, (value) {
    return _then(_self.copyWith(selectedPatient: value));
  });
}/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res>? get selectedClinic {
    if (_self.selectedClinic == null) {
    return null;
  }

  return $ClinicCopyWith<$Res>(_self.selectedClinic!, (value) {
    return _then(_self.copyWith(selectedClinic: value));
  });
}/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientDraftCopyWith<$Res> get patientDraft {
  
  return $PatientDraftCopyWith<$Res>(_self.patientDraft, (value) {
    return _then(_self.copyWith(patientDraft: value));
  });
}/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicDraftCopyWith<$Res> get clinicDraft {
  
  return $ClinicDraftCopyWith<$Res>(_self.clinicDraft, (value) {
    return _then(_self.copyWith(clinicDraft: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuickCreateState].
extension QuickCreateStatePatterns on QuickCreateState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuickCreateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuickCreateState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuickCreateState value)  $default,){
final _that = this;
switch (_that) {
case _QuickCreateState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuickCreateState value)?  $default,){
final _that = this;
switch (_that) {
case _QuickCreateState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QuickCreateIntent intent,  QuickCreateSource source,  Patient? selectedPatient,  Clinic? selectedClinic,  DateTime? selectedStartsAt,  int durationMinutes,  PatientDraft patientDraft,  ClinicDraft clinicDraft,  String patientSearchQuery,  List<Patient> patientResults,  List<Clinic> clinics,  List<AvailabilitySlot> suggestedSlots,  String visitNoteDraft,  bool isSchedulingPatient,  bool isCreatingPatient,  bool isCreatingClinic,  bool isSearchingPatients,  bool isLoadingClinics,  bool isLoadingSlots,  bool isSavingPatient,  bool isSavingClinic,  bool isSavingVisit,  Object? submitError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuickCreateState() when $default != null:
return $default(_that.intent,_that.source,_that.selectedPatient,_that.selectedClinic,_that.selectedStartsAt,_that.durationMinutes,_that.patientDraft,_that.clinicDraft,_that.patientSearchQuery,_that.patientResults,_that.clinics,_that.suggestedSlots,_that.visitNoteDraft,_that.isSchedulingPatient,_that.isCreatingPatient,_that.isCreatingClinic,_that.isSearchingPatients,_that.isLoadingClinics,_that.isLoadingSlots,_that.isSavingPatient,_that.isSavingClinic,_that.isSavingVisit,_that.submitError);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QuickCreateIntent intent,  QuickCreateSource source,  Patient? selectedPatient,  Clinic? selectedClinic,  DateTime? selectedStartsAt,  int durationMinutes,  PatientDraft patientDraft,  ClinicDraft clinicDraft,  String patientSearchQuery,  List<Patient> patientResults,  List<Clinic> clinics,  List<AvailabilitySlot> suggestedSlots,  String visitNoteDraft,  bool isSchedulingPatient,  bool isCreatingPatient,  bool isCreatingClinic,  bool isSearchingPatients,  bool isLoadingClinics,  bool isLoadingSlots,  bool isSavingPatient,  bool isSavingClinic,  bool isSavingVisit,  Object? submitError)  $default,) {final _that = this;
switch (_that) {
case _QuickCreateState():
return $default(_that.intent,_that.source,_that.selectedPatient,_that.selectedClinic,_that.selectedStartsAt,_that.durationMinutes,_that.patientDraft,_that.clinicDraft,_that.patientSearchQuery,_that.patientResults,_that.clinics,_that.suggestedSlots,_that.visitNoteDraft,_that.isSchedulingPatient,_that.isCreatingPatient,_that.isCreatingClinic,_that.isSearchingPatients,_that.isLoadingClinics,_that.isLoadingSlots,_that.isSavingPatient,_that.isSavingClinic,_that.isSavingVisit,_that.submitError);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QuickCreateIntent intent,  QuickCreateSource source,  Patient? selectedPatient,  Clinic? selectedClinic,  DateTime? selectedStartsAt,  int durationMinutes,  PatientDraft patientDraft,  ClinicDraft clinicDraft,  String patientSearchQuery,  List<Patient> patientResults,  List<Clinic> clinics,  List<AvailabilitySlot> suggestedSlots,  String visitNoteDraft,  bool isSchedulingPatient,  bool isCreatingPatient,  bool isCreatingClinic,  bool isSearchingPatients,  bool isLoadingClinics,  bool isLoadingSlots,  bool isSavingPatient,  bool isSavingClinic,  bool isSavingVisit,  Object? submitError)?  $default,) {final _that = this;
switch (_that) {
case _QuickCreateState() when $default != null:
return $default(_that.intent,_that.source,_that.selectedPatient,_that.selectedClinic,_that.selectedStartsAt,_that.durationMinutes,_that.patientDraft,_that.clinicDraft,_that.patientSearchQuery,_that.patientResults,_that.clinics,_that.suggestedSlots,_that.visitNoteDraft,_that.isSchedulingPatient,_that.isCreatingPatient,_that.isCreatingClinic,_that.isSearchingPatients,_that.isLoadingClinics,_that.isLoadingSlots,_that.isSavingPatient,_that.isSavingClinic,_that.isSavingVisit,_that.submitError);case _:
  return null;

}
}

}

/// @nodoc


class _QuickCreateState extends QuickCreateState {
  const _QuickCreateState({required this.intent, required this.source, this.selectedPatient, this.selectedClinic, this.selectedStartsAt, required this.durationMinutes, this.patientDraft = const PatientDraft(), this.clinicDraft = const ClinicDraft(), this.patientSearchQuery = '',  List<Patient> patientResults = const <Patient>[],  List<Clinic> clinics = const <Clinic>[],  List<AvailabilitySlot> suggestedSlots = const <AvailabilitySlot>[], this.visitNoteDraft = '', required this.isSchedulingPatient, this.isCreatingPatient = false, this.isCreatingClinic = false, this.isSearchingPatients = false, this.isLoadingClinics = false, this.isLoadingSlots = false, this.isSavingPatient = false, this.isSavingClinic = false, this.isSavingVisit = false, this.submitError}): _patientResults = patientResults,_clinics = clinics,_suggestedSlots = suggestedSlots,super._();
  

@override final  QuickCreateIntent intent;
@override final  QuickCreateSource source;
@override final  Patient? selectedPatient;
@override final  Clinic? selectedClinic;
@override final  DateTime? selectedStartsAt;
@override final  int durationMinutes;
@override@JsonKey() final  PatientDraft patientDraft;
@override@JsonKey() final  ClinicDraft clinicDraft;
@override@JsonKey() final  String patientSearchQuery;
 final  List<Patient> _patientResults;
@override@JsonKey() List<Patient> get patientResults {
  if (_patientResults is EqualUnmodifiableListView) return _patientResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_patientResults);
}

 final  List<Clinic> _clinics;
@override@JsonKey() List<Clinic> get clinics {
  if (_clinics is EqualUnmodifiableListView) return _clinics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clinics);
}

 final  List<AvailabilitySlot> _suggestedSlots;
@override@JsonKey() List<AvailabilitySlot> get suggestedSlots {
  if (_suggestedSlots is EqualUnmodifiableListView) return _suggestedSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestedSlots);
}

@override@JsonKey() final  String visitNoteDraft;
@override final  bool isSchedulingPatient;
@override@JsonKey() final  bool isCreatingPatient;
@override@JsonKey() final  bool isCreatingClinic;
@override@JsonKey() final  bool isSearchingPatients;
@override@JsonKey() final  bool isLoadingClinics;
@override@JsonKey() final  bool isLoadingSlots;
@override@JsonKey() final  bool isSavingPatient;
@override@JsonKey() final  bool isSavingClinic;
@override@JsonKey() final  bool isSavingVisit;
@override final  Object? submitError;

/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuickCreateStateCopyWith<_QuickCreateState> get copyWith => __$QuickCreateStateCopyWithImpl<_QuickCreateState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuickCreateState&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.source, source) || other.source == source)&&(identical(other.selectedPatient, selectedPatient) || other.selectedPatient == selectedPatient)&&(identical(other.selectedClinic, selectedClinic) || other.selectedClinic == selectedClinic)&&(identical(other.selectedStartsAt, selectedStartsAt) || other.selectedStartsAt == selectedStartsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.patientDraft, patientDraft) || other.patientDraft == patientDraft)&&(identical(other.clinicDraft, clinicDraft) || other.clinicDraft == clinicDraft)&&(identical(other.patientSearchQuery, patientSearchQuery) || other.patientSearchQuery == patientSearchQuery)&&const DeepCollectionEquality().equals(other.patientResults, _patientResults)&&const DeepCollectionEquality().equals(other.clinics, _clinics)&&const DeepCollectionEquality().equals(other.suggestedSlots, _suggestedSlots)&&(identical(other.visitNoteDraft, visitNoteDraft) || other.visitNoteDraft == visitNoteDraft)&&(identical(other.isSchedulingPatient, isSchedulingPatient) || other.isSchedulingPatient == isSchedulingPatient)&&(identical(other.isCreatingPatient, isCreatingPatient) || other.isCreatingPatient == isCreatingPatient)&&(identical(other.isCreatingClinic, isCreatingClinic) || other.isCreatingClinic == isCreatingClinic)&&(identical(other.isSearchingPatients, isSearchingPatients) || other.isSearchingPatients == isSearchingPatients)&&(identical(other.isLoadingClinics, isLoadingClinics) || other.isLoadingClinics == isLoadingClinics)&&(identical(other.isLoadingSlots, isLoadingSlots) || other.isLoadingSlots == isLoadingSlots)&&(identical(other.isSavingPatient, isSavingPatient) || other.isSavingPatient == isSavingPatient)&&(identical(other.isSavingClinic, isSavingClinic) || other.isSavingClinic == isSavingClinic)&&(identical(other.isSavingVisit, isSavingVisit) || other.isSavingVisit == isSavingVisit)&&const DeepCollectionEquality().equals(other.submitError, submitError));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,intent,source,selectedPatient,selectedClinic,selectedStartsAt,durationMinutes,patientDraft,clinicDraft,patientSearchQuery,const DeepCollectionEquality().hash(_patientResults),const DeepCollectionEquality().hash(_clinics),const DeepCollectionEquality().hash(_suggestedSlots),visitNoteDraft,isSchedulingPatient,isCreatingPatient,isCreatingClinic,isSearchingPatients,isLoadingClinics,isLoadingSlots,isSavingPatient,isSavingClinic,isSavingVisit,const DeepCollectionEquality().hash(submitError)]);
}

@override
String toString() {
    return 'QuickCreateState(intent: $intent, source: $source, selectedPatient: $selectedPatient, selectedClinic: $selectedClinic, selectedStartsAt: $selectedStartsAt, durationMinutes: $durationMinutes, patientDraft: $patientDraft, clinicDraft: $clinicDraft, patientSearchQuery: $patientSearchQuery, patientResults: $patientResults, clinics: $clinics, suggestedSlots: $suggestedSlots, visitNoteDraft: $visitNoteDraft, isSchedulingPatient: $isSchedulingPatient, isCreatingPatient: $isCreatingPatient, isCreatingClinic: $isCreatingClinic, isSearchingPatients: $isSearchingPatients, isLoadingClinics: $isLoadingClinics, isLoadingSlots: $isLoadingSlots, isSavingPatient: $isSavingPatient, isSavingClinic: $isSavingClinic, isSavingVisit: $isSavingVisit, submitError: $submitError)';
}


}

/// @nodoc
abstract mixin class _$QuickCreateStateCopyWith<$Res> implements $QuickCreateStateCopyWith<$Res> {
  factory _$QuickCreateStateCopyWith(_QuickCreateState value, $Res Function(_QuickCreateState) _then) = __$QuickCreateStateCopyWithImpl;
@override @useResult
$Res call({
 QuickCreateIntent intent, QuickCreateSource source, Patient? selectedPatient, Clinic? selectedClinic, DateTime? selectedStartsAt, int durationMinutes, PatientDraft patientDraft, ClinicDraft clinicDraft, String patientSearchQuery, List<Patient> patientResults, List<Clinic> clinics, List<AvailabilitySlot> suggestedSlots, String visitNoteDraft, bool isSchedulingPatient, bool isCreatingPatient, bool isCreatingClinic, bool isSearchingPatients, bool isLoadingClinics, bool isLoadingSlots, bool isSavingPatient, bool isSavingClinic, bool isSavingVisit, Object? submitError
});


@override $PatientCopyWith<$Res>? get selectedPatient;@override $ClinicCopyWith<$Res>? get selectedClinic;@override $PatientDraftCopyWith<$Res> get patientDraft;@override $ClinicDraftCopyWith<$Res> get clinicDraft;

}
/// @nodoc
class __$QuickCreateStateCopyWithImpl<$Res>
    implements _$QuickCreateStateCopyWith<$Res> {
  __$QuickCreateStateCopyWithImpl(this._self, this._then);

  final _QuickCreateState _self;
  final $Res Function(_QuickCreateState) _then;

/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intent = null,Object? source = null,Object? selectedPatient = freezed,Object? selectedClinic = freezed,Object? selectedStartsAt = freezed,Object? durationMinutes = null,Object? patientDraft = null,Object? clinicDraft = null,Object? patientSearchQuery = null,Object? patientResults = null,Object? clinics = null,Object? suggestedSlots = null,Object? visitNoteDraft = null,Object? isSchedulingPatient = null,Object? isCreatingPatient = null,Object? isCreatingClinic = null,Object? isSearchingPatients = null,Object? isLoadingClinics = null,Object? isLoadingSlots = null,Object? isSavingPatient = null,Object? isSavingClinic = null,Object? isSavingVisit = null,Object? submitError = freezed,}) {
  return _then(_QuickCreateState(
intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as QuickCreateIntent,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as QuickCreateSource,selectedPatient: freezed == selectedPatient ? _self.selectedPatient : selectedPatient // ignore: cast_nullable_to_non_nullable
as Patient?,selectedClinic: freezed == selectedClinic ? _self.selectedClinic : selectedClinic // ignore: cast_nullable_to_non_nullable
as Clinic?,selectedStartsAt: freezed == selectedStartsAt ? _self.selectedStartsAt : selectedStartsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,patientDraft: null == patientDraft ? _self.patientDraft : patientDraft // ignore: cast_nullable_to_non_nullable
as PatientDraft,clinicDraft: null == clinicDraft ? _self.clinicDraft : clinicDraft // ignore: cast_nullable_to_non_nullable
as ClinicDraft,patientSearchQuery: null == patientSearchQuery ? _self.patientSearchQuery : patientSearchQuery // ignore: cast_nullable_to_non_nullable
as String,patientResults: null == patientResults ? _self._patientResults : patientResults // ignore: cast_nullable_to_non_nullable
as List<Patient>,clinics: null == clinics ? _self._clinics : clinics // ignore: cast_nullable_to_non_nullable
as List<Clinic>,suggestedSlots: null == suggestedSlots ? _self._suggestedSlots : suggestedSlots // ignore: cast_nullable_to_non_nullable
as List<AvailabilitySlot>,visitNoteDraft: null == visitNoteDraft ? _self.visitNoteDraft : visitNoteDraft // ignore: cast_nullable_to_non_nullable
as String,isSchedulingPatient: null == isSchedulingPatient ? _self.isSchedulingPatient : isSchedulingPatient // ignore: cast_nullable_to_non_nullable
as bool,isCreatingPatient: null == isCreatingPatient ? _self.isCreatingPatient : isCreatingPatient // ignore: cast_nullable_to_non_nullable
as bool,isCreatingClinic: null == isCreatingClinic ? _self.isCreatingClinic : isCreatingClinic // ignore: cast_nullable_to_non_nullable
as bool,isSearchingPatients: null == isSearchingPatients ? _self.isSearchingPatients : isSearchingPatients // ignore: cast_nullable_to_non_nullable
as bool,isLoadingClinics: null == isLoadingClinics ? _self.isLoadingClinics : isLoadingClinics // ignore: cast_nullable_to_non_nullable
as bool,isLoadingSlots: null == isLoadingSlots ? _self.isLoadingSlots : isLoadingSlots // ignore: cast_nullable_to_non_nullable
as bool,isSavingPatient: null == isSavingPatient ? _self.isSavingPatient : isSavingPatient // ignore: cast_nullable_to_non_nullable
as bool,isSavingClinic: null == isSavingClinic ? _self.isSavingClinic : isSavingClinic // ignore: cast_nullable_to_non_nullable
as bool,isSavingVisit: null == isSavingVisit ? _self.isSavingVisit : isSavingVisit // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError ,
  ));
}

/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientCopyWith<$Res>? get selectedPatient {
    if (_self.selectedPatient == null) {
    return null;
  }

  return $PatientCopyWith<$Res>(_self.selectedPatient!, (value) {
    return _then(_self.copyWith(selectedPatient: value));
  });
}/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res>? get selectedClinic {
    if (_self.selectedClinic == null) {
    return null;
  }

  return $ClinicCopyWith<$Res>(_self.selectedClinic!, (value) {
    return _then(_self.copyWith(selectedClinic: value));
  });
}/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientDraftCopyWith<$Res> get patientDraft {
  
  return $PatientDraftCopyWith<$Res>(_self.patientDraft, (value) {
    return _then(_self.copyWith(patientDraft: value));
  });
}/// Create a copy of QuickCreateState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicDraftCopyWith<$Res> get clinicDraft {
  
  return $ClinicDraftCopyWith<$Res>(_self.clinicDraft, (value) {
    return _then(_self.copyWith(clinicDraft: value));
  });
}
}

// dart format on
