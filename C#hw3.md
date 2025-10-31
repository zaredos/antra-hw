## Test Your Knowledge
1) Six access modifiers and effects
public, private, protected, internal, protected internal, private protected.

2) static vs const vs readonly
static = one per type, const = compile-time constant, readonly = set in constructor or declaration.

3) Constructor
Initializes new instance.

4) partial keyword
Allows splitting class across multiple files.

5) Tuple
Grouping of values.

6) record
Value-based equality and immutability.

7) Overloading vs Overriding
Overloading: same name, different functions
Overriding: replace the method virtually

8) Field vs Property
Field stores data directly, Property wraps field with get/set.

9) Optional parameters
Provide default value.

10) Interface vs Abstract class
Interface defines contract, Abstract class defines base implementation.

11) Accessibility of interface members
Public.

12) Polymorphism allows derived classes to provide different implementations of the same method: True
13) override indicates derived class provides its own implementation: True
14) new indicates derived class provides its own implementation: False
15) Abstract methods in normal class: False
16) Normal methods in abstract class: True
17) Derived classes override virtual methods: True
18) Derived classes override abstract methods: True
19) Override non-virtual/non-abstract: False
20) Class implementing interface must implement all members: True
21) Class implementing interface can have extra members: True
22) Multiple base classes: False
23) Multiple interfaces: True

### 1) Reverse an array using three methods

```csharp
using System;

namespace MethodsExercises
{
    class Program
    {
        static void Main(string[] args)
        {
            int[] numbers = GenerateNumbers(10); // gen arr of length 10
            Reverse(numbers);
            PrintNumbers(numbers);
        }

        static int[] GenerateNumbers(int length = 10)
        {
            var arr = new int[length];
            for (int i = 0; i < length; i++) arr[i] = i + 1;
            return arr;
        }

        static void Reverse(int[] arr)
        {
            for (int i = 0; i < arr.Length / 2; i++)
            {
                int j = arr.Length - i - 1;
                int temp = arr[i]; // swap until reach middle
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }

        static void PrintNumbers(int[] arr)
        {
            foreach (var n in arr) Console.Write($"{n} ");
            Console.WriteLine();
        }
    }
}
```

### 2) Fibonacci

```csharp
using System;

namespace MethodsExercises
{
    class FibDemo
    {
        static void Main()
        {
            for (int i = 1; i <= 10; i++)
            {
                Console.WriteLine(Fibonacci(i));
            }
        }

        static long Fibonacci(int n)
        {
            if (n <= 2) return 1;
            return Fibonacci(n - 1) + Fibonacci(n - 2);
        }
    }
}
```

---

## Designing & Building Classes (OOP Principles)


```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace UniversityModel
{
    // interfaces
    public interface IPersonService
    {
        int CalculateAge(Person person, DateTime asOf);
        decimal CalculateSalary(Person person);
        IReadOnlyList<Address> GetAddresses(Person person);
        void AddAddress(Person person, Address address);
    }

    public interface IStudentService : IPersonService
    {
        void Enroll(Student student, Course course);
        void AssignGrade(Student student, Course course, Grade grade);
        double CalculateGpa(Student student);
    }

    public interface IInstructorService : IPersonService
    {
        Department? GetDepartment(Instructor instructor);
        void AssignDepartment(Instructor instructor, Department department, bool asHead = false);
        int YearsOfExperience(Instructor instructor, DateTime asOf);
        decimal CalculateSalaryWithBonus(Instructor instructor);
    }

    public interface ICourseService
    {
        void AddStudent(Course course, Student student);
        IReadOnlyList<Student> ListStudents(Course course);
    }

    public interface IDepartmentService
    {
        void SetHead(Department department, Instructor head);
        Instructor? GetHead(Department department);
        void OfferCourse(Department department, Course course);
        IReadOnlyList<Course> OfferedCourses(Department department);
        void SetBudget(Department department, decimal amount, DateTime start, DateTime end);
    }

    // core domain 
    public abstract class Person
    {
        private readonly List<Address> _addresses = new();
        public Guid Id { get; } = Guid.NewGuid();
        public string FirstName { get; init; } = "";
        public string LastName { get; init; } = "";
        public DateTime BirthDate { get; init; }

        private decimal _baseSalary;
        public decimal BaseSalary
        {
            get => _baseSalary;
            init
            {
                if (value < 0) throw new ArgumentOutOfRangeException(nameof(BaseSalary), "Salary cannot be negative.");
                _baseSalary = value;
            }
        }

        public void AddAddress(Address address) => _addresses.Add(address);
        public IReadOnlyList<Address> GetAddresses() => _addresses.AsReadOnly();

        public virtual decimal CalculateSalary() => BaseSalary;
        public int CalculateAge(DateTime asOf)
        {
            int age = asOf.Year - BirthDate.Year;
            if (asOf.Date < BirthDate.AddYears(age).Date) age--;
            return age;
        }

        public override string ToString() => $"{FirstName} {LastName}";
    }

    public class Instructor : Person
    {
        public DateTime JoinDate { get; init; } = DateTime.Today;
        public Department? Department { get; internal set; }
        public bool IsHead { get; internal set; }

        public int YearsOfExperience(DateTime asOf)
        {
            int years = asOf.Year - JoinDate.Year;
            if (asOf.Date < JoinDate.AddYears(years).Date) years--;
            return Math.Max(0, years);
        }

        public override decimal CalculateSalary()
        {
            // Example: 2% bonus per year up to 30%
            var years = YearsOfExperience(DateTime.Today);
            decimal bonusFactor = Math.Min(0.02m * years, 0.30m);
            return BaseSalary * (1 + bonusFactor) + (IsHead ? 5000m : 0m);
        }
    }

    public class Student : Person
    {
        private readonly Dictionary<Course, Grade> _grades = new();
        public IReadOnlyDictionary<Course, Grade> Grades => _grades;

        public void Enroll(Course course) => course.AddStudent(this);

        public void AssignGrade(Course course, Grade grade)
        {
            if (!course.Students.Contains(this))
                throw new InvalidOperationException("Student not enrolled in course.");
            _grades[course] = grade;
        }

        public double CalculateGpa()
        {
            if (_grades.Count == 0) return 0.0;
            double ToPoints(Grade g) => g switch
            {
                Grade.A => 4.0, Grade.B => 3.0, Grade.C => 2.0,
                Grade.D => 1.0, Grade.F => 0.0, _ => 0.0
            };
            return Math.Round(_grades.Values.Select(ToPoints).Average(), 2);
        }
    }

    public enum Grade { A, B, C, D, F }

    public class Course
    {
        private readonly List<Student> _students = new();
        public string Code { get; init; } = "";
        public string Title { get; init; } = "";

        public IReadOnlyList<Student> Students => _students.AsReadOnly();
        internal void AddStudent(Student s) => _students.Add(s);
    }

    public class Department
    {
        private readonly List<Course> _offered = new();
        public string Name { get; init; } = "";

        public Instructor? Head { get; internal set; }
        public decimal Budget { get; internal set; }
        public DateTime BudgetStart { get; internal set; }
        public DateTime BudgetEnd { get; internal set; }

        internal void Offer(Course c) => _offered.Add(c);
        public IReadOnlyList<Course> OfferedCourses => _offered.AsReadOnly();
    }

    public record Address(string Line1, string City, string State, string PostalCode);

    // concrete services
    public class PersonService : IPersonService
    {
        public int CalculateAge(Person person, DateTime asOf) => person.CalculateAge(asOf);
        public decimal CalculateSalary(Person person) => person.CalculateSalary();
        public IReadOnlyList<Address> GetAddresses(Person person) => person.GetAddresses();
        public void AddAddress(Person person, Address address) => person.AddAddress(address);
    }

    public class StudentService : PersonService, IStudentService
    {
        public void Enroll(Student student, Course course) => student.Enroll(course);
        public void AssignGrade(Student student, Course course, Grade grade) => student.AssignGrade(course, grade);
        public double CalculateGpa(Student student) => student.CalculateGpa();
    }

    public class InstructorService : PersonService, IInstructorService
    {
        public Department? GetDepartment(Instructor instructor) => instructor.Department;
        public void AssignDepartment(Instructor instructor, Department department, bool asHead = false)
        {
            instructor.Department = department;
            instructor.IsHead = asHead;
            if (asHead) department.Head = instructor;
        }
        public int YearsOfExperience(Instructor instructor, DateTime asOf) => instructor.YearsOfExperience(asOf);
        public decimal CalculateSalaryWithBonus(Instructor instructor) => instructor.CalculateSalary();
    }

    public class CourseService : ICourseService
    {
        public void AddStudent(Course course, Student student) => course.AddStudent(student);
        public IReadOnlyList<Student> ListStudents(Course course) => course.Students;
    }

    public class DepartmentService : IDepartmentService
    {
        public void SetHead(Department department, Instructor head)
        {
            department.Head = head;
            head.Department = department;
            head.IsHead = true;
        }

        public Instructor? GetHead(Department department) => department.Head;

        public void OfferCourse(Department department, Course course) => department.Offer(course);
        public IReadOnlyList<Course> OfferedCourses(Department department) => department.OfferedCourses;

        public void SetBudget(Department department, decimal amount, DateTime start, DateTime end)
        {
            if (amount < 0) throw new ArgumentOutOfRangeException(nameof(amount));
            if (end <= start) throw new ArgumentException("Budget end must be after start.");
            department.Budget = amount;
            department.BudgetStart = start;
            department.BudgetEnd = end;
        }
    }

    // the demo 
    public static class Demo
    {
        public static void Run()
        {
            var cs = new Department { Name = "Computer Science" };
            var instructor = new Instructor
            {
                FirstName = "Ada",
                LastName = "Lovelace",
                BirthDate = new DateTime(1990, 12, 10),
                BaseSalary = 90000m,
                JoinDate = new DateTime(2015, 9, 1)
            };
            var student = new Student
            {
                FirstName = "Grace",
                LastName = "Hopper",
                BirthDate = new DateTime(2003, 6, 9),
                BaseSalary = 0m // stipend only? still validated non-negative
            };

            var algo = new Course { Code = "CS101", Title = "Algorithms" };
            var ds = new Course { Code = "CS102", Title = "Data Structures" };

            var deptSvc = new DepartmentService();
            var instrSvc = new InstructorService();
            var studSvc  = new StudentService();

            deptSvc.SetHead(cs, instructor);
            deptSvc.OfferCourse(cs, algo);
            deptSvc.OfferCourse(cs, ds);
            deptSvc.SetBudget(cs, 1_000_000m, new DateTime(2025, 7, 1), new DateTime(2026, 6, 30));

            studSvc.Enroll(student, algo);
            studSvc.Enroll(student, ds);
            studSvc.AssignGrade(student, algo, Grade.A);
            studSvc.AssignGrade(student, ds, Grade.B);

            Console.WriteLine($"Head of {cs.Name}: {deptSvc.GetHead(cs)}");
            Console.WriteLine($"Instructor salary (with bonuses): {instrSvc.CalculateSalaryWithBonus(instructor):C}");
            Console.WriteLine($"Student GPA: {studSvc.CalculateGpa(student):F2}");
        }
    }
}
```

---

## Color & Ball Classes

```csharp
using System;

namespace ColorBallDemo
{
    public class Color
    {
        public int R;
        public int G;
        public int B;
        public int A;

        public Color(int r, int g, int b, int a = 255) // this counts as both constructors, as a is automatically defaulted to 255 if not a param
        {
            R = r; G = g; B = b; A = a;
        }

        public int Grayscale() => (R + G + B) / 3;
        public override string ToString() => $"rgba({R},{G},{B},{A})";
    }

    public class Ball
    {
        public int Size { get; private set; }
        public Color Color { get; }
        private int _throws;

        public Ball(int size, Color color)
        {
            Size = Math.max(0, size);
            Color = color
            _throws = 0;
        }

        public void Pop() => Size = 0;

        public void Throw()
        {
            if (Size > 0) _throws++;
        }

        public int ThrowCount() => _throws;
    }

    class Program
    {
        static void Main()
        {
            var red = new Color(255, 0, 0);
            var blue = new Color(0, 0, 255, 200);

            var b1 = new Ball(10, red);
            var b2 = new Ball(5, blue);

            b1.Throw(); b1.Throw(); b1.Throw();
            b2.Throw(); b2.Pop(); b2.Throw(); // last throw ignored due to pop

            Console.WriteLine($"b1 throws = {b1.ThrowCount()}"); // 3
            Console.WriteLine($"b2 throws = {b2.ThrowCount()}"); // 1
            Console.WriteLine($"b1 color gray = {b1.Color.Grayscale()}");
        }
    }
}
```