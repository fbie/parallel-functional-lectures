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
}
