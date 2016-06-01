// -*- c-basic-offset: 2; indent-tabs-mode: nil-*-

import java.util.function.*;
import java.util.stream.*;

public class Streams {

  public static class Student {
    public final String name;
    public final int grade;

    public Student(String name, int grade) {
      this.name = name;
      this.grade = grade;
    }

    public Student improveGrade(int grade) {
      return new Student(name, this.grade + grade);
    }

    @Override
    public String toString() {
      return String.format("%s: %d", name, grade);
    }
  }

  public static
    Stream<Student> students = Stream.of(new Student("A", 89),
                                         new Student("B", 44),
                                         new Student("C", 62));

  public static Stream<Student> everyoneBetterGrade(Stream<Student> students) {
    return students.map(s -> s.improveGrade(10));
  }

  public static double courseAverage(Stream<Student> students) {
    return students.collect(Collectors.averagingInt((Student s) -> s.grade));
  }

  public static void printStudents(Stream<Student> students) {
    students.forEach(System.out::println);
  }

  public static boolean isPrime(long n) {
    long k = 2;
    while (k * k <= n && n % k != 0)
      k++;
    return 2 <= n && n < k * k;
  }

  public static long getNumPrimes(long n) {
    long count = 0;
    for (long p = 0; p < n; ++p)
      if (isPrime(p))
        ++count;
    return count;
  }

  public static long getNumPrimesStream(long n) {
    return LongStream
      .range(0, n)
      .filter(p -> isPrime(p))
      .count();
  }

  public static long getNumPrimesParallel(long n) {
    return LongStream
      .range(0, n)
      .parallel()
      .filter(p -> isPrime(p))
      .count();
  }

  public static void main(String[] args) {
    long n = Integer.parseInt(args[0]);
    System.out.println(getNumPrimes(n));
    System.out.println(getNumPrimesStream(n));
    System.out.println(getNumPrimesParallel(n));
  }
}
