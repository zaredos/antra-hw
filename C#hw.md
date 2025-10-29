

## 01 — Introduction to C# and Data Types

**1) 
- A person’s telephone number → **`string`** 
- A person’s height → **`decimal`** 
- A person’s age → **`int`** 
- A person’s gender (Male, Female, Prefer Not To Answer) → **`enum`**
- A person’s salary → **`decimal`**  
- A book’s ISBN → **`string`** 
- A book’s price → **`decimal`**
- A book’s shipping weight → **`decimal`**  
- A country’s population → **`int`**  
- The number of stars in the universe → **`BigInteger`** 
- Employees per SMB (up to ~50,000) → **`int`** 

**2) 
- Value types hold their data directly, assignment copies the value.
- Reference types hold a reference to an object on the heap, assignment copies the reference (not actual value)
- Boxing: wrapping a value type into an object/reference.  
- Unboxing: extracting the value type from a boxed object.

**3) 
- Managed: memory/resources tracked by the CLR and GC
- Unmanaged: OS/Native resources not tracked by GC.

**4) Garbage Collector**  
- Automatically reclaims heap memory for objects that are no longer reachable.  
- Compacts/optimizes the heap, reduces fragmentation, and minimizes leaks.  
- Frees developers from most manual memory management

---

### A. Change the message & provoke compiler errors
Done.

### B. Simple “Hacker Name” generator (uses only `ReadLine`/`WriteLine`)

```csharp
using System;

class Program
{
    static void Main()
    {
        Console.Write("Favorite color: ");
        string color = Console.ReadLine();

        Console.Write("Astrology sign: ");
        string sign = Console.ReadLine();

        Console.Write("Street address number: ");
        string streetNum = Console.ReadLine();

        Console.WriteLine($"Your hacker name is {color}{sign}{streetNum}.");
    }
}
```

---

### 1) Project: 02UnderstandingTypes

```csharp
using System;
using System.Numerics;
using System.Runtime.InteropServices;

class Program
{
    static void Print<T>(string label, T min, T max)
    {
        int bytes = Marshal.SizeOf<T>();
        Console.WriteLine($"{label,-8} | {bytes,5} bytes | min = {min,-30} | max = {max}");
    }

    static void Main()
    {
        Print<sbyte>("sbyte", sbyte.MinValue, sbyte.MaxValue);
        Print<byte>("byte", byte.MinValue, byte.MaxValue);
        Print<short>("short", short.MinValue, short.MaxValue);
        Print<ushort>("ushort", ushort.MinValue, ushort.MaxValue);
        Print<int>("int", int.MinValue, int.MaxValue);
        Print<uint>("uint", uint.MinValue, uint.MaxValue);
        Print<long>("long", long.MinValue, long.MaxValue);
        Print<ulong>("ulong", ulong.MinValue, ulong.MaxValue);
        Print<float>("float", float.MinValue, float.MaxValue);
        Print<double>("double", double.MinValue, double.MaxValue);
        // decimal: Marshal.SizeOf<decimal>() returns 16, and Min/Max are exact
        Print<decimal>("decimal", decimal.MinValue, decimal.MaxValue);

        // Bonus: BigInteger has arbitrary precision, but we can show a sample
        Console.WriteLine($"BigInteger |   N/A  bytes | arbitrary precision (no fixed min/max)");
    }
}
```

### 2) Centuries -> years/days/hours/

````csharp
using System;
using System.Numerics;

class Program
{
    static void Main()
    {
        Console.Write("Enter centuries: ");
        if (!int.TryParse(Console.ReadLine(), out int centuries) || centuries < 0)
        {
            Console.WriteLine("Please enter a non-negative integer.");
            return;
        }

        // 1 century = 100 years
        long years = centuries * 100L;

        // Round to nearest day using the Gregorian average 365.2425
        long days = (long)Math.Round(years * 365.2425, MidpointRounding.AwayFromZero);
        BigInteger hours = (BigInteger)days * 24;
        BigInteger minutes = hours * 60;
        BigInteger seconds = minutes * 60;
        BigInteger millis = seconds * 1000;
        BigInteger micros = millis * 1000;
        BigInteger nanos = micros * 1000;

        Console.WriteLine($"{centuries} centuries = {years} years = {days} days = {hours} hours = {minutes} minutes = {seconds} seconds = {millis} milliseconds = {micros} microseconds = {nanos} nanoseconds");
    }
}
````

---

1) int ÷ 0 → DivideByZeroException at runtime.  
2) double ÷ 0 → Infinity (±∞ for nonzero numerator) or NaN (0/0).  
3) Overflowing int → in unchecked context it wraps around; in checked context throws OverflowException.  
4) x = y++; assigns original y to x, then increments y. x = ++y; increments first, then assigns incremented value to x.  
5) break exits the nearest loop; continue skips to next loop iteration; return exits the current method/function.  
6) for has initializer; condition; iterator — all optional.  
7) = is assignment; == is equality comparison.  
8) for ( ; true; ) ; compiles; it’s an infinite loop with an empty statement body.  
9) _ in a switch expression is the discard/default pattern (matches anything not previously matched).  
10) foreach requires IEnumerable/IEnumerable<T> or the enumeration pattern (GetEnumerator, MoveNext, Current).

---

### 1) FizzBuzz to 100

```csharp
using System;

class Program
{
    static void Main()
    {
        for (int i = 1; i <= 100; i++)
        {
            bool fizz = i % 3 == 0;
            bool buzz = i % 5 == 0;
            Console.WriteLine(fizz && buzz ? "fizzbuzz" : fizz ? "fizz" : buzz ? "buzz" : i);
        }
    }
}
```

#### Byte overflow thought experiment

```csharp
int max = 500;
for (byte i = 0; i < max; i++)
{
    Console.WriteLine(i);
}
```
**What happens?** `byte` ranges 0–255. After 255, it overflows to 0 and the condition `i < 500` is always true ⇒ **infinite loop** (wraparound).

**Add a warning (without changing the given lines):**
```csharp
int max = 500;
for (byte i = 0; i < max; i++)
{
    if (i == byte.MaxValue) Console.WriteLine("WARNING: byte will overflow and loop forever.");
    Console.WriteLine(i);
}
```

### 2) Guess‑the‑Number (1–3)

```csharp
using System;

class Program
{
    static void Main()
    {
        int correctNumber = new Random().Next(3) + 1;
        Console.Write("Guess a number (1-3): ");
        int guessedNumber = int.Parse(Console.ReadLine()!); // assume valid per instructions

        if (guessedNumber < 1 || guessedNumber > 3)
            Console.WriteLine("Out of range.");
        else if (guessedNumber < correctNumber)
            Console.WriteLine("Too low.");
        else if (guessedNumber > correctNumber)
            Console.WriteLine("Too high.");
        else
            Console.WriteLine("Correct!");
    }
}
```

### 3) Print‑a‑Pyramid

```csharp
using System;

class Program
{
    static void Main()
    {
        int lines = 5;
        for (int row = 1; row <= lines; row++)
        {
            // spaces
            for (int s = 0; s < lines - row; s++) Console.Write(" ");
            // stars
            for (int k = 0; k < 2 * row - 1; k++) Console.Write("*");
            Console.WriteLine();
        }
    }
}
```

### 4) Days old & next 10,000‑day anniversary

```csharp
using System;

class Program
{
    static void Main()
    {
        // Example fixed birthdate. Replace with your own or parse from input.
        DateTime birth = new DateTime(2000, 1, 1);
        DateTime today = DateTime.Today;

        int daysOld = (today - birth).Days;
        Console.WriteLine($"Days old: {daysOld}");

        int daysToNextAnniversary = 10000 - (daysOld % 10000);
        DateTime nextAnniversary = today.AddDays(daysToNextAnniversary);
        Console.WriteLine($"Next 10,000-day anniversary: {nextAnniversary:yyyy-MM-dd}");
    }
}
```

### 5) Time‑of‑day greeting (if only)

```csharp
using System;

class Program
{
    static void Main()
    {
        DateTime now = DateTime.Now; // swap in a fixed time during testing
        int h = now.Hour;

        if (h >= 5 && h < 12) Console.WriteLine("Good Morning");
        if (h >= 12 && h < 17) Console.WriteLine("Good Afternoon");
        if (h >= 17 && h < 21) Console.WriteLine("Good Evening");
        if (h >= 21 || h < 5) Console.WriteLine("Good Night");
    }
}
```

### 6) Count to 24 with increments 1–4

```csharp
using System;

class Program
{
    static void Main()
    {
        for (int outer = 1; outer <= 4; outer++)
        {
            for (int i = 0; i <= 24; i += outer)
            {
                Console.Write(i);
                if (i + outer <= 24) Console.Write(",");
            }
            Console.WriteLine();
        }
    }
}
```