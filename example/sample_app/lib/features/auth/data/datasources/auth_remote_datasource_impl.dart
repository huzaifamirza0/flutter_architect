import '../models/auth_model.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl();

  @override
  Future<List<AuthModel>> getAll() async {
    // Demo stub — replace with ApiClient call.
    return const [AuthModel(id: '1'), AuthModel(id: '2')];
  }
}
