import 'package:dartz/dartz.dart';
import '../../../../core/base/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class GetAllAuthUseCase implements UseCase<List<AuthEntity>, NoParams> {
  const GetAllAuthUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, List<AuthEntity>>> call(NoParams params) {
    return repository.getAll();
  }
}
