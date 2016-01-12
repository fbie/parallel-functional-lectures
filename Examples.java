// -*- c-basic-offset: 2; indent-tabs-mode: nil -*-

public class Examples {

  public static class Maybe<A> {
    public final A a;

    private Maybe(A a) {
      this.a = a;
    }

    public static Maybe<A> None() {
      return new Maybe(null);
    }

    public static Maybe<A> Some(A a) {
      return new Maybe(a);
    }

    public boolean hasValue() {
      return a != null;
    }
  }

  public static class LinkedList<A> {
    public final A a;
    public final LinkedList<A> tail;

    private LinkedList(A a, LinkedList<A> tail) {
      this.a = a;
      this.tail = tail;
    }

    public static LinkedList<A> Nil() {
      return new LinkedList<A>(null, null);
    }

    public static LinkedList<A> Cons(A a, LinkedList<A> tail) {
      return new LinkedList<A>(a, tail);
    }

    public boolean isNil() {
      return tail == null;
    }
  }

  public static class BinaryTree<A> {
    public final A a;
    public final BinaryTree<A> left, right;

    private BinaryTree(A a, BinaryTree<A> left, BinaryTree<A> right) {
      this.a = a;
      this.left = left;
      this.right = right;
    }

    public static BinaryTree<A> Leaf(A a) {
      return new BinaryTree<A>(a, null, null);
    }

    public static BinaryTree<A> Node(A a, BinaryTree<A> left, BinaryTree<A> right) {
      return new BinaryTree<A>(a, left, right);
    }

    public boolean isLeaf() {
      return left == null && right == null;
    }
  }
}
