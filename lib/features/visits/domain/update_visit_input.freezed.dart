// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_visit_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateVisitInput {

 String get visitId; String get patientId; String get clinicId; DateTime get startsAt; int get durationMinutes; String get note;
/// Create a copy of UpdateVisitInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateVisitInputCopyWith<UpdateVisitInput> get copyWith => _$UpdateVisitInputCopyWithImpl<UpdateVisitInput>(this as UpdateVisitInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UpdateVisitInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateVisitInput&&(identical(other.visitId, _this.visitId) || other.visitId == _this.visitId)&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.clinicId, _this.clinicId) || other.clinicId == _this.clinicId)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.durationMinutes, _this.durationMinutes) || other.durationMinutes == _this.durationMinutes)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as UpdateVisitInput;
  return Object.hash(runtimeType,_this.visitId,_this.patientId,_this.clinicId,_this.startsAt,_this.durationMinutes,_this.note);
}

@override
String toString() {
  final _this = this as UpdateVisitInput;
  return 'UpdateVisitInput(visitId: ${_this.visitId}, patientId: ${_this.patientId}, clinicId: ${_this.clinicId}, startsAt: ${_this.startsAt}, durationMinutes: ${_this.durationMinutes}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $UpdateVisitInputCopyWith<$Res>  {
  factory $UpdateVisitInputCopyWith(UpdateVisitInput value, $Res Function(UpdateVisitInput) _then) = _$UpdateVisitInputCopyWithImpl;
@useResult
$Res call({
 String visitId, String patientId, String clinicId, DateTime startsAt, int durationMinutes, String note
});




}
/// @nodoc
class _$UpdateVisitInputCopyWithImpl<$Res>
    implements $UpdateVisitInputCopyWith<$Res> {
  _$UpdateVisitInputCopyWithImpl(this._self, this._then);

  final UpdateVisitInput _self;
  final $Res Function(UpdateVisitInput) _then;

/// Create a copy of UpdateVisitInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? visitId = null,Object? patientId = null,Object? clinicId = null,Object? startsAt = null,Object? durationMinutes = null,Object? note = null,}) {
  return _then(UpdateVisitInput(
visitId: null == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateVisitInput].
extension UpdateVisitInputPatterns on UpdateVisitInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateVisitInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateVisitInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateVisitInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateVisitInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateVisitInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateVisitInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String visitId,  String patientId,  String clinicId,  DateTime startsAt,  int durationMinutes,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateVisitInput() when $default != null:
return $default(_that.visitId,_that.patientId,_that.clinicId,_that.startsAt,_that.durationMinutes,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String visitId,  String patientId,  String clinicId,  DateTime startsAt,  int durationMinutes,  String note)  $default,) {final _that = this;
switch (_that) {
case _UpdateVisitInput():
return $default(_that.visitId,_that.patientId,_that.clinicId,_that.startsAt,_that.durationMinutes,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String visitId,  String patientId,  String clinicId,  DateTime startsAt,  int durationMinutes,  String note)?  $default,) {final _that = this;
switch (_that) {
case _UpdateVisitInput() when $default != null:
return $default(_that.visitId,_that.patientId,_that.clinicId,_that.startsAt,_that.durationMinutes,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateVisitInput extends UpdateVisitInput {
  const _UpdateVisitInput({required this.visitId, required this.patientId, required this.clinicId, required this.startsAt, required this.durationMinutes, this.note = ''}): super._();
  

@override final  String visitId;
@override final  String patientId;
@override final  String clinicId;
@override final  DateTime startsAt;
@override final  int durationMinutes;
@override@JsonKey() final  String note;

/// Create a copy of UpdateVisitInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateVisitInputCopyWith<_UpdateVisitInput> get copyWith => __$UpdateVisitInputCopyWithImpl<_UpdateVisitInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateVisitInput&&(identical(other.visitId, visitId) || other.visitId == visitId)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,visitId,patientId,clinicId,startsAt,durationMinutes,note);
}

@override
String toString() {
    return 'UpdateVisitInput(visitId: $visitId, patientId: $patientId, clinicId: $clinicId, startsAt: $startsAt, durationMinutes: $durationMinutes, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdateVisitInputCopyWith<$Res> implements $UpdateVisitInputCopyWith<$Res> {
  factory _$UpdateVisitInputCopyWith(_UpdateVisitInput value, $Res Function(_UpdateVisitInput) _then) = __$UpdateVisitInputCopyWithImpl;
@override @useResult
$Res call({
 String visitId, String patientId, String clinicId, DateTime startsAt, int durationMinutes, String note
});




}
/// @nodoc
class __$UpdateVisitInputCopyWithImpl<$Res>
    implements _$UpdateVisitInputCopyWith<$Res> {
  __$UpdateVisitInputCopyWithImpl(this._self, this._then);

  final _UpdateVisitInput _self;
  final $Res Function(_UpdateVisitInput) _then;

/// Create a copy of UpdateVisitInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? visitId = null,Object? patientId = null,Object? clinicId = null,Object? startsAt = null,Object? durationMinutes = null,Object? note = null,}) {
  return _then(_UpdateVisitInput(
visitId: null == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
