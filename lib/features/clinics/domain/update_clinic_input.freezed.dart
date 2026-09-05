// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_clinic_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateClinicInput {

 String get clinicId; String get name; String get address;
/// Create a copy of UpdateClinicInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateClinicInputCopyWith<UpdateClinicInput> get copyWith => _$UpdateClinicInputCopyWithImpl<UpdateClinicInput>(this as UpdateClinicInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UpdateClinicInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateClinicInput&&(identical(other.clinicId, _this.clinicId) || other.clinicId == _this.clinicId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.address, _this.address) || other.address == _this.address));
}


@override
int get hashCode {
  final _this = this as UpdateClinicInput;
  return Object.hash(runtimeType,_this.clinicId,_this.name,_this.address);
}

@override
String toString() {
  final _this = this as UpdateClinicInput;
  return 'UpdateClinicInput(clinicId: ${_this.clinicId}, name: ${_this.name}, address: ${_this.address})';
}


}

/// @nodoc
abstract mixin class $UpdateClinicInputCopyWith<$Res>  {
  factory $UpdateClinicInputCopyWith(UpdateClinicInput value, $Res Function(UpdateClinicInput) _then) = _$UpdateClinicInputCopyWithImpl;
@useResult
$Res call({
 String clinicId, String name, String address
});




}
/// @nodoc
class _$UpdateClinicInputCopyWithImpl<$Res>
    implements $UpdateClinicInputCopyWith<$Res> {
  _$UpdateClinicInputCopyWithImpl(this._self, this._then);

  final UpdateClinicInput _self;
  final $Res Function(UpdateClinicInput) _then;

/// Create a copy of UpdateClinicInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clinicId = null,Object? name = null,Object? address = null,}) {
  return _then(UpdateClinicInput(
clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateClinicInput].
extension UpdateClinicInputPatterns on UpdateClinicInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateClinicInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateClinicInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateClinicInput value)  $default,){
final _that = this;
switch (_that) {
case _UpdateClinicInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateClinicInput value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateClinicInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clinicId,  String name,  String address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateClinicInput() when $default != null:
return $default(_that.clinicId,_that.name,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clinicId,  String name,  String address)  $default,) {final _that = this;
switch (_that) {
case _UpdateClinicInput():
return $default(_that.clinicId,_that.name,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clinicId,  String name,  String address)?  $default,) {final _that = this;
switch (_that) {
case _UpdateClinicInput() when $default != null:
return $default(_that.clinicId,_that.name,_that.address);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateClinicInput extends UpdateClinicInput {
  const _UpdateClinicInput({required this.clinicId, required this.name, this.address = ''}): super._();
  

@override final  String clinicId;
@override final  String name;
@override@JsonKey() final  String address;

/// Create a copy of UpdateClinicInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateClinicInputCopyWith<_UpdateClinicInput> get copyWith => __$UpdateClinicInputCopyWithImpl<_UpdateClinicInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateClinicInput&&(identical(other.clinicId, clinicId) || other.clinicId == clinicId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address));
}


@override
int get hashCode {
    return Object.hash(runtimeType,clinicId,name,address);
}

@override
String toString() {
    return 'UpdateClinicInput(clinicId: $clinicId, name: $name, address: $address)';
}


}

/// @nodoc
abstract mixin class _$UpdateClinicInputCopyWith<$Res> implements $UpdateClinicInputCopyWith<$Res> {
  factory _$UpdateClinicInputCopyWith(_UpdateClinicInput value, $Res Function(_UpdateClinicInput) _then) = __$UpdateClinicInputCopyWithImpl;
@override @useResult
$Res call({
 String clinicId, String name, String address
});




}
/// @nodoc
class __$UpdateClinicInputCopyWithImpl<$Res>
    implements _$UpdateClinicInputCopyWith<$Res> {
  __$UpdateClinicInputCopyWithImpl(this._self, this._then);

  final _UpdateClinicInput _self;
  final $Res Function(_UpdateClinicInput) _then;

/// Create a copy of UpdateClinicInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clinicId = null,Object? name = null,Object? address = null,}) {
  return _then(_UpdateClinicInput(
clinicId: null == clinicId ? _self.clinicId : clinicId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
