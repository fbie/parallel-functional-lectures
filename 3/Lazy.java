// -*- c-basic-offset: 2; indent-tabs-mode: nil-*-

import java.util.function.*;

public class Lazy<T> implements Supplier<T> {
  private final Supplier<T> f;
  private volatile T t;

  public Lazy(Supplier<T> f) {
    this.f = f;
  }

  public T get() {
    if (t == null)
      t = f.get();
    return t;
  }

  public static void main(String[] args) {
    Lazy<String> s = new Lazy<String>(() -> {
        System.out.println("Calling get()");
        return "someString";
      }); // Not yet computed!
    String s1 = s.get(); // "Calling get()"
    String s2 = s.get(); // Nothing printed.
  }
}
