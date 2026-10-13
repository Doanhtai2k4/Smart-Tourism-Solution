// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherResponseModel _$WeatherResponseModelFromJson(
  Map<String, dynamic> json,
) => WeatherResponseModel(
  coord: CoordModel.fromJson(json['coord'] as Map<String, dynamic>),
  weather: (json['weather'] as List<dynamic>)
      .map((e) => WeatherConditionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  base: json['base'] as String,
  main: MainModel.fromJson(json['main'] as Map<String, dynamic>),
  visibility: (json['visibility'] as num).toInt(),
  wind: WindModel.fromJson(json['wind'] as Map<String, dynamic>),
  clouds: CloudsModel.fromJson(json['clouds'] as Map<String, dynamic>),
  dt: (json['dt'] as num).toInt(),
  sys: SysModel.fromJson(json['sys'] as Map<String, dynamic>),
  timezone: (json['timezone'] as num).toInt(),
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  cod: (json['cod'] as num).toInt(),
);

Map<String, dynamic> _$WeatherResponseModelToJson(
  WeatherResponseModel instance,
) => <String, dynamic>{
  'coord': instance.coord.toJson(),
  'weather': instance.weather.map((e) => e.toJson()).toList(),
  'base': instance.base,
  'main': instance.main.toJson(),
  'visibility': instance.visibility,
  'wind': instance.wind.toJson(),
  'clouds': instance.clouds.toJson(),
  'dt': instance.dt,
  'sys': instance.sys.toJson(),
  'timezone': instance.timezone,
  'id': instance.id,
  'name': instance.name,
  'cod': instance.cod,
};

CoordModel _$CoordModelFromJson(Map<String, dynamic> json) => CoordModel(
  lon: (json['lon'] as num).toDouble(),
  lat: (json['lat'] as num).toDouble(),
);

Map<String, dynamic> _$CoordModelToJson(CoordModel instance) =>
    <String, dynamic>{'lon': instance.lon, 'lat': instance.lat};

WeatherConditionModel _$WeatherConditionModelFromJson(
  Map<String, dynamic> json,
) => WeatherConditionModel(
  id: (json['id'] as num).toInt(),
  main: json['main'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
);

Map<String, dynamic> _$WeatherConditionModelToJson(
  WeatherConditionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'main': instance.main,
  'description': instance.description,
  'icon': instance.icon,
};

MainModel _$MainModelFromJson(Map<String, dynamic> json) => MainModel(
  temp: (json['temp'] as num).toDouble(),
  feelsLike: (json['feels_like'] as num).toDouble(),
  tempMin: (json['temp_min'] as num).toDouble(),
  tempMax: (json['temp_max'] as num).toDouble(),
  pressure: (json['pressure'] as num).toInt(),
  humidity: (json['humidity'] as num).toInt(),
);

Map<String, dynamic> _$MainModelToJson(MainModel instance) => <String, dynamic>{
  'temp': instance.temp,
  'feels_like': instance.feelsLike,
  'temp_min': instance.tempMin,
  'temp_max': instance.tempMax,
  'pressure': instance.pressure,
  'humidity': instance.humidity,
};

WindModel _$WindModelFromJson(Map<String, dynamic> json) => WindModel(
  speed: (json['speed'] as num).toDouble(),
  deg: (json['deg'] as num).toInt(),
);

Map<String, dynamic> _$WindModelToJson(WindModel instance) => <String, dynamic>{
  'speed': instance.speed,
  'deg': instance.deg,
};

CloudsModel _$CloudsModelFromJson(Map<String, dynamic> json) =>
    CloudsModel(all: (json['all'] as num).toInt());

Map<String, dynamic> _$CloudsModelToJson(CloudsModel instance) =>
    <String, dynamic>{'all': instance.all};

SysModel _$SysModelFromJson(Map<String, dynamic> json) => SysModel(
  country: json['country'] as String,
  sunrise: (json['sunrise'] as num).toInt(),
  sunset: (json['sunset'] as num).toInt(),
);

Map<String, dynamic> _$SysModelToJson(SysModel instance) => <String, dynamic>{
  'country': instance.country,
  'sunrise': instance.sunrise,
  'sunset': instance.sunset,
};
