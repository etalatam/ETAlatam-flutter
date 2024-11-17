


import 'package:eta_school_app/infrastructure/datasources/isar_datasource.dart';
import 'package:eta_school_app/infrastructure/repositories/local_storage_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageRepositoryProvider = Provider((ref) => LocalStorageRepositoryImpl(IsarDatasource()));