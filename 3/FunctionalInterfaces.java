// -*- c-basic-offset: 2; indent-tabs-mode: nil-*-

import java.util.concurrent.*;
import java.util.function.*;

public class FunctionalInterfaces {

  public static class Inner {
    public static Runnable runnable() {
      Runnable r =
        new Runnable() {
          public void run() {
            System.out.println("Anonymous inner class.");
          }
        };
      return r;
    }

    public static Runnable readVariable() {
      final String s = "This is final!";
      Runnable r = new Runnable() {
          public void run() {
            System.out.println(s);
        }
        };
      return r;
    }

    public static Callable<String> callable() {
      final String s = "Callable.";
      Callable<String> c = new Callable<String>() {
          public String call() {
            return s;
          }
        };
      return c;
    }
  }

  public static class Lambda {
    public static Runnable runnable1() {
      Runnable r =
        () -> System.out.println("Runnable from lambda expression.");
      return r;
    }

    public static Runnable runnable2() {
      Runnable r =
        () -> { System.out.println("Runnable from lambda expression."); };
      return r;
    }

    public static Callable<String> callable1() {
      Callable<String> c = () -> "Lambda.";
      return c;
    }

    public static Callable<String> callable2() {
      Callable<String> c = () -> { return "Lambda."; };
      return c;
    }
  }

  public static class Interface {
    public static interface StringToInt {
      public int apply(String s);
    }

    public static StringToInt parseToInt = s -> Integer.parseInt(s);
  }

  public static class Interfaces {
    public static Function<String, String> toUpperCase = s -> s.toUpperCase();
    public static Predicate<String> isEmpty = s -> s.isEmpty();
    public static Consumer<String> print = s -> System.out.println(s);
    public static Supplier<String> genString = () -> "Nihao.";
    public static ToIntFunction<String> parseToInt = s -> Integer.parseInt(s);
    public static LongBinaryOperator longMul = (x, y) -> x * y;
    public static DoubleToIntFunction round = x -> (int)(x + 0.5d);
    public static IntPredicate isEven = x -> x % 2 == 0;
    public static IntUnaryOperator abs = n -> Math.abs(n);
    public static ToIntFunction<String> parseToInt2 = Integer::parseInt;
  }

  public static class Composition {
    public static <V, T, S> Function<T, V> compose(Function<T, S> f, Function<S, V> g) {
      return f.andThen(g);
    }
  }

  public static void main(String[] args) {
    try {
      Inner.runnable().run();
      Inner.readVariable().run();
      System.out.println(Inner.callable().call());
      Lambda.runnable1().run();
      Lambda.runnable2().run();
      System.out.println(Lambda.callable1().call());
      System.out.println(Lambda.callable2().call());
    } catch (Exception e) {
      System.err.println(e);
    }
  }
}
