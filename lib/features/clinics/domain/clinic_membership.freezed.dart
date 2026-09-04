// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinic_membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicMembership {

 Clinic get clinic; bool get isDefault;
/// Create a copy of ClinicMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicMembershipCopyWith<ClinicMembership> get copyWith => _$ClinicMembershipCopyWithImpl<ClinicMembership>(this as ClinicMembership, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClinicMembership;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicMembership&&(identical(other.clinic, _this.clinic) || other.clinic == _this.clinic)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault));
}


@override
int get hashCode {
  final _this = this as ClinicMembership;
  return Object.hash(runtimeType,_this.clinic,_this.isDefault);
}

@override
String toString() {
  final _this = this as ClinicMembership;
  return 'ClinicMembership(clinic: ${_this.clinic}, isDefault: ${_this.isDefault})';
}


}

/// @nodoc
abstract mixin class $ClinicMembershipCopyWith<$Res>  {
  factory $ClinicMembershipCopyWith(ClinicMembership value, $Res Function(ClinicMembership) _then) = _$ClinicMembershipCopyWithImpl;
@useResult
$Res call({
 Clinic clinic, bool isDefault
});


$ClinicCopyWith<$Res> get clinic;

}
/// @nodoc
class _$ClinicMembershipCopyWithImpl<$Res>
    implements $ClinicMembershipCopyWith<$Res> {
  _$ClinicMembershipCopyWithImpl(this._self, this._then);

  final ClinicMembership _self;
  final $Res Function(ClinicMembership) _then;

/// Create a copy of ClinicMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clinic = null,Object? isDefault = null,}) {
  return _then(ClinicMembership(
clinic: null == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as Clinic,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ClinicMembership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res> get clinic {
  
  return $ClinicCopyWith<$Res>(_self.clinic, (value) {
    return _then(_self.copyWith(clinic: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClinicMembership].
extension ClinicMembershipPatterns on ClinicMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicMembership value)  $default,){
final _that = this;
switch (_that) {
case _ClinicMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicMembership value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Clinic clinic,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicMembership() when $default != null:
return $default(_that.clinic,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Clinic clinic,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _ClinicMembership():
return $default(_that.clinic,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Clinic clinic,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _ClinicMembership() when $default != null:
return $default(_that.clinic,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicMembership implements ClinicMembership {
  const _ClinicMembership({required this.clinic, this.isDefault = false});
  

@override final  Clinic clinic;
@override@JsonKey() final  bool isDefault;

/// Create a copy of ClinicMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicMembershipCopyWith<_ClinicMembership> get copyWith => __$ClinicMembershipCopyWithImpl<_ClinicMembership>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicMembership&&(identical(other.clinic, clinic) || other.clinic == clinic)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}


@override
int get hashCode {
    return Object.hash(runtimeType,clinic,isDefault);
}

@override
String toString() {
    return 'ClinicMembership(clinic: $clinic, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$ClinicMembershipCopyWith<$Res> implements $ClinicMembershipCopyWith<$Res> {
  factory _$ClinicMembershipCopyWith(_ClinicMembership value, $Res Function(_ClinicMembership) _then) = __$ClinicMembershipCopyWithImpl;
@override @useResult
$Res call({
 Clinic clinic, bool isDefault
});


@override $ClinicCopyWith<$Res> get clinic;

}
/// @nodoc
class __$ClinicMembershipCopyWithImpl<$Res>
    implements _$ClinicMembershipCopyWith<$Res> {
  __$ClinicMembershipCopyWithImpl(this._self, this._then);

  final _ClinicMembership _self;
  final $Res Function(_ClinicMembership) _then;

/// Create a copy of ClinicMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clinic = null,Object? isDefault = null,}) {
  return _then(_ClinicMembership(
clinic: null == clinic ? _self.clinic : clinic // ignore: cast_nullable_to_non_nullable
as Clinic,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ClinicMembership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClinicCopyWith<$Res> get clinic {
  
  return $ClinicCopyWith<$Res>(_self.clinic, (value) {
    return _then(_self.copyWith(clinic: value));
  });
}
}

// dart format on
