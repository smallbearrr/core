// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
/// Creates a new empty queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.new()
///   assert_eq(queue.length(), 0)
/// ```
pub fn[A] new() -> T[A] {
  { length: 0, first: None, last: None }
}

///|
/// Creates a new queue from an array.
///
/// # Example
/// ```mbt
///   let array = Array::makei(3, (idx) => { idx + 1 })
///   let queue : @queue.T[Int] = @queue.from_array(array)
///   assert_eq(queue.length(), 3)
/// ```
pub fn[A] from_array(arr : Array[A]) -> T[A] {
  guard arr.length() > 0 else { return new() }
  let length = arr.length()
  let last = { content: arr[length - 1], next: None }
  let first = for i = length - 2, x = last; i >= 0; {
    continue i - 1, { content: arr[i], next: Some(x) }
  } else {
    x
  }
  { length, first: Some(first), last: Some(last) }
}

///|
pub impl[A : Show] Show for T[A] with output(self, logger) {
  logger.write_iter(self.iter(), prefix="@queue.of([", suffix="])")
}

///|
/// Tests if two queues are equal.
impl[A : Eq] Eq for T[A] with op_equal(self, other) {
  self.length == other.length && self.first == other.first
}

///|
/// Clears the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   queue.clear()
/// ```
pub fn[A] clear(self : T[A]) -> Unit {
  self.length = 0
  self.first = None
  self.last = None
}

///|
/// Get the length of the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.new()
///   assert_eq(queue.length(), 0)
/// ```
pub fn[A] length(self : T[A]) -> Int {
  self.length
}

///|
/// Checks if the queue is empty.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.new()
///   assert_true(queue.is_empty())
/// ```
pub fn[A] is_empty(self : T[A]) -> Bool {
  self.length == 0
}

///|
/// Adds a value to the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.new()
///   queue.push(1)
/// ```
pub fn[A] push(self : T[A], x : A) -> Unit {
  let cell = Some({ content: x, next: None })
  match self.last {
    None => {
      self.length = 1
      self.first = cell
      self.last = cell
    }
    Some(last) => {
      last.next = cell
      self.length += 1
      self.last = cell
    }
  }
}

///|
/// Peeks at the first value in the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   assert_eq(queue.unsafe_peek(), 1)
/// ```
#internal(unsafe, "Panics if the queue is empty.")
pub fn[A] unsafe_peek(self : T[A]) -> A {
  match self.first {
    None => abort("Queue is empty")
    Some(first) => first.content
  }
}

///|
/// Peeks at the first value in the queue, which returns None if the queue is empty.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   assert_eq(queue.peek(), Some(1))
/// ```
pub fn[A] peek(self : T[A]) -> A? {
  match self.first {
    None => None
    Some(first) => Some(first.content)
  }
}

///|
/// Pops the first value from the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   assert_eq(queue.unsafe_pop(), 1)
/// ```
#internal(unsafe, "Panics if the queue is empty.")
pub fn[A] unsafe_pop(self : T[A]) -> A {
  match self.first {
    None => abort("Queue is empty")
    Some({ content, next: None }) => {
      self.clear()
      content
    }
    Some({ content, next }) => {
      self.length -= 1
      self.first = next
      content
    }
  }
}

///|
/// Pops the first value from the queue, which returns None if the queue is empty.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   assert_eq(queue.pop(), Some(1))
/// ```
pub fn[A] pop(self : T[A]) -> A? {
  match self.first {
    None => None
    Some({ content, next: None }) => {
      self.clear()
      Some(content)
    }
    Some({ content, next }) => {
      self.length -= 1
      self.first = next
      Some(content)
    }
  }
}

///|
/// Iterates over the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   let mut sum = 0
///   queue.each((x) => { sum = sum + x })
/// ```
pub fn[A] each(self : T[A], f : (A) -> Unit) -> Unit {
  loop self.first {
    Some({ content, next }) => {
      f(content)
      continue next
    }
    None => ()
  }
}

///|
/// Iterates over the queue with index.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   let mut sum = 0
///   queue.eachi((x, i) => { sum = sum + x * i })
/// ```
pub fn[A] eachi(self : T[A], f : (Int, A) -> Unit) -> Unit {
  loop (self.first, 0) {
    (Some({ content, next }), index) => {
      f(index, content)
      continue (next, index + 1)
    }
    (None, _) => ()
  }
}

///|
/// Folds over the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.new()
///   let sum = queue.fold(init=0, (acc, x) => { acc + x })
///   assert_eq(sum, 0)
/// ```
pub fn[A, B] fold(self : T[A], init~ : B, f : (B, A) -> B) -> B {
  loop (self.first, init) {
    (None, acc) => acc
    (Some({ content, next }), acc) => continue (next, f(acc, content))
  }
}

///|
/// Returns a copy of the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   let queue2 : @queue.T[Int] = queue.copy()
///   assert_eq(queue2.length(), 4)
/// ```
pub fn[A] copy(self : T[A]) -> T[A] {
  guard self.first is Some({ content, next }) else { return new() }
  let first = { content, next: None }
  let last = loop (first, next) {
    (pre, Some({ content, next })) => {
      let curr = { content, next: None }
      pre.next = Some(curr)
      continue (curr, next)
    }
    (pre, None) => pre
  }
  { length: self.length, first: Some(first), last: Some(last) }
}

///|
/// Transfers all elements from one queue to another.
///
/// Adds all of the elements of source to the end of destination, then clears source.
///
/// # Example
/// ```mbt
///   let dst : @queue.T[Int] = @queue.new()
///   let src : @queue.T[Int] = @queue.of([5, 6, 7, 8])
///   src.transfer(dst)
/// ```
pub fn[A] transfer(self : T[A], dst : T[A]) -> Unit {
  if self.length > 0 {
    match dst.last {
      None => {
        dst.length = self.length
        dst.first = self.first
        dst.last = self.last
        self.clear()
      }
      Some(last) => {
        last.next = self.first
        dst.length = dst.length + self.length
        dst.last = self.last
        self.clear()
      }
    }
  }
}

///|
/// Creates an iter from the queue.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([5, 6, 7, 8])
///   let sum = queue.iter().fold((x, y) => { x + y }, init=0)
///   assert_eq(sum, 26)
/// ```
pub fn[A] iter(self : T[A]) -> Iter[A] {
  Iter::new(yield_ => loop self.first {
    Some({ content, next }) => {
      if yield_(content) == IterEnd {
        break IterEnd
      }
      continue next
    }
    None => IterContinue
  })
}

///|
/// Creates a new queue from an iter.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.from_iter(Iter::empty())
///   assert_eq(queue.length(), 0)
/// ```
pub fn[A] from_iter(iter : Iter[A]) -> T[A] {
  let q = new()
  iter.each(e => q.push(e))
  q
}

///|
/// Creates a new queue from a FixedArray.
///
/// # Example
/// ```mbt
///   let queue : @queue.T[Int] = @queue.of([1, 2, 3, 4])
///   assert_eq(queue.length(), 4)
/// ```
pub fn[A] of(arr : FixedArray[A]) -> T[A] {
  guard arr.length() > 0 else { return new() }
  let length = arr.length()
  let last = { content: arr[length - 1], next: None }
  let first = for i = length - 2, x = last; i >= 0; {
    continue i - 1, { content: arr[i], next: Some(x) }
  } else {
    Some(x)
  }
  { length, first, last: Some(last) }
}

///|
test "from_fixed_array_2" {
  let q = of([1, 2, 3, 4])
  q.push(11)
  assert_eq(q, of([1, 2, 3, 4, 11]))
  q.unsafe_pop() |> ignore
  assert_eq(q, of([2, 3, 4, 11]))
}

///|
test "from_array_2" {
  let q = of([1, 2, 3, 4])
  q.push(11)
  assert_eq(q, of([1, 2, 3, 4, 11]))
  q.unsafe_pop() |> ignore
  assert_eq(q, of([2, 3, 4, 11]))
}

///|
test "op_equal" {
  let queue = of([1, 2, 3, 4])
  let queue2 = of([1, 2, 3, 4])
  let queue3 = of([1, 2, 3, 5])
  assert_true(queue == queue2)
  assert_false(queue == queue3)
  queue.unsafe_pop() |> ignore
  assert_false(queue == queue2)
  assert_eq(queue, of([2, 3, 4]))
}

///|
test "push" {
  let queue : T[Int] = new()
  queue.push(1)
  queue.push(2)
  queue.push(3)
  queue.push(1)
  assert_eq(queue.length(), 4)
  assert_eq(queue, of([1, 2, 3, 1]))
}

///|
test "copy" {
  let queue : T[Int] = of([1, 2, 3, 4])
  let queue2 : T[Int] = queue.copy()
  assert_eq(queue2.length(), 4)
  assert_eq(queue2, of([1, 2, 3, 4]))
  assert_eq(queue.length(), 4)
  assert_eq(queue, of([1, 2, 3, 4]))
}

///|
test "transfer" {
  let queue : T[Int] = of([1, 2, 3, 4])
  let queue2 : T[Int] = of([5, 6, 7, 8])
  queue.transfer(queue2)
  assert_eq(queue.length(), 0)
  assert_eq(queue2.length(), 8)
  assert_eq(queue2, of([5, 6, 7, 8, 1, 2, 3, 4]))
}

///|
test "cell_equal" {
  assert_false(of([]).first == of([1]).first)
}

///|
pub impl[X : @quickcheck.Arbitrary] @quickcheck.Arbitrary for T[X] with arbitrary(
  size,
  rs
) {
  @quickcheck.Arbitrary::arbitrary(size, rs) |> from_iter
}
