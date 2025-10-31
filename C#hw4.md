## Test Your Knowledge

1) Describe the problem generics address  
Generics let you define classes, methods, and interfaces with placeholders for types to achieve compile-time type safety, eliminate casts, avoid boxing and unboxing for value types, and improve performance and reuse without duplicating code for each concrete type.

2) How would you create a list of strings, using the generic List class?  
```csharp
var names = new List<string>();
```

3) How many generic type parameters does the Dictionary class have?  
Two: key and value.

4) True/False. When a generic class has multiple type parameters, they must all match.  
False. They can be different and independent.

5) What method is used to add items to a List object?  
Add.

6) Name two methods that cause items to be removed from a List.  
Remove, RemoveAt. (Also Clear, RemoveAll.)

7) How do you indicate that a class has a generic type parameter?  
Place the type parameter list in angle brackets after the type name, for example: class Box<T> { }.

8) True/False. Generic classes can only have one generic type parameter.  
False. They can have many, for example: Tuple<T1,T2,T3>.

9) True/False. Generic type constraints limit what can be used for the generic type.  
True.

10) True/False. Constraints let you use the methods of the thing you are constraining to.  
True. For example, where T : Stream lets you call Stream members on values of type T.

## Practice working with Generics

## 1) Custom stack

```csharp
using System;
using System.Collections.Generic;

public class MyStack<T>
{
    private readonly List<T> _items = new List<T>();

    public int Count()
    {
        return _items.Count;
    }

    public void Push(T item)
    {
        _items.Add(item);
    }

    public T Pop()
    {
        if (_items.Count == 0)
            throw new InvalidOperationException("Stack is empty.");
        int lastIndex = _items.Count - 1;
        T value = _items[lastIndex];
        _items.RemoveAt(lastIndex);
        return value;
    }
}

// Demo
public static class MyStackDemo
{
    public static void Run()
    {
        var s = new MyStack<int>();
        s.Push(10);
        s.Push(20);
        Console.WriteLine($"Count before pop: {s.Count()}"); // 2
        Console.WriteLine($"Popped: {s.Pop()}");              // 20
        Console.WriteLine($"Popped: {s.Pop()}");              // 10
        Console.WriteLine($"Count after pop: {s.Count()}");   // 0
    }
}
```

## 2) Generic list data structure

```csharp
using System;
using System.Collections.Generic;

public class MyList<T>
{
    private T[] _data;
    private int _count;

    public MyList(int capacity = 4)
    {
        if (capacity < 0) throw new ArgumentOutOfRangeException(nameof(capacity));
        _data = new T[capacity];
        _count = 0;
    }

    public int Count => _count;

    public void Add(T element)
    {
        EnsureCapacity(_count + 1);
        _data[_count++] = element;
    }

    public T Remove(int index)
    {
        ValidateIndex(index);
        T removed = _data[index];
        ShiftLeft(index + 1, 1);
        _count--;
        _data[_count] = default!;
        return removed;
    }

    public bool Contains(T element)
    {
        var cmp = EqualityComparer<T>.Default;
        for (int i = 0; i < _count; i++)
            if (cmp.Equals(_data[i], element)) return true;
        return false;
    }

    public void Clear()
    {
        Array.Clear(_data, 0, _count);
        _count = 0;
    }

    public void InsertAt(T element, int index)
    {
        if (index < 0 || index > _count) throw new ArgumentOutOfRangeException(nameof(index));
        EnsureCapacity(_count + 1);
        ShiftRight(index, 1);
        _data[index] = element;
        _count++;
    }

    public void DeleteAt(int index)
    {
        ValidateIndex(index);
        ShiftLeft(index + 1, 1);
        _count--;
        _data[_count] = default!;
    }

    public T Find(int index)
    {
        ValidateIndex(index);
        return _data[index];
    }

    private void EnsureCapacity(int desired)
    {
        if (desired <= _data.Length) return;
        int newCap = Math.Max(_data.Length * 2, desired);
        Array.Resize(ref _data, newCap);
    }

    private void ShiftRight(int startIndex, int amount)
    {
        if (amount <= 0) return;
        Array.Copy(_data, startIndex, _data, startIndex + amount, _count - startIndex);
    }

    private void ShiftLeft(int startIndex, int amount)
    {
        if (amount <= 0) return;
        int moveCount = _count - startIndex;
        if (moveCount > 0)
            Array.Copy(_data, startIndex, _data, startIndex - amount, moveCount);
    }

    private void ValidateIndex(int index)
    {
        if (index < 0 || index >= _count)
            throw new ArgumentOutOfRangeException(nameof(index));
    }
}

// Demo
public static class MyListDemo
{
    public static void Run()
    {
        var list = new MyList<string>();
        list.Add("Ada");
        list.Add("Grace");
        list.InsertAt("Alan", 1);
        Console.WriteLine(list.Contains("Grace")); // True
        Console.WriteLine(list.Find(1));           // Alan
        Console.WriteLine(list.Remove(1));         // Alan
        list.DeleteAt(0);                          // remove "Ada"
        Console.WriteLine(list.Count);             // 1 ("Grace" remains)
        list.Clear();
        Console.WriteLine(list.Count);             // 0
    }
}
```

## 3) GenericRepository<T> 

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

// Base entity with Id
public abstract class Entity
{
    public int Id { get; set; }
}

public interface IRepository<T> where T : class
{
    void Add(T item);
    void Remove(T item);
    void Save();
    IEnumerable<T> GetAll();
    T GetById(int id);
}

// Generic repository constrained to reference types that are Entity
public class GenericRepository<T> : IRepository<T> where T : class
{
    private readonly List<T> _items = new List<T>();

    public void Add(T item)
    {
        if (item == null) throw new ArgumentNullException(nameof(item));
        _items.Add(item);
    }

    public void Remove(T item)
    {
        if (item == null) throw new ArgumentNullException(nameof(item));
        _items.Remove(item);
    }

    public void Save()
    {
        // In-memory implementation: no-op.
        // In a real implementation, persist to SQL/Oracle/etc.
    }

    public IEnumerable<T> GetAll()
    {
        return _items.ToList();
    }

    public T GetById(int id)
    {
        // Use reflection to read Id if the concrete type has it (typical when T : Entity)
        var prop = typeof(T).GetProperty("Id");
        if (prop == null)
            throw new InvalidOperationException("Type does not expose an Id property.");
        foreach (var item in _items)
        {
            var value = prop.GetValue(item);
            if (value is int i && i == id) return item;
        }
        throw new KeyNotFoundException($"No item with Id={id} was found.");
    }
}

// Example concrete entity
public class Student : Entity
{
    public string Name { get; set; } = "";
}

// Demo
public static class RepositoryDemo
{
    public static void Run()
    {
        IRepository<Student> repo = new GenericRepository<Student>();
        repo.Add(new Student { Id = 1, Name = "Ada" });
        repo.Add(new Student { Id = 2, Name = "Grace" });
        repo.Save();

        foreach (var s in repo.GetAll())
            Console.WriteLine($"{s.Id}: {s.Name}");

        var one = repo.GetById(1);
        Console.WriteLine($"Found: {one.Name}");

        repo.Remove(one);
        Console.WriteLine("After remove:");
        foreach (var s in repo.GetAll())
            Console.WriteLine($"{s.Id}: {s.Name}");
    }
}
```