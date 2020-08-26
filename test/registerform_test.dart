import 'package:flutter_test/flutter_test.dart';
import 'package:whiteboard/registerpage.dart';

void main() {
  test("username", () {
    res = donametest();

    // expect(res,'valid username');
    print(res);
  });
  test("mobilenumber", () {
    res = domobtest();

    // expect(res,'valid username');
    print(res);
  });
  test("Professional", () {
    res = doprotest();

    // expect(res,'valid username');
    print(res);
  });
  test("College", () {
    res = docollegetest();

    // expect(res,'valid username');
    print(res);
  });
  test("State", () {
    res = dostatetest();

    // expect(res,'valid username');
    print(res);
  });

  test("District", () {
    res = dodistest();

    // expect(res,'valid username');
    print(res);
  });
}
