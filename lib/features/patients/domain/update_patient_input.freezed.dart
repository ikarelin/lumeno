// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_patient_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdatePatientInput {

 String get patientId; String get name; String get phone; String get note;
/// Create a copy of UpdatePatientInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatePatientInputCopyWith<UpdatePatientInput> get copyWith => _$UpdatePatientInputCopyWithImpl<UpdatePatientInput>(this as UpdatePatientInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UpdatePatientInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePatientInput&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as UpdatePatientInput;
  return Object.hash(runtimeType,_this.patientId,_this.name,_this.phone,_this.note);
}

@override
String toString() {
  final _this = this as UpdatePatientInput;
  return 'UpdatePatientInput(patientId: ${_this.patientId}, name: ${_this.name}, phone: ${_this.phone}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $UpdatePatientInputCopyWith<$Res>  {
  factory $UpdatePatientInputCopyWith(UpdatePatientInput value, $Res Function(UpdatePatientInput) _then) = _$UpdatePatientInputCopyWithImpl;
@useResult
$Res call({
 String patientId, String name, String phone, String note
});




}
/// @nodoc
class _$UpdatePatientInputCopyWithImpl<$Res>
    implements $UpdatePatientInputCopyWith<$Res> {
  _$UpdatePatientInputCopyWithImpl(this._self, this._then);

  final UpdatePatientInput _self;
  final $Res Function(UpdatePatientInput) _then;

/// Create a copy of UpdatePatientInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? patientId = null,Object? name = null,Object? phone = null,Object? note = null,}) {
  return _then(UpdatePatientInput(
patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdatePatientInput].
extension UpdatePatientInputPatterns on UpdatePatientInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdatePatientInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdatePatientInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdatePatientInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdatePatientInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdatePatientInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdatePatientInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String patientId,  String name,  String phone,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdatePatientInput() when $default != null:
return $default(_that.patientId,_that.name,_that.phone,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String patientId,  String name,  String phone,  String note)  $default,) {final _that = this;
switch (_that) {
case _UpdatePatientInput():
return $default(_that.patientId,_that.name,_that.phone,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String patientId,  String name,  String phone,  String note)?  $default,) {final _that = this;
switch (_that) {
case _UpdatePatientInput() when $default != null:
return $default(_that.patientId,_that.name,_that.phone,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _UpdatePatientInput extends UpdatePatientInput {
  const _UpdatePatientInput({required this.patientId, required this.name, required this.phone, this.note = ''}): super._();
  

@override final  String patientId;
@override final  String name;
@override final  String phone;
@override@JsonKey() final  String note;

/// Create a copy of UpdatePatientInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePatientInputCopyWith<_UpdatePatientInput> get copyWith => __$UpdatePatientInputCopyWithImpl<_UpdatePatientInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePatientInput&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,patientId,name,phone,note);
}

@override
String toString() {
    return 'UpdatePatientInput(patientId: $patientId, name: $name, phone: $phone, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdatePatientInputCopyWith<$Res> implements $UpdatePatientInputCopyWith<$Res> {
  factory _$UpdatePatientInputCopyWith(_UpdatePatientInput value, $Res Function(_UpdatePatientInput) _then) = __$UpdatePatientInputCopyWithImpl;
@override @useResult
$Res call({
 String patientId, String name, String phone, String note
});




}
/// @nodoc
class __$UpdatePatientInputCopyWithImpl<$Res>
    implements _$UpdatePatientInputCopyWith<$Res> {
  __$UpdatePatientInputCopyWithImpl(this._self, this._then);

  final _UpdatePatientInput _self;
  final $Res Function(_UpdatePatientInput) _then;

/// Create a copy of UpdatePatientInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? patientId = null,Object? name = null,Object? phone = null,Object? note = null,}) {
  return _then(_UpdatePatientInput(
patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
