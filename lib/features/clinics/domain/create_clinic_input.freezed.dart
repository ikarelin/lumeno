// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_clinic_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateClinicInput {

 String get name;
/// Create a copy of CreateClinicInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateClinicInputCopyWith<CreateClinicInput> get copyWith => _$CreateClinicInputCopyWithImpl<CreateClinicInput>(this as CreateClinicInput, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreateClinicInput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateClinicInput&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as CreateClinicInput;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as CreateClinicInput;
  return 'CreateClinicInput(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $CreateClinicInputCopyWith<$Res>  {
  factory $CreateClinicInputCopyWith(CreateClinicInput value, $Res Function(CreateClinicInput) _then) = _$CreateClinicInputCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$CreateClinicInputCopyWithImpl<$Res>
    implements $CreateClinicInputCopyWith<$Res> {
  _$CreateClinicInputCopyWithImpl(this._self, this._then);

  final CreateClinicInput _self;
  final $Res Function(CreateClinicInput) _then;

/// Create a copy of CreateClinicInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(CreateClinicInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateClinicInput].
extension CreateClinicInputPatterns on CreateClinicInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateClinicInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateClinicInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateClinicInput value)  $default,){
final _that = this;
switch (_that) {
case _CreateClinicInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateClinicInput value)?  $default,){
final _that = this;
switch (_that) {
case _CreateClinicInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateClinicInput() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _CreateClinicInput():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _CreateClinicInput() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _CreateClinicInput extends CreateClinicInput {
  const _CreateClinicInput({required this.name}): super._();
  

@override final  String name;

/// Create a copy of CreateClinicInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateClinicInputCopyWith<_CreateClinicInput> get copyWith => __$CreateClinicInputCopyWithImpl<_CreateClinicInput>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateClinicInput&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'CreateClinicInput(name: $name)';
}


}

/// @nodoc
abstract mixin class _$CreateClinicInputCopyWith<$Res> implements $CreateClinicInputCopyWith<$Res> {
  factory _$CreateClinicInputCopyWith(_CreateClinicInput value, $Res Function(_CreateClinicInput) _then) = __$CreateClinicInputCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$CreateClinicInputCopyWithImpl<$Res>
    implements _$CreateClinicInputCopyWith<$Res> {
  __$CreateClinicInputCopyWithImpl(this._self, this._then);

  final _CreateClinicInput _self;
  final $Res Function(_CreateClinicInput) _then;

/// Create a copy of CreateClinicInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_CreateClinicInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
