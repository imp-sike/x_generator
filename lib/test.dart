import 'annotations/x_api.dart';
import 'annotations/x_get.dart';

@XApi(baseUrl: "https://jsonplaceholder.typicode.com/")
abstract class Test {
  @XGet(endpoint: "/posts")
  Future<List<Map>> getAllPosts();
}
