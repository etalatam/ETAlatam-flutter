


import 'package:MediansSchoolDriver/infrastructure/datasources/isar_datasource.dart';
import 'package:MediansSchoolDriver/infrastructure/repositories/local_storage_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localStorageRepositoryProvider = Provider((ref) => LocalStorageRepositoryImpl(IsarDatasource()));