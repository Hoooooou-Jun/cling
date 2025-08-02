import 'package:cling/core/supabase_initialize.dart';
import 'package:cling/models/simple_user_info.dart';

abstract class SupabaseUserDataSource {
  Future<List<Map<String, dynamic>>> checkUser(String userId);
  Future<List<Map<String, dynamic>>> registUser(String userId, SimpleUserInfo userInfo);
}

class SupabaseUserDataSourceImpl implements SupabaseUserDataSource {
  @override
  Future<List<Map<String, dynamic>>> checkUser(String userId) async {

    final response = await supabase
        .from('user')
        .select()
        .eq('id', userId);

    return response;
  }  

  @override
  Future<List<Map<String, dynamic>>> registUser(String userId, SimpleUserInfo userInfo) async {
    try {
      final response = await supabase
          .from('user')
          .insert({
            'id': userId,
            'nickname': userInfo.nickname,
            'address': userInfo.address,
            'gender': userInfo.gender,
            'bike_experience': userInfo.bikeYearLabel,
          })
          .select();

      return response ?? [];
    } catch (err) {
      throw err;
    }
  }
}

