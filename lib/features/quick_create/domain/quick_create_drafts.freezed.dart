// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quick_create_drafts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PatientDraft {

 String get name; String get phone; String get note;
/// Create a copy of PatientDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientDraftCopyWith<PatientDraft> get copyWith => _$PatientDraftCopyWithImpl<PatientDraft>(this as PatientDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PatientDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientDraft&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as PatientDraft;
  return Object.hash(runtimeType,_this.name,_this.phone,_this.note);
}

@override
String toString() {
  final _this = this as PatientDraft;
  return 'PatientDraft(name: ${_this.name}, phone: ${_this.phone}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $PatientDraftCopyWith<$Res>  {
  factory $PatientDraftCopyWith(PatientDraft value, $Res Function(PatientDraft) _then) = _$PatientDraftCopyWithImpl;
@useResult
$Res call({
 String name, String phone, String note
});




}
/// @nodoc
class _$PatientDraftCopyWithImpl<$Res>
    implements $PatientDraftCopyWith<$Res> {
  _$PatientDraftCopyWithImpl(this._self, this._then);

  final PatientDraft _self;
  final $Res Function(PatientDraft) _then;

/// Create a copy of PatientDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? note = null,}) {
  return _then(PatientDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientDraft].
extension PatientDraftPatterns on PatientDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientDraft value)  $default,){
final _that = this;
switch (_that) {
case _PatientDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientDraft value)?  $default,){
final _that = this;
switch (_that) {
case _PatientDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientDraft() when $default != null:
return $default(_that.name,_that.phone,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  String note)  $default,) {final _that = this;
switch (_that) {
case _PatientDraft():
return $default(_that.name,_that.phone,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  String note)?  $default,) {final _that = this;
switch (_that) {
case _PatientDraft() when $default != null:
return $default(_that.name,_that.phone,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _PatientDraft implements PatientDraft {
  const _PatientDraft({this.name = '', this.phone = '', this.note = ''});
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String note;

/// Create a copy of PatientDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientDraftCopyWith<_PatientDraft> get copyWith => __$PatientDraftCopyWithImpl<_PatientDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,phone,note);
}

@override
String toString() {
    return 'PatientDraft(name: $name, phone: $phone, note: $note)';
}


}

/// @nodoc
abstract mixin class _$PatientDraftCopyWith<$Res> implements $PatientDraftCopyWith<$Res> {
  factory _$PatientDraftCopyWith(_PatientDraft value, $Res Function(_PatientDraft) _then) = __$PatientDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, String note
});




}
/// @nodoc
class __$PatientDraftCopyWithImpl<$Res>
    implements _$PatientDraftCopyWith<$Res> {
  __$PatientDraftCopyWithImpl(this._self, this._then);

  final _PatientDraft _self;
  final $Res Function(_PatientDraft) _then;

/// Create a copy of PatientDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? note = null,}) {
  return _then(_PatientDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ClinicDraft {

 String get name;
/// Create a copy of ClinicDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicDraftCopyWith<ClinicDraft> get copyWith => _$ClinicDraftCopyWithImpl<ClinicDraft>(this as ClinicDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClinicDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicDraft&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as ClinicDraft;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as ClinicDraft;
  return 'ClinicDraft(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $ClinicDraftCopyWith<$Res>  {
  factory $ClinicDraftCopyWith(ClinicDraft value, $Res Function(ClinicDraft) _then) = _$ClinicDraftCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$ClinicDraftCopyWithImpl<$Res>
    implements $ClinicDraftCopyWith<$Res> {
  _$ClinicDraftCopyWithImpl(this._self, this._then);

  final ClinicDraft _self;
  final $Res Function(ClinicDraft) _then;

/// Create a copy of ClinicDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(ClinicDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicDraft].
extension ClinicDraftPatterns on ClinicDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicDraft value)  $default,){
final _that = this;
switch (_that) {
case _ClinicDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicDraft() when $default != null:
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
case _ClinicDraft() when $default != null:
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
case _ClinicDraft():
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
case _ClinicDraft() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicDraft implements ClinicDraft {
  const _ClinicDraft({this.name = ''});
  

@override@JsonKey() final  String name;

/// Create a copy of ClinicDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicDraftCopyWith<_ClinicDraft> get copyWith => __$ClinicDraftCopyWithImpl<_ClinicDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicDraft&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'ClinicDraft(name: $name)';
}


}

/// @nodoc
abstract mixin class _$ClinicDraftCopyWith<$Res> implements $ClinicDraftCopyWith<$Res> {
  factory _$ClinicDraftCopyWith(_ClinicDraft value, $Res Function(_ClinicDraft) _then) = __$ClinicDraftCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$ClinicDraftCopyWithImpl<$Res>
    implements _$ClinicDraftCopyWith<$Res> {
  __$ClinicDraftCopyWithImpl(this._self, this._then);

  final _ClinicDraft _self;
  final $Res Function(_ClinicDraft) _then;

/// Create a copy of ClinicDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_ClinicDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
