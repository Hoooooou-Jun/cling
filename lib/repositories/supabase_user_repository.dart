import 'package:cling/datasources/supabase_user_data_source.dart';
import 'package:cling/models/simple_user_info.dart';

abstract class SupabaseUserRepository {
  Future<bool> checkUserExist(userId);
  Future<bool> registUser(userId, SimpleUserInfo userInfo);
}

class SupabaseUserRepositoryImpl implements SupabaseUserRepository {
  final SupabaseUserDataSource _ds;
  SupabaseUserRepositoryImpl(this._ds);
  
  @override
  Future<bool> checkUserExist(userId) async {
    final response = await _ds.checkUser(userId);
    return response.isNotEmpty;
  }

  @override
  Future<bool> registUser(userId, SimpleUserInfo userInfo) async {
    final response = await _ds.registUser(userId, userInfo);
    return response.isNotEmpty;
  }
}