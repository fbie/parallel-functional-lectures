// -*- c-basic-offset: 2; indent-tabs-mode: nil -*-

public class Examples {

  // A Java approximation of the Maybe type.
  public static abstract class Maybe<A> {}

  public static class None<A> extends Maybe<A> {

    public None() {}

  }

  public static class Some<A> extends Maybe<A> {

    public final A a;

    public Some(A a) {
      this.a = a;
    }
  }

  // A Java approximation of the linked list type.
  public static abstract class LinkedList<A> {}

  public static class Nil<A> extends LinkedList<A> {

    public Nil() {}

  }

  public static class Cons<A> extends LinkedList<A> {

    public final A a;
    public final LinkedList<A> tail;

    public Cons(A a, LinkedList<A> tail) {
      this.a = a;
      this.tail = tail;
    }
  }

  // An approximation of the binary tree type.
  public static abstract class BinaryTree<A> {}

  public static class Leaf<A> extends BinaryTree<A> {
    public final A a;

    public Leaf(A a) {
      this.a = a;
    }
  }

  public static class Node<A> extends BinaryTree<A> {
    public final BinaryTree<A> left, right;

    public Node(BinaryTree<A> left, BinaryTree<A> right) {
      this.left = left;
      this.right = right;
    }
  }
}
