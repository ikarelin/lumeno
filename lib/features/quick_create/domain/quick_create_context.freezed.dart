// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_create_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QuickCreateContext {

 QuickCreateIntent get intent; QuickCreateSource get source; Patient? get patient; Clinic? get clinic; DateTime? get startsAt; int? get durationMinutes;
/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuickCreateContextCopyWith<QuickCreateContext> get copyWith => _$QuickCreateContextCopyWithImpl<QuickCreateContext>(this as QuickCreateContext, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as QuickCreateContext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuickCreateContext&&(identical(other.intent, _this.intent) || other.intent == _this.intent)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.patient, _this.patient) || other.patient == _this.patient)&&(identical(other.clinic, _this.clinic) || other.clinic == _this.clinic)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.durationMinutes, _this.durationMinutes) || other.durationMinutes == _this.durationMinutes));
}


@override
int get hashCode {
  final _this = this as QuickCreateContext;
  return Object.hash(runtimeType,_this.intent,_this.source,_this.patient,_this.clinic,_this.startsAt,_this.durationMinutes);
}

@override
String toString() {
  final _this = this as QuickCreateContext;
  return 'QuickCreateContext(intent: ${_this.intent}, source: ${_this.source}, patient: ${_this.patient}, clinic: ${_this.clinic}, startsAt: ${_this.startsAt}, durationMinutes: ${_this.durationMinutes})';
}


}

/// @nodoc
abstract mixin class $QuickCreateContextCopyWith<$Res>  {
  factory $QuickCreateContextCopyWith(QuickCreateContext value, $Res Function(QuickCreateContext) _then) = _$QuickCreateContextCopyWithImpl;
@useResult
$Res call({
 QuickCreateIntent intent, QuickCreateSource source, Patient? patient, Clinic? clinic, DateTime? startsAt, int? durationMinutes
});


$PatientCopyWith<$Res>? get patient;$ClinicCopyWith<$Res>? get clinic;

}
/// @nodoc
class _$QuickCreateContextCopyWithImpl<$Res>
    implements $QuickCreateContextCopyWith<$Res> {
  _$QuickCreateContextCopyWithImpl(this._self, this._then);

  final QuickCreateContext _self;
  final $Res Function(QuickCreateContext) _then;

/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intent = null,Object? source = null,Object? patient = freezed,Object? clinic = freezed,Object? startsAt = freezed,Object? durationMinutes = freezed,}) {
  return _then(QuickCreateContext(
intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as QuickCreateIntent,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as QuickCreateSource,patient: freezed == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as Patient?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as Clinic?,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientCopyWith<$Res>? get patient {
    if (_self.patient == null) {
    return null;
  }

  return $PatientCopyWith<$Res>(_self.patient!, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res>? get clinic {
    if (_self.clinic == null) {
    return null;
  }

  return $ClinicCopyWith<$Res>(_self.clinic!, (value) {
    return _then(_self.copyWith(clinic: value));
  });
}
}


/// Adds pattern-matching-related methods to [QuickCreateContext].
extension QuickCreateContextPatterns on QuickCreateContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuickCreateContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuickCreateContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuickCreateContext value)  $default,){
final _that = this;
switch (_that) {
case _QuickCreateContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuickCreateContext value)?  $default,){
final _that = this;
switch (_that) {
case _QuickCreateContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QuickCreateIntent intent,  QuickCreateSource source,  Patient? patient,  Clinic? clinic,  DateTime? startsAt,  int? durationMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuickCreateContext() when $default != null:
return $default(_that.intent,_that.source,_that.patient,_that.clinic,_that.startsAt,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QuickCreateIntent intent,  QuickCreateSource source,  Patient? patient,  Clinic? clinic,  DateTime? startsAt,  int? durationMinutes)  $default,) {final _that = this;
switch (_that) {
case _QuickCreateContext():
return $default(_that.intent,_that.source,_that.patient,_that.clinic,_that.startsAt,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QuickCreateIntent intent,  QuickCreateSource source,  Patient? patient,  Clinic? clinic,  DateTime? startsAt,  int? durationMinutes)?  $default,) {final _that = this;
switch (_that) {
case _QuickCreateContext() when $default != null:
return $default(_that.intent,_that.source,_that.patient,_that.clinic,_that.startsAt,_that.durationMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _QuickCreateContext implements QuickCreateContext {
  const _QuickCreateContext({required this.intent, required this.source, this.patient, this.clinic, this.startsAt, this.durationMinutes});
  

@override final  QuickCreateIntent intent;
@override final  QuickCreateSource source;
@override final  Patient? patient;
@override final  Clinic? clinic;
@override final  DateTime? startsAt;
@override final  int? durationMinutes;

/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuickCreateContextCopyWith<_QuickCreateContext> get copyWith => __$QuickCreateContextCopyWithImpl<_QuickCreateContext>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuickCreateContext&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.source, source) || other.source == source)&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.clinic, clinic) || other.clinic == clinic)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,intent,source,patient,clinic,startsAt,durationMinutes);
}

@override
String toString() {
    return 'QuickCreateContext(intent: $intent, source: $source, patient: $patient, clinic: $clinic, startsAt: $startsAt, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class _$QuickCreateContextCopyWith<$Res> implements $QuickCreateContextCopyWith<$Res> {
  factory _$QuickCreateContextCopyWith(_QuickCreateContext value, $Res Function(_QuickCreateContext) _then) = __$QuickCreateContextCopyWithImpl;
@override @useResult
$Res call({
 QuickCreateIntent intent, QuickCreateSource source, Patient? patient, Clinic? clinic, DateTime? startsAt, int? durationMinutes
});


@override $PatientCopyWith<$Res>? get patient;@override $ClinicCopyWith<$Res>? get clinic;

}
/// @nodoc
class __$QuickCreateContextCopyWithImpl<$Res>
    implements _$QuickCreateContextCopyWith<$Res> {
  __$QuickCreateContextCopyWithImpl(this._self, this._then);

  final _QuickCreateContext _self;
  final $Res Function(_QuickCreateContext) _then;

/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intent = null,Object? source = null,Object? patient = freezed,Object? clinic = freezed,Object? startsAt = freezed,Object? durationMinutes = freezed,}) {
  return _then(_QuickCreateContext(
intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as QuickCreateIntent,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as QuickCreateSource,patient: freezed == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as Patient?,clinic: freezed == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as Clinic?,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatientCopyWith<$Res>? get patient {
    if (_self.patient == null) {
    return null;
  }

  return $PatientCopyWith<$Res>(_self.patient!, (value) {
    return _then(_self.copyWith(patient: value));
  });
}/// Create a copy of QuickCreateContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res>? get clinic {
    if (_self.clinic == null) {
    return null;
  }

  return $ClinicCopyWith<$Res>(_self.clinic!, (value) {
    return _then(_self.copyWith(clinic: value));
  });
}
}

// dart format on
