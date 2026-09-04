// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Visit {

 String get id; String get patientId; String get clinicId; DateTime get startsAt; int get durationMinutes; String get note;
/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitCopyWith<Visit> get copyWith => _$VisitCopyWithImpl<Visit>(this as Visit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Visit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Visit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.clinicId, _this.clinicId) || other.clinicId == _this.clinicId)&&(identical(other.startsAt, _this.startsAt) || other.startsAt == _this.startsAt)&&(identical(other.durationMinutes, _this.durationMinutes) || other.durationMinutes == _this.durationMinutes)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as Visit;
  return Object.hash(runtimeType,_this.id,_this.patientId,_this.clinicId,_this.startsAt,_this.durationMinutes,_this.note);
}

@override
String toString() {
  final _this = this as Visit;
  return 'Visit(id: ${_this.id}, patientId: ${_this.patientId}, clinicId: ${_this.clinicId}, startsAt: ${_this.startsAt}, durationMinutes: ${_this.durationMinutes}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $VisitCopyWith<$Res>  {
  factory $VisitCopyWith(Visit value, $Res Function(Visit) _then) = _$VisitCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String clinicId, DateTime startsAt, int durationMinutes, String note
});




}
/// @nodoc
class _$VisitCopyWithImpl<$Res>
    implements $VisitCopyWith<$Res> {
  _$VisitCopyWithImpl(this._self, this._then);

  final Visit _self;
  final $Res Function(Visit) _then;

/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? clinicId = null,Object? startsAt = null,Object? durationMinutes = null,Object? note = null,}) {
  return _then(Visit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Visit].
extension VisitPatterns on Visit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Visit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Visit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Visit value)  $default,){
final _that = this;
switch (_that) {
case _Visit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Visit value)?  $default,){
final _that = this;
switch (_that) {
case _Visit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String clinicId,  DateTime startsAt,  int durationMinutes,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Visit() when $default != null:
return $default(_that.id,_that.patientId,_that.clinicId,_that.startsAt,_that.durationMinutes,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String clinicId,  DateTime startsAt,  int durationMinutes,  String note)  $default,) {final _that = this;
switch (_that) {
case _Visit():
return $default(_that.id,_that.patientId,_that.clinicId,_that.startsAt,_that.durationMinutes,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String clinicId,  DateTime startsAt,  int durationMinutes,  String note)?  $default,) {final _that = this;
switch (_that) {
case _Visit() when $default != null:
return $default(_that.id,_that.patientId,_that.clinicId,_that.startsAt,_that.durationMinutes,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _Visit extends Visit {
  const _Visit({required this.id, required this.patientId, required this.clinicId, required this.startsAt, required this.durationMinutes, this.note = ''}): super._();
  

@override final  String id;
@override final  String patientId;
@override final  String clinicId;
@override final  DateTime startsAt;
@override final  int durationMinutes;
@override@JsonKey() final  String note;

/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitCopyWith<_Visit> get copyWith => __$VisitCopyWithImpl<_Visit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Visit&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,patientId,clinicId,startsAt,durationMinutes,note);
}

@override
String toString() {
    return 'Visit(id: $id, patientId: $patientId, clinicId: $clinicId, startsAt: $startsAt, durationMinutes: $durationMinutes, note: $note)';
}


}

/// @nodoc
abstract mixin class _$VisitCopyWith<$Res> implements $VisitCopyWith<$Res> {
  factory _$VisitCopyWith(_Visit value, $Res Function(_Visit) _then) = __$VisitCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String clinicId, DateTime startsAt, int durationMinutes, String note
});




}
/// @nodoc
class __$VisitCopyWithImpl<$Res>
    implements _$VisitCopyWith<$Res> {
  __$VisitCopyWithImpl(this._self, this._then);

  final _Visit _self;
  final $Res Function(_Visit) _then;

/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? clinicId = null,Object? startsAt = null,Object? durationMinutes = null,Object? note = null,}) {
  return _then(_Visit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
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
